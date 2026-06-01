# Simulation v2 — iOS App

Нативний iPhone-застосунок (SwiftUI), який запускає та візуалізує симуляцію
**SIM-002** прямо на пристрої за законами з [`PHYSICS.md`](../PHYSICS.md).

## Що робить

- Завантажує світ `sim/sim-002_world/world.yaml` (як `Resources/world-sim002.json`):
  сітка 8×8, агент у `(0,0)`, ціль у `(7,7)`.
- Кроково (tick) рухає агента до цілі за правилами оновлення PHYSICS §2 / §5.
- Детермінізм через контрольований `seed` (PHYSICS §5.1): однаковий seed →
  однакова траєкторія.
- Зупиняється за умовами `reached_goal` або `max_ticks`.

## Інтерфейс

- **Сітка** — поточний стан світу: агент (помаранчевий), ціль (зелений прапор),
  слід пройденого шляху.
- **Запуск / Пауза / Крок / Скинути** — керування циклом тіків.
- **Швидкість** — tick/секунду (1–20).
- **Seed** — змінює зерно випадковості й перезапускає прогін.
- **Журнал** — події симуляції (PHYSICS §6).

## Структура

```
ios-app/
├─ SimulationV2.xcodeproj/        # проєкт Xcode 16 (синхронізовані папки)
└─ SimulationV2/
   ├─ SimulationV2App.swift        # точка входу
   ├─ Models/
   │  ├─ World.swift               # сітка, сутності (§3, §4)
   │  ├─ WorldLoader.swift         # завантаження світу (§6)
   │  ├─ DeterministicRandom.swift # SplitMix64, seed (§5.1)
   │  └─ SimulationEngine.swift    # цикл тіків (§2, §5)
   ├─ Views/                       # ContentView, Grid, Controls, Stats, Log
   ├─ Resources/world-sim002.json  # світ SIM-002
   └─ Assets.xcassets/
```

## Запуск

1. Відкрити `ios-app/SimulationV2.xcodeproj` у Xcode 16+.
2. Вибрати симулятор iPhone (iOS 17+) → **Run** (⌘R).

Або через CLI:

```bash
xcodebuild -project ios-app/SimulationV2.xcodeproj \
  -scheme SimulationV2 \
  -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Розширення

Архітектура data-driven: щоб додати новий світ, покладіть JSON у тому ж форматі,
що `world-sim002.json`, і завантажте його через `WorldLoader`. Так само можна
підключати багатші світи з `sim_core_v2_archive.zip` (гео-світи, процеси, ринки),
розширивши модель `World` під відповідні поля.
