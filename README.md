# MineGrid

MineGrid — игра «Сапёр» для iPhone и iPad на SwiftUI. Проект использует MVVM, SwiftData, Observation, dependency injection через протоколы и OSLog.

## Возможности

- три уровня: 10×10/10 мин, 25×25/87 мин, 50×50/450 мин;
- безопасный первый ход с защитой соседних ячеек;
- итеративный flood fill, флаги, таймер и haptic feedback;
- автосохранение активной игры и таблица рекордов в SwiftData;
- валидация snapshot перед восстановлением.

## Требования

- Xcode 26.1.1 или новее;
- iOS/iPadOS 26.1+;
- Swift language mode 5.0 (текущая настройка target).

Сторонних зависимостей нет.

## Запуск

```bash
open MineGrid.xcodeproj
```

В Xcode выберите scheme `MineGrid` и симулятор/устройство. Проверка сборки без code signing:

```bash
xcodebuild -project MineGrid.xcodeproj -scheme MineGrid \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/MineGridDerivedData CODE_SIGNING_ALLOWED=NO build
```

## Как играть

Короткое нажатие открывает ячейку, долгое — переключает флаг. Победа наступает, когда открыты все безопасные ячейки. Также поддерживается вариант, когда все мины помечены и закрытх ячеек не осталось.

## Документация

- [ARCHITECTURE.md](ARCHITECTURE.md) — слои, потоки данных и инварианты;
- [LOGGING.md](LOGGING.md) — правила логирования;
- [TESTING.md](TESTING.md) — текущая стратегия проверок;
- [SECURITY.md](SECURITY.md) — модель данных и disclosure;
- [IMPROVEMENTS.md](IMPROVEMENTS.md) — приоритетный чек-лист.
