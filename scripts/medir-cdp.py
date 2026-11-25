#!/usr/bin/env python3
"""Mede uma pagina local num navegador headless — UM navegador, reutilizado.

Substitui os scripts cdp_*.py que cada sessao reescrevia e que, em loop, encheram
a maquina de processos do Edge (25/11/2026). Regras embutidas:

  1. INSTANCIA UNICA: se ja existe navegador vivo na porta, ele e reaproveitado.
     Nao se lanca um processo por medicao.
  2. TRAVA: no maximo 30 lancamentos por hora. Ao passar disso, aborta com erro
     em vez de abrir mais um.
  3. TEARDOWN GARANTIDO: no fim (inclusive em excecao) mata a arvore inteira
     (`taskkill /T /F`), espera e apaga o perfil temporario.
  4. TIMEOUT: 40 s por medicao; estourou, mata tudo e falha.

Uso:
    python scripts/medir-cdp.py <url> <largura> <altura> [saida.png] [--js "expr"]
        [--wait segundos] [--throttle 4g|3g] [--perf]
Exemplo:
    python scripts/medir-cdp.py http://127.0.0.1:8787/ 1440 900 print-1440.png
"""
import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time
import urllib.request

PORT = 9333
EDGE_CANDIDATOS = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]
PERFIL = os.path.join(tempfile.gettempdir(), "jhw-cdp-perfil")
CONTADOR = os.path.join(tempfile.gettempdir(), "jhw-cdp-contador.json")
LIMITE_HORA = 30
TIMEOUT_S = 40

# Perfis de rede do CDP (bytes/s e ms). "4g" = Slow 4G do Lighthouse mobile:
# 1,6 Mbps de descida, 750 kbps de subida, 150 ms de RTT.
REDES = {
    "4g": {"latency": 150, "downloadThroughput": 200 * 1024, "uploadThroughput": 94 * 1024},
    "3g": {"latency": 400, "downloadThroughput": 50 * 1024, "uploadThroughput": 25 * 1024},
}

# Instrumentacao instalada ANTES da navegacao (Page.addScriptToEvaluateOnNewDocument):
# sem isso, LCP/CLS ja passaram quando o Runtime.evaluate roda.
_PERF_JS = """
(()=>{const P=window.__jhwPerf={lcp:[],cls:[],long:[],evt:[],fcp:null,first:[]};
const ob=(t,f)=>{try{new PerformanceObserver(l=>{for(const e of l.getEntries())f(e)}).observe({type:t,buffered:true})}catch(e){}};
ob("largest-contentful-paint",e=>P.lcp.push({t:Math.round(e.startTime),s:e.size||0,el:e.element?(e.element.tagName+"."+String(e.element.className||"").slice(0,60)):null}));
ob("layout-shift",e=>{if(!e.hadRecentInput)P.cls.push({v:e.value,src:(e.sources||[]).map(s=>s.node?(s.node.nodeName+"."+String(s.node.className||"").slice(0,40)):"?")})});
ob("longtask",e=>P.long.push([Math.round(e.startTime),Math.round(e.duration)]));
ob("paint",e=>{if(e.name==="first-contentful-paint")P.fcp=Math.round(e.startTime)});
ob("first-input",e=>P.first.push({t:Math.round(e.startTime),d:Math.round(e.duration),n:e.name}));
try{new PerformanceObserver(l=>{for(const e of l.getEntries())P.evt.push({n:e.name,t:Math.round(e.startTime),d:Math.round(e.duration),i:e.interactionId||0})}).observe({type:"event",buffered:true,durationThreshold:16})}catch(e){}
})();
"""

