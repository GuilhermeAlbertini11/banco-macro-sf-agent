![Salesforce Cloud](https://cdn.prod.website-files.com/691f4b0505409df23e191b87/69416b267de7ae6888996981_logo.svg)

# Refinamiento Técnico — Datos del Cliente PJ: Panel Lateral de Caja de Ahorro

**Autor:** Salesforce Professional Services  
**Versión:** 1.0  
**Fecha:** 2026-07-30  
**Historia:** Datos del Cliente — Banca Empresas / Caja de Ahorro PJ

---

## Historia de Usuario

> Como oficial BE con cartera, líder de venta y servicio, gerente de sucursal, gerente regional,
> gerente divisional y área central, quiero visualizar en el panel lateral izquierdo de la página
> de detalle de producto **Caja de Ahorro en pesos y/o dólares** los siguientes datos de un cliente
> **persona jurídica**:
>
> - Razón Social
> - Tipo y Nro Tributario
> - ID COBIS
> - Sucursal
> - Fecha de Constitución + Antigüedad (años/meses)
> - Fecha de Incorporación + Antigüedad como cliente (años/meses)

---

## Architectural Concerns (inherited)

**Ninguno identificado.** La propuesta reutiliza el stack OmniStudio existente (`CardAccountSideInfoBE` +
`IPGetAccountSideInfoBE_Procedure` + `DMGetAccountSideInfoBE`) y los campos `Account` ya existentes.
No se propone ningún objeto, clase Apex ni Flow personalizado nuevo.

## Architectural Concerns (self-imposed)

| Metadata API Name | Justificación | OOTB vs Custom |
|---|---|---|
| `CardAccountSideInfoBE` (versión nueva) | Nueva versión del FlexCard — no se crea una segunda tarjeta para PJ | Reutiliza componente existente |
| `IPGetAccountSideInfoBE_Procedure` (versión nueva) | Reutiliza el mismo IP; solo se actualiza el SetValues para incluir `AccountName` en la respuesta | Reutiliza IP existente |
| `DMGetAccountSideInfoBE` | Ya extrae todos los campos necesarios — **no requiere cambios** | Campo ya mapeado |

Sin nueva metadata personalizada — todos los campos fuente ya existen en `Account`.

---

## Análisis de Impacto

### Estado Actual — Lo que ya existe y ya funciona

| Campo requerido | Campo fuente en Account | Output del DataRaptor | Estado |
|---|---|---|---|
| Razón Social | `FinancialAccountParty:Account.Name` → `AccountName` (en `DMGetAccountFromFinancialParty`) | `AccountName` | ✅ Extraído en DR previo; **falta en SetValues del IP** |
| Tipo Tributario | `Account.TaxType__c` | `TaxId` (concat con `TaxNumber__c`) | ✅ Formula en DR: `toLabel(TaxType__c) + '/' + TaxNumber__c` |
| Nro Tributario | `Account.TaxNumber__c` | incluido en `TaxId` | ✅ Incluido |
| ID COBIS | `Account.IDCobis__c` | `IdCobis` (formula con "No informado") | ✅ Mapeado |
| Sucursal | `BranchUnitRelatedRecord:BranchUnit.Name` | `BranchName` | ✅ Mapeado vía Related Record |
| Fecha de Constitución | `Account.Date_of_Establishment__c` | `DateOfEstablishment` (dd/MM/yyyy) | ✅ Mapeado |
| Antigüedad (constitución) | Calculado en DR desde `Date_of_Establishment__c` | `DateOfEstablishmentAge` (años) + `DateOfEstablishmentLeftOverMonths` (meses) | ✅ Calculado |
| Fecha de Incorporación | `Account.Service_Start_Date__c` | `ServiceStartDate` (dd/MM/yyyy) | ✅ Mapeado |
| Antigüedad como cliente | Calculado en DR desde `Service_Start_Date__c` | `ServiceStartAge` (años) + `ServiceStartLeftOverMonths` (meses) | ✅ Calculado |

**Conclusión:** el `DMGetAccountSideInfoBE` ya extrae todos los datos. El `IPGetAccountSideInfoBE_Procedure` ya los procesa en el `SetValues`. Los campos muestran "No informado" en la tarjeta porque los datos no están cargados en el sandbox, **no** por ausencia de lógica.

### Estado Actual — Gaps reales

| Gap | Causa | Solución |
|---|---|---|
| `AccountName` (Razón Social) no llega al FlexCard | El IP no incluye `AccountName` en el nodo `SuccessResponse` — solo lo extrae `ExtractAccountFromFA` pero no lo propaga en `SetValues` | Agregar `"AccountName": "%SetValues:AccountName%"` (o directamente `"%ExtractAccountFromFA:AccountName%"`) en `SuccessResponse` del IP |
| FlexCard no renderiza `AccountName` | El template `CardAccountSideInfoBE` no tiene binding al campo `AccountName` | Agregar elemento de texto `{AccountName}` en la sección de datos del cliente PJ |
| FlexiPage: `CardAccountSideInfoBE` solo visible con `LineOfBusiness__c = 'Banca Empresas'` | Visibilidad correcta para BE, pero la historia cubre explícitamente Caja de Ahorro PJ en pesos y dólares | **No requiere cambio en FlexiPage**: el FinancialAccount de Caja de Ahorro PJ ya tiene `LineOfBusiness__c = 'Banca Empresas'` según el RecordType `Caja_ahorro` (valor picklist `Banca Empresas` incluido). Verificar en sandbox. |

---

## Diseño Técnico

### Decisión de Diseño: Reutilizar sin duplicar

El stack `CardAccountSideInfoBE → IPGetAccountSideInfoBE_Procedure → DMGetAccountSideInfoBE` ya implementa el 95% del requerimiento. La estrategia es:

1. **No crear un nuevo FlexCard para PJ** — publicar una nueva versión activa del FlexCard existente con el campo `AccountName` agregado.
2. **Agregar `AccountName` en el nodo de respuesta del IP** — única modificación al Integration Procedure.
3. **No tocar el DataRaptor** — ya extrae todos los campos requeridos.
4. **No tocar la FlexiPage** — la visibilidad `LineOfBusiness__c = 'Banca Empresas'` es correcta.

### Cambio 1 — Integration Procedure: agregar AccountName en SuccessResponse

**Archivo:** `IPGetAccountSideInfoBE_Procedure_Procedure_1.oip-meta.xml`

**Paso `SetValues` — agregar en el inputMap:**
```json
"AccountName": "%ExtractAccountFromFA:AccountName%"
```

**Paso `SuccessResponse` — agregar en el outputMap:**
```json
"AccountName": "%SetValues:AccountName%"
```

El campo `AccountName` ya es extraído por `ExtractAccountFromFA` (DataRaptor `DMGetAccountFromFinancialParty` → `FinancialAccountParty:Account.Name`). Solo falta propagarlo al `SetValues` y al response.

### Cambio 2 — FlexCard: agregar sección Razón Social

**Archivo:** `CardAccountSideInfoBE_Developer_4.ouc-meta.xml` → nueva versión activa

Agregar elemento de texto en la sección "Datos del cliente PJ" (antes del bloque de TaxId):

| Componente FlexCard | Binding | Label visible |
|---|---|---|
| Text — Razón Social | `{AccountName}` | Razón Social |

La nueva versión del FlexCard debe activarse (`isActive: true`) y desactivar la versión anterior (`Developer_4` → `Developer_5`).

### Resumen de cambios por componente

| Componente | Acción | Versión |
|---|---|---|
| `DMGetAccountSideInfoBE` | **Sin cambios** | 1 (actual) |
| `DMGetAccountFromFinancialParty` | **Sin cambios** | 1 (actual) |
| `IPGetAccountSideInfoBE_Procedure` | **Nueva versión activa** — agregar `AccountName` en SetValues + SuccessResponse | 2 |
| `CardAccountSideInfoBE` | **Nueva versión activa** — agregar binding `{AccountName}` para Razón Social | 5 |
| `Financial_Account_Page.flexipage-meta.xml` | **Sin cambios** — visibilidad `LineOfBusiness__c = 'Banca Empresas'` ya cubre PJ BE | — |

---

## Render esperado en el panel lateral (Caja de Ahorro PJ)

```
┌──────────────────────────────────────┐
│  Razón Social         EMPRESA SA     │
│  Tipo y Nro Tributario   CUIT 20-12345678-9  │
│  ID COBIS             1234567        │
│  Sucursal             Rosario Central│
├──────────────────────────────────────┤
│  Fecha de Constitución  15/03/1995   │
│  Antigüedad             31 años 4 meses │
│  Fecha de Incorporación  01/06/2010  │
│  Antigüedad como cliente 16 años 1 mes │
└──────────────────────────────────────┘
```

> Cuando el campo en Account es `null` → la formula en el DataRaptor ya retorna `"No informado"`.

---

## Lógica existente — TaxId (Tipo y Nro Tributario)

El DataRaptor ya tiene esta formula:
claude
```
IF(
  Account:TaxType__c ISNOTBLANK AND Account:TaxNumber__c ISNOTBLANK,
  toLabel(Account:TaxType__c) + '/' + Account:TaxNumber__c,
  'No informado'
)
```

Resultado esperado: `"CUIT / 20-12345678-9"` (usando la label del picklist `TaxType__c`).

---

## Lógica existente — IsPyMEPlus

El DataRaptor ya calcula:

```
IF(Account:ClientCategory__c = '20' AND Account:Segment__c = '07', true, false)
```

Donde `'20'` = `MEDIANAS` y `'07'` = `PEQUEÑAS EMPRESAS`. El badge **PyME Plus** ya se renderiza condicionalmente en el FlexCard basado en el valor `IsPyMEPlus`.

---

## Lógica existente — Antigüedad

El DataRaptor ya calcula `DateOfEstablishmentAge` (años) y `DateOfEstablishmentLeftOverMonths` (meses restantes) usando:

```
AGE(Account:Date_of_Establishment__c)  → DateOfEstablishmentAge
IF(MONTH(TODAY()) >= MONTH(Date_of_Establishment__c),
   MONTH(TODAY()) - MONTH(Date_of_Establishment__c),
   12 + MONTH(TODAY()) - MONTH(Date_of_Establishment__c))
→ DateOfEstablishmentLeftOverMonths
```

Idéntico cálculo para `Service_Start_Date__c` → `ServiceStartAge` / `ServiceStartLeftOverMonths`.

El FlexCard ya renderiza estos valores — solo verificar que los bindings estén activos para la versión PJ.

---

## Condiciones de Activación del Panel

El FlexCard `CardAccountSideInfoBE` tiene visibilidad en FlexiPage:
```
{!Record.LineOfBusiness__c} EQUAL 'Banca Empresas'
```

Para que Caja de Ahorro PJ muestre el panel:
- El FinancialAccount debe tener `LineOfBusiness__c = 'Banca Empresas'`
- El RecordType `Caja_ahorro` tiene `Banca Empresas` como valor picklist disponible
- **Acción de QA:** verificar en sandbox que los registros de Caja de Ahorro PJ tengan el campo `LineOfBusiness__c` poblado con `'Banca Empresas'` — si no, puede requerir una Data Fix o una Rule de asignación automática.

---

## Criterios de Aceptación Técnicos

| # | Criterio | Tipo | Cómo verificar |
|---|---|---|---|
| AC-01 | En la página de detalle de Caja de Ahorro con `LineOfBusiness__c = 'Banca Empresas'`, el panel lateral muestra `AccountName` (Razón Social) del Account del titular principal | Happy path | Abrir registro FA tipo Caja de Ahorro PJ → verificar Razón Social visible |
| AC-02 | El campo Tipo y Nro Tributario muestra `toLabel(TaxType__c) + '/' + TaxNumber__c`; si alguno es nulo → muestra "No informado" | Happy path + Negativo | Verificar con Account con y sin TaxType/TaxNumber |
| AC-03 | Fecha de Constitución se muestra en formato `dd/MM/yyyy`; Antigüedad se muestra en años + meses | Happy path | Verificar registro con `Date_of_Establishment__c` poblado |
| AC-04 | Si `Date_of_Establishment__c` es nulo → Fecha de Constitución muestra "No informado" | Negativo | Verificar con Account sin Fecha de Constitución |
| AC-05 | Fecha de Incorporación se muestra en formato `dd/MM/yyyy`; Antigüedad como cliente en años + meses | Happy path | Verificar con `Service_Start_Date__c` poblado |
| AC-06 | Sucursal muestra el nombre de la sucursal (`BranchUnit.Name`); si es nulo → "No informado" | Happy path + Negativo | Verificar con y sin BranchUnit asignado |
| AC-07 | El panel **no** se muestra en Caja de Ahorro PF (`LineOfBusiness__c = 'Banca Individuos'`) | Regresión | Abrir FA tipo CA con LOB = Individuos → panel no visible |
| AC-08 | El badge PyME Plus se muestra solo cuando `ClientCategory__c = '20' (MEDIANAS)` Y `Segment__c = '07' (PEQUEÑAS EMPRESAS)` | Condicionado | Verificar con y sin la combinación de categoría/segmento |

---

## Alcance y No-Alcance

### Dentro del alcance
- Nueva versión del FlexCard `CardAccountSideInfoBE` con campo `AccountName` (Razón Social)
- Nueva versión del IP `IPGetAccountSideInfoBE_Procedure` con `AccountName` en la respuesta
- QA: verificar datos en sandbox con registros PJ de Caja de Ahorro
- Data fix si `LineOfBusiness__c` no está poblado en los registros existentes

### Fuera del alcance
- Modificación del DataRaptor (no requerido)
- Modificación de la FlexiPage (no requerido)
- Nuevos campos en Account (todos los campos fuente ya existen)
- Lógica para pesos vs dólares en el panel de datos del cliente (la distinción pesos/dólares es del `FinancialAccount`, no del panel de cliente)
- CEO: ya implementado en la versión actual del FlexCard — fuera del alcance de esta historia

---

## Tareas de Implementación

| # | Tarea | Responsable | Estimación |
|---|---|---|---|
| T1 | Verificar en sandbox que registros de Caja de Ahorro PJ tienen `LineOfBusiness__c = 'Banca Empresas'` | Developer / Admin | 1h |
| T2 | Publicar nueva versión del IP `IPGetAccountSideInfoBE_Procedure` — agregar `AccountName` en SetValues + SuccessResponse | Developer (OmniStudio) | 2h |
| T3 | Publicar nueva versión del FlexCard `CardAccountSideInfoBE` — agregar binding `{AccountName}` para Razón Social | Developer (OmniStudio) | 3h |
| T4 | Activar nueva versión del FlexCard y del IP | Developer | 30min |
| T5 | QA: ejecutar los 8 ACs del apartado anterior contra sandbox MacroDev | QA | 3h |
| T6 | Deploy validado a producción | Developer | 1h |

**Estimación total:** ~XS (10h = 1,25 días)

---

## Dependencias

- **Datos de sandbox:** los campos `Date_of_Establishment__c`, `Service_Start_Date__c`, `TaxType__c`, `TaxNumber__c`, `IDCobis__c`, `BranchUnit__c` deben estar poblados en al menos un registro PJ para QA.
- **LineOfBusiness__c:** si el campo no está poblado en registros de Caja de Ahorro PJ, se requiere data fix antes de QA (fuera del alcance de esta historia, pero condición de QA).

---

*Documento generado por Salesforce Professional Services — Banco Macro MDA*
