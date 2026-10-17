# EasyShop: Admin API Response Shapes

Source: tested in Postman on 2026-10-16 (admin account, one client order). Register and login details were added on 2026-10-17 from A's tests. Complements `endpoints.md`, which lists the requests. This file lists what the server **returns**.

No real emails, tokens, keys or base URLs are in this file. Hosts are shown as `<host>`.

## 1. Rules that apply to every response

**Envelope.** Every response has `data` and `message`:

```json
{ "data": <object | list | null>, "message": "Data retrieved successfully" }
```

- Success: `data` holds the result. Lists are a plain JSON array, with **no** `meta`, `links` or `next_page`, so treat the API as **not paginated**.
- Error: `data` is `null`, and `message` explains the problem (see section 3).
- `POST /admin/otp/verify` is the only response that adds a top-level `token` next to `data` and `message`.

**Identifiers.**
- Categories and products are addressed in paths by `slug`.
- Orders are addressed by `code` (example: `0D8CKBZJ`), not by `id`.

**Types (parse defensively).**
- Timestamps `created_at` / `updated_at`: ISO 8601, UTC, with `Z`.
- `image_url`, `picture_url` and similar: **absolute URLs**. Use them as they are, never prepend the base URL. When nothing was uploaded, a default image URL comes back.
- The same field can arrive as a **number in one response and a string in another** (see section 4). Use a tolerant parser (for example `parseNum`) in every model.
- `visible` is an int (`1` / `0`), not a bool.

## 2. Endpoints

### Auth

| Step | Request | Result |
|---|---|---|
| 1 | `POST /admin/register` (form-data) | **201**. `data` = the new admin. **No token.** |
| 2 | `POST /admin/login` (`email`, `password`) | 200. `data: null`, `message: "OTP sent to your email and phone"` |
| 3 | `POST /admin/otp/verify` (`email`, `otp_code`) | 200. `data` = admin, plus a top-level **`token`** |
| - | `POST /admin/otp/resend` (`email`) | Resends the code by email (response body not recorded yet) |

- Login **never** returns a token. Every sign-in goes through an OTP.
- Login sends the OTP both for an account that was never verified and for one that was (same message, `data: null`).
- The OTP has 6 digits and is valid for 10 minutes. The SMS part is not working yet (the mentor will fix it), so email is the only channel.
- **The token is a JWT valid for 1 hour (3600 seconds).** No refresh endpoint exists in the collection. After it expires the user must log in again, with a new OTP.

Register response (`data`):

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name`, `email`, `phone`, `national_id`, `business_name` | string | |
| `address` | string? | optional |
| `latitude`, `longitude` | **string** here | numbers in the verify and profile responses |
| `picture_url`, `commercial_register_url`, `tax_card_url` | string | the default image URL (`/assets/images/default.png`) when no file was uploaded (seen in the verify response of an account registered without files) |
| `created_at`, `updated_at` | string | |

Verify response (`data`): the same fields, with `latitude` and `longitude` as **numbers**.

Register validation (**422**, `message` is a map of field to list of messages):

```json
{ "data": null, "message": { "email": ["The email has already been taken."] } }
```

Rules found so far:
- Required: `name`, `email`, `phone`, `password`, `national_id`, `business_name`.
- `email` must be a valid email.
- `password` has at least 6 characters and must match `password_confirmation`.
- `national_id` has a format rule (the exact rule is not known yet).
- `email`, `phone` and `national_id` must be unique.

### Profile: `GET /admin/profile`

Same fields as the verify `data`, plus `products` (a list, empty for a new admin).

`PUT /admin/profile/update` (form-data): a real `PUT` with form-data does not work in Postman. Same cause as the product update below (the server does not read the form on `PUT`). The `POST` + `_method` workaround is **not tested yet** on this endpoint.

### Categories

Categories are **global**. `GET /admin/categories` returns the categories of every admin (21 at the time of testing), not only the logged-in admin's.

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name` | string | |
| `slug` | string | used in `update` and `destroy` paths |
| `description` | string? | `null` when empty. Sending `""` is saved as `null`. |
| `created_at`, `updated_at` | string | |

`POST /admin/categories/store` returns the created category in `data`, message `"Category created successfully"`.

### Products

