# Архитектура проекта MineGrid

## 📋 Обзор

**MineGrid** — это iOS-приложение «Сапёр», разработанное с использованием SwiftUI и Swift 6. Проект следует принципам **MVVM (Model-View-ViewModel)** архитектуры с разделением на слои и использованием Dependency Injection (DI) для улучшения тестируемости и поддерживаемости кода.

## 🏗 Структура проекта

```
MineGrid/
├── Models/              # Модели данных
├── ViewModels/          # ViewModels для бизнес-логики
├── Views/               # SwiftUI Views
│   ├── Buttons/        # Кнопки
│   └── ViewModifiers/  # Модификаторы представлений
├── Services/            # Бизнес-логика и сервисы
│   ├── Protocols/      # Протоколы для DI
│   └── [Services]      # Реализации сервисов
├── Infrastructure/      # Инфраструктура
│   ├── Logging/       # Система логирования
│   │   ├── LogLevel.swift  # Уровни логирования
│   │   ├── LogService.swift # Протокол логирования
│   │   └── AppLogger.swift # Реализация логгера
│   └── Utilities/     # Вспомогательные утилиты
└── Assets.xcassets/    # Ресурсы
```

## 📐 Архитектурные принципы

### 1. MVVM (Model-View-ViewModel)

- **Models**: чистые структуры данных без бизнес-логики;
- **Views**: только UI, без логики (SwiftUI Views);
- **ViewModels**: управление состоянием и координация между Views и Services;
- **Services**: вся бизнес-логика вынесена в отдельные сервисы.

### 2. Dependency Injection (DI)

Все сервисы используют протоколы для возможности замены реализаций:

```swift
protocol MineGeneratorProtocol { ... }
protocol GameLogicProtocol { ... }
protocol TimerServiceProtocol { ... }
protocol GameStorageProtocol { ... }
protocol ScoreServiceProtocol { ... }
protocol GameSaveServiceProtocol { ... }
protocol GameRulesProtocol { ... }
protocol HapticFeedbackProtocol { ... }
protocol LogService { ... }
```

Это позволяет:
- легко тестировать компоненты с моками;
- заменять реализации без изменения ViewModels;
- следовать принципу Dependency Inversion (SOLID);
- внедрять логирование через DI во все компоненты.

### 3. SOLID принципы

- **Single Responsibility**: каждый класс/структура имеет одну ответственность;
- **Open/Closed**: открыт для расширения через протоколы, закрыт для модификации;
- **Liskov Substitution**: протоколы позволяют заменять реализации;
- **Interface Segregation**: протоколы разделены по функциональности;
- **Dependency Inversion**: зависимости от абстракций (протоколов), а не от конкретных реализаций.

### 4. Протоколы сервисов

Все сервисы используют протоколы для Dependency Injection:

- **`MineGeneratorProtocol`**: генерация мин на поле;
- **`GameLogicProtocol`**: игровая логика (открытие ячеек, flood fill, проверка победы);
- **`TimerServiceProtocol`**: управление таймером игры;
- **`GameStorageProtocol`**: сохранение и загрузка игр;
- **`ScoreServiceProtocol`**: работа с результатами;
- **`GameSaveServiceProtocol`**: сохранение состояния игры;
- **`GameRulesProtocol`**: правила игры;
- **`HapticFeedbackProtocol`**: тактильная обратная связь;
- **`LogService`**: логирование.

### 5. Dependency Container

**`DependencyContainer`** — это контейнер зависимостей, который управляет созданием и предоставлением сервисов и ViewModel. Он реализован как синглтон и предоставляет следующие методы:

- **`makeMineGenerator()`**: Возвращает сервис генерации мин.
- **`makeGameLogic()`**: Возвращает сервис игровой логики.
- **`makeTimerService()`**: Возвращает сервис таймера.
- **`makeGameStorage()`**: Возвращает сервис сохранения игр.
- **`makeScoreService()`**: Возвращает сервис результатов.
- **`makeGameSaveService()`**: Возвращает сервис сохранения состояния игры.
- **`makeGameRulesService()`**: Возвращает сервис правил игры.
- **`makeHapticFeedbackService()`**: Возвращает сервис тактильной обратной связи.
- **`makeLogger()`**: Возвращает сервис логирования.
- **`makeGameViewModel(difficulty:)`**: Создает GameViewModel с заданным уровнем сложности.
- **`makeGameViewModel(from:)`**: Создает GameViewModel из сохраненной игры.

