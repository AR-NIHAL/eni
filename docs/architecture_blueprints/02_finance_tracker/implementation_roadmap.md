# Finance Tracker: Production Implementation Roadmap

> Tailored for: **Offline-First Encrypted Hive** + **Clean Architecture** + **Riverpod** + **Gemini AI Financial Coach**.

---

## 1. System Architecture & Data Flow

### Flow 1: Transaction Creation & Instant Ledger Reconciliation

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as Presentation (TransactionSheet)
    participant Notifier as Riverpod (TransactionsNotifier)
    participant UseCase as AddTransactionUseCase
    participant Repo as TransactionRepository
    participant Hive as Encrypted Hive (Ledger Box)
    participant AI as Gemini AI (Categorization Service)

    User->>UI: Inputs amount ($15.00), note ("Starbucks"), taps Save
    UI->>Notifier: submitTransaction(amount: 1500, note: "Starbucks")
    
    alt Category is not chosen by user
        Notifier->>AI: suggestCategory("Starbucks")
        AI-->>Notifier: return Category("Dining & Drinks")
    end

    Notifier->>UseCase: execute(transaction)
    UseCase->>UseCase: validateInvariants (amount > 0, valid account)
    UseCase->>Repo: saveTransaction(transaction)
    Repo->>Hive: put(transaction.id, encryptedModel)
    Hive-->>Repo: success
    Repo-->>UseCase: Result.success(transaction)
    UseCase-->>Notifier: update local state
    Notifier-->>UI: recalculate account balance & budget progress
```

### Flow 2: AI Monthly Spending & Budget Anomaly Analysis

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as Dashboard / Insights View
    participant Notifier as Riverpod (AiFinanceNotifier)
    participant UseCase as GenerateFinancialInsightsUseCase
    participant Repo as TransactionRepository
    participant Gemini as Gemini AI Client

    User->>UI: Opens "Financial Insights" Tab
    UI->>Notifier: fetchMonthlyInsight(month: October)
    Notifier->>UseCase: execute(dateRange)
    UseCase->>Repo: getAggregatedExpensesByCategory(dateRange)
    Repo-->>UseCase: returns Map~Category, Money~
    UseCase->>Gemini: promptWithStructuredSchema(spendingData, budgetLimits)
    Gemini-->>UseCase: returns JSON { anomalies: [...], savingsTips: [...], forecast: ... }
    UseCase-->>Notifier: yield HealthInsight domain entity
    Notifier-->>UI: Render interactive InsightCards & Savings Recommendations
```

---

## 2. Modular Folder Structure for Finance App

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp, Theme (Currency locale, dark mode)
│   └── router.dart                # App navigation
├── core/
│   ├── errors/
│   │   ├── exceptions.dart        # Database / IO exceptions
│   │   └── failures.dart          # Pure Dart Result<S, F>
│   ├── security/
│   │   └── secure_key_manager.dart# AES-256 key generation via flutter_secure_storage
│   └── utils/
│       ├── currency_formatter.dart# Locale-aware formatting (Intl)
│       └── date_helpers.dart      # Billing cycles, start of month, week ranges
├── features/
│   ├── accounts/                  # Wallets / Bank / Cash accounts
│   │   ├── domain/                # Account entity, AccountRepository
│   │   ├── data/                  # AccountHiveModel, AccountRepositoryImpl
│   │   └── presentation/          # AccountCard, AccountsNotifier
│   ├── transactions/              # Ledger & Logging
│   │   ├── domain/
│   │   │   ├── entities/          # Money (Value Object), Transaction, Category
│   │   │   ├── repositories/      # TransactionRepository (interface)
│   │   │   └── usecases/          # AddTransaction, GetRecentTransactions, GetCategorySummary
│   │   ├── data/
│   │   │   ├── models/            # TransactionHiveModel, Mappers
│   │   │   ├── datasources/       # LocalEncryptedTransactionDataSource
│   │   │   └── repositories/      # TransactionRepositoryImpl
│   │   └── presentation/
│   │       ├── controllers/       # TransactionsNotifier (AsyncNotifier)
│   │       ├── widgets/           # TransactionTile, AmountKeypad, CategoryPicker
│   │       └── views/             # TransactionHistoryScreen, AddTransactionModal
│   ├── budgets/                   # Budget tracking & limits
│   │   ├── domain/                # Budget entity, EvaluateBudgetStatusUseCase
│   │   ├── data/                  # BudgetHiveModel, BudgetRepositoryImpl
│   │   └── presentation/          # BudgetProgressBar, BudgetsScreen
│   └── ai_coach/                  # Gemini AI Financial Advisor
│       ├── domain/
│       │   ├── entities/          # FinancialInsight, SpendingAnomaly, AdviceItem
│       │   ├── repositories/      # AiCoachRepository (interface)
│       │   └── usecases/          # GenerateMonthlyInsightsUseCase, CategorizeNoteUseCase
│       ├── data/
│       │   ├── datasources/       # GeminiFinancialClient (structured JSON schema)
│       │   └── repositories/      # AiCoachRepositoryImpl
│       └── presentation/
│           ├── controllers/       # AiCoachNotifier
│           └── widgets/           # AnomalyAlertCard, AdviceRecommendationCard
└── main.dart
```

---

## 3. The 6-Phase Engineering Roadmap

```mermaid
flowchart TD
    P1["Phase 1: Financial Core & Money Value Object<br/>- Money(amountInCents, currency)<br/>- Result & Failure sealed classes<br/>- Encrypted Hive initialization"]
    P2["Phase 2: Domain Layer (Pure Invariants)<br/>- Account, Transaction, Category, Budget entities<br/>- Repository interfaces<br/>- Use cases: AddTransaction, CalculateBalance, EvaluateBudget"]
    P3["Phase 3: Data Layer & Persistence<br/>- Hive TypeAdapters for Money & Transactions<br/>- Encrypted box repositories<br/>- TransactionRepositoryImpl with audit ledger logic"]
    P4["Phase 4: Gemini AI Financial Engine<br/>- Category auto-tagging from transaction notes<br/>- Monthly spending anomaly prompt with JSON responseSchema<br/>- Caching insights in local storage"]
    P5["Phase 5: Presentation & Riverpod State<br/>- AccountBalanceNotifier & BudgetProgressNotifier<br/>- Numeric keypad & quick transaction bottom sheet<br/>- Spending breakdown pie/bar charts"]
    P6["Phase 6: Reconciliation & Edge-Case Testing<br/>- Floating-point prevention tests<br/>- Multi-currency validation<br/>- Negative balance & budget overflow alerts"]

    P1 --> P2 --> P3 --> P4 --> P5 --> P6
