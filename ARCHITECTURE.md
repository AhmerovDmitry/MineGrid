# Архитектура MineGrid

## Слои

- `Views` — SwiftUI-экраны и переиспользуемые компоненты.
- `ViewModels` — observable-состояние и координация use case.
- `Models` — состояние поля, переходы ячеек, счётчики и SwiftData-модели.
- `Services` — генерация мин, правила, flood fill, таймер, persistence, scores и haptics.
- `Infrastructure` — OSLog и утилиты.

`DependencyContainer` создаёт `GameViewModel`. Stateless-сервисы могут переиспользоваться; `TimerService` всегда session-scoped, чтобы игры не делили mutable state.

## Игровой поток

1. ViewModel создаёт пустую `GameBoardModel`.
2. На первом открытии `MineGeneratorService` размещает мины, исключая ячейку и её соседей.
3. `GameLogicService` открывает ячейку; для нулей запускает итеративный flood fill с индексом головы очереди.
4. `GameBoardModel` поддерживает counters; `GameRulesService` делегирует единственную проверку победы `board.isWon()`.
5. ViewModel меняет `GameState`, таймер и haptic feedback; Observation обновляет UI.

## Persistence

`GameSaveService` кодирует `CellData` в JSON и делает upsert одного `SavedGame`. Перед записью новые данные кодируются; при ошибке context откатывается. При restore проверяются metadata, payload, `size²` уникальных координат, enums, adjacent/mine/flag counts.

`GameStorageService` — legacy-реализация, которая ещё находится в target, но не участвует в текущем save flow. Её удаление отмечено в checklist.

## Инварианты

- все изменения `CellState` идут через `GameBoardModel`, чтобы counters не расходились;
- до первого открытия на поле нет мин;
- таймер принадлежит одной игровой сессии;
- завершённые игры не сохраняются для Continue.
