import '../models/entity_config.dart';

const categoriesConfig = EntityConfig(
  collection: 'categories',
  title: 'Категории',
  singular: 'категорию',
  listFields: ['name', 'description'],
  fields: [
    FieldSpec(name: 'name', label: 'Название', requiredField: true, searchable: true),
    FieldSpec(name: 'description', label: 'Описание', kind: FieldKind.multiline, searchable: true),
  ],
);

const brandsConfig = EntityConfig(
  collection: 'brands',
  title: 'Бренды',
  singular: 'бренд',
  listFields: ['name', 'country'],
  fields: [
    FieldSpec(name: 'name', label: 'Название', requiredField: true, searchable: true),
    FieldSpec(name: 'country', label: 'Страна', requiredField: true, searchable: true),
  ],
);

const suppliersConfig = EntityConfig(
  collection: 'suppliers',
  title: 'Поставщики',
  singular: 'поставщика',
  listFields: ['name', 'phone', 'email'],
  fields: [
    FieldSpec(name: 'name', label: 'Название', requiredField: true, searchable: true),
    FieldSpec(name: 'phone', label: 'Телефон', requiredField: true),
    FieldSpec(name: 'email', label: 'E-mail', kind: FieldKind.email, requiredField: true, searchable: true),
  ],
);

const productsConfig = EntityConfig(
  collection: 'products',
  title: 'Товары',
  singular: 'товар',
  listFields: ['name', 'hardness', 'price', 'stock'],
  fields: [
    FieldSpec(name: 'name', label: 'Название', requiredField: true, searchable: true),
    FieldSpec(
      name: 'hardness',
      label: 'Жёсткость',
      kind: FieldKind.select,
      requiredField: true,
      options: ['Мягкая', 'Средняя', 'Жёсткая'],
    ),
    FieldSpec(name: 'price', label: 'Цена', kind: FieldKind.number, requiredField: true, min: 1),
    FieldSpec(name: 'stock', label: 'Остаток', kind: FieldKind.number, requiredField: true, min: 0),
    FieldSpec(
      name: 'category',
      label: 'Категория',
      kind: FieldKind.relation,
      requiredField: true,
      relationCollection: 'categories',
    ),
    FieldSpec(
      name: 'brand',
      label: 'Бренд',
      kind: FieldKind.relation,
      requiredField: true,
      relationCollection: 'brands',
    ),
    FieldSpec(
      name: 'suppliers',
      label: 'Поставщики',
      kind: FieldKind.relation,
      relationCollection: 'suppliers',
      multiple: true,
    ),
  ],
);

const ordersConfig = EntityConfig(
  collection: 'orders',
  title: 'Заказы',
  singular: 'заказ',
  listFields: ['number', 'status', 'total'],
  fields: [
    FieldSpec(name: 'number', label: 'Номер', requiredField: true, searchable: true),
    FieldSpec(
      name: 'user',
      label: 'Покупатель',
      kind: FieldKind.relation,
      requiredField: true,
      relationCollection: 'users',
    ),
    FieldSpec(
      name: 'status',
      label: 'Статус',
      kind: FieldKind.select,
      requiredField: true,
      options: ['Новый', 'В обработке', 'Готов', 'Выполнен', 'Отменён'],
    ),
    FieldSpec(name: 'subtotal', label: 'Сумма без скидки', kind: FieldKind.number, requiredField: true, min: 0),
    FieldSpec(name: 'discount', label: 'Скидка', kind: FieldKind.number, requiredField: true, min: 0),
    FieldSpec(name: 'delivery', label: 'Доставка', kind: FieldKind.number, requiredField: true, min: 0),
    FieldSpec(name: 'total', label: 'Итого', kind: FieldKind.number, requiredField: true, min: 0),
  ],
);

const orderItemsConfig = EntityConfig(
  collection: 'order_items',
  title: 'Позиции заказов',
  singular: 'позицию',
  listFields: ['order', 'product', 'quantity', 'price'],
  fields: [
    FieldSpec(name: 'order', label: 'Заказ', kind: FieldKind.relation, requiredField: true, relationCollection: 'orders'),
    FieldSpec(name: 'product', label: 'Товар', kind: FieldKind.relation, requiredField: true, relationCollection: 'products'),
    FieldSpec(name: 'quantity', label: 'Количество', kind: FieldKind.number, requiredField: true, min: 1),
    FieldSpec(name: 'price', label: 'Цена', kind: FieldKind.number, requiredField: true, min: 0),
  ],
);

const cartsConfig = EntityConfig(
  collection: 'carts',
  title: 'Корзины',
  singular: 'корзину',
  listFields: ['user'],
  fields: [
    FieldSpec(name: 'user', label: 'Пользователь', kind: FieldKind.relation, requiredField: true, relationCollection: 'users'),
  ],
);

const cartItemsConfig = EntityConfig(
  collection: 'cart_items',
  title: 'Позиции корзин',
  singular: 'позицию',
  listFields: ['cart', 'product', 'quantity'],
  fields: [
    FieldSpec(name: 'cart', label: 'Корзина', kind: FieldKind.relation, requiredField: true, relationCollection: 'carts'),
    FieldSpec(name: 'product', label: 'Товар', kind: FieldKind.relation, requiredField: true, relationCollection: 'products'),
    FieldSpec(name: 'quantity', label: 'Количество', kind: FieldKind.number, requiredField: true, min: 1),
  ],
);

const reviewsConfig = EntityConfig(
  collection: 'reviews',
  title: 'Отзывы',
  singular: 'отзыв',
  listFields: ['product', 'rating', 'text'],
  fields: [
    FieldSpec(name: 'user', label: 'Пользователь', kind: FieldKind.relation, requiredField: true, relationCollection: 'users'),
    FieldSpec(name: 'product', label: 'Товар', kind: FieldKind.relation, requiredField: true, relationCollection: 'products'),
    FieldSpec(name: 'rating', label: 'Оценка', kind: FieldKind.number, requiredField: true, min: 1, max: 5),
    FieldSpec(name: 'text', label: 'Текст', kind: FieldKind.multiline, requiredField: true, searchable: true),
  ],
);

const allEntityConfigs = [
  categoriesConfig,
  brandsConfig,
  suppliersConfig,
  productsConfig,
  ordersConfig,
  orderItemsConfig,
  cartsConfig,
  cartItemsConfig,
  reviewsConfig,
];
