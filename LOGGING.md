# 📊 Система логирования MineGrid

## Обзор

MineGrid использует полноценную систему логирования, построенную на протоколах и Dependency Injection (DI). Это позволяет легко тестировать код и заменять реализацию логирования при необходимости.

## Архитектура

Система логирования состоит из трех основных компонентов:

### 1. `LogLevel` (enum)

Определяет уровни логирования:
- `debug` - Отладочная информация (только в Debug build)
- `info` - Информационные сообщения
- `warning` - Предупреждения
- `error` - Ошибки

### 2. `LogService` (protocol)

Протокол для сервиса логирования, который определяет интерфейс для логирования сообщений.

### 3. `AppLogger` (class)

Реализация `LogService`, которая:
- Использует OSLog для системного логирования
- Выводит логи в консоль в Debug режиме
- Поддерживает фильтрацию по уровням
- Автоматически определяет минимальный уровень в зависимости от build configuration

## Использование

### Базовое использование

```swift
let logger = AppLogger(category: "MyService")
logger.debug("Debug message")
logger.info("Info message")
logger.warning("Warning message")
logger.error("Error message")
```

### С объектом Error

```swift
do {
    try someOperation()
} catch {
    logger.error("Operation failed", error: error)
}
```

### Dependency Injection

Все сервисы и ViewModels принимают `LogService` через инициализатор:

```swift
final class MyService {
    private let logger: LogService
    
    init(logger: LogService = AppLogger(category: "MyService")) {
        self.logger = logger
    }
    
    func doSomething() {
        logger.info("Doing something")
    }
}
```

Это позволяет легко создавать моки для тестирования:

```swift
class MockLogger: LogService {
    var loggedMessages: [String] = []
    
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        loggedMessages.append(message)
    }
}

// В тестах
let mockLogger = MockLogger()
let service = MyService(logger: mockLogger)
```

## Формат логов

Формат строки лога:

```
[LEVEL] HH:mm:ss FileName.swift:LineNumber functionName() → Message
```

Примеры:

```
[DEBUG] 12:41:55 MineGenerator.swift:55 placeMines() → "Placing 40 mines on 10×10 board"
[INFO] 12:42:01 GameLogic.swift:120 openCell() → "Cell opened at (5, 3), adjacent mines: 2"
[ERROR] 12:45:02 GameViewModel.swift:180 openCell() → "Mine exploded at (7, 8)"
```

## Уровни логирования по Build Configuration

### Debug Build
- Минимальный уровень: `debug`
- Логируются все уровни: `debug`, `info`, `warning`, `error`
- Логи выводятся в консоль и в OSLog

### Release Build
- Минимальный уровень: `warning`
- Логируются только: `warning`, `error`
- Логи выводятся только в OSLog (не в консоль)

## Отключение логирования

Для полного отключения логирования:

```swift
let logger = AppLogger(category: "MyService")
logger.isLoggingEnabled = false
```

## Категории логов

Каждая категория логирования соответствует определенному модулю:

- `App` - Логи приложения (инициализация, запуск)
- `GameViewModel` - Логи ViewModel игры
- `GameLogic` - Логи игровой логики
- `MineGenerator` - Логи генерации мин
- `Timer` - Логи таймера
- `GameStorage` - Логи сохранения/загрузки игр
- `Score` - Логи работы с результатами
- `MainMenuView` - Логи главного меню
- `GameView` - Логи экрана игры

## Просмотр логов

### В Xcode Console

1. Запустите приложение в Xcode (⌘R)
2. Откройте консоль: **View → Debug Area → Activate Console** (⌘⇧Y)
3. В фильтре консоли введите категорию или часть сообщения

### В Instruments

1. Запустите **Instruments** (⌘I)
2. Выберите **Logging** template
3. Запустите приложение
4. Просматривайте логи в реальном времени

### В Console.app (macOS)

1. Откройте приложение **Console** на Mac
2. Подключите iOS устройство или выберите симулятор
3. Фильтруйте по `subsystem` или `category`

## Ключевые точки логирования

### Запуск приложения
- `MineGridApp initializing` - инициализация приложения
- `Creating ModelContainer` - создание контейнера данных
- `MainMenuView initializing` - инициализация главного меню

### Создание игры
- `Initializing GameViewModel with difficulty` - создание новой игры
- `Creating GameBoardModel` - создание игрового поля
- `GameView initializing` - инициализация экрана игры

### Генерация мин
- `Placing X mines on Y×Y board` - начало размещения мин
- `Successfully placed X mines` - успешное размещение
- `Calculating adjacent mines` - вычисление соседних мин

### Игровой процесс
- `Opening cell at (row, column)` - открытие ячейки
- `First move detected, placing mines` - первый ход
- `Cell opened at (row, column), adjacent mines: X` - ячейка открыта
- `Flood fill completed: opened X cells` - завершение flood fill

### Сохранение/загрузка
- `Saving game state` - сохранение игры
- `Loading saved game` - загрузка сохраненной игры
- `Loading cells from saved data` - загрузка ячеек

### Ошибки
- `Failed to load difficulty` - ошибка загрузки сложности
- `Failed to decode cells data` - ошибка декодирования
- `Mine exploded at (row, column)` - взрыв мины

## Рекомендации

1. **Используйте правильные уровни**: 
   - `debug` - для детальной отладочной информации
   - `info` - для важных событий
   - `warning` - для потенциальных проблем
   - `error` - для ошибок

2. **Логируйте ключевые события**:
   - Начало и конец важных операций
   - Изменения состояния
   - Ошибки и исключения
   - Метрики производительности

3. **Не логируйте слишком часто**:
   - Избегайте логирования в циклах с большим количеством итераций
   - Используйте `debug` уровень для детальной информации

4. **Используйте категории**:
   - Каждая категория помогает фильтровать логи
   - Используйте осмысленные названия категорий

## Примеры использования в коде

### В сервисах

```swift
final class MineGeneratorService: MineGeneratorProtocol {
    private let logger: LogService
    
    init(logger: LogService = AppLogger(category: "MineGenerator")) {
        self.logger = logger
    }
    
    func placeMines(...) {
        logger.info("Placing \(mineCount) mines")
        // ... код ...
        logger.info("Successfully placed \(mineCount) mines")
    }
}
```

### В ViewModels

```swift
@Observable
final class GameViewModel {
    private let logger: LogService
    
    init(..., logger: LogService = AppLogger(category: "GameViewModel")) {
        self.logger = logger
        logger.info("Initializing GameViewModel")
    }
    
    func openCell(row: Int, column: Int) {
        logger.debug("Opening cell at (\(row), \(column))")
        // ... код ...
    }
}
```

### В Views

```swift
struct GameView: View {
    private let logger: LogService
    
    init(viewModel: GameViewModel, logger: LogService = AppLogger(category: "GameView")) {
        self.logger = logger
        logger.debug("GameView initializing")
    }
}
```

---

**Версия документа**: 2.0  
**Дата обновления**: 03.12.2025
