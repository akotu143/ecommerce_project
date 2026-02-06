# Advanced eCommerce Blueprint (Angular + FastAPI + SQL Server)

## 1) Best project type for learning + resume value
**Recommended:** **Multi-vendor marketplace (B2C)** with admin back-office.

### Why this is the best choice
1. Demonstrates broad architecture depth (customer, seller, admin personas).
2. Covers real-world complexity recruiters value: onboarding, catalog moderation, order split by seller, payouts, commissions.
3. Naturally introduces domain-driven modular design and role-based authorization.
4. Scales from MVP to enterprise features without rewriting core modules.
5. Strong portfolio narrative: “Built production-ready marketplace with JWT auth, SQL Server optimization, and Angular modular frontend.”

---

## 2) Project phases

### Phase 1 — MVP
- Goal: Ship a working marketplace with secure auth, product browsing, cart, checkout, and basic admin.

### Phase 2 — Intermediate
- Goal: Add seller operations, promotions, order tracking, and observability.

### Phase 3 — Advanced / Enterprise
- Goal: Introduce event-driven workflows, advanced search, multi-region readiness, and security hardening.

---

## 3) Phase-by-phase breakdown

## Phase 1 (MVP)
### Features
- **Customer:** register/login, browse products by category, add to cart, place order, view order history.
- **Seller:** submit products, update stock/price.
- **Admin:** approve sellers/products, manage categories, view orders/users.

### APIs
- `POST /auth/register` — create account.
- `POST /auth/login` — issue access/refresh JWT.
- `POST /auth/refresh` — rotate access token.
- `GET /products` — list active products with filters.
- `GET /products/{id}` — product details.
- `POST /products` — seller creates product.
- `PATCH /products/{id}` — seller/admin updates product.
- `POST /cart/items` — add/update item.
- `GET /cart` — fetch current cart.
- `POST /orders` — checkout cart.
- `GET /orders/me` — customer order history.

### Core DB tables
- `users` (role-bound identity)
- `sellers` (seller profile)
- `categories` (hierarchy)
- `products` (catalog)
- `carts`, `cart_items`
- `orders`, `order_items`
- `refresh_tokens`

Relationships:
- `users 1-1 sellers`
- `sellers 1-N products`
- `categories 1-N products`
- `users 1-N orders`
- `orders 1-N order_items`

### Angular pages/components
- Public: home, product list, product detail, login/register.
- Customer: cart, checkout, order history.
- Seller: product CRUD, inventory panel.
- Admin: dashboard, approvals, category management.

---

## Phase 2 (Intermediate)
### Features
- **Customer:** coupon support, order tracking timeline, reviews/ratings.
- **Seller:** sales analytics, bulk upload, shipment updates.
- **Admin:** commission rules, fraud review, refund workflows.

### APIs
- `POST /coupons/validate`
- `POST /reviews`
- `GET /seller/analytics`
- `POST /shipments`
- `POST /refunds`

### DB additions
- `coupons`, `coupon_redemptions`
- `reviews`
- `shipments`
- `refunds`
- `audit_logs`

### Angular additions
- reusable analytics widgets, review components, timeline component, admin refund queue.

---

## Phase 3 (Advanced/Enterprise)
### Features
- **Customer:** recommendations, wishlists, saved payments.
- **Seller:** dynamic pricing assistants, campaign manager.
- **Admin:** policy engine, SIEM audit export, business intelligence dashboards.

### APIs
- `GET /recommendations/me`
- `POST /wishlists/items`
- `POST /campaigns`
- `GET /admin/kpis`

### DB additions
- `wishlists`, `wishlist_items`
- `recommendation_events`
- `campaigns`, `campaign_targets`
- `security_events`

### Angular additions
- micro-frontend-friendly shell, feature flags, experimentation dashboards.

---

## 4) FastAPI backend guide

## Suggested folder structure
```text
backend/
  app/
    api/
      dependencies.py
      v1/
        auth.py
        products.py
    core/
      settings.py
      security.py
      logging.py
    db/
      base.py
      session.py
    modules/
      auth/
      catalog/
      orders/
    repositories/
    services/
    main.py
  tests/
  requirements.txt
  .env.example
```

## Environment setup
```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --port 8000
```

