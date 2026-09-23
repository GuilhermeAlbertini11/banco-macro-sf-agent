![Salesforce Cloud](https://cdn.prod.website-files.com/691f4b0505409df23e191b87/69416b267de7ae6888996981_logo.svg)

# Análisis de Riesgo — Deploy 09/10 vs Major Release Salesforce 10/10

**Autor:** Salesforce Professional Services  
**Versión:** 4.0  
**Fecha:** 14 de agosto de 2026  
**Clasificación:** Decisión de Release Management — Célula MDA  
**Referencia RM:** Guía de branching por funcionalidad v2 — Sthefano Marini

---

## RESUMEN EJECUTIVO

| | Opción 1 | **Opción 2 ✅** | Opción 3 |
|---|---|---|---|
| **Nombre** | Deploy 09/10 estándar | Deploy 09/10 con INT01 gate + Hypercare | Postponer a 13/10 |
| **Fecha de deploy en Prod** | 09/10 | **09/10** | 13/10 |
| **Cumple compromiso** | ✅ | ✅ | ❌ |
| **Riesgo técnico** | MEDIO | **BAJO** | MUY BAJO |
| **Esfuerzo adicional** | Ninguno | 1 deploy INT01 + script regresión (~6–8h) | Bajo técnico / Alto en gestión |
| **Pipeline alineado post-10/10** | No | No (aceptado y mitigado) | ✅ Sí |
| **Plan ante el 10/10 (sábado)** | Reactivo | **Smoke test lunes 13/10 antes de apertura** | N/A |
| **Impacto en usuarios durante el upgrade** | Ninguno (fin de semana) | **Ninguno (fin de semana)** | Ninguno |
| **Veredicto PS** | No recomendado | **EJECUTAR** | Contingencia |

### Recomendación Salesforce Professional Services

**Ejecutar Ruta Reforzada (Opción 2).** La fecha del 09/10 se mantiene.

**Factor adicional favorable:** el 09/10 es viernes y el 10/10 es sábado. El Major Release de Salesforce se aplica durante el fin de semana, cuando no hay usuarios en el sistema. Esto elimina cualquier impacto de negocio durante la ventana de upgrade y convierte el hypercare en un checklist ejecutado el lunes 13/10 por la mañana, antes de que el banco abra, sin presión de tiempo.

Lo que la Ruta Reforzada agrega sigue siendo válido: el INT01 gate confirma que el deploy funciona en la versión exacta de Producción; el análisis de Release Notes detecta incompatibilidades antes del deploy; el smoke test del lunes 13/10 garantiza que el sistema está limpio antes del primer usuario. El fin de semana no elimina la necesidad técnica de estos pasos — los hace más cómodos de ejecutar.

La Opción 3 (Ruta Conservadora, deploy el 13/10) se activa solo si el análisis del 26/09 revela un retiro *hard* de una feature utilizada en el deploy. En cualquier otro caso, Ruta Reforzada.

---

## 1. Contexto y estado del pipeline

### 1.1 Situación

| Variable | Valor |
|---|---|
| Deploy comprometido a Producción | **09/10** — fecha fija |
| Major Release Salesforce en Producción | **10/10** — controlado por Salesforce, irreversible |
| Ventana de riesgo | ~24 horas: Prod corre el deploy custom sobre versión actual, luego recibe el upgrade |

### 1.2 Estado de ambientes

| Ambiente | Tipo | Preview | Versión hoy | Versión post-10/10 | Rol en el pipeline |
|---|---|---|---|---|---|
| DevAgentF | Dev | No | = Producción actual | = Producción actual + Major Release | Desarrollo |
| DEVDATA | Dev | No | = Producción actual | = Producción actual + Major Release | Datos de desarrollo |
| DvDataClns | Dev | No | = Producción actual | = Producción actual + Major Release | Desarrollo |
| Enablement | Dev | No | = Producción actual | = Producción actual + Major Release | Desarrollo |
| **INT01** | Integración | **No** | **= Producción actual** | = Producción actual + Major Release | **Validación técnica pre-release** |
| IntSailp | Integración | No | = Producción actual | = Producción actual + Major Release | Integración |
| **QA01** | QA | **Sí** | **= Major Release (futura Prod)** | — ya está ahí | **Validación funcional** |
| **PREPROD01** | Pre-Prod | **Sí** | **= Major Release (futura Prod)** | — ya está ahí | **Validación pre-productiva** |
| **PRODUCCIÓN** | Prod | — | Versión actual | **Recibirá Major Release 10/10** | Destino del deploy |

> **Dato clave:** INT01 es el único ambiente de la cadena de entrega que corre la misma versión que Producción hoy. QA01 y PREPROD01 ya están en la versión del Major Release que llegará a Prod el 10/10.  
> **Consecuencia directa:** el deploy ya fue validado en el escenario post-Major-Release (QA01 + PREPROD01). Lo que no fue validado es el deploy sobre la versión *actual* de Producción, que es exactamente lo que INT01 puede confirmar.

### 1.3 Flujo de release según guía RM (Sthefano Marini v2)

```
develop
   └─► release/*  (Mario crea el corte)
           └─► QA01  (Mario despliega)
                   └─► XML + paso a paso  (Release Manager prepara y envía)
                               └─► PREPROD01  (Equipo Pasajes — lado Banco, cuando dispone)
                                           └─► PRODUCCIÓN  (Equipo Pasajes)
                                                       └─► release/* → main + tag
```

> INTEG/INT01 es la rama y ambiente de validación técnica intermedia **antes** de que el cambio entre a `develop`. No es origen del release. El release sale de `develop` completo.

---

## 2. Opción 1 — Deploy 09/10 sin medidas adicionales

### Descripción
Ejecutar el deploy siguiendo exactamente el flujo estándar del RM. No se agrega ningún paso, gate ni plan de respuesta al Major Release del 10/10.

### Actividades detalladas

**Fase de preparación (semanas previas al 09/10)**

| # | Actividad | Owner | Cuándo |
|---|---|---|---|
| 1.1 | Confirmar que todas las Feature/Bugfix del scope están mergeadas en `develop` | Release Manager | 4 semanas antes |
| 1.2 | Mario crea `release/*` desde `develop` con el contenido completo del scope | Mario (lado PS) | 3 semanas antes |
| 1.3 | Mario despliega `release/*` en QA01 | Mario | 3 semanas antes |
| 1.4 | QA valida funcionalmente en QA01 y adjunta evidencia en cada HU | QA | 3–2 semanas antes |
| 1.5 | Release Manager prepara XML completo + paso a paso de implementación | RM (Sthefano Marini) | 2 semanas antes |
| 1.6 | Mario envía el XML + paso a paso al Equipo Pasajes — lado Banco por mail | Mario | 2 semanas antes |
| 1.7 | Equipo Pasajes despliega en PREPROD01 cuando tiene capacidad | Equipo Pasajes — Banco | 1–2 semanas antes |
| 1.8 | Equipos responsables validan el release completo en PREPROD01 | QA + Referentes funcionales | Inmediatamente después del deploy de Pasajes |

**Día del deploy — 09/10**

| # | Actividad | Owner |
|---|---|---|
| 1.9 | Equipo Pasajes ejecuta el deploy en Producción | Equipo Pasajes — Banco |
| 1.10 | Mario verifica Deployment Status: todos los componentes OK | Mario |
| 1.11 | QA ejecuta smoke test básico en Producción | QA |
| 1.12 | Con Producción OK: PR `release/*` → `main` + tag productivo | Release Manager |

**Día 10/10 — Major Release (sin plan previsto)**

| # | Actividad | Owner |
|---|---|---|
| 1.13 | Salesforce aplica el Major Release en Producción | Salesforce (automático) |
| 1.14 | Si aparecen errores: diagnóstico reactivo sin playbook | Quien esté disponible |

### Riesgos específicos

| Riesgo | Probabilidad | Impacto | Observación |
|---|---|---|---|
| Error post-Major-Release sin playbook de respuesta | MEDIA | ALTO | El equipo no tiene casos de regresión preparados; el diagnóstico parte de cero |
| Confusión entre bug del deploy y cambio del Major Release | MEDIA | ALTO | Sin punto de referencia limpio, el triage puede demorar horas |
| Componente del deploy afectado por retiro hard en el Major Release | BAJA | MUY ALTO | No fue analizado; se descubre solo cuando falla en producción |
| Deploy no validado sobre versión actual de Prod | MEDIA | MEDIO | QA/PREPROD están en Preview; INT01 (non-preview) no fue usado explícitamente |

### Veredicto
**No recomendado.** El costo de no prepararse supera con creces el esfuerzo de la Opción 2. Que el 10/10 no tenga plan es innecesario y evitable.

---

## 3. Opción 2 — Deploy 09/10 con INT01 gate + Hypercare Plan ✅ RECOMENDADA

### Descripción
Misma fecha de deploy (09/10). Se agregan dos capas de protección que no afectan la cadena de entrega principal:

1. **INT01 como gate explícito de versión** — antes de enviar el XML a Pasajes, se valida el deploy en INT01 (espejo exacto de Producción hoy). Esto cierra la única brecha de validación existente.
2. **Hypercare Plan estructurado para el 10/10** — se documenta un script de regresión de los casos críticos del deploy y se ejecuta el mismo 10/10 post-upgrade. El equipo llega al 10/10 con un plan, no en modo reactivo.

### Actividades detalladas

**Fase de análisis — antes del 26/09**

| # | Actividad | Owner | Cuándo | Entregable |
|---|---|---|---|---|
| 2.1 | Descargar y revisar las Release Notes del Major Release de Salesforce | RM + TA | Semana del 22/09 | Lista de cambios relevantes |
| 2.2 | Identificar todos los tipos de metadata incluidos en el XML del deploy (Apex classes, Flows, Custom Objects, Permission Sets, LWC, etc.) | Developer lead | Semana del 22/09 | Inventario de componentes del deploy |
| 2.3 | Cruzar cada componente del inventario (2.2) contra las secciones "Deprecated Features" y "Removed Features" del Release Notes (2.1) | RM + TA | 24–25/09 | Matriz de compatibilidad (componente vs. cambio en el release) |
| 2.4 | Confirmar que `sourceApiVersion` en `sfdx-project.json` es compatible con la nueva API version del Major Release | Developer lead | 24/09 | Confirmación escrita en Jira |
| 2.5 | **Punto de decisión:** si (2.3) identifica un retiro *hard* de una feature utilizada → activar Opción 3. Si no → continuar Opción 2 | RM + TA | 26/09 | Decisión documentada en Jira |

**Fase de preparación del release (estándar)**

| # | Actividad | Owner | Cuándo |
|---|---|---|---|
| 2.6 | Confirmar que todas las Feature/Bugfix del scope están mergeadas en `develop` | RM | 4 semanas antes |
| 2.7 | Mario crea `release/*` desde `develop` con el contenido completo | Mario | 3 semanas antes |
| 2.8 | Mario despliega `release/*` en QA01 | Mario | 3 semanas antes |
| 2.9 | QA valida funcionalmente en QA01 y adjunta evidencia en cada HU | QA | 3–2 semanas antes |

**Gate INT01 — validación sobre versión actual de Producción**

| # | Actividad | Owner | Cuándo | Criterio de salida |
|---|---|---|---|---|
| 2.10 | Release Manager solicita a Mario el deploy del `release/*` en INT01 | RM | 01/10 | Solicitud enviada |
| 2.11 | Mario ejecuta el deploy en INT01 y verifica Deployment Status | Mario | 01–02/10 | Todos los componentes OK en Deployment Status |
| 2.12 | Si el deploy falla en INT01: identificar causa, corregir en la rama funcional correspondiente (no en INTEG), redeployar | Developer + Mario | Dentro del 02/10 | Deploy exitoso en INT01 |
| 2.13 | QA ejecuta smoke test funcional en INT01: los flujos principales del deploy operan correctamente | QA | 02–03/10 | Evidencia en Jira: OK en INT01 (versión = Producción actual) |
| 2.14 | Con INT01 validado: Release Manager prepara XML definitivo + paso a paso y envía a Pasajes | RM | 04/10 | XML + paso a paso en manos del Equipo Pasajes |
| 2.15 | Equipo Pasajes despliega en PREPROD01 | Equipo Pasajes — Banco | 04–07/10 | Deployment Status OK en PREPROD01 |
| 2.16 | Equipos responsables validan el release completo en PREPROD01 | QA + Referentes funcionales | 07–08/10 | Go/No-Go para Producción |

**Preparación del Hypercare Plan (en paralelo a 2.6–2.16)**

| # | Actividad | Owner | Cuándo | Entregable |
|---|---|---|---|---|
| 2.17 | Identificar los 8–12 casos de uso críticos del deploy (los que impactan más usuarios o procesos clave) | QA + BA | 04/10 | Lista de casos con descripción y pasos de verificación |
| 2.18 | Documentar el script de regresión post-upgrade: para cada caso, definir datos de prueba, pasos exactos y resultado esperado | QA | 04/10 | Script de regresión listo para ejecutar el 10/10 |
| 2.19 | Confirmar disponibilidad del equipo el 10/10 (QA, Developer lead, Mario) durante las primeras 4 horas post-upgrade | RM | 04/10 | Confirmación en calendario |

**Día del deploy — 09/10**

| # | Actividad | Owner | Resultado esperado |
|---|---|---|---|
| 2.20 | Equipo Pasajes ejecuta deploy en Producción | Equipo Pasajes — Banco | Deploy iniciado |
| 2.21 | Mario verifica Deployment Status: todos los componentes OK | Mario | Confirmación escrita en Jira |
| 2.22 | QA ejecuta smoke test inicial en Producción (versión pre-upgrade) y documenta resultado | QA | Evidencia en Jira: deploy funciona en Prod versión actual |
| 2.23 | Si el deploy falla en Producción: activar rollback (XML de versión anterior, ejecutado por Pasajes) | RM + Pasajes | Prod vuelve al estado anterior al deploy |
| 2.24 | Con Producción OK: PR `release/*` → `main` + tag productivo | RM | `main` actualizado, tag creado |

**10/10 (sábado) — Major Release aplicado, sin usuarios en el sistema**

> El 10/10 es sábado. No hay usuarios en Producción. No se requiere presencia del equipo ni respuesta en tiempo real. Las actividades de validación se desplazan al lunes 13/10 antes de la apertura del banco.

| # | Actividad | Owner | Cuándo | Resultado esperado |
|---|---|---|---|---|
| 2.25 | Confirmar que el Major Release fue aplicado en Producción (verificar versión en Setup → About Salesforce) | [Release Manager] | 10/10 — en cualquier momento del día | Versión de Prod = Major Release |
| 2.26 | Opcional: revisión rápida de Apex Jobs y Flow errors si alguien está disponible | [Tech Lead] | 10/10 — opcional, sin urgencia | Registro de estado inicial post-upgrade |

**13/10 (lunes) — Hypercare: validación pre-apertura**

> Primera acción del día, antes de que los usuarios del banco accedan al sistema.

| # | Actividad | Owner | Cuándo | Resultado esperado |
|---|---|---|---|---|
| 2.27 | Ejecutar el script de regresión completo (actividad 2.18) sobre Producción post-upgrade | [QA Lead] | 13/10 — antes de la apertura | Todos los casos pasan |
| 2.28 | Revisar Apex Debug Logs y Apex Jobs en busca de errores nuevos post-upgrade | [Tech Lead] | 13/10 — antes de la apertura | Sin errores nuevos |
| 2.29 | Revisar Flow Errors en Setup → Flows → Paused/Failed Interviews | [Tech Lead] | 13/10 — antes de la apertura | Sin flows fallidos |
| 2.30 | Si se detecta un error: clasificar causa (¿deploy custom o Major Release?) → documentar en Jira con evidencia antes de actuar | [Release Manager] + [Tech Lead] | 13/10 — antes de la apertura | Causa identificada antes de cualquier acción |
| 2.31 | Si la causa es el deploy custom: ejecutar rollback (XML de versión anterior, vía Equipo de Pasajes) | [Release Manager] + Pasajes | 13/10 — antes de la apertura | Prod vuelve a estado pre-deploy, sin impacto en usuarios |
| 2.32 | Si la causa es el Major Release: abrir Case en Salesforce Support con Priority High | [Release Manager] | 13/10 | Case abierto con evidencia antes de que lleguen los usuarios |
| 2.33 | Confirmar sistema estable → comunicar apertura normal al banco | [Release Manager] | 13/10 — apertura | Confirmación enviada |

**Cierre del Hypercare — 13/10**

| # | Actividad | Owner | Entregable |
|---|---|---|---|
| 2.34 | Registrar resultado del Hypercare en Jira: sin incidentes / incidentes resueltos / incidentes abiertos | [Release Manager] | Cierre formal en Jira |
| 2.35 | Comunicar cierre al cliente: deploy productivo estable post-Major-Release | [PM] | Comunicación al referente técnico Banco Macro |

### Riesgos específicos

| Riesgo | Probabilidad | Impacto | Mitigación en esta opción |
|---|---|---|---|
| Componente del deploy afectado por retiro hard en el Major Release | BAJA | MUY ALTO | Actividad 2.3 lo detecta antes del deploy; si se detecta → Opción 3 |
| Deploy falla en INT01 (versión actual de Prod) | BAJA | MEDIO | Actividad 2.12 lo resuelve antes del 04/10; hay 5 días de buffer |
| Error post-Major-Release en algo no cubierto por el script de regresión | MUY BAJA | MEDIO | Script cubre los 8–12 casos críticos; edge cases menores son aceptables |
| Equipo no disponible el 10/10 | BAJA | ALTO | Actividad 2.19 confirma disponibilidad con anticipación |
| Rollback del deploy custom necesario post-upgrade | MUY BAJA | ALTO | Rollback documentado y en manos de Pasajes; ejecutable en la misma jornada |

### Veredicto
**Ejecutar esta opción.** Cierra la única brecha real (validación en versión actual de Prod) y convierte el 10/10 de evento desconocido en evento controlado. El esfuerzo adicional es de 6–8 horas distribuidas en 2 semanas.

---

## 4. Opción 3 — Postponer el deploy al 13/10

### Descripción
Abandonar la fecha del 09/10 y deployar después de que el Major Release sea aplicado el 10/10. El fin de semana actúa como buffer natural. El deploy se ejecuta el 13/10 (lunes) con el pipeline completamente alineado.

### Cuándo activar esta opción
Esta no es una opción de primera elección. Se activa en uno de dos escenarios:

1. **Hallazgo crítico en el análisis de Release Notes (actividad 2.3 de la Opción 2):** se identifica un retiro *hard* de una feature que el código del deploy utiliza activamente. Deployar el 09/10 garantizaría un error el 10/10 sin solución inmediata.
2. **Decisión estratégica del cliente:** el referente técnico de Banco Macro decide que el riesgo político de tener dos eventos en 24 horas supera el impacto de postponer.

### Actividades detalladas

**Fase de análisis — antes del 26/09 (idéntica a Opción 2)**

| # | Actividad | Owner | Cuándo | Entregable |
|---|---|---|---|---|
| 3.1 | Revisar Release Notes del Major Release | RM + TA | Semana del 22/09 | Lista de cambios relevantes |
| 3.2 | Inventariar componentes del XML del deploy | Developer lead | Semana del 22/09 | Inventario de componentes |
| 3.3 | Cruzar componentes vs. deprecated/removed features del release | RM + TA | 24–25/09 | Matriz de compatibilidad |
| 3.4 | Confirmar `sourceApiVersion` compatible con nueva API version | Developer lead | 24/09 | Confirmación en Jira |
| 3.5 | **Confirmación de activación:** RM + TA documentan la causa técnica o la decisión del cliente que justifica el postpone | RM + TA | 26/09 | ADR o decisión firmada |

**Fase de comunicación al cliente (obligatoria antes de cambiar la fecha)**

| # | Actividad | Owner | Cuándo | Entregable |
|---|---|---|---|---|
| 3.6 | PM redacta comunicación formal al cliente explicando la causa técnica del postpone | PM | 27/09 | Comunicación enviada y acusada de recibo |
| 3.7 | Referente técnico Banco Macro confirma aceptación del cambio de fecha | Referente Banco Macro | 27–30/09 | Aprobación escrita (mail o Jira) |
| 3.8 | Actualizar el plan de sprint y notificar a todos los equipos involucrados (RM, QA, Pasajes, Mario) | PM | 30/09 | Plan actualizado distribuido |

**Fase de preparación del release (estándar — sin INT01 gate porque Prod ya estará en Major Release)**

| # | Actividad | Owner | Cuándo |
|---|---|---|---|
| 3.9 | Confirmar que todas las Feature/Bugfix del scope están mergeadas en `develop` | RM | 04/10 |
| 3.10 | Mario crea `release/*` desde `develop` | Mario | 04/10 |
| 3.11 | Mario despliega `release/*` en QA01 | Mario | 04–05/10 |
| 3.12 | QA valida funcionalmente en QA01 y adjunta evidencia | QA | 05–07/10 |

**Post-Major-Release — buffer del fin de semana 10–12/10**

| # | Actividad | Owner | Cuándo | Objetivo |
|---|---|---|---|---|
| 3.13 | Verificar que el Major Release fue aplicado correctamente en Producción (sin errores base) | Mario | 10/10 — primeras 2h | Confirmar estabilidad de Prod post-upgrade antes de deployar |
| 3.14 | Si Salesforce presenta incidentes globales post-release (verificar trust.salesforce.com): evaluar si postponer aún más | RM | 10–11/10 | Decisión documentada |
| 3.15 | Verificar estado de QA01 y PREPROD01 post-upgrade (ya estarán alineados con Prod ahora) | Mario | 10/10 | Pipeline completamente alineado confirmado |

**Semana del 13/10 — deploy en Producción**

| # | Actividad | Owner | Cuándo | Criterio de salida |
|---|---|---|---|---|
| 3.16 | Release Manager prepara XML definitivo + paso a paso | RM | 10/10 | XML listo |
| 3.17 | Mario envía XML + paso a paso a Equipo Pasajes | Mario | 10/10 | Solicitud enviada |
| 3.18 | Equipo Pasajes despliega en PREPROD01 | Equipo Pasajes — Banco | 10–11/10 | Deployment Status OK |
| 3.19 | Equipos validan en PREPROD01 | QA + Referentes | 11–12/10 | Go/No-Go para Producción |
| 3.20 | Equipo Pasajes ejecuta deploy en Producción | Equipo Pasajes — Banco | **13/10** | Deploy OK en Prod |
| 3.21 | Mario verifica Deployment Status + QA ejecuta smoke test | Mario + QA | 13/10 | Evidencia en Jira |
| 3.22 | PR `release/*` → `main` + tag productivo | RM | 13/10 | `main` actualizado |

### Riesgos específicos

| Riesgo | Probabilidad | Impacto | Observación |
|---|---|---|---|
| Cliente no acepta el cambio de fecha | MEDIA | ALTO | La comunicación (3.6–3.7) debe ir con justificación técnica sólida |
| Salesforce presenta incidentes propios post-Major-Release el 10/10 | MUY BAJA | MEDIO | trust.salesforce.com monitorea esto; buffer del fin de semana absorbe incidentes menores |
| Conflicto de sprint/capacidad del Equipo Pasajes para semana del 13/10 | MEDIA | ALTO | Confirmar disponibilidad de Pasajes en cuanto se tome la decisión (3.8) |
| Incumplimiento de SLA o compromisos contractuales del 09/10 | DEPENDE | ALTO | Evaluar con PM y referente legal antes de comunicar al cliente |

### Veredicto
**Contingencia técnica justificada.** Esta opción es técnicamente superior a las otras dos en términos de alineación de pipeline, pero rompe el compromiso con el cliente. Solo se activa si la causa técnica es objetiva (retiro hard identificado en 3.3) o si el cliente lo decide explícitamente con pleno conocimiento del impacto.

---

## 5. Aprobación y distribución

| Rol | Nombre | Firma | Fecha |
|---|---|---|---|
| Release Manager / DevOps | Sthefano Marini | _____________ | ___/___/___ |
| Project Manager | _____________ | _____________ | ___/___/___ |
| Referente técnico Banco Macro | _____________ | _____________ | ___/___/___ |

**Distribución:** Release Manager · Project Manager · Referente técnico Banco Macro · Equipo Pasajes · Tech Lead MDA

---

*Salesforce Professional Services — Proyecto MDA Banco Macro*
