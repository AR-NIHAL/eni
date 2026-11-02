# AI Health Tracker: Production Implementation Roadmap

> Tailored for: **Apple HealthKit & Android Health Connect** + **Encrypted Hive** + **Gemini API** + **Clean Architecture with Riverpod**.

---

## 1. Architectural Strategy: The Offline-First Sync Pattern

Because you chose direct OS Health integration, you are building a real production-grade health system. Here is how a senior engineer conceptualizes the data flow:

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Presentation as Presentation (Riverpod)
    participant UseCase as Domain Use Case
    participant Repo as HealthMetricsRepository
    participant OS as OS Health Service (HealthKit / Health Connect)
    participant Hive as Encrypted Hive Box (Local Cache)
    participant AI as Gemini API Client

    User->>Presentation: Opens Dashboard
    Presentation->>UseCase: execute(GetDailyMetrics)
    UseCase->>Repo: getDailyMetrics(dateRange)
    Repo->>Hive: getCachedMetrics(dateRange)
    Hive-->>Repo: return local cached data (instant UI render)
    Repo-->>Presentation: Yield cached state (Snappy UX)

    Note over Repo,OS: Background Sync with OS Health Platforms
    Repo->>OS: fetchLatestMetrics(since: lastSyncTimestamp)
    OS-->>Repo: return OS vitals (Steps, Sleep, SpO2, BP)
    Repo->>Hive: saveEncrypted(newVitals)
    Repo-->>Presentation: Yield updated fresh state

    User->>Presentation: Tap "Generate AI Insights"
    Presentation->>UseCase: execute(GenerateInsightsUseCase)
    UseCase->>AI: promptWithStructuredSchema(last7DaysMetrics)
    AI-->>UseCase: returns validated JSON (HealthInsight)
    UseCase->>Hive: cacheInsight(HealthInsight)
    UseCase-->>Presentation: Display typed InsightCard & Recommendations
```

---

## 2. Core Dependencies Strategy

| Capability | Package | Architectural Role | Why this choice? |
| :--- | :--- | :--- | :--- |
| **State Management** | `flutter_riverpod` | Presentation Layer | Unidirectional data flow, compile-safe DI, testable notifiers. |
| **Local Database** | `hive_flutter`, `hive` | Data Layer Cache | Fast key-value binary storage with zero native SQL overhead. |
| **Key Management** | `flutter_secure_storage` | Security Infrastructure | Hardware-backed keystore/keychain for the 256-bit Hive encryption key. |
| **Health Sensors** | `health` | Platform Data Source | Unified cross-platform abstraction over Apple HealthKit and Android Health Connect. |
| **AI Intelligence** | `google_generative_ai` | AI Data Source | Official Google SDK with `responseSchema` support for guaranteed JSON output. |
| **Error Handling** | Pure Dart 3 Sealed Classes | Core / Domain | `Result<T, Failure>` pattern without heavy external dependencies. |

---

## 3. The 6-Phase Engineering Roadmap

```mermaid
flowchart TD
    P1["Phase 1: Project Setup & Core Foundation<br/>- Pure Dart Result pattern & Failure types<br/>- Analysis options, strict typing<br/>- Dependencies & Env configuration"]
    P2["Phase 2: Domain Layer (Pure Business Logic)<br/>- Metric Entities: Steps, Sleep, SpO2, BloodPressure<br/>- Metric Invariants (Validation rules)<br/>- Repository Contracts (Abstract Interfaces)<br/>- Use Cases"]
    P3["Phase 3: Security & Data Layer<br/>- Secure key generator & Encrypted Hive Manager<br/>- Hive TypeAdapters & DTO Mappers<br/>- HealthKit & Health Connect DataSource<br/>- HealthMetricsRepository Implementation"]
    P4["Phase 4: AI Insights Engine<br/>- Gemini API Client with structured JSON schema<br/>- Prompt builder (sanitizing personal data)<br/>- HealthInsight Domain & Cache"]
    P5["Phase 5: Presentation & Riverpod State<br/>- Dashboard AsyncNotifier (Syncing OS -> Hive -> UI)<br/>- Permission handling state machine<br/>- Metric cards & trend charts"]
    P6["Phase 6: Verification & Edge Cases<br/>- Unit tests for Use Cases and Mappers<br/>- Permission denied fallbacks<br/>- Simulator/Device smoke testing"]

    P1 --> P2 --> P3 --> P4 --> P5 --> P6
```

---

## 4. Phase-by-Phase Checklist & Deliverables

### Phase 1: Core Foundation & Strict Setup
- [ ] Configure `pubspec.yaml` with production-pinned dependencies.
- [ ] Create `lib/core/errors/failures.dart` using modern Dart 3 `sealed class Result<S, F>`.
- [ ] Set up secure environment config (`.env` or `--dart-define` for Gemini API Key).
- [ ] Configure Android Health Connect manifest permissions & iOS `Info.plist` HealthKit privacy strings.

### Phase 2: Domain Layer (Zero Dependencies)
- [ ] Define `StepMetric`, `SleepMetric`, `BloodOxygenMetric`, and `BloodPressureMetric`.
- [ ] Implement domain invariants (e.g., Blood Pressure systolic must exceed diastolic; SpO2 within 50–100%).
- [ ] Define `HealthMetricsRepository` abstract interface.
- [ ] Define `AiInsightRepository` abstract interface.
- [ ] Create Use Cases: `GetDailyMetricsUseCase`, `SyncHealthDataUseCase`, `GenerateHealthInsightUseCase`.

### Phase 3: Data & Security Layer
- [ ] Implement `SecureStorageService` to retrieve or generate a random 256-bit Hive encryption key.
- [ ] Implement `HiveDatabaseService` with encrypted boxes for metrics and insights.
- [ ] Create Hive DTOs (`BloodPressureHiveModel`, etc.) and register TypeAdapters.
- [ ] Implement `HealthPlatformDataSource` utilizing the `health` package for Apple HealthKit and Android Health Connect permissions and queries.
- [ ] Implement `HealthMetricsRepositoryImpl` marrying Hive local storage with OS sync.

### Phase 4: Gemini AI Integration
- [ ] Define the JSON output schema (`GeminiSchema`) ensuring the model returns strictly typed data.
- [ ] Implement `GeminiAiDataSource` with temperature tuning and health context prompt formatting.
- [ ] Enforce non-diagnostic disclaimers in the domain entity validation.

### Phase 5: Presentation Layer (Riverpod)
- [ ] Set up `ProviderScope` and Riverpod observers.
- [ ] Build `HealthDashboardNotifier` (`AsyncNotifier<HealthDashboardState>`).
- [ ] Build UI widgets:
  - Metric summary cards with live status (Normal, Elevated, Caution).
  - HealthKit / Health Connect authorization banner if permissions are pending.
  - AI Insights interactive card with collapsible medical suggestions.

### Phase 6: Testing & Quality Assurance
- [ ] Unit test Domain Use Cases with mock repositories.
- [ ] Unit test Hive DTO mappers (`toDomain()` and `fromDomain()`).
- [ ] Test offline behavior (verifying encrypted Hive loads when device has no internet).
