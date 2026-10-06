# Чек-лист улучшений

## Выполнено в текущем аудите

- [x] Вернуть Debug build, исправив `FetchDescriptor`.
- [x] Убрать ложную победу при первом флаге и централизовать win condition.
- [x] Валидировать metadata и все ячейки snapshot до restore.
- [x] Заменить delete-before-encode на upsert с rollback.
- [x] Сделать `TimerService` session-scoped и синхронным по lifecycle.
- [x] Заменить O(n²) `removeFirst()` в flood fill на head index.
- [x] Санитизировать/ограничить имя и убрать его из ScoreService log.
- [x] Удалить мёртвый Combine-код из `GameViewModel`.
- [x] Обновить README, architecture, testing, security и logging docs.

## P0 — до следующего merge

- [ ] Добавить `MineGridTests` и test action в scheme; реализовать матрицу из TESTING.md.
- [ ] Удалить legacy `GameStorageService`; оставить один persistence API с `throws`.
- [ ] Добавить version в snapshot и план миграций SwiftData.

## P1 — архитектура и UX

- [ ] Вынести SwiftData fetch/delete из Views в repository/use case.
- [ ] Разделить `GameViewModel` на session, persistence/results coordinator и presentation state.
- [ ] Заменить `fatalError` при инициализации SwiftData на recovery/error UI.
- [ ] Исключить debug mutation API из Release через `#if DEBUG`.
- [ ] VoiceOver, Dynamic Type, contrast/hit targets и String Catalog.

## P2 — release engineering

- [ ] CI: clean build, tests, static analysis, archive.
- [ ] Typed OSLog privacy; не выводить arbitrary `localizedDescription` в Release.
- [ ] Убрать already tracked `xcuserdata` и `.DS_Store` из Git index.
- [ ] Перед App Store повторить privacy/required-reason API review.
