# 🎮 MineGrid

**MineGrid** — это классическая игра «Сапёр» (Minesweeper) для iOS, написанная на SwiftUI и Swift 6 с использованием современной архитектуры MVVM и принципов SOLID. Проект является pet-project с возможной публикацией в App Store.

## 📱 Описание

MineGrid — это логическая игра-головоломка, где игрок должен открыть все ячейки на поле, избегая мин. Цифры на открытых ячейках показывают количество соседних мин, что помогает игроку определить безопасные и опасные зоны.

## 🎯 Цель проекта

- **Pet-project**: разработка современного iOS-приложения с использованием лучших практик;
- **Образовательные цели**: демонстрация архитектуры MVVM, Dependency Injection и SOLID-принципов;
- **Потенциальная публикация**: возможность размещения в App Store после завершения разработки.

## ✨ Особенности

- 🎯 **Три уровня сложности:**
  - **Beginner**: 10×10 клеток, 10 мин (10%);
  - **Intermediate**: 25×25 клеток, 87 мин (14%);
  - **Expert**: 50×50 клеток, 450 мин (18%).

- 🎮 **Игровые функции:**
  - безопасный первый ход (мины генерируются после первого клика);
  - автоматическое открытие пустых зон (flood fill);
  - установка флагов для пометки предполагаемых мин;
  - таймер игры;
  - счётчик оставшихся мин;
  - визуальная обратная связь при победе или поражении;
  - сохранение и продолжение игры;
  - таблица лидеров с лучшими результатами.

- 🎨 **Современный UI:**
  - минималистичный дизайн;
  - градиентный фон;
  - адаптивный размер ячеек;
  - цветовая индикация цифр;
  - стеклянный эффект карточек.

## 🏗️ Архитектура

Проект использует архитектуру **MVVM** (Model-View-ViewModel) с разделением на слои:

### Models
- `Difficulty` — перечисление уровней сложности;
- `CellModel` — модель ячейки игрового поля;
- `GameBoardModel` — модель игрового поля;
- `GameState` — состояние игры;
- `GameResult` — результат игры для таблицы лидеров;
- `SavedGame` — сохранённая игра;
- `LeaderboardEntry` — запись в таблице лидеров.

### ViewModels
- `GameViewModel` — бизнес-логика игры, управление состоянием;
- `LeaderboardViewModel` — управление таблицей лидеров.

### Views
- `MainMenuView` — главное меню с выбором сложности;
- `GameView` — экран игры;
- `GridCellView` — компонент отдельной ячейки;
- `LeaderboardView` — таблица лидеров;
- `GameRulesView` — правила игры;
- `EmojiAnimationView` — анимация эмодзи;
- `DebugView` — отладочный экран.

### Services
Бизнес-логика вынесена в отдельные сервисы с использованием протоколов для Dependency Injection:

- `MineGeneratorService` — генерация мин на поле;
- `GameLogicService` — игровая логика (открытие ячеек, flood fill, проверка победы);
- `TimerService` — управление таймером игры;
- `GameStorageService` — сохранение и загрузка игр;
- `ScoreService` — работа с результатами;
- `GameSaveService` — сохранение состояния игры;
- `GameRulesService` — правила игры;
- `HapticFeedbackService` — тактильная обратная связь;
- `DependencyContainer` — контейнер зависимостей.

### Infrastructure
Инфраструктура проекта:
- **Logging**: система логирования (`AppLoggerService`, `LogService`, `LogLevel`);
- **Utilities**: вспомогательные утилиты (`IntFormatting`, `StringValidation`).

### UI Components
Переиспользуемые компоненты и модификаторы:
- `PrimaryButton` / `SecondaryButton` — кнопки;
- `BackgroundGradientModifier` — фоновый градиент;
- `ShakeDetectionModifier` — обнаружение встряхивания.

Подробнее об архитектуре см. [ARCHITECTURE.md](ARCHITECTURE.md).

## 🚀 Требования

- iOS 26.0+;
- Xcode 15.0+;
- Swift 6.0+.

## 📦 Установка и запуск

1. **Клонируйте репозиторий:**
```bash
git clone <repository-url>
```

2. **Откройте проект в Xcode:**
```bash
open MineGrid.xcodeproj
```

3. **Выберите целевое устройство или симулятор.**

4. **Нажмите ⌘R для сборки и запуска проекта.**

## 🎮 Как играть

1. **Выберите уровень сложности** на главном экране.
2. **Откройте ячейку** — нажмите на закрытую ячейку, чтобы открыть её.
3. **Установите флаг** — долгое нажатие на ячейку, чтобы пометить её как предполагаемую мину.
4. **Используйте цифры** — цифры показывают количество мин в соседних ячейках.
5. **Цель игры** — открыть все ячейки без мин или правильно пометить все мины флагами.

### Правила победы

- Все не-мины открыты **ИЛИ**
- Все мины помечены флагами и нет неоткрытых ячеек.

### Ограничения

- Нельзя поставить больше флагов, чем мин на поле.
- Игра не заканчивается победой, пока есть неоткрытые ячейки.

