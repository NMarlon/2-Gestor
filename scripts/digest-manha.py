#!/usr/bin/env python3
"""Digest das 6h30 — o que só o Marlon pode fazer, por projeto.

Roda sem IA: lê o bloco marcado em DOCS/08-GERENTE/PENDENTES.md e imprime.
Agendado por cronjob (no_agent), então o custo é zero e a saída vai verbatim.

Uso:  python scripts/digest-manha.py
"""
import datetime
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PENDENTES = os.path.join(BASE, "DOCS", "08-GERENTE", "PENDENTES.md")
INI, FIM = "<!-- DIGEST:INICIO -->", "<!-- DIGEST:FIM -->"


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    if not os.path.exists(PENDENTES):
        print(f"Digest indisponivel: {PENDENTES} nao existe.")
        return 1

    texto = open(PENDENTES, encoding="utf-8").read()
    if INI not in texto or FIM not in texto:
        print("Digest indisponivel: bloco DIGEST ausente em PENDENTES.md.")
        return 1

    bloco = texto.split(INI, 1)[1].split(FIM, 1)[0].strip()
    # mantém a tabela inteira (inclusive a linha de separador, senão o markdown quebra)
    corpo = [l for l in bloco.splitlines() if l.strip()]

    hoje = datetime.date.today().strftime("%d/%m/%Y")
    print(f"**Ações que dependem de você — {hoje}**")
    print("")
    for l in corpo:
        print(l)
    print("")
    print("_Janela combinada: perguntas que exigem ação manual só entre 06h30 e 10h. "
          "Fora disso, os gestores seguem sozinhos._")

    # Auditoria da memória do Gerente (regra de 26/11: nada de projeto específico aqui).
    # Script puro, sem IA — se acusar, o procedimento está em REGRAS.md §12.
    try:
        import subprocess
        chk = os.path.join(BASE, "scripts", "check-memory.py")
        if os.path.exists(chk):
            saida = subprocess.run([sys.executable, chk], capture_output=True,
                                   text=True, encoding="utf-8", errors="replace", timeout=20)
            if saida.stdout.strip():
                print("")
                print(saida.stdout.strip())
    except Exception as erro:  # nunca derrubar o digest por causa da auditoria
        print(f"\n_Memória: auditoria indisponível ({type(erro).__name__})._")
    return 0


if __name__ == "__main__":
    sys.exit(main())