```

---

## 4. Phase-by-Phase Checklist & Deliverables

### Phase 1: Financial Core Foundation
- [ ] Implement `Money` value object (`amountInCents`, currency matching, safe math operators).
- [ ] Implement `Result<S, F>` sealed class with exhaustive pattern matching.
- [ ] Configure `flutter_secure_storage` to generate and persist a 256-bit AES encryption key.
- [ ] Initialize Hive with the encrypted cipher box.

### Phase 2: Domain Layer (Zero Dependencies)
- [ ] Define `Account` entity (id, name, type: cash/bank/credit, balance).
- [ ] Define `Transaction` entity (id, accountId, type: expense/income/transfer, amount, category, date).
- [ ] Define `Budget` entity (categoryId, limit, period: weekly/monthly).
- [ ] Define abstract `TransactionRepository`, `AccountRepository`, `BudgetRepository`.
- [ ] Implement `AddTransactionUseCase`, `GetAccountBalanceUseCase`, and `CheckBudgetExceededUseCase`.

### Phase 3: Data Layer & Encryption
- [ ] Write `TransactionHiveModel` with explicit Hive field indices.
- [ ] Implement `toDomain()` and `fromDomain()` mapping functions (handling cents conversion cleanly).
- [ ] Implement `LocalTransactionDataSource` storing encrypted records.
- [ ] Write unit tests verifying that balance calculation matches the sum of ledger transactions.

### Phase 4: Gemini AI Financial Coach
- [ ] Define Gemini JSON Schema for `FinancialInsight`:
  - `summary`: string
  - `anomalies`: list of category spikes
  - `actionableTips`: list of concrete savings actions
  - `disclaimer`: required non-fiduciary statement
- [ ] Implement `GeminiAiCoachDataSource` using `google_generative_ai`.
- [ ] Build a categorization heuristic: prompt Gemini to infer category from unstructured merchant notes (e.g. "Uber 0842" -> "Transportation").

### Phase 5: Presentation Layer (Riverpod)
- [ ] Implement `AccountsNotifier` providing live balance streams.
- [ ] Implement `BudgetsNotifier` tracking percentage spent against limits.
- [ ] Build a custom transaction input sheet with a clean number keypad (typing \$15.00 directly into cents).
- [ ] Build visual category indicators with progress bars (Green -> Amber -> Red when over 90% budget).

### Phase 6: Edge Cases & Verification
- [ ] Test round-trip conversions (making sure 100 iterations of +$0.10 never yields $9.999999).
- [ ] Test atomic transfers (ensuring transfer failure rolls back both accounts).
- [ ] Test offline behavior (logging transactions without internet, queuing AI categorization when online).