## 🔧 Компоненты системы

### Models

#### `GameState`
Состояние игры: `notStarted`, `playing`, `won`, `lost`.

#### `CellModel`
Модель ячейки игрового поля с состоянием, координатами и информацией о минах.

#### `GameBoardModel`
Модель игрового поля, содержащая двумерный массив ячеек.

#### `Difficulty`
Уровни сложности: `beginner`, `intermediate`, `expert`.

#### `GameResult`
Модель результата игры для сохранения в SwiftData.

#### `SavedGame`
Модель сохранённой игры для продолжения после выхода.

### Services

#### `MineGeneratorService`
- генерация мин на поле;
- вычисление количества соседних мин;
- исключение первой кликнутой ячейки и её соседей.

#### `GameLogicService`
- открытие ячеек;
- flood fill алгоритм;
- проверка условия победы;
- открытие всех мин при поражении.

#### `TimerService`
- управление таймером игры;
- обновление времени каждую секунду.

#### `GameStorageService`
- сохранение состояния игры;
- загрузка сохранённой игры;
- удаление сохранений;
- проверка наличия активной игры.

#### `ScoreService`
- сохранение результатов игры;
- валидация имени игрока.

#### `GameSaveService`
- сохранение состояния игры;
- загрузка сохранённой игры.

#### `GameRulesService`
- управление правилами игры.

#### `HapticFeedbackService`
- тактильная обратная связь.

### Logging

#### `LogService` (protocol)
Протокол для сервиса логирования, позволяющий внедрять логирование через DI.

#### `AppLogger` (class)
Реализация `LogService`:
- использует OSLog для системного логирования;
- поддерживает уровни: `debug`, `info`, `warning`, `error`;
- автоматически определяет минимальный уровень в зависимости от build configuration;
- выводит логи в консоль в Debug режиме;
- поддерживает отключение логирования.

#### `LogLevel` (enum)
Уровни логирования с поддержкой сравнения и фильтрации.

Подробнее см. [LOGGING.md](LOGGING.md).

### ViewModels

#### `GameViewModel`
Основной ViewModel для управления игрой:
- координация между сервисами;
- управление состоянием игры;
- обработка действий пользователя;
- сохранение/загрузка игры.

**Зависимости:**
- `MineGeneratorProtocol`;
- `GameLogicProtocol`;
- `TimerServiceProtocol`;
- `GameStorageProtocol`;
- `ScoreServiceProtocol`;
- `LogService`.

### Views

#### `MainMenuView`
Главное меню с выбором сложности и продолжением игры.

#### `GameView`
Основной экран игры с полем и элементами управления.

#### `LeaderboardView`
Таблица лидеров с лучшими результатами.

#### `GridCellView`
Компонент отображения одной ячейки игрового поля.

#### `EmojiAnimationView`
Компонент для анимации эмодзи.

#### `GameRulesView`
Экран с правилами игры.

#### `DebugView`
Отладочный экран.

### UI Components

#### ViewModifiers
- `BackgroundGradientModifier`: стандартный фоновый градиент;
- `ShakeDetectionModifier`: обнаружение встряхивания устройства.

#### Buttons
- `PrimaryButton`: основная кнопка приложения;
- `SecondaryButton`: вторичная кнопка.

### Helpers

#### Utilities
- `IntFormatting`: форматирование времени;
- `StringValidation`: валидация и санитизация строк.

## 🔄 Потоки данных

### Начало новой игры

1. Пользователь выбирает сложность в `MainMenuView`.
2. Создаётся `GameViewModel` с выбранной сложностью.
3. Инициализируется пустое игровое поле.
4. При первом клике вызывается `MineGeneratorService` для размещения мин.

### Продолжение игры

1. `MainMenuView` проверяет наличие сохранённой игры через `GameStorageService`.
2. Если есть, создаётся `GameViewModel` из сохранённых данных.
3. Восстанавливается состояние поля и таймера.

### Игровой процесс

1. Пользователь кликает на ячейку.
2. `GameView` вызывает `viewModel.openCell(row:column:)`.
3. `GameViewModel` использует `GameLogicService` для обработки.
4. При необходимости вызывается `MineGeneratorService` (первый ход).
5. Проверяется условие победы через `GameLogicService`.
6. Обновляется UI через `@Observable` механизм SwiftUI.

