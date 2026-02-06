/* SQL Server schema for modular marketplace eCommerce */
CREATE TABLE roles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    role_id INT NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(150) NOT NULL,
    phone NVARCHAR(30) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_users_roles FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE sellers (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    store_name NVARCHAR(150) NOT NULL,
    tax_number NVARCHAR(50) NOT NULL,
    verification_status NVARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_sellers_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    parent_id INT NULL,
    name NVARCHAR(100) NOT NULL,
    slug NVARCHAR(120) NOT NULL UNIQUE,
    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id)
);

CREATE TABLE products (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    seller_id BIGINT NOT NULL,
    category_id INT NOT NULL,
    sku NVARCHAR(50) NOT NULL UNIQUE,
    name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    stock INT NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'draft',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_products_seller FOREIGN KEY (seller_id) REFERENCES sellers(id),
    CONSTRAINT FK_products_category FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE orders (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_no NVARCHAR(30) NOT NULL UNIQUE,
    status NVARCHAR(30) NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(12,2) NOT NULL,
    discount_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    shipping_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    grand_total DECIMAL(12,2) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_orders_customer FOREIGN KEY (customer_id) REFERENCES users(id)
);

CREATE TABLE order_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    seller_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT FK_order_items_seller FOREIGN KEY (seller_id) REFERENCES sellers(id)
);

CREATE TABLE refresh_tokens (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash NVARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME2 NOT NULL,
    revoked_at DATETIME2 NULL,
    CONSTRAINT FK_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX IX_users_email_active ON users(email, is_active);
CREATE INDEX IX_products_seller_status ON products(seller_id, status) INCLUDE (price, stock);
CREATE INDEX IX_products_category_status ON products(category_id, status);
CREATE INDEX IX_orders_customer_created ON orders(customer_id, created_at DESC);
CREATE INDEX IX_order_items_order ON order_items(order_id);

INSERT INTO roles(name) VALUES ('admin'), ('seller'), ('customer');