_PERF_LEITURA = """
JSON.stringify((()=>{const P=window.__jhwPerf||{};const lcp=(P.lcp||[]).slice(-1)[0]||null;
const cls=(P.cls||[]).reduce((a,e)=>a+(e.v||0),0);const long=P.long||[];const rs=performance.getEntriesByType("resource");
const nav=performance.getEntriesByType("navigation")[0]||{};
const dom={};for(const r of rs){const u=new URL(r.name);const k=u.hostname;dom[k]=(dom[k]||0)+(r.transferSize||0)}
const total=Object.values(dom).reduce((a,b)=>a+b,0);
const imgs=rs.filter(r=>r.initiatorType==="img"||/\\.(webp|jpe?g|png|avif|gif)(\\?|$)/i.test(r.name)).map(r=>({arq:r.name.split("/").pop().slice(0,60),kb:Math.round((r.transferSize||0)/102.4)/10,decodificado_kb:Math.round((r.decodedBodySize||0)/102.4)/10}));
return {fcp_ms:P.fcp||null,lcp_ms:lcp?lcp.t:null,lcp_px:lcp?lcp.s:null,lcp_el:lcp?lcp.el:null,
cls:Math.round(cls*1000)/1000,cls_shifts:(P.cls||[]).map(x=>({v:Math.round(x.v*1000)/1000,src:x.src})),
tbt_ms:Math.round(long.reduce((a,x)=>a+Math.max(0,x[1]-50),0)),
longtasks:long.length,longtask_max_ms:long.length?Math.max(...long.map(x=>x[1])):0,
first_input:(P.first||[])[0]||null,
inp_ms:(()=>{const ev=(P.evt||[]).filter(x=>x.i);return ev.length?Math.max(...ev.map(x=>x.d)):null})(),
eventos:(P.evt||[]).length,
load_ms:Math.round(nav.loadEventEnd||0),dcl_ms:Math.round(nav.domContentLoadedEventEnd||0),
recursos:rs.length,transfer_kb:Math.round(total/102.4)/10,
por_dominio_kb:Object.fromEntries(Object.entries(dom).sort((a,b)=>b[1]-a[1]).map(([k,v])=>[k,Math.round(v/102.4)/10])),
imgs:imgs,cookie:document.cookie.slice(0,300)}})())
"""


def _contar_lancamento():
    agora = time.time()
    try:
        d = json.load(open(CONTADOR, encoding="utf-8"))
    except Exception:
        d = {"inicio": agora, "n": 0}
    if agora - d.get("inicio", 0) > 3600:
        d = {"inicio": agora, "n": 0}
    if d["n"] >= LIMITE_HORA:
        raise SystemExit(
            f"trava: {d['n']} lancamentos nesta hora (limite {LIMITE_HORA}). "
            "Pare e reporte — nao abra mais navegador."
        )
    d["n"] += 1
    json.dump(d, open(CONTADOR, "w", encoding="utf-8"))
    return d["n"]


def _matar_por_perfil():
    """O msedge.exe que lancamos e um stub: o navegador real tem outro PID.
    Mata quem carrega o NOSSO --user-data-dir e, por garantia, quem escuta a porta."""
    try:
        ps = subprocess.run(
            ["powershell", "-NoProfile", "-Command",
             "Get-CimInstance Win32_Process -Filter \"name='msedge.exe'\" | "
             "Where-Object { $_.CommandLine -like '*jhw-cdp-perfil*' } | "
             "ForEach-Object { $_.ProcessId }"],
            capture_output=True, text=True, timeout=30)
        for pid in ps.stdout.split():
            subprocess.run(["taskkill", "/PID", pid, "/T", "/F"], capture_output=True, timeout=20)
    except Exception:
        pass
    try:
        ps = subprocess.run(
            ["powershell", "-NoProfile", "-Command",
             f"(Get-NetTCPConnection -LocalPort {PORT} -State Listen -ErrorAction SilentlyContinue).OwningProcess"],
            capture_output=True, text=True, timeout=30)
        for pid in ps.stdout.split():
            if pid.strip().isdigit():
                subprocess.run(["taskkill", "/PID", pid.strip(), "/T", "/F"], capture_output=True, timeout=20)
    except Exception:
        pass


def _vivo():
    try:
        urllib.request.urlopen(f"http://127.0.0.1:{PORT}/json/version", timeout=2).read()
        return True
    except Exception:
        return False