### Сохранение игры

1. При выходе из `GameView` вызывается `viewModel.saveGame()`.
2. `GameViewModel` использует `GameStorageService` для сохранения.
3. Состояние сериализуется в JSON и сохраняется в SwiftData.

## 🧪 Тестирование

Проект подготовлен к unit-тестированию:

1. **Протоколы для DI**: все сервисы используют протоколы, что позволяет создавать моки;
2. **Чистые функции**: бизнес-логика вынесена в сервисы с чистыми функциями;
3. **Разделение ответственности**: каждый компонент тестируется изолированно.

### Пример тестирования

```swift
// Создание мок-сервисов
class MockMineGenerator: MineGeneratorProtocol {
    func placeMines(...) { ... }
    func calculateAdjacentMines(...) { ... }
}

class MockLogger: LogService {
    var loggedMessages: [String] = []
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        loggedMessages.append(message)
    }
}

// Тестирование ViewModel с моками
let mockLogger = MockLogger()
let viewModel = GameViewModel(
    difficulty: .beginner,
    mineGenerator: MockMineGenerator(),
    logger: mockLogger
)
```

## 🚀 Производительность

### Оптимизации SwiftUI

1. **@Observable**: используется вместо `@ObservableObject` для лучшей производительности;
2. **Локальные состояния**: минимизация перерисовок через правильное использование `@State`;
3. **LazyVStack/LazyHStack**: для больших полей (50×50) используется ленивая загрузка ячеек;
4. **Оптимизация Grid**: эффективная структура данных с предварительным выделением памяти.

### Оптимизации кода

1. **Избежание копий**: использование `inout` параметров где возможно;
2. **Ленивая инициализация**: сервисы создаются только при необходимости;
3. **Эффективные алгоритмы**:
   - flood fill использует итеративный подход вместо рекурсии;
   - генерация мин использует предварительный список доступных позиций вместо случайного выбора;
   - проверка условия победы оптимизирована для больших полей;
4. **Предварительное выделение памяти**: для больших массивов используется `reserveCapacity`;
5. **Оптимизация сериализации**: эффективная сериализация ячеек при сохранении игры.

## 📝 Соглашения о коде

### Именование

- **Типы**: PascalCase (`GameViewModel`, `MineGeneratorService`);
- **Переменные/функции**: camelCase (`gameState`, `openCell`);
- **Константы**: camelCase для локальных, UPPER_CASE для глобальных;
- **Протоколы**: заканчиваются на `Protocol` (`MineGeneratorProtocol`).

### Организация кода

- **MARK**: используются для разделения секций кода;
- **Документация**: все публичные методы документированы;
- **Приватность**: используется `private`/`fileprivate` где возможно.

### Swift 6 особенности

- использование современных возможностей языка;
- строгая типизация;
- избегание force unwrap где возможно;
- использование `guard` для раннего выхода.

## 🔮 Будущие улучшения

1. **Unit-тесты**: добавление полного набора unit-тестов;
2. **UI-тесты**: автоматизированное тестирование UI;
3. **Анимации**: улучшение анимаций и переходов;
4. **Доступность**: поддержка VoiceOver и других функций доступности;
5. **Локализация**: поддержка нескольких языков;
6. **Темы**: возможность выбора цветовой темы.

## 📚 Дополнительные ресурсы

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/);
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/);
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID).

---

## 📊 Система логирования

Проект использует полноценную систему логирования, построенную на протоколах и Dependency Injection:

- **LogService** (protocol) — протокол для логирования;
- **AppLogger** (class) — реализация с использованием OSLog;
- **LogLevel** (enum) — уровни логирования (debug, info, warning, error).

Все сервисы и ViewModels принимают `LogService` через инициализатор, что позволяет:
- легко тестировать с моками;
- заменять реализацию логирования;
- контролировать уровень логирования в зависимости от build configuration.

**Debug build**: логируются все уровни (debug, info, warning, error);
**Release build**: логируются только warning и error.

Подробнее см. [LOGGING.md](LOGGING.md).

---

**Версия документа**: 2.0;
**Дата обновления**: 03.12.2025.

