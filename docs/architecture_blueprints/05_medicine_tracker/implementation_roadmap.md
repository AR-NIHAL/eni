# Medicine Tracker: Production Implementation Roadmap

> Tailored for: **Clean Architecture** + **Riverpod** + **Native Exact Alarms** + **Encrypted Hive** + **Gemini AI Prescription Scanner**.

---

## 1. System Architecture & Core Flows

### Flow 1: Exact Alarm Trigger & Adherence Logging (Even in Doze Mode)

```mermaid
sequenceDiagram
    autonumber
    participant OS as Android AlarmManager / iOS APNs
    participant Native as Native Alarm Receiver / Foreground Service
    participant Flutter as Flutter App Engine
    participant UseCase as RecordDoseTakenUseCase
    participant Hive as Encrypted Hive (Ledger Box)
    participant UI as Full-Screen Alarm Modal

    OS->>Native: exactAlarmFired(alarmId: 8821)
    Native->>UI: Launch Full-Screen Intent (Rings custom sound & vibration)
    UI->>User: Display "Time for Metformin 500mg"
    User->>UI: Taps "Take Dose"
    UI->>Flutter: recordDose(medicationId, scheduledTime, recordedTime: now)
    Flutter->>UseCase: execute(log)
    UseCase->>UseCase: validateInvariants (no future timestamps)
    UseCase->>Hive: appendDoseLog(log)
    UseCase->>Hive: decrementInventoryStock(medicationId, dosage: 1)
    UseCase-->>UI: Confirm success & schedule next occurrence
```

### Flow 2: AI Prescription Label Scanner (Vision OCR)

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as ScanPrescriptionScreen
    participant Notifier as Riverpod (PrescriptionScannerNotifier)
    participant Gemini as Gemini Vision API
    participant UseCase as CreateMedicationFromDraftUseCase

    User->>UI: Takes photo of medicine bottle / prescription label
    UI->>Notifier: processLabelImage(imageBytes)
    Notifier->>Gemini: generateContent(imageBytes, structuredResponseSchema)
    Note over Gemini: Extracts name, dosage, unit, frequency, warnings
    Gemini-->>Notifier: returns JSON { name: "Amoxicillin", dose: 500, unit: "mg", frequency: "every_8_hours" }
    Notifier-->>UI: Pre-populate "New Medication" form for user review
    User->>UI: Reviews & confirms schedule
    UI->>UseCase: saveMedication(entity)
```

---

## 2. Modular Folder Structure for Medicine Tracker

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp, Theme (High-contrast medical theme)
│   └── router.dart                # Deep links (alarm-action/:medicationId)
├── core/
│   ├── alarms/
│   │   ├── alarm_scheduler.dart   # Bridge to OS AlarmManager (Exact alarms)
│   │   ├── boot_receiver.dart     # Auto-reschedules alarms on device reboot
│   │   └── notification_channels.dart # Critical medical alert sound channels
│   ├── errors/
│   │   ├── exceptions.dart        # AlarmSchedulingException, StorageException
│   │   └── failures.dart          # Result<S, F> sealed classes
│   └── utils/
│       ├── recurrence_engine.dart # Pure Dart next-dose calculator
│       └── timezone_handler.dart  # Wall-clock to local timezone converter
├── features/
│   ├── medications/               # Medication definitions & inventory
│   │   ├── domain/
│   │   │   ├── entities/          # Medication, Dosage, ScheduleRule, Inventory
│   │   │   ├── repositories/      # MedicationRepository (interface)
│   │   │   └── usecases/          # AddMedication, UpdateInventoryStock
│   │   ├── data/
│   │   │   ├── models/            # MedicationHiveModel, DosageHiveModel
│   │   │   └── repositories/      # MedicationRepositoryImpl
│   │   └── presentation/
│   │       ├── controllers/       # MedicationListNotifier
│   │       └── views/             # MedicationDetailScreen, AddMedicationScreen
│   ├── adherence/                 # Daily Timeline & Pill Logging
│   │   ├── domain/
│   │   │   ├── entities/          # DoseLog, DoseStatus (Taken/Skipped/Missed)
│   │   │   ├── repositories/      # AdherenceRepository (interface)
│   │   │   └── usecases/          # RecordDoseActionUseCase, GetDailyTimelineUseCase
│   │   ├── data/
│   │   │   ├── models/            # DoseLogHiveModel
│   │   │   └── repositories/      # AdherenceRepositoryImpl
│   │   └── presentation/
│   │       ├── controllers/       # TodayTimelineNotifier (AsyncNotifier)
│   │       ├── widgets/           # PillDoseCard, QuickActionButtons, RefillBadge
│   │       └── views/             # TodayScheduleScreen, AdherenceReportScreen
│   └── ai_prescription_scanner/   # Gemini OCR & Interaction Checks
│       ├── domain/
│       │   ├── entities/          # ScannedMedicationDraft, DrugInteractionWarning
│       │   └── usecases/          # ScanLabelImageUseCase, CheckDrugInteractionsUseCase
│       ├── data/
│       │   └── datasources/       # GeminiPrescriptionVisionDataSource
│       └── presentation/
│           ├── controllers/       # ScannerNotifier
│           └── views/             # CameraScannerScreen, ReviewExtractedDataScreen
└── main.dart
```

