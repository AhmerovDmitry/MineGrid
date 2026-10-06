# Тестирование

## Текущее состояние

Target собирается командой из README. В `.xcodeproj` пока нет test target, поэтому `xcodebuild test` завершается с «Scheme MineGrid is not currently configured for the test action». Это открытая задача, а не замена тестов ручной проверкой.

## Обязательная unit-матрица

- первый флаг не приводит к победе;
- первое открытие и его соседи безопасны;
- mine count и adjacent counts корректны;
- flood fill не открывает мины/флаги и работает на 50×50;
- counters совпадают с полным пересчётом;
- победа, поражение и лимит флагов;
- malformed snapshot: size, duplicate/negative coordinate, bad enum/count;
- save round-trip и rollback при ошибке;
- timer start/stop/restart и независимость двух ViewModel;
- sanitation имени, сортировка/фильтр leaderboard.

## UI smoke

New game → open → flag → background/restore → win/lose → save score → leaderboard. Отдельно проверить VoiceOver, Dynamic Type, iPhone/iPad и доску 50×50.
