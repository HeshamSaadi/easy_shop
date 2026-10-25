# EasyShop: Admin API Response Shapes

Source: tested in Postman on 2026-10-16 (admin account, one client order). Register and login details were added on 2026-10-17, and the auth and profile tests on 2026-10-18, from A's tests. Category update, delete and errors were added on 2026-10-17 from B's tests. Complements `endpoints.md`, which lists the requests. This file lists what the server **returns**.

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
| 1 | `POST /admin/register` (form-data) | **201**, message `"Account created successfully"`. `data` = the new admin. **No token**, and **no OTP is sent**. |
| 2 | `POST /admin/login` (`email`, `password`) | 200. `data: null`, `message: "OTP sent to your email and phone"` |
| 3 | `POST /admin/otp/verify` (`email`, `otp_code`) | 200, message `"OTP verified successfully"`. `data` = admin, plus a top-level **`token`** |
| - | `POST /admin/otp/resend` (`email`) | 200. `data: null`, message `"OTP resent to your email"` |
| - | `POST /admin/logout` (token) | 200. `data: null`, message `"Account logged out successfully"` |

- Login **never** returns a token. Every sign-in goes through an OTP.
- Login sends the OTP both for an account that was never verified and for one that was (same message, `data: null`).
- The OTP has 6 digits and is valid for 10 minutes. The SMS part is not working yet (the mentor will fix it), so email is the only channel.
- **The token is a JWT valid for 1 hour (3600 seconds).** No refresh endpoint exists in the collection. After it expires the user must log in again, with a new OTP.
- **Register does not send an OTP.** Only login does (tested 2026-10-18). After a successful register, go to the login screen.
- **Every login sends a new OTP**, even for an account that is already verified. Being verified once is not remembered, so a new sign-in always needs login, then OTP.
- **The OTP is single-use.** Verifying the same code a second time returns `"Invalid or expired OTP"`.
- The `token` field is at the top level of the verify response, next to `data`, not inside it.
- Logout is a `POST` with the token and no body. Whether the server invalidates the token after logout is **not tested yet** (see section 5).

Register response (`data`):

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name`, `email`, `phone`, `national_id`, `business_name` | string | |
| `address` | string? | optional |
| `latitude`, `longitude` | **string** here | numbers in the verify and profile responses |
| `picture_url`, `commercial_register_url`, `tax_card_url` | string | the default image URL (`/assets/images/default.png`) when no file was uploaded. When files are sent, the uploaded URLs (under `/uploads/users/`) appear **immediately** in the register response. `.jfif` is accepted for all three |
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
- `national_id`: 14 digits is accepted, 12 digits is rejected (`"The national id field format is invalid."`). Most likely exactly 14 digits, but 13, 15 and letters are not tested yet.
- `phone`: `+20` followed by 10 digits is accepted (for example `+201013114901`). Rejected with `"The phone field format is invalid."`: the local format `01013114002`, `+20` followed by only 9 digits, and numbers with another country code (`+100...`, `+1001...`). Spaces inside the number are **not tested yet**, so remove them before sending.
- `email`, `phone` and `national_id` must be unique.
- Optional fields: `address`, `latitude`, `longitude`, `commercial_register`, `tax_card`, `picture`.

### Profile: `GET /admin/profile`

Same fields as the verify `data`, plus `products` (a list, empty for a new admin).

`PUT /admin/profile/update` (form-data), tested 2026-10-18:
- A **real `PUT` with form-data fails**: 422, and `message` lists `name`, `email`, `phone`, `national_id` and `business_name` as required even though they were filled in. Same cause as the product update below (the server does not read the form on `PUT`).
- A plain `POST` to the same URL **without** `_method` returns **405** with an HTML page.
- **The workaround works:** `POST` to the same URL with the same form-data plus a text field `_method` = `PUT`. It returns **201 Created**, message `"Account updated successfully"`. Treat any 2xx as success.
- `data` has the register fields, with `latitude` and `longitude` as **strings** and **no `products` key**.
- Sending your own `email`, `phone` and `national_id` again is accepted (no "already taken").
- Sending **no files** keeps the old `picture_url`, `commercial_register_url` and `tax_card_url`. Sending files **replaces** them (new URLs).

### Categories

Categories are **global**. `GET /admin/categories` returns the categories of every admin (21 at the time of testing), not only the logged-in admin's.

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name` | string | |
| `slug` | string | used in `update` and `destroy` paths |
| `description` | string? | `null` when empty. Sending `""` is saved as `null`. |
| `created_at`, `updated_at` | string | |

- The list has no pagination.

| Request | Status | `data` | `message` |
|---|---|---|---|
| `GET /admin/categories` | 200 | list of categories | `"Data retrieved successfully"` |
| `POST /admin/categories/store` (JSON) | 201 | the new category | `"Category created successfully"` |
| `PUT /admin/categories/update/{slug}` (JSON) | 200 | the updated category | `"Category updated successfully"` |
| `DELETE /admin/categories/destroy/{slug}` | 200 | `null` | `"Category deleted successfully"` |

- `slug` is generated by the server from `name`.
- **Renaming a category changes its `slug`**, and the old slug stops working (404). After an update, use the `slug` from the response, then refetch the list.
- Categories are sent as **JSON**, so a plain `PUT` works.
- For reference: a `PUT` with **form-data** fails here too (422, `"The name field is required."` even though `name` was sent). `POST` + `_method` = `PUT` with form-data works and returns **201**, the same as products.