---

## 3. The 6-Phase Engineering Roadmap

```mermaid
flowchart TD
    P1["Phase 1: Foundation & Exact Alarm Permissions<br/>- SCHEDULE_EXACT_ALARM setup<br/>- Pure Dart RecurrenceEngine & Result pattern<br/>- Encrypted Hive initialization"]
    P2["Phase 2: Domain Layer (Schedules & Adherence)<br/>- Medication, Dosage, ScheduleRule, DoseLog entities<br/>- Invariant validation (PRN limits, no future doses)<br/>- Repository contracts & Use Cases"]
    P3["Phase 3: Data Layer & Native Alarm Engine<br/>- Native AlarmManager / Notification integration<br/>- BOOT_COMPLETED receiver for reboots<br/>- Hive TypeAdapters for medication & dose logs"]
    P4["Phase 4: Gemini AI Prescription OCR & Interactions<br/>- Camera photo -> Gemini Vision JSON schema<br/>- Pre-populating schedule rules<br/>- Drug interaction safety warning queries"]
    P5["Phase 5: Presentation & Riverpod State<br/>- TodayTimelineNotifier (Reactive dose list)<br/>- One-tap 'Take' / 'Skip' interactions<br/>- Full-screen wakeup ringing alarm screen"]
    P6["Phase 6: Verification, Timezones & Clinical Export<br/>- Timezone shift / DST transition testing<br/>- Device reboot survival test<br/>- PDF adherence report generator for doctors"]

    P1 --> P2 --> P3 --> P4 --> P5 --> P6
```

---

## 4. Phase-by-Phase Checklist & Deliverables

### Phase 1: Core Foundation & Alarm System Setup
- [ ] Add `android.permission.SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, and `WAKE_LOCK` to Android manifest.
- [ ] Configure `flutter_local_notifications` and the native `alarm` package for lockscreen wakeups.
- [ ] Write pure Dart `RecurrenceEngine` (calculating next trigger dates for daily, interval, cyclical, and PRN schedules).

### Phase 2: Domain Layer (Zero Dependencies)
- [ ] Implement `Dosage` value object (`amount`, `unit`, `instructions`).
- [ ] Implement `ScheduleRule` supporting fixed times, intervals, day-of-week filters, and cycles.
- [ ] Implement `DoseLog` entity with status enum: `Scheduled`, `Taken`, `Skipped`, `Missed`, `Snoozed`.
- [ ] Write use case tests ensuring PRN drugs reject doses taken too close together.

### Phase 3: Data Layer & Native Boot Resilience
- [ ] Implement `EncryptedMedicationBox` and `EncryptedDoseLogBox` in Hive.
- [ ] Wire native Android `BroadcastReceiver` for `BOOT_COMPLETED` to reschedule alarms whenever the phone reboots.
- [ ] Implement `AlarmSchedulerService` to synchronize upcoming schedule occurrences with native OS alarms.

### Phase 4: Gemini AI Vision Prescription Scanner
- [ ] Build camera capture flow using `image_picker` or `camera`.
- [ ] Configure Gemini Vision prompt with strict JSON schema:
  - Extract: `medicationName`, `strengthNumber`, `strengthUnit`, `frequencyDescription`, `suggestedTimes`.
- [ ] Create `CheckDrugInteractionsUseCase` that compares newly added medications against existing active medications and returns flagged contraindications.

### Phase 5: Presentation Layer (Riverpod)
- [ ] Build `TodayTimelineNotifier`:
  - Groups doses into Morning, Afternoon, Evening, Bedtime buckets.
  - Reactive updating when a pill is marked taken.
- [ ] Build `FullScreenAlarmView` displaying high-contrast buttons for elderly/impaired vision accessibility.
- [ ] Implement inventory low-stock alert pill card (`"Only 4 tablets remaining"`).

### Phase 6: Edge Cases & Reliability Verification
- [ ] **The Reboot Test**: schedule an alarm 3 minutes in the future, reboot the device, and verify the alarm still fires.
- [ ] **The Timezone Test**: change the phone's clock or timezone; verify scheduled doses stay fixed to local wall-clock time.
- [ ] **The Zero-Dose Edge Case**: verify inventory correctly transitions to "Empty" without crashing or allowing negative integers.
