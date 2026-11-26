#!/usr/bin/env python3
"""Audita a memória do Gerente — sem IA.

Regra do Marlon (26/11): memória do Gerente é **ponteiro + regra transversal**. Nada de
projeto específico: nome de projeto, perfil de gestor, caminho de repositório, estado,
comando, ID. Isso vive no arquivo do projeto (`REGRAS.md` §12.4).

Este script é a parte "imposta" da regra: roda todo dia no digest das 6h30 e acusa o que
escapou. Regra que só existe no papel decai; regra que aparece na tela de manhã, não.

Código de saída: 0 memória limpa · 2 achou algo suspeito · 1 erro de leitura.
"""
import glob
import os
import re
import sys

PERFIL = os.environ.get("HERMES_PROFILE_DIR") or os.path.expanduser(
    os.path.join("~", "AppData", "Local", "hermes", "profiles", "manager-developer-hermes")
)
ARQUIVOS = [
    (os.path.join(PERFIL, "memories", "MEMORY.md"), 2800),
    (os.path.join(PERFIL, "memories", "USER.md"), 3500),
]

# (rótulo, regex, o que fazer)
REGRAS = [
    ("caminho de projeto", re.compile(r"[A-Za-z]:[\\/]"),
     "mover para PAINEL-DE-GESTORES.md (roteamento) e deixar ponteiro"),
    ("projeto P-0x", re.compile(r"\bP-0[1-9]\b"),
     "estado e dono vão para PAINEL-DE-GESTORES.md"),
    ("tarefa T-Pxx-NNN", re.compile(r"\bT-P\d{2}-\d+"),
     "o registro da tarefa é 04-TAREFAS.md"),
    ("perfil de gestor", re.compile(r"\b(jessica-p03|p03-jessica|painel-p05|p05-painel|ctm-p06|pdf-tts)\b"),
     "perfil e repo vão para PAINEL-DE-GESTORES.md"),
    ("segredo", re.compile(r"(ghp_[A-Za-z0-9]{8,}|sk-[A-Za-z0-9]{8,}|Bearer\s+[A-Za-z0-9]|GITHUB_PAT\s*=)"),
     "token só no .env; apagar da memória imediatamente"),
    ("URL", re.compile(r"https?://"),
     "URL de projeto vai para o caderno do projeto"),
]


def auditar():
    achados = []
    resumo = []
    for caminho, limite in ARQUIVOS:
        if not os.path.exists(caminho):
            continue
        texto = open(caminho, encoding="utf-8", errors="replace").read()
        entradas = len([l for l in texto.splitlines() if l.strip() and l.strip() != "§"])
        resumo.append((os.path.basename(caminho), len(texto), limite, entradas))
        for n, linha in enumerate(texto.splitlines(), 1):
            if not linha.strip():
                continue
            for rotulo, rx, acao in REGRAS:
                if rx.search(linha):
                    achados.append((os.path.basename(caminho), n, rotulo, linha.strip()[:90], acao))
    return resumo, achados


def perfis_dos_cadernos():
    """Lê `**Perfil:** \`x\`` dos cadernos em DOCS/P-*/GESTOR.md — só audita quem é gestor de projeto."""
    base = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "DOCS")
    nomes = []
    for caminho in glob.glob(os.path.join(base, "P-*", "GESTOR.md")):
        texto = open(caminho, encoding="utf-8", errors="replace").read()
        m = re.search(r"\*\*Perfil:\*\*\s*`([a-z0-9-]+)`", texto)
        if m:
            nomes.append(m.group(1))
    return nomes


def perfis_hermes():
    raiz = os.path.dirname(PERFIL)  # ...\hermes\profiles
    alvos = perfis_dos_cadernos()
    achados, sem = [], []
    for d in sorted(glob.glob(os.path.join(raiz, "*"))):
        if not os.path.isdir(d) or os.path.basename(d) == os.path.basename(PERFIL):
            continue
        # só conta como perfil quem tem SOUL.md
        if not os.path.exists(os.path.join(d, "SOUL.md")):
            continue
        if alvos and os.path.basename(d) not in alvos:
            continue
        arq = os.path.join(d, "memories", "MEMORY.md")
        if not os.path.exists(arq):
            sem.append(os.path.basename(d))
            continue
        texto = open(arq, encoding="utf-8", errors="replace").read()
        for n, linha in enumerate(texto.splitlines(), 1):
            if not linha.strip():
                continue
            for rotulo, rx, acao in REGRAS:
                if rx.search(linha):
                    achados.append((os.path.basename(d), n, rotulo, linha.strip()[:80], acao))
    return achados, sem


def main_perfis() -> int:
    achados, sem = perfis_hermes()
    print(f"**Memória dos gestores:** {len(perfis_dos_cadernos())} perfil(is) declarado(s) "
          f"· {len(sem)} sem memória · {len(achados)} achado(s)")
    if sem:
        print("- sem memória (nada a auditar): " + ", ".join(sem[:8]))
    for perfil, n, rotulo, trecho, acao in achados[:6]:
        visivel = "[linha omitida: contém segredo]" if rotulo == "segredo" else trecho
        print(f"- **{perfil}** linha {n} — {rotulo}: {visivel}")
        print(f"  → {acao}")
    if achados:
        print("Regra: detalhe de projeto vai para o caderno do projeto (REGRAS §12.4).")
        return 2
    return 0


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    if "--perfis" in sys.argv:
        return main_perfis()

    resumo, achados = auditar()
    if not resumo:
        print("Memória não encontrada em:", PERFIL)
        return 1
    for nome, total, limite, entradas in resumo:
        pct = round(100 * total / limite)
        print(f"**{nome}:** {total} / {limite} ({pct}%) · {entradas} entradas")
    if not achados:
        print("Limpa: nenhum item específico de projeto.")
        return 0

    print(f"{len(achados)} item(ns) que não deveriam estar aqui:")
    for arq, n, rotulo, trecho, acao in achados[:8]:
        # segredo nunca se imprime, nem mascarado por truncamento
        visivel = "[linha omitida: contém segredo]" if rotulo == "segredo" else trecho
        print(f"- `{arq}` linha {n} — **{rotulo}**: {visivel}")
        print(f"  → {acao}")
    if len(achados) > 8:
        print(f"- … e mais {len(achados) - 8}.")
    print("Procedimento: gravar no arquivo do projeto e **só então** remover (REGRAS §12.1).")
    return 2


if __name__ == "__main__":
    sys.exit(main())