Category errors:

| Case | Status | `message` |
|---|---|---|
| Empty `name` | 422 | `{ "name": ["The name field is required."] }` |
| `name` already used | 422 | `{ "name": ["The name has already been taken."] }` |
| Unknown slug (update or delete) | 404 | `"Category is not found"` |

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
- Required fields: `name`, `price`, `quantity`, `category_id`. `visible` is required.
- **Renaming a product changes its `slug`**, and the old slug stops working. After an update, use the `slug` from the response.
- Sending **no `image`** keeps the product's existing image.

`POST /admin/products/store` **with an image** (tested): 201, same response as without an image, but `image_url` is the uploaded file (an absolute URL under `/uploads/products/`).

`DELETE /admin/products/destroy/{slug}`: 200, `data: null`, message `"Product deleted successfully"`.

Tested 2026-10-21:
- `GET /admin/products` returns only the **logged-in admin's** products. A second account got `[]`. Unlike categories, products are not global.
- `show/{slug}` for another admin's product returns `"Product is not found"` (status code not recorded).
- Slugs are unique across **all** admins. A second admin creating "Desc Test" got `desc-test-1`. Always use the slug from the response.
- Required fields: `name`, `price`, `quantity`, `category_id`, `visible`. Optional: `description`, `image`.
- `description` sent as an empty value on update is saved as `null`. What happens when the key is omitted is **not tested**, so the app always sends `description`.
- Store validation (422, `message` is a map): unknown `category_id` gives `"The selected category id is invalid."`, and an empty `name` gives `"The name field is required."` (an empty value counts as missing).

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
| Missing or edited token | `"Please login first"` | string |
| Expired token | `"Access token expired"` | string |
| Token invalidated by logout | `"Invalid access token"` | string |
| Validation (empty `name`) | `{ "name": ["The name field is required."] }` | **object**: field to list of strings |
| Product not found | `"Product is not found"` | string |
| Category not found | `"Category is not found"` | string |
| Name already used | `{ "name": ["The name has already been taken."] }` | **object** |
| Wrong password | `"Invalid email or password"` | string |
| Wrong or expired OTP | `"Invalid or expired OTP"` | string |
| OTP already used | `"Invalid or expired OTP"` | string |

- `message` is a `String` **or** a `Map<String, List<String>>`. The error parser must check which one it received.
- A missing token gives `"Please login first"` and an expired token gives `"Access token expired"` (seen on 2026-10-17 on a category request). Both are 401, and both mean "go to login".
- A wrong OTP and an expired OTP give the same message.
- A wrong HTTP method (a `POST` to `/store` carrying `_method=PUT`) returned **405** with an **HTML page**, not JSON. The error handler must not assume the body is a JSON map.
- A `POST` to `/admin/profile/update` without `_method` also returned **405** with an HTML page.
- `POST /admin/logout` returned 401 twice on 2026-10-18 when called with a missing or expired token. The cause was not isolated.
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
| `latitude` / `longitude` are strings in register and profile update, numbers in verify and `GET /admin/profile` | Same |
| Verified once does not mean logged in: every login sends a new OTP | After login success always go to the OTP screen |
| OTP is single-use | After a failed verify, send the user to resend instead of retrying the same code |
| Register does not return a token or send an OTP | After register go to login |
| Phone must be `+20` plus 10 digits | Validate and strip spaces before sending |
| Omitting file fields keeps old files, sending replaces them | Send a file field only when the user picked a new file |
| Product store has no `category` object | Don't rely on it after creating |
| `message` can be a string or an object | Parse by type in the error handler |
| `date` is local time, `created_at` is UTC | Pick one for display and convert to the device time zone |
| Categories are shared by all admins | Don't edit or delete categories you did not create |
| Form-data updates fail on a real `PUT` | Send `POST` + form field `_method` = `PUT` (confirmed for products, categories and profile) |
| Update returns 201, not 200 | Accept any 2xx as success |
| Renaming a product or a category changes its slug | Use the slug from the update response, then refetch the list |
| Errors can come back as an HTML page (405) | Recommended: send `Accept: application/json` by default (not tested yet) and handle a non-JSON body without crashing |

## 5. Tested 2026-10-20

- `POST /admin/login` and `POST /admin/otp/verify` accept raw JSON (form-data is not required).
- Login with empty fields: 422, `message` = `{ "email": [...], "password": [...] }`.
- Reusing an OTP: 401, `"Invalid or expired OTP"`.
- Logout with a valid token: 200.
- `GET /admin/profile` right after logout: 401, `"Invalid access token"`. This suggests the server invalidates the token on logout, but the control test (200 before logout) is still pending.
- Register with all fields and 3 `.jfif` files: 201 (confirmed).

## 6. Not tested yet

- The control test for logout: `GET /admin/profile` with the same token returns 200 before logout.
- Spaces inside `phone` (for example `+20 101 311 4002`). Other `national_id` lengths (13, 15) and letters.
- Upload limits: large images and other extensions (only `.jfif` was tested here).
- Order statuses other than `pending`, and the `payment` object after paying.