def _ws_pagina():
    """WebSocket da ABA, nao do navegador: evita Target.* e sessao plana."""
    for _ in range(40):
        try:
            alvos = json.loads(urllib.request.urlopen(f"http://127.0.0.1:{PORT}/json", timeout=5).read())
            for a in alvos:
                if a.get("type") == "page" and a.get("webSocketDebuggerUrl"):
                    return a["webSocketDebuggerUrl"]
        except Exception:
            pass
        time.sleep(0.25)
    raise SystemExit("erro: nenhuma aba depuravel no navegador")


class Cdp:
    """Cliente CDP minimo sobre websocket cru (stdlib)."""

    def __init__(self, ws_url):
        import socket, struct, base64 as b64
        from urllib.parse import urlparse
        u = urlparse(ws_url)
        self.s = socket.create_connection((u.hostname, u.port), timeout=TIMEOUT_S)
        chave = b64.b64encode(os.urandom(16)).decode()
        self.s.sendall(
            (f"GET {u.path} HTTP/1.1\r\nHost: {u.hostname}:{u.port}\r\nUpgrade: websocket\r\n"
             f"Connection: Upgrade\r\nSec-WebSocket-Key: {chave}\r\nSec-WebSocket-Version: 13\r\n\r\n").encode()
        )
        buf = b""
        while b"\r\n\r\n" not in buf:
            buf += self.s.recv(4096)
        self.n = 0

    def _send(self, texto):
        dados = texto.encode()
        cab = b"\x81"
        m = len(dados)
        if m < 126:
            cab += bytes([0x80 | m])
        elif m < 65536:
            cab += bytes([0x80 | 126]) + m.to_bytes(2, "big")
        else:
            cab += bytes([0x80 | 127]) + m.to_bytes(8, "big")
        mascara = os.urandom(4)
        self.s.sendall(cab + mascara + bytes(b ^ mascara[i % 4] for i, b in enumerate(dados)))

    def _recv(self):
        h = self.s.recv(2)
        if len(h) < 2:
            return None
        m = h[1] & 0x7F
        if m == 126:
            m = int.from_bytes(self.s.recv(2), "big")
        elif m == 127:
            m = int.from_bytes(self.s.recv(8), "big")
        buf = b""
        while len(buf) < m:
            buf += self.s.recv(m - len(buf))
        return buf.decode(errors="replace")

    def cmd(self, metodo, params=None):
        self.n += 1
        self._send(json.dumps({"id": self.n, "method": metodo, "params": params or {}}))
        while True:
            msg = self._recv()
            if msg is None:
                return None
            try:
                d = json.loads(msg)
            except Exception:
                continue
            if d.get("id") == self.n:
                if "error" in d:
                    raise RuntimeError(f"CDP {metodo}: {d['error'].get('message', d['error'])}")
                return d.get("result", {})


def _ler_args():
    """Posicionais e flags separados: o valor de --js nao pode virar caminho de PNG."""
    pos, fl, i = [], {}, 1
    while i < len(sys.argv):
        a = sys.argv[i]
        if a in ("--js", "--wait", "--throttle", "--clique") and i + 1 < len(sys.argv):
            fl[a[2:]] = sys.argv[i + 1]
            i += 2
        elif a == "--perf":
            fl["perf"] = True
            i += 1
        else:
            pos.append(a)
            i += 1
    return pos, fl