## 📁 Структура проекта

```
MineGrid/
├── MineGrid/
│   ├── Models/              # Модели данных
│   │   ├── CellModel.swift
│   │   ├── Difficulty.swift
│   │   ├── GameBoardModel.swift
│   │   ├── GameResult.swift
│   │   ├── GameState.swift
│   │   └── SavedGame.swift
│   ├── ViewModels/          # ViewModels
│   │   ├── GameViewModel.swift
│   │   └── LeaderboardViewModel.swift
│   ├── Views/               # SwiftUI Views
│   │   ├── DebugView.swift
│   │   ├── EmojiAnimationView.swift
│   │   ├── GameRulesView.swift
│   │   ├── GameView.swift
│   │   ├── GridCellView.swift
│   │   ├── LeaderboardView.swift
│   │   ├── MainMenuView.swift
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   └── SecondaryButton.swift
│   │   └── ViewModifiers/
│   │       ├── BackgroundGradientModifier.swift
│   │       └── ShakeDetectionModifier.swift
│   ├── Services/            # Бизнес-логика
│   │   ├── DependencyContainer.swift
│   │   ├── GameLogicService.swift
│   │   ├── GameRulesService.swift
│   │   ├── GameSaveService.swift
│   │   ├── GameStorageService.swift
│   │   ├── HapticFeedbackService.swift
│   │   ├── MineGeneratorService.swift
│   │   ├── ScoreService.swift
│   │   ├── TimerService.swift
│   │   └── Protocols/
│   │       ├── GameLogicProtocol.swift
│   │       ├── GameSaveServiceProtocol.swift
│   │       ├── GameStorageProtocol.swift
│   │       ├── HapticFeedbackProtocol.swift
│   │       ├── MineGeneratorProtocol.swift
│   │       ├── ScoreServiceProtocol.swift
│   │       └── TimerServiceProtocol.swift
│   ├── Infrastructure/      # Инфраструктура
│   │   ├── Logging/
│   │   │   ├── AppLoggerService.swift
│   │   │   ├── LogLevel.swift
│   │   │   └── LogService.swift
│   │   └── Utilities/
│   │       ├── IntFormatting.swift
│   │       └── StringValidation.swift
│   ├── MineGridApp.swift
│   └── Assets.xcassets/
├── ARCHITECTURE.md          # Документация архитектуры
├── LOGGING.md              # Документация системы логирования
└── README.md
```

## 🔧 Технические детали

### Основные технологии

- **SwiftUI** — современный фреймворк для создания пользовательского интерфейса;
- **Swift 6** — последняя версия языка программирования Swift;
- **SwiftData** — фреймворк для работы с данными;
- **MVVM** — архитектурный паттерн для разделения логики и представления;
- **@Observable** — макрос Swift 6 для реактивного программирования;
- **Dependency Injection** — через протоколы для тестируемости;
- **iOS 26** — таргет платформа.

### Принципы разработки

- **SOLID** — принципы объектно-ориентированного программирования;
- **KISS** — простота и понятность кода;
- **DRY** — избегание дублирования кода;
- **Clean Architecture** — разделение на слои.

### Алгоритмы

- **Flood Fill** — итеративный алгоритм для автоматического открытия пустых зон;
- **Random Mine Placement** — случайная генерация мин с исключением первого клика и его соседей;
- **Adjacent Mines Calculation** — подсчёт количества мин вокруг каждой ячейки.

## 📊 Система логирования

Проект использует полноценную систему логирования, построенную на протоколах и Dependency Injection:

- **LogService** (protocol) — протокол для логирования;
- **AppLogger** (class) — реализация с использованием OSLog;
- **LogLevel** (enum) — уровни логирования (debug, info, warning, error).

Подробнее см. [LOGGING.md](LOGGING.md).

## 🧪 Тестирование

Проект подготовлен к unit-тестированию:

- все сервисы используют протоколы, что позволяет создавать моки;
- бизнес-логика вынесена в чистые функции;
- ViewModels тестируются изолированно через DI.

Пример тестирования см. в [ARCHITECTURE.md](ARCHITECTURE.md).

## 📝 Важные примечания для разработчиков

1. **Архитектура**: следуйте принципам MVVM и SOLID при добавлении нового функционала;
2. **Логирование**: используйте систему логирования через Dependency Injection;
3. **Тестирование**: все новые сервисы должны иметь протоколы для возможности тестирования;
4. **Производительность**: для больших полей (50×50) используйте ленивую загрузку (LazyVStack/LazyHStack);
5. **Документация**: обновляйте ARCHITECTURE.md при изменении архитектуры.

## 🎯 Будущие улучшения

- добавление полного набора unit-тестов;
- UI-тесты для основных экранов;
- улучшение анимаций и переходов;
- поддержка VoiceOver и других функций доступности;
- локализация на несколько языков;
- возможность выбора цветовой темы.

## 📝 Лицензия

Этот проект создан в образовательных целях.

## 👤 Автор

Dmitriy Akhmerov

---

**Приятной игры! 🎮**
