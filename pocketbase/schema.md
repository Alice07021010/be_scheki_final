# Схема PocketBase

## users

Тип: Auth collection.

Дополнительные поля:

| Поле | Тип | Настройка |
|---|---|---|
| name | text | required, max 100 |
| role | select | required, buyer / manager / admin |

Правила:

```text
List/View: @request.auth.id != ""
Create: пустая строка
Update: @request.auth.role = "admin" || id = @request.auth.id
Delete: @request.auth.role = "admin"
```

## categories

| Поле | Тип |
|---|---|
| name | text required |
| description | text |
| deleted | bool |

List/View:

```text
@request.auth.id != ""
```

Create/Update/Delete:

```text
@request.auth.role = "manager" || @request.auth.role = "admin"
```

## brands

| Поле | Тип |
|---|---|
| name | text required |
| country | text required |
| deleted | bool |

Правила такие же, как у categories.

## suppliers

| Поле | Тип |
|---|---|
| name | text required |
| phone | text required |
| email | email required |
| deleted | bool |

List/View/Create/Update/Delete:

```text
@request.auth.role = "manager" || @request.auth.role = "admin"
```

## products

| Поле | Тип | Настройка |
|---|---|---|
| name | text | required |
| hardness | select | Мягкая / Средняя / Жёсткая |
| price | number | min 1 |
| stock | number | min 0 |
| category | relation | categories, max 1, required |
| brand | relation | brands, max 1, required |
| suppliers | relation | suppliers, multiple |
| deleted | bool | |

List/View:

```text
@request.auth.id != ""
```

Create/Update/Delete:

```text
@request.auth.role = "manager" || @request.auth.role = "admin"
```

## orders

| Поле | Тип | Настройка |
|---|---|---|
| user | relation | users, max 1, required |
| number | text | required, unique |
| status | select | Новый / В обработке / Готов / Выполнен / Отменён |
| subtotal | number | min 0 |
| discount | number | min 0 |
| delivery | number | min 0 |
| total | number | min 0 |
| deleted | bool | |

List/View:

```text
@request.auth.role = "manager" || @request.auth.role = "admin" || user = @request.auth.id
```

Create:

```text
@request.auth.id != ""
```

Update/Delete:

```text
@request.auth.role = "manager" || @request.auth.role = "admin"
```

## order_items

| Поле | Тип |
|---|---|
| order | relation orders required max 1 |
| product | relation products required max 1 |
| quantity | number min 1 |
| price | number min 0 |
| deleted | bool |

List/View/Create:

```text
@request.auth.id != ""
```

Update/Delete:

```text
@request.auth.role = "manager" || @request.auth.role = "admin"
```

## carts

| Поле | Тип | Настройка |
|---|---|---|
| user | relation | users, max 1, required, unique |
| deleted | bool | |

List/View/Create/Update/Delete:

```text
@request.auth.role = "admin" || user = @request.auth.id
```

## cart_items

| Поле | Тип |
|---|---|
| cart | relation carts required max 1 |
| product | relation products required max 1 |
| quantity | number min 1 |
| deleted | bool |

Для учебного проекта можно поставить:

```text
@request.auth.id != ""
```

на List/View/Create/Update/Delete.

## reviews

| Поле | Тип |
|---|---|
| user | relation users required max 1 |
| product | relation products required max 1 |
| rating | number min 1 max 5 |
| text | text required max 1000 |
| deleted | bool |

List/View:

```text
@request.auth.id != ""
```

Create:

```text
user = @request.auth.id
```

Update/Delete:

```text
@request.auth.role = "admin" || user = @request.auth.id
```

## Связи

```text
users 1:1 carts
users 1:N orders
users 1:N reviews
categories 1:N products
brands 1:N products
products M:N suppliers
orders 1:N order_items
products 1:N order_items
carts 1:N cart_items
products 1:N cart_items
products 1:N reviews
```

## Тестовые данные

Категории:

```text
Мануальные
Электрические
Детские
```

Бренды:

```text
Oral-B / США
Splat / Россия
Curaprox / Швейцария
```

Поставщики:

```text
ООО ЩёткаОпт / +7 999 111-22-33 / opt@bescheki.local
ООО Чистые зубы / +7 999 222-33-44 / clean@bescheki.local
```

Товары:

```text
Oral-B Pro Clean / Средняя / 299 / 45
Splat Junior / Мягкая / 189 / 25
Curaprox CS 5460 / Мягкая / 799 / 16
Oral-B Vitality / Средняя / 2499 / 9
```
