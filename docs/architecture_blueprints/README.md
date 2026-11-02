# Senior Engineer Architecture & Implementation Blueprints

A comprehensive guide and design library for building enterprise-grade Flutter applications using **Clean Architecture**, **Riverpod**, **Hive**, and **Gemini AI**.

---

## 📚 Blueprint Library

| # | Domain | Core Architectural Paradigm | Documentation Links |
| :---: | :--- | :--- | :--- |
| **01** | **AI Health Tracker** | Biometric time-series, HealthKit/Health Connect sync, encrypted local cache | • [Architecture & Thinking Blueprint](01_health_tracker/architecture_and_thinking_blueprint.md)<br/>• [Implementation Roadmap](01_health_tracker/implementation_roadmap.md) |
| **02** | **Money & Finance Tracker** | Zero-tolerance ledger math, `Money` Value Object, anti-rounding patterns | • [Architecture & Thinking Blueprint](02_finance_tracker/architecture_and_thinking_blueprint.md)<br/>• [Implementation Roadmap](02_finance_tracker/implementation_roadmap.md) |
| **03** | **E-Commerce Platform** | Inventory concurrency, Product vs. SKU modeling, idempotent checkout | • [Architecture & Thinking Blueprint](03_ecommerce/architecture_and_thinking_blueprint.md)<br/>• [Implementation Roadmap](03_ecommerce/implementation_roadmap.md) |
| **04** | **On-Demand Delivery** | Real-time geospatial streams, 3-actor state machine, offline dead-zone queue | • [Architecture & Thinking Blueprint](04_delivery/architecture_and_thinking_blueprint.md)<br/>• [Implementation Roadmap](04_delivery/implementation_roadmap.md) |
| **05** | **Medicine & Pill Tracker** | Life-critical exact OS alarms, reboot recovery, adherence event ledger | • [Architecture & Thinking Blueprint](05_medicine_tracker/architecture_and_thinking_blueprint.md)<br/>• [Implementation Roadmap](05_medicine_tracker/implementation_roadmap.md) |

---

## 🧠 Master Engineering Comparison Matrix

| App Domain | Data Authority | Error Tolerance | Number Representation | AI Responsibility |
| :--- | :--- | :--- | :--- | :--- |
| **Health** | Client / OS Sensor APIs | Approximate samples OK | `int` / `double` | Biometric anomaly flags & non-diagnostic coaching |
| **Finance** | Client encrypted ledger | **Zero tolerance** | **Integer minor units (cents)** in `Money` Value Object | Categorization & budget anomalies (non-fiduciary) |
| **E-Commerce** | **Server-authoritative** | Strict inventory rules | `Money` Value Object + SKUs | Semantic search query extraction & recommendations |
| **Delivery** | Dispatch WebSocket broker | Latency-sensitive streams | `Coordinates` Value Object with bearing | Contextual kitchen delay prediction & smart routing |
| **Medicine** | Local device alarm engine | **Zero missed alerts** | Wall-Clock `TimeOfDay` | Prescription label OCR & drug interaction warnings |

---

## 🏛️ Clean Architecture Core Rule

In all 5 applications, the architecture follows the strict **Dependency Rule**:

```
Presentation Layer (UI, Riverpod AsyncNotifiers)
         ↓ calls
Domain Layer (Pure Dart: Entities, Invariants, Repository Contracts, Use Cases)
         ↑ implements
Data Layer (Hive Models, TypeAdapters, Remote APIs, OS Sensors/Alarms)
```

- **Domain depends on nothing.** It does not import Flutter, Hive, or Riverpod.
- **Data depends on Domain** by implementing repository interfaces.
- **Presentation depends on Domain** by calling use cases and reading entities.

