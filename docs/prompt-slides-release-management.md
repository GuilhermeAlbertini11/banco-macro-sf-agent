# Prompt para Google Slides — Release Management Decision

> Cole este prompt no Gemini (Google Slides > Insert > Help me create a presentation)
> ou em qualquer ferramenta de geração de slides (Gamma.app, Beautiful.ai, Tome, etc.)

---

## PROMPT

Create a professional executive presentation in Spanish for a Salesforce Professional Services engagement. The client is a major Argentine bank. The audience is the client's technical team and project leadership. Use a clean, modern design with Salesforce brand colors (primary: #1B96FF, accent: #032D60, background: white or very light gray). All text must be in Spanish.

The presentation has 10 slides. Follow this structure exactly:

---

**SLIDE 1 — Cover**
Title: "Deploy 09/10 vs. Major Release Salesforce 10/10"
Subtitle: "Análisis de Riesgo y Decisión de Release Management"
Add a footer with: "Salesforce Professional Services | Proyecto MDA | Agosto 2026"
Visual: clean cover with Salesforce blue gradient background, white text.

---

**SLIDE 2 — Situación**
Title: "El desafío"
Four key facts presented as cards with icons:
1. Icon: calendar. Text: "Deploy comprometido el viernes 09/10 — fecha fija, no negociable"
2. Icon: lightning bolt. Text: "Major Release Salesforce se aplica el sábado 10/10 — al día siguiente"
3. Icon: moon or weekend symbol. Text: "El 10/10 es sábado — cero usuarios en el sistema durante el upgrade"
4. Icon: checkmark. Text: "El deploy ya fue testeado en QA01 y PREPROD01 (Preview). El escenario más difícil ya fue validado."

Below, one highlighted callout box in green:
"El fin de semana elimina el impacto de negocio durante la ventana de upgrade. La validación post-release se ejecuta el lunes 13/10 antes de que el banco abra — sin presión de tiempo real."

---

**SLIDE 3 — Estado del Pipeline**
Title: "¿En qué versión está cada ambiente?"
Show a horizontal pipeline diagram:
[DEV environments] → [INT01] → [QA01] → [PREPROD01] → [PRODUCCIÓN]

Color coding:
- DEV environments and INT01: gray label "Non-Preview = versión actual de Prod"
- QA01 and PREPROD01: blue label "Preview = ya tienen el Major Release"
- PRODUCCIÓN: orange label "Recibirá Major Release el 10/10"

Key insight box (highlighted in light blue at bottom):
"INT01 es el único ambiente de la cadena que replica exactamente la versión actual de Producción. QA01 y PREPROD01 ya están en la versión futura."

---

**SLIDE 4 — Las 3 Rutas**
Title: "Tres rutas posibles"
Show a comparison table with 4 columns (header + 3 options) and these rows:
- Nombre de la ruta
- Fecha de deploy en Producción
- Cumple el compromiso
- Impacto en usuarios durante el upgrade
- Nivel de riesgo técnico
- Esfuerzo adicional
- Validación post-upgrade
- Recomendación PS

Column 1 — "Ruta Directa": viernes 09/10 | ✅ Sí | Ninguno (sábado) | 🟡 Medio | Ninguno | Reactiva — sin plan | ❌ No recomendada
Column 2 — "Ruta Reforzada" (highlighted with blue border): viernes 09/10 | ✅ Sí | Ninguno (sábado) | 🟢 Bajo | 6–8 horas | Smoke test lunes 13/10 pre-apertura | ✅ RECOMENDADA
Column 3 — "Ruta Conservadora": lunes 13/10 | ❌ No | Ninguno | 🟢 Muy bajo | Bajo técnico / Alto gestión | N/A | ⚠️ Solo si hallazgo crítico en Release Notes

Make column 2 "Ruta Reforzada" visually distinct — highlighted background or blue border to show it is the recommendation.
Add a small note below the table: "El 10/10 es sábado. En las 3 rutas el impacto de usuarios durante el upgrade es cero."

---

**SLIDE 5 — Ruta Directa**
Title: "Ruta Directa — Ejecución estándar sin cambios"
Subtitle in red/orange: "No recomendada"

Left side: brief description in 3 bullet points:
• El deploy sigue el flujo estándar del Release Manager
• No se agregan gates ni planes de respuesta
• El equipo llega al 10/10 sin ninguna preparación

Right side: risk table with 2 columns (Riesgo / Nivel):
• Error post-Major-Release sin playbook de respuesta → 🔴 Alto
• Diagnóstico lento: ¿bug del deploy o del Major Release? → 🔴 Alto
• Componente afectado por retiro del release (no analizado) → 🔴 Alto
• Deploy no validado sobre versión actual de Prod → 🟡 Medio

Bottom callout in red/light red: "El costo de no prepararse supera el esfuerzo de la Ruta Reforzada."

---

