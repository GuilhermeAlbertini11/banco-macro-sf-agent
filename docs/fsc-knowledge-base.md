# Salesforce Financial Services Cloud — Base de Conhecimento
Fonte: https://developer.salesforce.com/docs/platform/data-models/guide/financial-services-cloud-category.html
Verificado por deep-research (101 agentes, 1.3M tokens) em 2026-07-07.

---

## Estrutura da Documentação FSC

O FSC é documentado em dois lugares principais:

**FSC Data Model Gallery** — 22+ categorias de domínio (ERDs):
Branch Management, Business Client Engagement, Business Relationship Plan, Complaint Management, Customer, Financial Account, Financial Deal Management, Flexible Hierarchies, Groups and Household, Insurance, Integration Orchestration, Know Your Customer (KYC), Managed Package, Mortgage, Service Processes, e outros.

**FSC Object Reference** — 11 seções:
1. Standard Objects
2. Managed Package Objects
3. Associated Objects
4. Apex Reference
5. Business APIs
6. Metadata API
7. Standard Invocable Actions
8. Tooling API Objects
9. Custom Metadata Types
10. Custom Triggers and Validation Rules
11. Data Processing Engine / Monitor Workflow Services

---

## Domínios Principais

### Customer Domain (15 objetos)
> "Entities and relationships used for understanding the financial services customer."

- Account
- Account Account Relationship (AAR)
- Account Contact Relationship (ACR)
- Contact
- Contact Point
- Contact Point Address
- Contact Point Email
- Contact Point Phone
- Contact Relationship
- Individual
- Lead
- Party
- Party Relationship Group
- Party Role Relationship
- User

### Groups and Household (9 objetos)
> "Entities and relationships that organize customers into groups, providing insights into their financial circles and household structures."

- Account
- Account Account Relationship (AAR)
- Account Contact Relationship (ACR)
- Business Account
- Contact
- Contact Contact Relationship (CCR) — permite relacionamento direto contato-contato
- Party Relationship Group
- Party Role Relationship
- Person Account

**Relacionamentos para Household mapping:**
- **ACR** — Account-Contact Relationships entre clientes e households
- **AAR** — relaciona households com businesses/organizações
- **CCR** — relaciona membros do household com outros contatos

### Financial Account Domain (~20 objetos)
> "Entities and relationships around Financial Accounts and standard Party Profile, Account, Product related entities."

**Financial Account objects (8 core):**
- Financial Account
- Financial Account Address
- Financial Account Balance
- Financial Account Fee
- Financial Account Milestone
- Financial Account Party
- Financial Account Statement
- Financial Account Transaction

**Party Profile entities:**
- Party Profile
- Party Financial Asset
- Party Financial Asset Additional Owner
- Party Financial Liability

**Product entities:**
- Product2
- Product Fee

**Record Types de Financial Account (FSC managed package):**
- Investment Account
- Bank Account
- Insurance Policy Account

### Managed Package (namespace `FinServ__`)
> "Entities and relationships used for managing holdings, assets & liabilities, roles, alerts, transactions, and revenue."

**Regra crítica:** Todos os objetos e campos do managed package usam o prefixo `FinServ__`.
- Exemplo de campo custom: `FinServ__IndividualId__c` no objeto Account
- Exemplo de objeto custom: `FinServ__FinancialAccount__c`
- Objetos FSC Standard (sem namespace) NÃO têm o prefixo `FinServ__`

**Objetos-chave do managed package:**
- Financial Account *(distinto do Standard Financial Account)*
- Financial Account Role — modela o relacionamento party-to-account
- Financial Holding — objeto SEPARADO do Financial Account
- Financial Account Transaction

### Insurance Domain (~56 objetos)
Objetos de Claims:
- Claim (base)
- Casualty Claim
- Life Claim
- Property Claim
- Claim Case
- Claim Coverage
- Claim Item
- Claim Participant
- Claim Payment Summary
- Insurance Claim Asset

*Nota: a documentação lista os objetos em ordem alfabética flat, sem agrupamento funcional explícito.*

### Know Your Customer — KYC (21 objetos)
- Account
- Contact
- Identity Document
- Lead
- Party Credit Profile
- Party Credit Profile Alert
- Party Credit Profile Additional Owner
- Party Identity Verification
- Party Profile
- Party Screening Summary
- (+ 11 outros objetos)

### Mortgage (13 objetos específicos)
Separados em dois níveis:
- **Applicant-level:** Loan Applicant Income, Employment
- **Application-level:** Loan Application Asset, Property
- (+ 9 outros objetos)

### Financial Deal Management (8 objetos)
- Financial Deal (central)
- Financial Deal Asset
- Financial Deal Bid
- Financial Deal Interaction
- Financial Deal Interaction Summary
- Financial Deal Participant
- Financial Deal Party
- Financial Deal Product

### Integration Orchestration
> "Entities and relationships to dynamically determine and orchestrate integration callouts."
- Integration Provider Definition
- Fulfillment Plan
- Omni UI Card Configuration *(conexão direta com OmniStudio)*