`GET /admin/products` and `GET /admin/products/show/{slug}` return this object:

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name`, `slug` | string | |
| `price` | number | |
| `quantity` | int | stock |
| `category_id` | int | |
| `description` | string? | |
| `visible` | int | `1` visible, `0` hidden |
| `admin_id` | int | |
| `image_url` | string | absolute URL, default image when none was uploaded |
| `created_at`, `updated_at` | string | |
| `category` | object | full category (section above) |

`POST /admin/products/store` returns the same object **with differences**:
- `price`, `quantity`, `category_id` and `visible` come back as **strings** (`"150"`, `"1"`).
- There is **no `category` object**. After creating a product, refetch the list.
- Message: `"Product created successfully"`.

`PUT /admin/products/update/{slug}` (form-data):
- A **real `PUT` with form-data fails**: 422, and `message` lists `name`, `price`, `quantity` and `category_id` as required even though they were filled in. The server does not read the form on a `PUT`.
- **The workaround works:** send a `POST` to the **same update URL**, with the same form-data plus one extra field `_method` = `PUT`.
- Success returns **201 Created** (not 200). Treat any 2xx as success. Message: `"Product updated successfully"`.
- `data` has the same shape as the **store** response: `price`, `quantity`, `category_id` and `visible` as **strings**, and **no `category` object**. Refetch the list after an update.
- Required fields: `name`, `price`, `quantity`, `category_id`. `visible` was not reported as required (its default when omitted is unknown, so always send it).
- **Renaming a product changes its `slug`**, and the old slug stops working. After an update, use the `slug` from the response.
- Sending **no `image`** keeps the product's existing image.

`POST /admin/products/store` **with an image** (tested): 201, same response as without an image, but `image_url` is the uploaded file (an absolute URL under `/uploads/products/`).

`DELETE /admin/products/destroy/{slug}`: 200, `data: null`, message `"Product deleted successfully"`.

### Orders

`GET /admin/orders` (list) and `GET /admin/orders/show/{code}` (details) return **the same object**, fully nested. Use one model for both.

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `code` | string | used in the details path |
| `date` | string | `"2026-10-16 23:57:40"`: **local Cairo time**, not ISO |
| `created_at`, `updated_at` | string | ISO, UTC. For example `date` 23:57 matches `created_at` 20:57Z. |
| `client_id` | int | |
| `total_price` | number | |
| `address` | string | **delivery address of this order** |
| `latitude`, `longitude` | number | delivery location of this order, for "View on Map" |
| `payment_method` | string | `"cash"` or `"card"` |
| `status` | string | only `"pending"` seen so far |
| `payment` | object? | `null` for the card order tested. What it holds after paying: unknown. |
| `client` | object | `id`, `name`, `email`, `phone`, `address?`, `latitude?`, `longitude?`, `picture_url`, timestamps |
| `order_items` | list | see below |

Each item in `order_items`:

| Field | Type | Notes |
|---|---|---|
| `id`, `order_id`, `product_id` | int | |
| `price` | number | **price at order time**, sent by the client app |
| `quantity` | int | |
| `total_price` | number | `price` x `quantity` |
| `product` | object | the full product (section above), with its `category` |

Important notes for the orders screens:
- Show `order_items[].price` in the item lines, **not** `product.price`. In the test, the item price was 300 while the product price was 150, because the server stores the price the client sent.
- The delivery address and coordinates come from the **order**. The client's own `address`, `latitude` and `longitude` were `null` here.
- Status is read-only for the admin (no endpoint). Treat `status` as a string and keep a fallback for unknown values.
- Stock did not change after the order (`quantity` stayed 10).

## 3. Errors

| Case | `message` | Type of `message` |
|---|---|---|
| Missing, edited or expired token | `"Please login first"` | string |
| Validation (empty `name`) | `{ "name": ["The name field is required."] }` | **object**: field to list of strings |
| Product not found | `"Product is not found"` | string |
| Wrong password | `"Invalid email or password"` | string |
| Wrong or expired OTP | `"Invalid or expired OTP"` | string |

- `message` is a `String` **or** a `Map<String, List<String>>`. The error parser must check which one it received.
- An expired token and a missing token give the same message, so both mean "go to login".
- A wrong OTP and an expired OTP give the same message.
- A wrong HTTP method (a `POST` to `/store` carrying `_method=PUT`) returned **405** with an **HTML page**, not JSON. The error handler must not assume the body is a JSON map.
- Status codes seen for each case:

| Case | Status code |
|---|---|
| Missing or expired token | 401 Unauthorized |
| Validation error | 422 Unprocessable Entity |
| Not found | 404 Not Found |
| Wrong password | 401 Unauthorized |
| Wrong OTP | 401 Unauthorized |
| Wrong HTTP method | 405 Method Not Allowed (HTML body) |

**Careful with 401.** It means three different things: an expired token, a wrong password and a wrong OTP. A global rule like "on 401, log out and go to login" would also fire when the user only mistyped a password. Apply the session-expired handling only to requests that **sent a token**, and let the login and OTP screens show their own `message` instead.

## 4. Quirks to handle in the data layer

| Quirk | What to do |
|---|---|
| Same field is `150` in one response and `"150"` in another | Tolerant number parsing in all models |
| `latitude` / `longitude` are strings in register, numbers elsewhere | Same |
| Product store has no `category` object | Don't rely on it after creating |
| `message` can be a string or an object | Parse by type in the error handler |
| `date` is local time, `created_at` is UTC | Pick one for display and convert to the device time zone |
| Categories are shared by all admins | Don't edit or delete categories you did not create |
| Form-data updates fail on a real `PUT` | Send `POST` + form field `_method` = `PUT` (confirmed for products) |
| Update returns 201, not 200 | Accept any 2xx as success |
| Renaming a product changes its slug | Use the slug from the update response, then refetch the list |
| Errors can come back as an HTML page (405) | Recommended: send `Accept: application/json` by default (not tested yet) and handle a non-JSON body without crashing |

## 5. Not tested yet

- Profile update with `POST` + `_method` = `PUT` (the same workaround as products).
- Category update and delete.
- Does register itself send an OTP email? Do uploaded files appear in the `*_url` fields right after register?
- File type and size limits for uploads, and the exact `national_id` rule.
- Whether the admin products list contains only the logged-in admin's products.
- Order statuses other than `pending`, and the `payment` object after paying.
- The response of `POST /admin/otp/resend`.
