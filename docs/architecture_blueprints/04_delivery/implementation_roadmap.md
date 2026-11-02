# Delivery App: Production Implementation Roadmap

> Tailored for: **Clean Architecture** + **Riverpod** + **WebSocket / MQTT Live Streams** + **Offline Hive Queue** + **Gemini AI Predictive ETA**.

---

## 1. System Architecture & Real-Time Flows

### Flow 1: Live Driver Telemetry & Map Marker Interpolation

```mermaid
sequenceDiagram
    autonumber
    actor Driver as Courier App
    participant GPS as Background Geolocation
    participant WS as WebSocket / MQTT Broker
    participant Riverpod as Customer App (StreamNotifier)
    participant UI as LiveMap Tracking Widget

    Driver->>GPS: Move 15 meters
    GPS->>Driver: onLocationChanged(lat, lng, heading, speed)
    Driver->>WS: publish("orders/90214/telemetry", coords)
    WS->>Riverpod: stream.onData(coords)
    Riverpod->>Riverpod: filterJitter & calculateSmoothBearing()
    Riverpod-->>UI: emit(DriverMarkerPosition(coords, bearing))
    UI->>UI: Animate marker from Point A to Point B over 1.5s
```

### Flow 2: Offline-First Proof of Delivery in a Cellular Dead Zone

```mermaid
sequenceDiagram
    autonumber
    actor Driver as Courier (In Apartment Elevator / Dead Zone)
    participant UI as Courier Delivery Sheet
    participant Notifier as Riverpod (DeliveryActionNotifier)
    participant UseCase as CompleteDeliveryUseCase
    participant Hive as Encrypted Hive (Action Queue)
    participant Worker as Background Sync Service
    participant Backend as Dispatch API

    Driver->>UI: Enters Customer OTP ("4829"), taps Confirm Delivery
    UI->>Notifier: completeDelivery(orderId: "90214", otp: "4829")
    Notifier->>UseCase: execute(orderId, otp)
    UseCase->>UseCase: validateLocalOTP(otp)
    
    alt Device has No Cellular Connection
        UseCase->>Hive: queueAction(ActionType.completeDelivery, payload)
        UseCase-->>Notifier: emit(DeliveryState.locallyCompletedPendingSync)
        Notifier-->>UI: Show "Delivery Confirmed (Syncing in background)"
    end

    Note over Worker: Courier walks outside -> Cellular connection restored
    Worker->>Hive: getPendingActions()
    Worker->>Backend: POST /orders/90214/complete (with queued timestamp)
    Backend-->>Worker: HTTP 200 OK
    Worker->>Hive: removeAction(actionId)
```

---