### Flexible Hierarchies (4 objetos)
- Flexible Hierarchy
- Flexible Hierarchy Node
- Flexible Hierarchy Node Relation
- Relationship Graph Definition

### Service Processes — Service Catalog
- ServiceCatalogItemDefinition
- ServiceCatalogItemVersion
- ServiceCatalogItemAttribute
- ServiceCatalogItemAttributeDetail
- ServiceCatalogItemDependency
- ServiceCatalogItemGroup
- ServiceCatalogCategory
- ServiceCatalogCategoryItem

### Financial Services Overview (35+ objetos)
Categorias principais do diagrama overview:
- Holdings
- Assets & Liabilities
- Roles
- Alerts
- Transactions
- Revenue

Objetos presentes: Account, Financial Account, Household, Financial Goal, Financial Plan, Group, Party Relationship Group, entre outros.

---

## Compliant Data Sharing (CDS)

### O que é
Feature no-code do FSC que implementa o **Princípio do Menor Privilégio** (Principle of Least Privilege): funcionários acessam apenas os dados necessários para seus papéis específicos.

Configurado por admins e compliance managers, sem necessidade de código complexo.

### Como funciona
1. **Participant Roles** — definem o nível de acesso (read-only ou read/write) por objeto. São customizáveis.
2. **Participant Groups** — permitem compartilhar um registro com múltiplos usuários que exercem o mesmo papel no relacionamento com o cliente.
3. Quando um usuário/grupo é atribuído como participante, o sistema cria um **junction object** conectando: usuário + participant role + registro compartilhado.

### Limites hardcoded
| Limite | Valor |
|--------|-------|
| Roles ativas por objeto | **10** (máximo) |
| Participant groups por parent record | **100** (máximo) |
| Níveis de aninhamento de groups | **5** (máximo) |

### Regras de acesso
- Se um usuário pertence a múltiplos grupos com níveis de acesso diferentes → recebe o **acesso mais permissivo**.
- Funciona apenas quando o OWD (Org-Wide Default) do objeto está em **Private** ou **Public Read-Only**. Com Public Read/Write, o CDS não tem efeito.

### Restrições
- Objetos com CDS **não podem** ser compartilhados automaticamente (ex: sharing controlado por parent object).
- **Activities** (tasks, events, calendars) são incompatíveis — são acessíveis via parent-object sharing, não por CDS.

---

## OmniStudio e FSC

A conexão está documentada no domínio **Integration Orchestration**, que inclui o objeto `Omni UI Card Configuration`, estabelecendo integração direta entre a camada de orquestração do FSC e os OmniStudio components (FlexCards, OmniScripts, Integration Procedures).

---

## Questões em Aberto (para pesquisa futura)
1. Inventário completo do ARC (Actionable Relationship Center) e sua integração com Party Relationship Group e CCR
2. Quais objetos FSC específicos são pré-configurados como data sources do OmniStudio (DataRaptors, Integration Procedures)
3. Lista completa de objetos FSC Standard (sem `FinServ__`) vs Managed Package
4. Objetos FSC compatíveis com CDS e interação com OWD/role-hierarchy quando ambos ativos

---

## Fontes Verificadas (primárias)
- https://developer.salesforce.com/docs/platform/data-models/guide/financial-services-cloud-category.html
- https://developer.salesforce.com/docs/platform/data-models/guide/financial-services-overview.html
- https://developer.salesforce.com/docs/platform/data-models/guide/fsc-customer.html
- https://developer.salesforce.com/docs/platform/data-models/guide/groups-and-household.html
- https://developer.salesforce.com/docs/platform/data-models/guide/financial-account.html
- https://developer.salesforce.com/docs/platform/data-models/guide/managed-package.html
- https://developer.salesforce.com/docs/platform/data-models/guide/insurance.html
- https://developer.salesforce.com/docs/platform/data-models/guide/know-your-customer.html
- https://developer.salesforce.com/docs/platform/data-models/guide/mortgage.html
- https://developer.salesforce.com/docs/platform/data-models/guide/integration-orchestration.html
- https://developer.salesforce.com/docs/platform/data-models/guide/flexible-hierarchies.html
- https://developer.salesforce.com/docs/platform/data-models/guide/fsc-service-processes.html
- https://developer.salesforce.com/docs/platform/data-models/guide/financial-deal-management.html
- https://developer.salesforce.com/docs/atlas.en-us.financial_services_cloud_object_reference.meta/financial_services_cloud_object_reference/fsc_obj_ref_intro.htm
- https://trailhead.salesforce.com/content/learn/modules/compliant-data-sharing-in-financial-services-cloud/get-started-with-compliant-data-sharing
- https://trailhead.salesforce.com/content/learn/modules/compliant-data-sharing-in-financial-services-cloud/set-up-participants
- https://trailhead.salesforce.com/content/learn/modules/compliant-data-sharing-in-financial-services-cloud/set-up-compliant-data-sharing
