# 🛠️ Sad Servers - Writeups & Soluciones

Este repositorio contiene las soluciones, notas y comandos utilizados para resolver las dinámicas de [Sad Servers](https://sadservers.com) ("Like LeetCode for Linux / DevOps").

El objetivo es documentar las prácticas de troubleshooting, administración de sistemas y depuración en entornos Linux.

---

## 📂 Escenarios Resueltos

| # | Nombre del Escenario | Nivel | Descripción / Conceptos Clave | Solución |
| :-: | :--- | :---: | :--- | :-: |
| 01 | **"Saint John"** | 🟢 Fácil | Logs, permisos y servicios `systemd`. | [Ver writeup](./solutions/saint-john.md) |
| 02 | **"Santiago"** | 🟡 Medio | Diagnóstico de red, `iptables` y puertos. | [Ver writeup](./solutions/santiago.md) |
| 03 | **"Omaha"** | 🔴 Difícil | Filtrado de texto masivo con `awk`, `grep` y `sed`. | [Ver writeup](./solutions/omaha.md) |

---

## 🧰 Herramientas & Comandos Frecuentes

Durante la resolución de estos escenarios utilizo principalmente:

* **Inspección de procesos y recursos:** `top`, `htop`, `ps aux`, `lsof`, `df -h`
* **Manipulación y filtrado de texto:** `grep`, `awk`, `sed`, `cut`, `sort`, `uniq`
* **Redes y conectividad:** `netstat`, `ss`, `curl`, `tcpdump`, `iptables`
* **Servicios y logs:** `journalctl`, `systemctl`

---

## 🚀 Estructura del Repositorio

```text
.
├── README.md
├── scripts/             # Scripts automatizados creados durante los retos
└── solutions/           # Guías paso a paso de cada servidor
    ├── saint-john.md
    └── santiago.md