## SQL Server via SQLAlchemy
- Engine URL uses `mssql+pyodbc` and ODBC Driver 18.
- Keep credentials in `.env`; never hard-code secrets.

## Clean layers
- **Models:** ORM entities.
- **Schemas:** Pydantic validation contracts.
- **Repositories:** DB access boundaries.
- **Services:** business logic + transactions.
- **Routers:** transport layer only.

## JWT + RBAC
- access token (short TTL), refresh token (long TTL).
- role claim in access token + DB lookup in dependency.
- `require_roles('admin', 'seller')` guard for sensitive endpoints.

## Error handling/logging
- Raise `HTTPException` with domain-safe messages.
- Use structured logs (`structlog`) and correlation IDs.
- Add global exception handler for unexpected errors.

---

## 5) SQL Server design summary
- Use `BIGINT IDENTITY` for high-growth tables.
- Use `NVARCHAR` for multilingual data.
- Money fields: `DECIMAL(12,2)` (not floating types).
- Add covering indexes for product browse and order timeline queries.
- See `database/sqlserver/schema.sql` for a full starter script.

---

## 6) Angular guide

## Setup
```bash
npm install -g @angular/cli
ng new frontend --routing --style=scss
cd frontend
npm install
ng serve -o
```

## Structure
```text
src/app/
  core/
    guards/
    interceptors/
    services/
    state/
  features/
    auth/
    shop/
    admin/
    seller/
  shared/
  app.routes.ts
```

## Routing
- public: `/`, `/auth/login`, `/products/:id`
- protected: `/admin/**`, `/seller/**`, `/account/**`

## API integration
- central `ApiService` wraps `HttpClient`.
- `AuthInterceptor` appends bearer token.
- `AuthGuard` blocks protected routes.

## State management
- MVP: RxJS service-store pattern.
- Scale: NgRx (auth, cart, catalog, checkout, orders slices).

---

## 7) End-to-end request flow
1. Angular login form posts credentials to `/auth/login`.
2. FastAPI validates credentials (hashed password compare).
3. FastAPI returns access + refresh tokens.
4. Angular stores tokens and sends access token in `Authorization` header.
5. Protected API call arrives; dependency decodes JWT and checks role.
6. Service executes business logic via repository.
7. Repository runs SQL via SQLAlchemy to SQL Server.
8. Response mapped to schema and returned to Angular.

Refresh flow:
- On access token expiry, frontend calls `/auth/refresh` with refresh token; backend verifies/rotates and returns a new access token.

---

## 8) Security best practices
- Password hashing: `passlib[bcrypt]`.
- Rotate refresh tokens and store hashed token server-side.
- Input validation: Pydantic + Angular reactive forms.
- CORS: explicit allow-list by environment.
- Secrets/config: environment variables and secret manager.
- SQL injection defense: SQLAlchemy ORM + bound params.

---

## 9) Deployment guidance

## Backend
- Containerize FastAPI + Uvicorn/Gunicorn.
- Deploy to Azure App Service, AKS, ECS/Fargate, or VM.
- Add reverse proxy (Nginx), HTTPS, health probes.

## Frontend
- Build with `ng build --configuration production`.
- Host on Azure Static Web Apps, Vercel, Netlify, or S3+CloudFront.

## Database
- Azure SQL Database / managed SQL Server preferred.
- Enable automated backups, geo-replication, and maintenance windows.

## Environment config
- Separate dev/staging/prod settings.
- CI/CD pipeline with migrations, tests, and smoke checks.

---

## 10) Testing strategy

## FastAPI unit testing
- `pytest` for services + repositories.
- mock DB for unit-level business rules.

## API testing
- `TestClient` integration tests for auth, product CRUD, and order checkout.
- Postman/Newman for workflow regression suites.

## Angular testing
- unit tests with Karma/Jasmine.
- component tests for forms and guards.
- e2e tests with Cypress or Playwright.

---

## Production roadmap (quick checklist)
- [ ] Complete OpenAPI docs and API versioning policy.
- [ ] Add Alembic migrations.
- [ ] Add Redis for caching and queues.
- [ ] Add payment integration (Stripe/Adyen).
- [ ] Add observability: metrics + tracing + logs.
- [ ] Add WAF, rate limits, bot protection.
