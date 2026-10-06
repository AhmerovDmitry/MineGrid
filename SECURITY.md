# Security

## Данные

Приложение не имеет сетевого кода и сторонних SDK. SwiftData локально хранит состояние игры, имя игрока и результаты. Внешней передачи нет. Имя очищается от control characters, обрезается до 32 графем и не пишется в ScoreService log.

Snapshot SwiftData считается недоверенным вводом: metadata, payload, coordinates, enums и counters валидируются до индексации массива.

## Сообщение о проблеме

Не публикуйте exploit до исправления. Создайте private security advisory в хостинге репозитория и укажите версию, шаги воспроизведения, impact и proof of concept.

## Release review

Перед App Store archive проверить Privacy Report, required-reason API, entitlement/permissions, Release-логи и схему миграции SwiftData. Сейчас `PrivacyInfo.xcprivacy` отсутствует; directly-used required-reason API в аудите не найдены.
