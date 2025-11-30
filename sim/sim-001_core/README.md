# SIM-001 Core Templates

Physics: 0.1  
Status: draft  
Role: lab

## Призначення

SIM-001 — це лабораторія шаблонів.  
Тут ми визначаємо **стандарти для всіх інших SIM-ів**:

- як виглядає README симуляції;
- як описується світ (`world.yaml`);
- як описуються агенти (`agents.yaml` або інший формат).

Усе, що стає стабільним у SIM-001, може бути винесене в `PHYSICS.md` як правило.

---

## Артефакти

Планова структура папки:

- `sim/sim-001_core/README.md` — цей файл.
- `sim/sim-001_core/TEMPLATE_SIM_README.md` — шаблон README для будь-якого SIM.
- `sim/sim-001_core/TEMPLATE_WORLD.yaml` — базовий шаблон світу.
- `sim/sim-001_core/TEMPLATE_AGENTS.yaml` — базовий шаблон опису агентів (чернетка).

---

## Критерії завершення SIM-001

SIM-001 переходить зі `Status: draft` у `Status: active`, коли:

1. Є робочий шаблон `TEMPLATE_SIM_README.md`.
2. Є робочий шаблон `TEMPLATE_WORLD.yaml`, який уже використовується в якомусь SIM (наприклад, SIM-002).
3. Є хоча б чернетка `TEMPLATE_AGENTS.yaml`.
4. `PHYSICS.md` посилається на ці шаблони як на канонічні.

---

## Звʼязок із REGISTRY

- Запис у `REGISTRY.md` для SIM-001 повинен мати:
  - `ID = SIM-001`
  - `Path = sim/sim-001_core/`
  - `Physics = 0.1`
  - `Status = draft` (поки ми формуємо шаблони)
  - `Role = lab`