## 2. Modular Folder Structure for Delivery App

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp, Theme, Global Lifecycle
│   └── router.dart                # Deep links (e.g., track/order/:id)
├── core/
│   ├── errors/
│   │   ├── exceptions.dart        # SocketException, GeolocationException
│   │   └── failures.dart          # Result<S, F> sealed classes
│   ├── geospatial/
│   │   ├── coordinates.dart       # Coordinates Value Object (lat, lng, bearing)
│   │   ├── haversine.dart         # Pure Dart distance & proximity calculator
│   │   └── polyline_decoder.dart  # Decode route polylines into LatLng lists
│   ├── network/
│   │   ├── websocket_client.dart  # Resilient WebSocket connection with heartbeat
│   │   └── offline_queue.dart     # Action replay manager for dead zones
│   └── utils/
│       └── marker_interpolator.dart# Spherical linear interpolation (Slerp)
├── features/
│   ├── order_fulfillment/         # Lifecycle state machine
│   │   ├── domain/
│   │   │   ├── entities/          # DeliveryOrder, OrderStatus, DeliveryParty
│   │   │   ├── repositories/      # DeliveryOrderRepository (interface)
│   │   │   └── usecases/          # GetActiveOrderUseCase, UpdateOrderStatusUseCase
│   │   ├── data/
│   │   │   ├── models/            # DeliveryOrderHiveModel, DTO Mappers
│   │   │   └── repositories/      # DeliveryOrderRepositoryImpl (Hive + REST)
│   │   └── presentation/
│   │       ├── controllers/       # OrderLifecycleNotifier
│   │       ├── widgets/           # OrderTimelineStepper, OtpVerificationDialog
│   │       └── views/             # ActiveOrderDashboardScreen
│   ├── live_tracking/             # Real-time GPS & Map
│   │   ├── domain/
│   │   │   ├── entities/          # TelemetrySample, RouteLeg, ETAEstimate
│   │   │   ├── repositories/      # LiveTrackingRepository (Stream interface)
│   │   │   └── usecases/          # StreamDriverPositionUseCase, CalculateEtaUseCase
│   │   ├── data/
│   │   │   ├── datasources/       # WebSocketTelemetryDataSource, GoogleDirectionsApi
│   │   │   └── repositories/      # LiveTrackingRepositoryImpl
│   │   └── presentation/
│   │       ├── controllers/       # LiveMapTrackingNotifier (StreamNotifier)
│   │       ├── widgets/           # GoogleMap/MapboxWidget, DriverInfoCard
│   │       └── views/             # LiveTrackingMapScreen
│   └── ai_dispatch_eta/           # Gemini AI Contextual Delay Engine
│       ├── domain/
│       │   ├── entities/          # PredictiveEta, DelayRiskFactor
│       │   └── usecases/          # PredictKitchenDelayUseCase
│       ├── data/
│       │   └── datasources/       # GeminiEtaPredictorDataSource
│       └── presentation/
│           └── widgets/           # SmartEtaBadge, DelayExplanationCard
└── main.dart
```

---

## 3. The 6-Phase Engineering Roadmap

```mermaid
flowchart TD
    P1["Phase 1: Geospatial & Real-Time Foundation<br/>- Coordinates value object & Haversine math<br/>- WebSocket client with auto-reconnect<br/>- Pure Dart Result pattern"]
    P2["Phase 2: Domain Layer (State Machines & Streams)<br/>- DeliveryOrder entity & valid status transitions<br/>- LiveTrackingRepository stream contract<br/>- Use cases: StreamDriverLocation, VerifyDeliveryOtp"]
    P3["Phase 3: Real-Time Data Layer & Map SDK<br/>- Google Maps / Mapbox integration<br/>- WebSocket telemetry channel parsing<br/>- Encrypted Hive offline action queue"]
    P4["Phase 4: Gemini AI Contextual Delay Predictor<br/>- Predicting delay based on items, weather, and distance<br/>- Structured JSON schema output<br/>- Automated customer reassurance messages"]
    P5["Phase 5: Presentation & Riverpod State<br/>- LiveMapTrackingNotifier (StreamNotifier)<br/>- Smooth marker rotation & coordinate tween animation<br/>- Interactive order timeline stepper"]
    P6["Phase 6: Dead-Zone Recovery & Battery Testing<br/>- Airplane mode proof-of-delivery replay test<br/>- Driver background GPS throttling (10m / 10s)<br/>- High-speed telemetry jitter filter"]

    P1 --> P2 --> P3 --> P4 --> P5 --> P6
```

---

## 4. Phase-by-Phase Checklist & Deliverables

### Phase 1: Geospatial & Real-Time Infrastructure
- [ ] Implement `Coordinates` value object with range assertions ($\text{lat} \in [-90, 90]$, $\text{lng} \in [-180, 180]$).
- [ ] Write pure Dart Haversine formula to compute meters between two points.
- [ ] Implement `WebSocketClient` with ping/pong keepalive, exponential backoff reconnect, and connection state streams.

### Phase 2: Domain Layer (Zero Dependencies)
- [ ] Define `DeliveryOrder` and `OrderStatus` sealed class hierarchy:
  - `OrderPlaced`, `MerchantAccepted`, `Preparing`, `ReadyForPickup`, `OutForDelivery`, `Arrived`, `Delivered`, `Cancelled`.
- [ ] Implement state machine guards (e.g. `cannot transition to Delivered without valid OTP`).
- [ ] Define abstract `LiveTrackingRepository` returning `Stream<Coordinates>`.

### Phase 3: Real-Time Data & Offline Queue
- [ ] Configure `google_maps_flutter` or `mapbox_maps_flutter`.
- [ ] Implement `LiveTrackingRepositoryImpl` mapping incoming WebSocket JSON payloads to `Coordinates`.
- [ ] Implement `OfflineActionQueueService` in Hive to store pending status updates during dead zones.

### Phase 4: Gemini AI Contextual Delay Predictor
- [ ] Formulate prompt with structured JSON output schema:
  - Input: Restaurant busy score, items count (e.g., 8 large pizzas), precipitation, traffic multiplier.
  - Output: `{ "estimatedPrepMinutes": 22, "delayRisk": "HIGH", "customerNotice": "..." }`
- [ ] Enforce fallback to static distance/speed calculation if AI request times out.

### Phase 5: Presentation Layer (Riverpod)
- [ ] Implement `LiveTrackingNotifier` using `StreamNotifier<LiveTrackingState>`:
  - Calculate bearing (angle in degrees) between coordinate $N-1$ and coordinate $N$.
  - Animate custom vehicle icon along the polyline.
- [ ] Build `DeliveryProgressBottomSheet` with dynamic ETA countdown and call driver button.

### Phase 6: Edge Cases & Field Testing
- [ ] Test the **Tunnel Scenario**: disconnect internet while tracking; verify UI shows "Reconnecting..." and retains the driver's last known position without clearing the map.
- [ ] Test the **Elevator Scenario**: driver submits OTP offline; verify Hive queues it and auto-completes when network returns.
- [ ] Verify battery consumption of the driver app background tracking service.
