migrate((app) => {
  const superusers = app.findCollectionByNameOrId("_superusers")
  let superuser = new Record(superusers)
  superuser.set("email", "admin@bescheki.local")
  superuser.set("password", "PocketAdmin!123")
  app.save(superuser)

  let users = app.findCollectionByNameOrId("users")
  users.listRule = '@request.auth.id != ""'
  users.viewRule = '@request.auth.id != ""'
  users.createRule = ""
  users.updateRule = '@request.auth.role = "admin" || id = @request.auth.id'
  users.deleteRule = '@request.auth.role = "admin"'
  users.fields.add(new SelectField({
    name: "role",
    required: true,
    values: ["buyer", "manager", "admin"],
    maxSelect: 1
  }))
  app.save(users)

  let categories = new Collection({
    type: "base",
    name: "categories",
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    updateRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    deleteRule: '@request.auth.role = "admin"',
    fields: [
      { type: "text", name: "name", required: true, max: 100, presentable: true },
      { type: "text", name: "description", max: 500 },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(categories)

  let brands = new Collection({
    type: "base",
    name: "brands",
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    updateRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    deleteRule: '@request.auth.role = "admin"',
    fields: [
      { type: "text", name: "name", required: true, max: 100, presentable: true },
      { type: "text", name: "country", required: true, max: 100 },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(brands)

  let suppliers = new Collection({
    type: "base",
    name: "suppliers",
    listRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    viewRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    createRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    updateRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    deleteRule: '@request.auth.role = "admin"',
    fields: [
      { type: "text", name: "name", required: true, max: 150, presentable: true },
      { type: "text", name: "phone", required: true, max: 30 },
      { type: "email", name: "email", required: true },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(suppliers)

  let products = new Collection({
    type: "base",
    name: "products",
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    updateRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    deleteRule: '@request.auth.role = "admin"',
    fields: [
      { type: "text", name: "name", required: true, max: 150, presentable: true },
      { type: "select", name: "hardness", required: true, values: ["Мягкая", "Средняя", "Жёсткая"], maxSelect: 1 },
      { type: "number", name: "price", required: true, min: 1 },
      { type: "number", name: "stock", required: true, min: 0 },
      { type: "relation", name: "category", required: true, maxSelect: 1, collectionId: categories.id },
      { type: "relation", name: "brand", required: true, maxSelect: 1, collectionId: brands.id },
      { type: "relation", name: "suppliers", maxSelect: 20, collectionId: suppliers.id },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(products)

  let orders = new Collection({
    type: "base",
    name: "orders",
    listRule: '@request.auth.role = "manager" || @request.auth.role = "admin" || user = @request.auth.id',
    viewRule: '@request.auth.role = "manager" || @request.auth.role = "admin" || user = @request.auth.id',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    deleteRule: '@request.auth.role = "admin"',
    fields: [
      { type: "relation", name: "user", required: true, maxSelect: 1, collectionId: users.id },
      { type: "text", name: "number", required: true, max: 40, presentable: true },
      { type: "select", name: "status", required: true, values: ["Новый", "В обработке", "Готов", "Выполнен", "Отменён"], maxSelect: 1 },
      { type: "number", name: "subtotal", required: true, min: 0 },
      { type: "number", name: "discount", min: 0 },
      { type: "number", name: "delivery", min: 0 },
      { type: "number", name: "total", required: true, min: 0 },
      { type: "bool", name: "deleted" }
    ],
    indexes: ["CREATE UNIQUE INDEX idx_orders_number ON orders (number)"]
  })
  app.save(orders)

  let orderItems = new Collection({
    type: "base",
    name: "order_items",
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.role = "manager" || @request.auth.role = "admin"',
    deleteRule: '@request.auth.role = "admin"',
    fields: [
      { type: "relation", name: "order", required: true, maxSelect: 1, collectionId: orders.id },
      { type: "relation", name: "product", required: true, maxSelect: 1, collectionId: products.id },
      { type: "number", name: "quantity", required: true, min: 1 },
      { type: "number", name: "price", required: true, min: 0 },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(orderItems)

  let carts = new Collection({
    type: "base",
    name: "carts",
    listRule: '@request.auth.role = "admin" || user = @request.auth.id',
    viewRule: '@request.auth.role = "admin" || user = @request.auth.id',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.role = "admin" || user = @request.auth.id',
    deleteRule: '@request.auth.role = "admin" || user = @request.auth.id',
    fields: [
      { type: "relation", name: "user", required: true, maxSelect: 1, collectionId: users.id },
      { type: "bool", name: "deleted" }
    ],
    indexes: ["CREATE UNIQUE INDEX idx_carts_user ON carts (user)"]
  })
  app.save(carts)

  let cartItems = new Collection({
    type: "base",
    name: "cart_items",
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.id != ""',
    deleteRule: '@request.auth.id != ""',
    fields: [
      { type: "relation", name: "cart", required: true, maxSelect: 1, collectionId: carts.id },
      { type: "relation", name: "product", required: true, maxSelect: 1, collectionId: products.id },
      { type: "number", name: "quantity", required: true, min: 1 },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(cartItems)

  let reviews = new Collection({
    type: "base",
    name: "reviews",
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.role = "admin" || user = @request.auth.id',
    deleteRule: '@request.auth.role = "admin" || user = @request.auth.id',
    fields: [
      { type: "relation", name: "user", required: true, maxSelect: 1, collectionId: users.id },
      { type: "relation", name: "product", required: true, maxSelect: 1, collectionId: products.id },
      { type: "number", name: "rating", required: true, min: 1, max: 5 },
      { type: "text", name: "text", required: true, max: 1000 },
      { type: "bool", name: "deleted" }
    ]
  })
  app.save(reviews)

  const createUser = (email, password, name, role) => {
    let record = new Record(users)
    record.set("email", email)
    record.set("emailVisibility", true)
    record.set("verified", true)
    record.set("password", password)
    record.set("name", name)
    record.set("role", role)
    app.save(record)
    return record
  }

  const create = (collection, values) => {
    let record = new Record(collection)
    for (const key in values) record.set(key, values[key])
    app.save(record)
    return record
  }

  const buyer = createUser("buyer@bescheki.local", "Buyer!123", "Иван Покупатель", "buyer")
  createUser("manager@bescheki.local", "Manager!123", "Мария Менеджер", "manager")
  createUser("admin@bescheki.local", "Admin!123", "Алиса Администратор", "admin")

  const manual = create(categories, { name: "Мануальные", description: "Классические зубные щётки", deleted: false })
  const electric = create(categories, { name: "Электрические", description: "Электрические зубные щётки", deleted: false })
  const kids = create(categories, { name: "Детские", description: "Щётки для детей", deleted: false })

  const oralb = create(brands, { name: "Oral-B", country: "США", deleted: false })
  const splat = create(brands, { name: "Splat", country: "Россия", deleted: false })
  const curaprox = create(brands, { name: "Curaprox", country: "Швейцария", deleted: false })

  const supplier1 = create(suppliers, { name: "ООО ЩёткаОпт", phone: "+7 999 111-22-33", email: "opt@bescheki.local", deleted: false })
  const supplier2 = create(suppliers, { name: "ООО Чистые зубы", phone: "+7 999 222-33-44", email: "clean@bescheki.local", deleted: false })

  const product1 = create(products, { name: "Oral-B Pro Clean", hardness: "Средняя", price: 299, stock: 45, category: manual.id, brand: oralb.id, suppliers: [supplier1.id], deleted: false })
  const product2 = create(products, { name: "Splat Junior", hardness: "Мягкая", price: 189, stock: 25, category: kids.id, brand: splat.id, suppliers: [supplier1.id, supplier2.id], deleted: false })
  const product3 = create(products, { name: "Curaprox CS 5460", hardness: "Мягкая", price: 799, stock: 16, category: manual.id, brand: curaprox.id, suppliers: [supplier2.id], deleted: false })
  create(products, { name: "Oral-B Vitality", hardness: "Средняя", price: 2499, stock: 9, category: electric.id, brand: oralb.id, suppliers: [supplier1.id], deleted: false })
  create(products, { name: "Splat Professional", hardness: "Жёсткая", price: 359, stock: 18, category: manual.id, brand: splat.id, suppliers: [supplier2.id], deleted: false })

  const cart = create(carts, { user: buyer.id, deleted: false })
  create(cartItems, { cart: cart.id, product: product2.id, quantity: 1, deleted: false })

  const order = create(orders, { user: buyer.id, number: "BS-1001", status: "В обработке", subtotal: 1098, discount: 0, delivery: 0, total: 1098, deleted: false })
  create(orderItems, { order: order.id, product: product1.id, quantity: 1, price: 299, deleted: false })
  create(orderItems, { order: order.id, product: product3.id, quantity: 1, price: 799, deleted: false })

  create(reviews, { user: buyer.id, product: product1.id, rating: 5, text: "Удобная щётка, щетина средней жёсткости.", deleted: false })
}, (app) => {
  const names = ["reviews", "cart_items", "carts", "order_items", "orders", "products", "suppliers", "brands", "categories"]
  for (const name of names) {
    try {
      const collection = app.findCollectionByNameOrId(name)
      app.delete(collection)
    } catch (_) {}
  }
  try {
    const users = app.findCollectionByNameOrId("users")
    users.fields.removeByName("role")
    app.save(users)
  } catch (_) {}
  try {
    const record = app.findAuthRecordByEmail("_superusers", "admin@bescheki.local")
    app.delete(record)
  } catch (_) {}
})