**SLIDE 6 — Ruta Reforzada (RECOMMENDED)**
Title: "Ruta Reforzada — Deploy en fecha con red de seguridad"
Subtitle in green: "✅ Recomendada por Salesforce Professional Services"

Show two pillars side by side with icons:

Pillar 1 — "Gate INT01"
Icon: shield or checkmark
Text: "Antes de enviar el XML al Equipo de Pasajes, se despliega en INT01 y se ejecuta un smoke test funcional. INT01 corre la misma versión que Producción hoy — cierra la única brecha de validación existente."

Pillar 2 — "Smoke test lunes 13/10"
Icon: monitoring chart or eye
Text: "El 10/10 es sábado — no hay usuarios. Se documenta un script de regresión de los casos críticos del deploy y se ejecuta el lunes 13/10 antes de la apertura del banco. El equipo llega al lunes con un plan, no en modo reactivo."

Bottom: two key metrics in large format:
"6–8 horas de esfuerzo adicional" | "Cero impacto de usuarios durante el upgrade (fin de semana)"

---

**SLIDE 7 — Actividades clave: Ruta Reforzada**
Title: "Plan de ejecución — Ruta Reforzada"
Show a timeline with milestones from left to right:

26/09 (VIERNES): "Análisis Release Notes + verificación de API version" — Owner: [Release Manager] + [Tech Lead]
01/10 (MIÉRCOLES): "Deploy en INT01 + smoke test — validación sobre versión actual de Prod" — Owner: [Release Manager] + [QA Lead]
04/10 (SÁBADO): "XML definitivo enviado a Equipo de Pasajes. Script de regresión documentado." — Owner: [Release Manager]
07–08/10: "Validación en PREPROD01. Go/No-Go para Producción." — Owner: [QA Lead] + [Referentes funcionales]
09/10 (VIERNES): "▶ DEPLOY EN PRODUCCIÓN" — Owner: [Equipo de Pasajes — lado Banco] — highlight this milestone
10/10 (SÁBADO): "Major Release aplicado. Sin usuarios en el sistema. Sin acción requerida." — color: gray/neutral
13/10 (LUNES — antes de apertura): "Smoke test post-upgrade en Producción. Validación pre-usuarios." — Owner: [QA Lead] + [Tech Lead]
13/10 (LUNES): "Sistema estable → apertura normal del banco confirmada." — Owner: [Release Manager]

Note at bottom: "Los nombres de los responsables deben completarse por el equipo antes de distribuir este documento."

---

**SLIDE 8 — Ruta Conservadora**
Title: "Ruta Conservadora — Deploy post-Major-Release"
Subtitle in amber/yellow: "⚠️ Contingencia — activar solo bajo condición técnica específica"

Left side — "¿Cuándo activar esta ruta?":
• El análisis de Release Notes (26/09) identifica un retiro hard de una feature utilizada en el deploy
• El referente técnico del banco decide explícitamente asumir el impacto de cambiar la fecha

Right side — "Impacto de activar esta ruta":
• ❌ Rompe el compromiso del 09/10
• Requiere comunicación formal al cliente con justificación técnica
• Requiere aprobación escrita del referente técnico Banco Macro
• El deploy se ejecuta el 13/10 con el pipeline completamente alineado

Bottom callout in amber: "Esta no es una opción de primera elección. Es la salida de emergencia técnica."

---

**SLIDE 9 — Recomendación**
Title: "Decisión recomendada"
Large central statement (big font, Salesforce blue):
"Ejecutar la Ruta Reforzada el 09/10"

Below, three supporting reasons as horizontal cards:
1. "El deploy ya fue validado en la versión del Major Release (QA01 + PREPROD01 en Preview). El escenario más difícil ya fue testeado."
2. "INT01 cierra la única brecha pendiente: confirmar que el deploy funciona en la versión exacta de Producción hoy."
3. "El Hypercare Plan convierte el 10/10 de riesgo desconocido en evento controlado con tiempo de respuesta definido."

Bottom line in bold: "La Ruta Conservadora (13/10) se activa solo si el análisis del 26/09 revela un retiro hard. En cualquier otro escenario, ejecutar Ruta Reforzada."

---

**SLIDE 10 — Aprobación**
Title: "Aprobación y distribución"
Show a formal sign-off table with 3 rows and 4 columns:
Header: Rol | Nombre | Firma | Fecha

Row 1: Release Manager / DevOps | [completar] | _____________ | ___/___/___
Row 2: Project Manager | [completar] | _____________ | ___/___/___
Row 3: Referente técnico Banco Macro | [completar] | _____________ | ___/___/___

Below the table, Distribution list label:
"Distribución una vez aprobado: Release Manager · Project Manager · Referente técnico Banco Macro · Equipo de Pasajes · Tech Lead MDA"

Footer: "Salesforce Professional Services | Proyecto MDA Banco Macro | Confidencial"

---

END OF PROMPT
