# ЗАО «Бе щеки»

Итоговый проект на Flutter Web для магазина зубных щёток.

## Что есть

- PocketBase REST API
- регистрация и вход
- роли buyer, manager, admin
- защищённые маршруты
- 10 связанных сущностей
- CRUD
- логическое и физическое удаление
- серверные поиск, фильтрация, сортировка и пагинация
- адаптивный интерфейс 360–1920 px
- корзина и оформление заказа
- расчёт скидки и доставки
- подбор зубной щётки
- статистика
- 5 widget-тестов и 12 unit-тестов

## Запуск PocketBase

Скачайте PocketBase с официальной страницы релизов и положите исполняемый файл в папку `pocketbase`.

Windows:

```powershell
cd pocketbase
.\pocketbase.exe serve
```

Панель администратора:

```text
http://127.0.0.1:8090/_/
```

Коллекции и правила находятся в `pocketbase/schema.md`.

## Запуск Flutter

```powershell
flutter pub get --offline
flutter run -d chrome --web-port=5555 --dart-define=API_BASE_URL=http://127.0.0.1:8090
```

Если `--offline` не находит пакет:

```powershell
flutter pub get
```

## Проверка

```powershell
flutter analyze
flutter test
```

## Учётные записи

После создания коллекции users создайте три записи:

```text
buyer@bescheki.local / Buyer!123
manager@bescheki.local / Manager!123
admin@bescheki.local / Admin!123
```

В поле `role` укажите соответственно `buyer`, `manager`, `admin`.
