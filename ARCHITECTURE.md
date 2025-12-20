# Архитектура проекта MineGrid

## 📋 Обзор

MineGrid — это iOS-приложение-сапёр, разработанное с использованием SwiftUI и Swift 6. Проект следует принципам **MVVM (Model-View-ViewModel)** архитектуры с разделением на слои и использованием Dependency Injection (DI) для улучшения тестируемости и поддерживаемости кода.

## 🏗 Структура проекта

```
MineGrid/
├── Models/              # Модели данных
├── ViewModels/          # ViewModels для бизнес-логики
├── Views/               # SwiftUI Views
├── Services/            # Бизнес-логика и сервисы
│   ├── Protocols/      # Протоколы для DI
│   └── [Services]      # Реализации сервисов
├── Logging/             # Система логирования
│   ├── LogLevel.swift  # Уровни логирования
│   ├── LogService.swift # Протокол логирования
│   └── AppLogger.swift # Реализация логгера
├── UI Components/       # Переиспользуемые UI компоненты
│   ├── Buttons/        # Кнопки
│   └── ViewModifiers/  # Модификаторы представлений
└── Helpers/            # Вспомогательные утилиты
    └── Extensions/     # Расширения для типов
```

## 📐 Архитектурные принципы

### 1. MVVM (Model-View-ViewModel)

- **Models**: Чистые структуры данных без бизнес-логики
- **Views**: Только UI, без логики (SwiftUI Views)
- **ViewModels**: Управление состоянием и координация между Views и Services
- **Services**: Вся бизнес-логика вынесена в отдельные сервисы

### 2. Dependency Injection (DI)

Все сервисы используют протоколы для возможности замены реализаций:

```swift
protocol MineGeneratorProtocol { ... }
protocol GameLogicProtocol { ... }
protocol TimerServiceProtocol { ... }
protocol GameStorageProtocol { ... }
protocol ScoreServiceProtocol { ... }
protocol LogService { ... }
```

Это позволяет:
- Легко тестировать компоненты с моками
- Заменять реализации без изменения ViewModels
- Следовать принципу Dependency Inversion (SOLID)
- Внедрять логирование через DI во все компоненты

### 3. SOLID принципы

- **Single Responsibility**: Каждый класс/структура имеет одну ответственность
- **Open/Closed**: Открыт для расширения через протоколы, закрыт для модификации
- **Liskov Substitution**: Протоколы позволяют заменять реализации
- **Interface Segregation**: Протоколы разделены по функциональности
- **Dependency Inversion**: Зависимости от абстракций (протоколов), а не от конкретных реализаций

## 🔧 Компоненты системы

### Models

#### `GameState`
Состояние игры: `notStarted`, `playing`, `won`, `lost`

#### `CellModel`
Модель ячейки игрового поля с состоянием, координатами и информацией о минах

#### `GameBoardModel`
Модель игрового поля, содержащая двумерный массив ячеек

#### `Difficulty`
Уровни сложности: `beginner`, `intermediate`, `expert`

#### `GameResult`
Модель результата игры для сохранения в SwiftData

#### `SavedGame`
Модель сохраненной игры для продолжения после выхода

### Services

#### `MineGeneratorService`
- Генерация мин на поле
- Вычисление количества соседних мин
- Исключение первой кликнутой ячейки и её соседей

#### `GameLogicService`
- Открытие ячеек
- Flood fill алгоритм
- Проверка условия победы
- Открытие всех мин при поражении

#### `TimerService`
- Управление таймером игры
- Обновление времени каждую секунду

#### `GameStorageService`
- Сохранение состояния игры
- Загрузка сохраненной игры
- Удаление сохранений
- Проверка наличия активной игры

#### `ScoreService`
- Сохранение результатов игры
- Валидация имени игрока

### Logging

#### `LogService` (protocol)
Протокол для сервиса логирования, позволяющий внедрять логирование через DI.

#### `AppLogger` (class)
Реализация `LogService`:
- Использует OSLog для системного логирования
- Поддерживает уровни: `debug`, `info`, `warning`, `error`
- Автоматически определяет минимальный уровень в зависимости от build configuration
- Выводит логи в консоль в Debug режиме
- Поддерживает отключение логирования

#### `LogLevel` (enum)
Уровни логирования с поддержкой сравнения и фильтрации.

Подробнее см. [LOGGING.md](LOGGING.md)

### ViewModels

#### `GameViewModel`
Основной ViewModel для управления игрой:
- Координация между сервисами
- Управление состоянием игры
- Обработка действий пользователя
- Сохранение/загрузка игры

**Зависимости:**
- `MineGeneratorProtocol`
- `GameLogicProtocol`
- `TimerServiceProtocol`
- `GameStorageProtocol`
- `ScoreServiceProtocol`
- `LogService`

### Views

#### `MainMenuView`
Главное меню с выбором сложности и продолжением игры

#### `GameView`
Основной экран игры с полем и элементами управления

