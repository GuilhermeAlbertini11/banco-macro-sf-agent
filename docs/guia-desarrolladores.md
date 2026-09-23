# Banco Macro MDA — Guía del Desarrollador con Claude Code

> Herramienta oficial del equipo para desarrollo asistido por IA en Salesforce.
> Leer completo antes de empezar. Tiempo estimado de setup: 10 minutos.

---

## Índice

1. [Requisitos previos](#1-requisitos-previos)
2. [Instalación del agente](#2-instalación-del-agente)
3. [Configuración inicial del proyecto](#3-configuración-inicial-del-proyecto)
4. [Flujo de trabajo diario](#4-flujo-de-trabajo-diario)
5. [Git — convenciones y workflow del equipo](#5-git--convenciones-y-workflow-del-equipo)
6. [Trabajar con el agente](#6-trabajar-con-el-agente)
7. [Actualizar el agente y el metadata](#7-actualizar-el-agente-y-el-metadata)
8. [Comandos de referencia rápida](#8-comandos-de-referencia-rápida)
9. [Problemas frecuentes](#9-problemas-frecuentes)

---

## 1. Requisitos previos

Verificá que tenés todo instalado antes de continuar:

```bash
# Node.js 18+
node --version    # debe ser v18 o superior

# Salesforce CLI
sf --version

# Git
git --version
```

Si falta alguno:
```bash
# Node.js (via Homebrew en Mac)
brew install node

# Salesforce CLI
npm install -g @salesforce/cli
```

---

## 2. Instalación del agente

### Paso 1 — Instalar el plugin

```bash
sf plugins install sf-plugin-macro-agent
```

> Cuando pregunte *"Do you want to continue the installation?"* → escribí **y** + Enter

### Paso 2 — Setup completo (una sola vez por máquina)

```bash
sf macro agent setup
```

Este comando instala y configura automáticamente:

| Componente | Descripción |
|-----------|-------------|
| **Claude Code CLI** | Terminal interactivo con IA de Anthropic |
| **@jterrats/setup-agents** | Plugin de gestión de tareas y workflow del proyecto |
| **~/banco-macro-sf-agent** | Reglas de arquitectura y configuración del agente |
| **~/banco-macro-sf-agent/metadata** | Código fuente Salesforce (force-app, API v61) |

Cuando aparezca el prompt de API Key:
```
  Cole sua Anthropic API Key (console.anthropic.com → API Keys):
  sk-ant-... >
```
Ingresá tu clave personal de Anthropic (cada dev tiene la propia).

> **¿Dónde conseguir la API Key?**
> console.anthropic.com → Login con tu email Salesforce → API Keys → Create Key → copiá el valor `sk-ant-...`

---

## 3. Configuración inicial del proyecto

### Conectar tu org Salesforce

```bash
cd ~/banco-macro-sf-agent/metadata
sf org login web --alias MacroDev
```

Verificá la conexión:
```bash
sf org display --target-org MacroDev
```

### Verificar el setup-agents

```bash
cd ~/banco-macro-sf-agent
sf setup-agents task list
```

Si devuelve una lista vacía o mensajes del plugin → todo correcto.

---

## 4. Flujo de trabajo diario

### Iniciar sesión de trabajo

```bash
cd ~/banco-macro-sf-agent && claude
```

El agente arranca con todo el contexto del proyecto cargado. Escribís directamente lo que querés hacer:

```
> analiza la historia MBE-XXX y propone los cambios necesarios
> crea una clase Apex para manejar la lógica de X
> genera los tests para AccountTriggerHandler
> valida el deploy antes de subir
```

### Ciclo básico de una tarea

```
1. Abrís claude en ~/banco-macro-sf-agent
2. El agente registra la tarea automáticamente (sf setup-agents)
3. Implementa los cambios en ~/banco-macro-sf-agent/metadata
4. Validás contra la org: sf project deploy validate
5. Hacés commit y push con el formato del equipo
6. Marcás la tarea como done
```

---

## 5. Git — convenciones y workflow del equipo

### Repositorios

| Repo | URL | Contenido |
|------|-----|-----------|
| **banco-macro-sf-agent** | github.com/GuilhermeAlbertini11/banco-macro-sf-agent | Reglas del agente, CLAUDE.md, setup-agents config |
| **banco-macro-sf-metadata** | github.com/GuilhermeAlbertini11/banco-macro-sf-metadata | force-app, sfdx-project.json, manifest |

### Branching

```
main          ← rama principal, siempre deployable
│
├── feature/MBE-123-nombre-corto     ← nueva funcionalidad
├── fix/MBE-456-descripcion-bug      ← corrección de bug
└── hotfix/descripcion               ← fix urgente en producción
```

Crear rama para una historia:
```bash
cd ~/banco-macro-sf-agent/metadata
git checkout -b feature/MBE-XXX-nombre-corto
```

### Formato de commits

```
tipo(ID): descripción corta en español

feat(MBE-123): agrega campo FechaCierre__c en Oportunidad
fix(MBE-456): corrige validación de RUT en trigger de Cuenta
refactor(MBE-789): extrae lógica de descuento a clase servicio
test(MBE-321): agrega cobertura para InvocableCalcularComision
chore(MBE-111): actualiza manifest con nuevos objetos
```

**Tipos válidos:** `feat` · `fix` · `refactor` · `test` · `chore` · `docs`

### Pull Request

```bash
# 1. Asegurate de estar en tu rama
git status

# 2. Commit con el formato del equipo
git add force-app/...archivos-modificados...
git commit -m "feat(MBE-XXX): descripción"

# 3. Push
git push -u origin feature/MBE-XXX-nombre-corto

# 4. Crear PR desde GitHub o con gh CLI
gh pr create \
  --title "feat(MBE-XXX): descripción corta" \
  --body "## Resumen
- Cambio 1
- Cambio 2

## Historia
MBE-XXX

## Checklist
- [ ] Validación exitosa (sf project deploy validate)
- [ ] Tests con 90%+ de cobertura
- [ ] Sin errores de Code Analyzer"
```

**Reglas del equipo:**
- Todo cambio va por PR — nunca directo a `main`
- PR requiere al menos 1 revisión antes de merge
- CI debe pasar (validación + tests)
- Squash merge preferido

### Merge a main

```bash
# Después de aprobado el PR, merge desde GitHub UI o:
gh pr merge --squash --delete-branch
```

---

## 6. Trabajar con el agente

### Comandos frecuentes dentro de Claude Code

```bash
# Ver tareas activas del proyecto
sf setup-agents task list

# Crear una tarea nueva
sf setup-agents task create --summary "descripción" --profile developer

# Iniciar workflow de una historia
sf setup-agents workflow run --story <id>

# Validar deploy sin deployar
sf project deploy validate -d force-app --target-org MacroDev

# Correr tests de una clase específica
sf apex test run --class-names MiClase_Test --target-org MacroDev --result-format human

# Code Analyzer
sf code-analyzer run --target force-app/
```

### Cómo pedirle cosas al agente

```
# Desarrollo
> implementa la historia MBE-XXX siguiendo el workflow del proyecto
> crea el trigger handler para el objeto Oportunidad__c
> escribe los tests para CuentaTriggerHandler con 90% de cobertura

# Revisión
> revisa si este código cumple los estándares del proyecto
> analiza el impacto de cambiar el campo X en el objeto Y

# Deploy
> valida el deploy de los últimos cambios contra MacroDev
> genera el package.xml con los archivos modificados

# Git
> hace commit de los cambios con el formato del equipo para la historia MBE-XXX
```

---

## 7. Actualizar el agente y el metadata

### Actualizar el plugin a la última versión

```bash
sf plugins update sf-plugin-macro-agent
```

### Actualizar el metadata desde el repo central

```bash
cd ~/banco-macro-sf-agent/metadata
git pull origin main
```

### Actualizar las reglas del agente

```bash
cd ~/banco-macro-sf-agent
git pull origin main
```

### Sincronizar tu org local con el repo

```bash
cd ~/banco-macro-sf-agent/metadata

# Ver qué cambió en el repo
git log --oneline -10

# Traer cambios del equipo
git pull origin main

# Deployar los cambios nuevos a tu sandbox
sf project deploy start -d force-app --target-org MacroDev
```

### Push de tus cambios al repo

```bash
cd ~/banco-macro-sf-agent/metadata
git add force-app/main/default/classes/MiClase.cls
git add force-app/main/default/classes/MiClase_Test.cls
git commit -m "feat(MBE-XXX): descripción del cambio"
git push origin feature/MBE-XXX-nombre-corto
```

---

## 8. Comandos de referencia rápida

```bash
# ── AGENTE ────────────────────────────────────────────────────────────────────
cd ~/banco-macro-sf-agent && claude          # abrir el agente
sf macro agent setup                          # reinstalar / reparar setup
sf plugins update sf-plugin-macro-agent       # actualizar plugin

# ── ORG ───────────────────────────────────────────────────────────────────────
sf org login web --alias MacroDev             # conectar org
sf org list                                   # listar orgs conectadas
sf org display --target-org MacroDev          # info de la org activa

# ── DEPLOY ────────────────────────────────────────────────────────────────────
sf project deploy validate -d force-app --target-org MacroDev   # validar
sf project deploy start -d force-app --target-org MacroDev      # deployar
sf project retrieve start -d force-app --target-org MacroDev    # retrieve

# ── TESTS ─────────────────────────────────────────────────────────────────────
sf apex test run --class-names Clase_Test --target-org MacroDev --result-format human
sf apex test run --test-level RunLocalTests --target-org MacroDev --result-format human

# ── GIT (metadata) ────────────────────────────────────────────────────────────
cd ~/banco-macro-sf-agent/metadata
git pull origin main                          # traer cambios del equipo
git checkout -b feature/MBE-XXX-descripcion  # nueva rama
git add force-app/...                         # stagear cambios
git commit -m "feat(MBE-XXX): descripción"    # commit
git push origin feature/MBE-XXX-descripcion  # push

# ── SETUP-AGENTS ──────────────────────────────────────────────────────────────
sf setup-agents task list                     # tareas activas
sf setup-agents workflow pending              # workflows en curso
sf setup-agents dashboard --output dashboard.html  # reporte de entrega
```

---

## 9. Problemas frecuentes

**"command not found: claude"**
```bash
npm install -g @anthropic/claude-code
```

**"ANTHROPIC_API_KEY not set"**
```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc && source ~/.zshrc
```

**"sf: command not found"**
```bash
npm install -g @salesforce/cli
```

**El plugin no aparece después de instalar**
```bash
sf plugins install sf-plugin-macro-agent
# responder "y" al prompt de confianza
```

**Error de autenticación con la org**
```bash
sf org login web --alias MacroDev
```

**Conflicto de merge en force-app**
```bash
# Siempre preferir los cambios del repo remoto para archivos de config
git checkout --theirs force-app/main/default/...
git add force-app/...
git commit -m "chore: resuelve conflicto merge MBE-XXX"
```

**Dudas o problemas:** contactar a **Guilherme Albertini** por Slack.

---

*Documento mantenido por Salesforce Professional Services — Banco Macro MDA*
*Actualizalo si encontrás algo desactualizado.*
