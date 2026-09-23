![Salesforce Cloud](https://cdn.prod.website-files.com/691f4b0505409df23e191b87/69416b267de7ae6888996981_logo.svg)

# Naming Conventions — Banco Macro MDA

**Autor:** Salesforce Professional Services  
**Versión:** 1.0  
**Fecha:** 2026-07-31  
**Audiencia:** Equipo Dev, TA, BA — Proyecto MDA

---

## Principio rector

> Un nombre declara **qué es** el componente y **qué hace**. No abreviaciones que no sean
> ya convención del proyecto. Consistencia sobre novedad.

---

## 1. Objetos y Campos

### 1.1 Objetos personalizados

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| API Name | `PascalCase` inglés + `__c` | `LoanApplication__c` |
| Label | Español, descriptivo | `Solicitud de Préstamo` |
| Plural Label | Español plural | `Solicitudes de Préstamo` |
| Descripción | Obligatoria, en español | `Registra solicitudes de préstamo del cliente` |

### 1.2 Campos personalizados

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| API Name | `PascalCase` inglés + `__c` | `LoanAmount__c`, `ApprovalDate__c` |
| Label | Español | `Monto del Préstamo`, `Fecha de Aprobación` |
| Descripción | Obligatoria en español | propósito del campo, de dónde viene el dato |
| Help Text | Español, orientado al usuario | instrucción para quien completa el campo |

**Prefijos por tipo de dato sugeridos (opcional, usar si el equipo los adopta):**

| Tipo Salesforce | Prefijo | Ejemplo |
|----------------|---------|---------|
| Checkbox | `Is` / `Has` | `IsActive__c`, `HasConsent__c` |
| Date | (ninguno) | `ApprovalDate__c` |
| DateTime | (ninguno) | `SubmittedAt__c` |
| Currency / Number | (ninguno) | `LoanAmount__c` |
| Lookup / MD | nombre del objeto referenciado | `Account__c`, `Product__c` |

### 1.3 Campos estándar — NO renombrar la API Name
Solo se puede cambiar el **Label** de un campo estándar. Nunca crear un campo custom
que duplique un campo estándar (ej.: no crear `ClientName__c` si existe `Name`).

---

## 2. Clases Apex

| Componente | Patrón | Ejemplo |
|------------|--------|---------|
| Clase de servicio | `<Dominio>Service` | `LoanApplicationService` |
| Clase de dominio | `<Dominio>Domain` | `LoanApplicationDomain` |
| Trigger Handler | `<Objeto>TriggerHandler` | `LoanApplicationTriggerHandler` |
| Clase de test | `<ClasePrincipal>_Test` | `LoanApplicationService_Test` |
| Clase REST (`@RestResource`) | `<Recurso>RestResource` | `LoanApplicationRestResource` |
| Invocable | `Invocable<Acción>` | `InvocableCreateLoanApplication` |
| Batch | `<Dominio>Batch` | `LoanApplicationBatch` |
| Queueable | `<Dominio>Queueable` | `LoanNotificationQueueable` |
| Schedulable | `<Dominio>Schedulable` | `LoanReminderSchedulable` |
| Mock HTTP | `<Servicio>HttpMock` | `BancoCoreHttpMock` |
| TestDataFactory | `TestDataFactory` (singleton) | `TestDataFactory` |

**Reglas:**
- Una sola clase `TestDataFactory` en el proyecto — agregar métodos, no crear forks.
- Zero lógica en triggers — solo instanciar el handler y llamar `run()`.
- `with sharing` por defecto; `without sharing` solo en `@RestResource`.

---

## 3. Lightning Web Components (LWC)

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| Nombre del componente | `camelCase` | `loanApplicationForm`, `clientSummaryCard` |
| Carpeta | mismo nombre que el componente | `force-app/.../lwc/loanApplicationForm/` |
| Archivo principal | `<nombre>.html`, `<nombre>.js`, `<nombre>.js-meta.xml` | `loanApplicationForm.html` |
| Custom Events | `kebab-case` | `loan-submitted`, `record-updated` |
| Propiedades públicas `@api` | `camelCase` | `recordId`, `accountId` |
| CSS custom properties | `--slds-g-*` (tokens SLDS 2) | `--slds-g-color-brand-base-50` |

**Reglas:**
- Nunca hardcodear strings en templates — usar **Custom Labels**.
- Usar `lwc:if` / `lwc:elseif` / `lwc:else` (no `if:true` / `if:false`, deprecated).
- Tests unitarios en `__tests__/<nombre>.test.js`.

---

## 4. Flows

| Tipo | Patrón de nombre | Ejemplo |
|------|-----------------|---------|
| Record-Triggered (Before Save) | `<Objeto>_BeforeSave_<Propósito>` | `LoanApplication_BeforeSave_SetDefaults` |
| Record-Triggered (After Save) | `<Objeto>_AfterSave_<Propósito>` | `LoanApplication_AfterSave_NotifyApprover` |
| Screen Flow | `<Propósito>_ScreenFlow` | `NewLoanApplication_ScreenFlow` |
| Scheduled Flow | `<Propósito>_Scheduled` | `LoanReminder_Scheduled` |
| Autolaunched | `<Propósito>_Autolaunched` | `AssignLoanOfficer_Autolaunched` |
| Sub-Flow | `Sub_<Propósito>` | `Sub_ValidateLoanEligibility` |

**Reglas:**
- Un solo Record-Triggered Flow por objeto/contexto (Before Save **o** After Save).
- Sub-flows para lógica reutilizable — evitar Mega-Flows.
- Variables internas: `camelCase` (`loanAmount`, `isEligible`).
- Labels de elementos de Flow: en español.

---

## 5. Permission Sets y Permission Set Groups

| Componente | Patrón | Ejemplo |
|------------|--------|---------|
| Permission Set — acceso a objeto | `<Objeto>_ObjectAccess` | `LoanApplication_ObjectAccess` |
| Permission Set — funcional | `<Función>_Access` | `LoanOfficer_Access` |
| Permission Set Group | `PSG_<Persona>` | `PSG_LoanOfficer`, `PSG_BranchManager` |

**Regla crítica:** Todo campo custom DEBE estar en un Permission Set — nunca en un Profile.

---

## 6. Custom Metadata Types (CMDT)

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| CMDT Object API Name | `<Feature>_Config__mdt` | `LoanRules_Config__mdt` |
| Record API Name | `DeveloperName` descriptivo | `RetailLoan_Standard` |
| Label | Español | `Reglas de Préstamo Retail Estándar` |

---

## 7. Custom Labels

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| API Name | `<Componente>_<Propósito>` | `LoanForm_SubmitSuccess`, `LoanForm_RequiredField` |
| Value | Texto en español | `Solicitud enviada exitosamente` |
| Descripción | Contexto de uso | `Toast de éxito al enviar solicitud de préstamo` |

---

## 8. Named Credentials

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| API Name | `<Sistema>_<Ambiente>` | `BancoCore_Prod`, `BancoCore_Sandbox` |
| Label | Descriptivo | `Banco Core — Producción` |

---

## 9. Git — Branches y Commits

### Ramas

| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Feature | `feature/<ID>-descripcion-corta` | `feature/MDA-123-loan-form-lwc` |
| Fix | `fix/<ID>-descripcion-corta` | `fix/MDA-456-null-pointer-service` |
| Hotfix | `hotfix/<descripcion>` | `hotfix/approval-date-blank` |

### Commits (Conventional Commits)

```
tipo(ID): descripción corta en presente

1. Cambio A
2. Cambio B

Valor: por qué este cambio importa al negocio.
```

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | nueva funcionalidad |
| `fix` | corrección de bug |
| `refactor` | restructuración sin cambio de comportamiento |
| `test` | agregar o corregir tests |
| `chore` | tareas de mantenimiento (config, scripts) |
| `docs` | solo documentación |

**Ejemplo:**
```
feat(MDA-123): formulario de solicitud de préstamo

1. LWC loanApplicationForm con validación de campos requeridos
2. Apex LoanApplicationService.createLoan() con FLS enforcement
3. Custom Label para mensajes de error en español

Valor: permite al asesor registrar solicitudes sin abrir múltiples pantallas.
```

---

## 10. Archivos de Metadata (force-app)

### Estructura de carpetas recomendada

```
force-app/main/default/
├── classes/
│   ├── LoanApplicationService.cls
│   ├── LoanApplicationService_Test.cls
│   └── LoanApplicationTriggerHandler.cls
├── triggers/
│   └── LoanApplicationTrigger.trigger
├── lwc/
│   └── loanApplicationForm/
│       ├── loanApplicationForm.html
│       ├── loanApplicationForm.js
│       ├── loanApplicationForm.js-meta.xml
│       └── __tests__/
│           └── loanApplicationForm.test.js
├── flows/
│   └── LoanApplication_AfterSave_NotifyApprover.flow-meta.xml
├── objects/
│   └── LoanApplication__c/
│       ├── LoanApplication__c.object-meta.xml
│       └── fields/
│           └── LoanAmount__c.field-meta.xml
└── permissionsets/
    └── LoanApplication_ObjectAccess.permissionset-meta.xml
```

---

## 11. Resumen rápido — regla de oro

| Capa | PascalCase | camelCase | kebab-case |
|------|-----------|-----------|------------|
| Apex (clases, métodos) | ✅ clases | ✅ métodos/vars | — |
| LWC (componentes) | — | ✅ componente/props | ✅ custom events |
| Objetos / Campos / CMDT | ✅ API Name | — | — |
| Labels (usuario) | — | — | — *(español libre)* |
| Git branches | — | — | ✅ |

---

## Apéndice — Checklist antes de crear un componente

- [ ] Busqué si ya existe un componente/clase con este propósito en `force-app/`
- [ ] El API Name sigue PascalCase inglés con el sufijo correcto
- [ ] El Label está en español
- [ ] La descripción del campo/objeto está completa
- [ ] Si es campo custom: ya identifiqué el Permission Set que lo recibirá
- [ ] El nombre del commit incluye el Backlog Item ID

---

*Documento generado por Salesforce Professional Services — Banco Macro MDA*  
*Ante dudas o excepciones, consultar con el Technical Architect del proyecto.*