def main():
    args, flags = _ler_args()
    js = flags.get("js", "")
    espera = float(flags.get("wait", 1.5))
    rede = REDES.get(flags.get("throttle", ""), None)
    if len(args) < 3:
        print(__doc__)
        return 2
    url = args[0]
    largura, altura = int(args[1]), int(args[2])
    saida = args[3] if len(args) > 3 else ""

    proc = None
    try:
        if not _vivo():
            edge = next((c for c in EDGE_CANDIDATOS if os.path.exists(c)), None)
            if not edge:
                raise SystemExit("erro: msedge.exe nao encontrado")
            n = _contar_lancamento()
            shutil.rmtree(PERFIL, ignore_errors=True)
            os.makedirs(PERFIL, exist_ok=True)
            proc = subprocess.Popen(
                [edge, "--headless=new", "--disable-gpu", "--no-first-run",
                 "--no-default-browser-check", "--disable-extensions",
                 f"--remote-debugging-port={PORT}", f"--user-data-dir={PERFIL}",
                 f"--window-size={largura},{altura}", "about:blank"],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
            print(f"lancamento {n}/{LIMITE_HORA}", file=sys.stderr)
            for _ in range(60):
                if _vivo():
                    break
                time.sleep(0.25)
            else:
                raise SystemExit("erro: o navegador nao abriu a porta de depuracao")

        c = Cdp(_ws_pagina())
        c.cmd("Page.enable")
        if rede:
            c.cmd("Network.enable")
            c.cmd("Network.setCacheDisabled", {"cacheDisabled": True})
            c.cmd("Network.emulateNetworkConditions", {"offline": False, **rede})
        c.cmd("Emulation.setDeviceMetricsOverride",
              {"width": largura, "height": altura, "deviceScaleFactor": 1, "mobile": largura < 600})
        if flags.get("perf"):
            c.cmd("Page.addScriptToEvaluateOnNewDocument", {"source": _PERF_JS})
        c.cmd("Page.navigate", {"url": url})
        time.sleep(espera)
        info = c.cmd("Runtime.evaluate", {
            "expression": "JSON.stringify({titulo:document.title, w:innerWidth, h:innerHeight,"
                          "altura_doc:document.documentElement.scrollHeight,"
                          "h1:(document.querySelector('h1')||{}).innerText||''})",
            "returnByValue": True,
        })
        dados = json.loads(info["result"]["value"])
        if flags.get("clique"):
            sel = json.dumps(flags["clique"])
            c.cmd("Runtime.evaluate", {"expression":
                   "(()=>{const e=document.querySelector(%s);if(e)e.scrollIntoView({block:'center',behavior:'instant'});})()" % sel})
            time.sleep(0.4)
            res = c.cmd("Runtime.evaluate", {
                "expression": ("(()=>{const e=document.querySelector(%s);if(!e)return null;"
                               "const r=e.getBoundingClientRect();"
                               "return JSON.stringify({x:Math.round(r.x+r.width/2),y:Math.round(r.y+r.height/2),"
                               "tag:e.tagName+'.'+String(e.className).slice(0,40)})})()" % sel),
                "returnByValue": True})
            alvo = res.get("result", {}).get("value")
            dados["clique"] = alvo
            if alvo:
                pt = json.loads(alvo)
                for tipo, botoes in (("mouseMoved", 0), ("mousePressed", 1), ("mouseReleased", 0)):
                    c.cmd("Input.dispatchMouseEvent", {"type": tipo, "x": pt["x"], "y": pt["y"],
                                                       "button": "left", "clickCount": 1 if botoes else 0,
                                                       "buttons": botoes})
                time.sleep(2.0)
        if js:
            extra = c.cmd("Runtime.evaluate", {"expression": js, "returnByValue": True, "awaitPromise": True})
            dados["js"] = extra.get("result", {}).get("value")
        if flags.get("perf"):
            perf = c.cmd("Runtime.evaluate", {"expression": _PERF_LEITURA, "returnByValue": True})
            valor = perf.get("result", {}).get("value")
            dados["perf"] = json.loads(valor) if valor else None
        if saida:
            shot = c.cmd("Page.captureScreenshot", {"captureBeyondViewport": True})
            with open(saida, "wb") as f:
                f.write(base64.b64decode(shot["data"]))
            dados["png"] = os.path.abspath(saida)
        print(json.dumps(dados, ensure_ascii=False, indent=1))
        return 0
    except SystemExit:
        raise
    except Exception as e:
        print(f"erro: {type(e).__name__}: {e}", file=sys.stderr)
        return 1
    finally:
        # teardown garantido — inclusive quando o navegador foi reaproveitado
        if proc is not None:
            _matar_por_perfil()
            try:
                proc.wait(timeout=10)
            except Exception:
                pass
            shutil.rmtree(PERFIL, ignore_errors=True)
        time.sleep(0.5)


if __name__ == "__main__":
    sys.exit(main())
