# Roadmap Tentativo — Banco Macro MDA
Fonte: imagem compartilhada (2026-07-07)

## Squads

| Squad | Cor | Foco |
|-------|-----|------|
| **Squad Banda BI/Niñez (PBC)** | Ciano | Personas Físicas — V360 BI, Pre Venta, Venta |
| **Squad Banca Empresa (PBC)** | Roxo | Personas Jurídicas — V360 BE, Pre Venta, Venta |
| **Martech (Data Cloud & MKT Cloud)** | Laranja | Leads, Campanhas, Nurturing, Atribuição |
| **Habilitadores y Tecnologías Financieras (PBC)** | Salmão | Infraestrutura, Incrementos técnicos, NFE Segurança |

---

## Sprint 0
**Squad BI:**
- Aplicación SF BI
- V360 BI Datos Cliente PF (Account SF)
- V360 BI Datos de Productos (Préstamos, CA, CC, TC, TI y Seguros)
- Detalles de los Productos BI - Financial Account (TC y TD)

**Squad BE:**
- V360 BE Cliente PJ (Account SF)
- V360 BE Cliente PJ (Account/Contact SF)
- V360 BE Cliente PJ (Account/Account/Contact SF)
- V360 BE Datos Históricos / Dato Saldos (Financial Account) — Préstamos, CA...
- DATA Histórica de los Productos — Préstamos, CA, CC, TC, TD y Seguros
- Detalles de los Productos BE (TC y TD)

**Martech:**
- Dato preliminar disponible de PLGU o not disponible en Data Cloud
- Nueva ingesta de Leads en Data Cloud

**Habilitadores:**
- Incremento 0
- Setup e Infra Consolidadas / Salesforce & MFA
- Incremento 1 — Ingesta Datos Cliente SF
- Incremento 2 — Ingesta de Productos / Activaciones de SF
- Seguros de Orquestación — Integración de API
- Tipo de Seguridad Routes y Visualización Datos Tokens

---

## Sprint 1
**Squad BI:**
- V360 BI Lista de Leads (Lead)
- V360 BI Lista de Oportunidades (Oportunidades)
- Indicadores Métricas del Cliente PF
- Detalles de los Productos BI — Financial Account (Préstamos, CA, CC y Seguros)

**Squad BE:**
- Indicadores Métricas del Cliente PJ
- V360 BE Lista de Oportunidades (Oportunidades)
- V360 BE Lista de Leads (Lead)
- Detalles de los Productos BE — Financial Account (Préstamo, CA, CC y Seguros)

**Martech:**
- Brinda ingesta de Leads No Clientes en Data Cloud
- Contenidos para campaña Nurturing para Leads No Clientes en MKT Cloud - CI
- Configuración campaña Nurturing para Leads No Clientes en MKT Cloud - CI

**Habilitadores:**
- Incremento 1 — Ingesta Datos Clientes SF
- Incremento 2 — Ingesta de Datos Básicos Saldos Clientes SF
- Ajuste Cognitivo — Dimensiones Técnicas
- Cronograma de Sprints

---

## Sprint 2
**Squad BI:**
- Pre Venta BI — Cliente Creación manual
- Pre Venta BI — Cliente Ingesta Datos Masivos
- V360 BI Datos la Línea Productos (CA, CC, TC, TD, Seguros, FSD y Inversión)
- V360 BI Datos Producto — Activos (Préstamos)
- V360 BI Datos Productos Inversiones
- Gestión de Sucursales BI
- Detalles de los Productos BI — Financial Account (Préstamos, CA, CC y Seguros)

**Squad BE:**
- Pre Venta BE — Cliente Creación manual
- Pre Venta BE — Cliente Ingesta Datos Masivos
- V360 BE Datos la Línea Productos (CA, CC, TC, TD, Seguros, FSD y Inversión)
- V360 BE Datos Producto — Activos (Préstamos)
- V360 BE Datos Productos Inversiones
- Gestión de Sucursales BE
- Detalles de los Productos BE (Préstamo, CA, CC y Seguros)

**Martech:**
- Disponibilización de las de Clientes en Vista Uni - CI
- Configuración campaña Nurturing para Clientes en MKT Cloud - CI
- Clasificación de Leads Clientes y No Clientes en Base MKT

**Habilitadores:**
- Incremento 2 — Ingesta Datos Produto/Tasa
- Incremento 2 — Ingesta Datos Saldos/Clientes SF
- Mejora manejo de múltiples plataformas (Trimonio)
- NFE de Seguridad Acceso y Habilidad Datos (NFE-10)
- Sistema Autosuficiente Balanceo y Gestión de Servicios

---

## Sprint 3
**Squad BI:**
- **Venta BI — Alta Producto Préstamo Personal** *(destacado — prioridade alta)*
- V360 BI Historial de Relacionamiento
- V360 BI Información Transaccional — Reconocimiento Switch

**Squad BE:**
- Venta BE — Alta de Acuerdo en CC
- V360 BE Información Transaccional — Reconocimiento Saldo
- V360 BE Historial de Relacionamiento

**Martech:**
- Configuración campaña Nurturing para Clientes en MKT Cloud - CI
- Asignación directa Leads No Clientes a PAG VIA

**Habilitadores:**
- Incremento 3 — Ingesta Datos Produto Tasas/Características
- Incremento 3 — Ingesta Datos Sistema Clientes/Empresa Clientes (Plataformas)
- NFE de Seguridad Acceso y Visualización — Datos (NFE-10)
- Sistema Autorizaciones

---

## Sprint 4 / Sprint 5
**Squad BI:**
- Pre Venta BI — No Cliente Ingesta Datos Masivos
- Informes y Paneles BI
- Página Inicio BI

**Squad BE:**
- Pre Venta BE — No Cliente Creación manual
- Pre Venta BE — No Cliente Ingesta Datos Masivos
- Informes y Paneles BE
- Página Inicio BE

**Martech:**
- Asignación directa Leads No Clientes a PAG VIA
- Atribución campaña Nurturing para Leads No Clientes en MKT Cloud - CI

**Habilitadores:**
- (TBD) Incremento 9 — Sistema Matriz PBG
- Vida de Seguridad Acceso y Variabilidad Datos (Central)

---

## Padrões observados

- **V360** = Vista 360 do cliente (produtos, histórico, relacionamento)
- **Pre Venta** = Fluxo de criação/ingesta de clientes (prospect)
- **Venta** = Fluxo transacional (alta de produto, acuerdo)
- **BI** = Squad Banca Individuo / Personas Físicas
- **BE** = Squad Banca Empresa / Personas Jurídicas
- **CI** = Campanha / Campaign Instance (Martech)
- **NFE** = Non-Functional Enhancement (segurança, performance)