#### `LeaderboardView`
Таблица лидеров с лучшими результатами

#### `GridCellView`
Компонент отображения одной ячейки игрового поля

### UI Components

#### ViewModifiers
- `BackgroundGradientModifier`: Стандартный фоновый градиент
- `GlassCardModifier`: Стеклянный эффект для карточек

#### Buttons
- `PrimaryButton`: Основная кнопка приложения
- `SecondaryButton`: Вторичная кнопка

### Helpers

#### Extensions
- `Int+Formatting`: Форматирование времени
- `String+Validation`: Валидация и санитизация строк

## 🔄 Потоки данных

### Начало новой игры

1. Пользователь выбирает сложность в `MainMenuView`
2. Создается `GameViewModel` с выбранной сложностью
3. Инициализируется пустое игровое поле
4. При первом клике вызывается `MineGeneratorService` для размещения мин

### Продолжение игры

1. `MainMenuView` проверяет наличие сохраненной игры через `GameStorageService`
2. Если есть, создается `GameViewModel` из сохраненных данных
3. Восстанавливается состояние поля и таймера

### Игровой процесс

1. Пользователь кликает на ячейку
2. `GameView` вызывает `viewModel.openCell(row:column:)`
3. `GameViewModel` использует `GameLogicService` для обработки
4. При необходимости вызывается `MineGeneratorService` (первый ход)
5. Проверяется условие победы через `GameLogicService`
6. Обновляется UI через `@Observable` механизм SwiftUI

### Сохранение игры

1. При выходе из `GameView` вызывается `viewModel.saveGame()`
2. `GameViewModel` использует `GameStorageService` для сохранения
3. Состояние сериализуется в JSON и сохраняется в SwiftData

## 🧪 Тестирование

Проект подготовлен к unit-тестированию:

1. **Протоколы для DI**: Все сервисы используют протоколы, что позволяет создавать моки
2. **Чистые функции**: Бизнес-логика вынесена в сервисы с чистыми функциями
3. **Разделение ответственности**: Каждый компонент тестируется изолированно

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

1. **@Observable**: Используется вместо `@ObservableObject` для лучшей производительности
2. **Локальные состояния**: Минимизация перерисовок через правильное использование `@State`
3. **LazyVStack/LazyHStack**: Для больших полей (50×50) используется ленивая загрузка ячеек
4. **Оптимизация Grid**: Эффективная структура данных с предварительным выделением памяти

### Оптимизации кода

1. **Избежание копий**: Использование `inout` параметров где возможно
2. **Ленивая инициализация**: Сервисы создаются только при необходимости
3. **Эффективные алгоритмы**: 
   - Flood fill использует итеративный подход вместо рекурсии
   - Генерация мин использует предварительный список доступных позиций вместо случайного выбора
   - Проверка условия победы оптимизирована для больших полей
4. **Предварительное выделение памяти**: Для больших массивов используется `reserveCapacity`
5. **Оптимизация сериализации**: Эффективная сериализация ячеек при сохранении игры

## 📝 Соглашения о коде

### Именование

- **Типы**: PascalCase (`GameViewModel`, `MineGeneratorService`)
- **Переменные/функции**: camelCase (`gameState`, `openCell`)
- **Константы**: camelCase для локальных, UPPER_CASE для глобальных
- **Протоколы**: Заканчиваются на `Protocol` (`MineGeneratorProtocol`)

### Организация кода

- **MARK**: Используются для разделения секций кода
- **Документация**: Все публичные методы документированы
- **Приватность**: Используется `private`/`fileprivate` где возможно

### Swift 6 особенности

- Использование современных возможностей языка
- Строгая типизация
- Избежание force unwrap где возможно
- Использование `guard` для раннего выхода

## 🔮 Будущие улучшения

1. **Unit-тесты**: Добавление полного набора unit-тестов
2. **UI-тесты**: Автоматизированное тестирование UI
3. **Анимации**: Улучшение анимаций и переходов
4. **Доступность**: Поддержка VoiceOver и других функций доступности
5. **Локализация**: Поддержка нескольких языков
6. **Темы**: Возможность выбора цветовой темы

## 📚 Дополнительные ресурсы

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

---

## 📊 Система логирования

Проект использует полноценную систему логирования, построенную на протоколах и Dependency Injection:

- **LogService** (protocol) - протокол для логирования
- **AppLogger** (class) - реализация с использованием OSLog
- **LogLevel** (enum) - уровни логирования (debug, info, warning, error)

Все сервисы и ViewModels принимают `LogService` через инициализатор, что позволяет:
- Легко тестировать с моками
- Заменять реализацию логирования
- Контролировать уровень логирования в зависимости от build configuration

**Debug build**: логируются все уровни (debug, info, warning, error)  
**Release build**: логируются только warning и error

Подробнее см. [LOGGING.md](LOGGING.md)

---

**Версия документа**: 2.0  
**Дата обновления**: 03.12.2025

