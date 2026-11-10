# EasyShop: Client API Response Shapes

Source: tested in Postman on 2026-11-06 with a temporary client account. The auth and profile facts in section 1 were also checked on a phone on 2026-11-10. Complements `endpoints.md`, which lists the requests. This file lists what the server **returns**.

No real emails, tokens, keys or base URLs are in this file. Hosts are shown as `<host>`.

**Who writes what** (one section per person, each in their own PR, to avoid conflicts):

| Section | Owner | Status |
|---|---|---|
| 1. Auth and profile | A (CL-A2) | Basics confirmed by C, A to complete |
| 2. Catalog and favorites | B (CL-B3) | TBD |
| 3. Cart | C (CL-C1) | Done |
| 4. Orders | C (CL-C1) | Done |
| 5. Card payment | C (CL-C1) | Done, successful payment untested |
| 0, 6, 7 | C, others add their own rows | Started |

---

## 0. Rules that apply to every response

**Envelope.** Same as the Admin API: `{ "data": ..., "message": "..." }`.

- Success: `data` holds the result. Lists are a plain JSON array, with **no** pagination (`GET /client/products` returned 34 items in one array). Treat the API as **not paginated**.
- Error: `data` is `null`, and `message` explains the problem.
- Exceptions to the envelope:
  - `POST /client/otp/verify` adds a top-level `token` next to `data` and `message`.
  - `POST /client/payments/process` returns a top-level `url` and `message`, and **no `data`**.

**Identifiers.**
- Products are addressed by `slug` (`GET /client/products/show/{slug}`).
- Orders are addressed by `code`, 8 uppercase letters and digits (example: `66D1BJIY`), not by `id`.
- The cart is addressed by `product_id`, not by the cart row `id`.

**Token.** The token comes from `POST /client/otp/verify`. It is a JWT valid for **1 hour** (`exp` minus `iat` is 3600 seconds). Details of login and OTP belong to section 1.

**Types.** In the cart, order and payment responses every number came back as a JSON number (`price`, `quantity`, `total_price`, `latitude`, `longitude`, `paid`). Keep the tolerant number parser from `json_parsers` anyway, because the Admin API mixed strings and numbers.

**Private data inside product objects.** Every nested `product` (catalog, cart, order items) contains an `admin` object with the store owner's `email`, `phone`, `national_id` and document URLs. **Client models must read only `admin.id` and `admin.business_name`** (the "by Elbatal Store" line in the Figma) and ignore the rest. Never show or store the other fields. This should be reported to the mentor.

**Hidden products are returned.** `GET /client/products` returns products with `visible: 0` (8 of 34 at the time of testing). The server also accepts them in the cart and in orders. The Client app must filter `visible == 1` itself.

---

## 1. Auth and profile (A, CL-A2)

A completes this section from his Postman tests of register, login, OTP verify and resend, logout, profile and profile update. What is already confirmed:

- `POST /client/register` returns 201 and the new client. **No token and no OTP email** (confirmed on a phone: no email arrives after register).
- `POST /client/login` returns 200, `data: null`, message `"OTP sent to your email and phone"`. **The OTP email arrives only after login.**
- `POST /client/otp/verify` returns 200 and the client in `data`, plus a top-level `token`.
- The app flow is therefore: register, then login, then OTP, then home.
- In C's Postman test, register did **not** save `address`, `latitude`, `longitude` or `picture` (`GET /client/profile` showed `null` and the default picture).
- **Profile update saves them** (checked on a phone, 2026-11-10): `address`, location and `picture` were still there after reopening the profile. To set them, use `PUT /client/profile/update`, sent as `POST` + `_method=PUT` with `FormData`.
- Sending your **own email** again on profile update is accepted (no "already taken").

Still missing, for A (CL-A2): response fields, validation errors, login/OTP/logout errors, profile fields and token errors. A adds them in his own PR, section 1 only.

---

## 2. Catalog and favorites (B, CL-B3)

TBD. B fills this in. The product object as seen in the catalog, the cart and orders:

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name`, `slug` | string | |
| `price` | number | |
| `quantity` | int | stock |
| `category_id` | int | |
| `description` | string? | `null` when empty |
| `visible` | int | `1` visible, `0` hidden |
| `admin_id` | int | |
| `image_url` | string | absolute URL, default image when none was uploaded |
| `created_at`, `updated_at` | string | ISO 8601, UTC |
| `category` | object | `id`, `name`, `slug`, `description?`, timestamps |
| `admin` | object | see section 0: use only `id` and `business_name` |

---

## 3. Cart (C, CL-C1)

| Request | Status | `data` | `message` |
|---|---|---|---|
| `GET /client/carts` | 200 | list of cart items (`[]` when empty) | `"Data retrieved successfully"` |
| `POST /client/carts/store` (JSON `product_id`, `quantity`) | 201 | `null` | `"Product added successfully"` |
| `DELETE /client/carts/destroy` (JSON body `product_id`) | 200 | `null` | `"Product deleted successfully"` |

A cart item:

| Field | Type | Notes |
|---|---|---|
| `id` | int | cart row id. **Not used in any request.** |
| `client_id`, `product_id` | int | |
| `quantity` | int | |
| `created_at`, `updated_at` | string | |
| `product` | object | the full product (section 2), with `category` and `admin` |

Behavior found by testing:

- **`store` replaces the quantity, it does not add.** Sending 2 and then 5 gave 5. The +/- buttons send the **new total**.
- `store` returns no cart. After every change, refetch `GET /client/carts`.
- The cart has **no price field**. The price is `product.price`.
- Items come **oldest first** (by cart row id).
- **`DELETE` with a JSON body works** and uses `product_id`.
- Quantity `0` is rejected: **422**, `{ "quantity": ["The quantity field must be greater than 0."] }`, and the cart stays unchanged. The minus button at quantity 1 must call `destroy`.
- **No stock check in the cart.** A quantity of 41 was saved for a product with stock 40.
- **No visibility check in the cart.** A product with `visible: 0` was accepted, and the cart returns it with `visible: 0`.
- **Placing an order empties the whole cart**, including items that were not in the order (see section 4).

What the app must do: clamp the quantity to `product.quantity` before calling `store`, never add hidden products, and flag cart items that are hidden or above stock.

---

## 4. Orders (C, CL-C1)

| Request | Status | `data` | `message` |
|---|---|---|---|
| `GET /client/orders` | 200 | list of orders | `"Data retrieved successfully"` |
| `GET /client/orders/show/{code}` | 200 | one order | `"Data retrieved successfully"` |
| `POST /client/orders/store` (JSON) | 201 | the new order | `"Order has been created successfully"` |

`GET /client/orders/show/{code}` returns the **same object** as an item of the list and as the response of `store`. Use one model for all three.

**Request (`store`).** `product_id`, `quantity` and `price` are **parallel lists**: position `i` of each list describes the same item.

```json
{
  "product_id": [32, 33],
  "quantity": [2, 1],
  "price": [220, 600],
  "address": "Cairo, Egypt",
  "latitude": 30.033333,
  "longitude": 31.233334,
  "payment_method": "cash"
}
```

**Order object:**

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `code` | string | used in the details path |
| `date` | string | `"2026-11-06 13:27:57"`: **local Cairo time**, not ISO |
| `created_at`, `updated_at` | string | ISO 8601, UTC. `date` 13:27 matches `created_at` 11:27Z. |
| `client_id` | int | |
| `total_price` | number | computed by the server from the `price` and `quantity` lists you sent |
| `address` | string | delivery address of this order |
| `latitude`, `longitude` | number | delivery location, for "View on Map" |
| `payment_method` | string | `"cash"` or `"card"` |
| `status` | string | `"pending"` and `"processing"` seen so far |
| `payment` | object? | `null` until `orders/pay` is called on a card order (section 5) |
| `order_items` | list | see below |

There is **no `client` object** in the client's orders (the Admin one has it).

Each item in `order_items`:

| Field | Type | Notes |
|---|---|---|
| `id`, `order_id`, `product_id` | int | |
| `price` | number | the price **we sent** |
| `quantity` | int | |
| `total_price` | number | `price` x `quantity` |
| `product` | object | the full product (section 2) |

**What the server checks and what it does not:**

| Test | Result | What the app must do |
|---|---|---|
| Order while the cart is empty | Accepted. The order does not read the cart, only the body. | Nothing special. |
| Wrong price (`price: [1]` for a 600 product) | **Accepted.** The item and `total_price` use the price sent. | Always send `product.price` from the cart, never a typed or cached value. Report to the mentor. |
| Quantity above stock (41 for stock 40) | **422**, `{ "quantity.0": ["The quantity.0 field must be less than or equal to 40."] }` | The order checks stock (the cart does not). Clamp in the app and show the server message if it still happens. |
| Hidden product (`visible: 0`) | **Accepted.** | Filter hidden products out of the app. |
| Missing `payment_method` | **422**, `{ "payment_method": ["The payment method field is required."] }` | Required. |
| Missing `address`, `latitude`, `longitude` | **Not reported** (the test also omitted them). They seem optional for the server. | The app still requires them, because the brief says to send the location. |
| `payment_method: "bitcoin"` | **422**, `"The selected payment method is invalid."` | Only `cash` and `card`, lowercase. |
| Lists of different lengths | **422**, `{ "price.1": ["The price.1 field is required."], "quantity.1": [...] }` | Build the three lists in one loop over the cart items. |
| Unknown order code | **404**, `"Order is not found"` (string) | Show the message. |

Also found:
- **Stock is not reduced** by an order (product stock stayed 40 after ordering 2).
- **A successful order empties the whole cart**, even products that were not in the order. After `store` succeeds, reset the cart state and the tab badge.
- Error `message` is a **map** with field names that can contain a dot and an index (`quantity.0`). Do not rely on the field names. Show the first message.

---

## 5. Card payment (C, CL-C1)

Only the part **before** the payment page was tested. A successful payment was **not tested**: nobody should use a real card on this API.

Flow as observed (the order of the steps is an inference):

| Step | Request | Result |
|---|---|---|
| 1 | `POST /client/orders/store` with `"payment_method": "card"` | 201. `status: "pending"`, `payment: null`. |
| 2 | `POST /client/orders/pay/{code}` (no body) | 200, message `"You are being transferred to the payment gateway"`. The order becomes **`processing`** and a `payment` record is created (`paid: 0`). `data` is a ready-made payload for step 3. |
| 3 | `POST /client/payments/process` (JSON) | 200, top-level `url` (a Paymob checkout page) and message `"Payment done successfully"`. **Nothing is paid yet.** |
| 4 | Open the `url` | Not tested. |
| 5 | `GET /client/orders/show/{code}` | Look at `payment.paid`. What it becomes after a real payment is unknown. |

**`orders/pay` returns a payload with wrong data:**

| Field | Value seen |
|---|---|
| `gateway_type`, `currency` | `"paymob"`, `"EGP"` (correct) |
| `amount` | the order total (correct) |
| `first_name`, `last_name` | **both hold the full client name** |
| `phone_number`, `email` | **empty strings** |
| `code` | a **payment** code (not the order code) |

The app would have to fill `first_name`, `last_name`, `phone_number` and `email` from the profile before calling `process`.

`payment` object after step 2:

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `date` | string | local Cairo time, like the order |
| `code` | string | payment code |
| `method` | string | `"paymob"` |
| `amount` | number | |
| `paid` | int | `0` seen |
| `order_id` | int | |
| `created_at`, `updated_at` | string | |

Findings:
- **`orders/pay` is the call that creates the payment and sets `processing`.** `payments/process` on its own changes nothing (the order stayed `pending` with `payment: null`).
- **`payments/process` does not validate `code`.** A fake code (`kkkkkkkk`) also returned a URL. Its message "Payment done successfully" is misleading: it only creates a link.
- **`orders/pay` on a cash order** returns **404**, `"Payment method or order status is not supported"`, and the order is unchanged. Never call it for cash.
- No callback to the app is documented. The app would have to open the URL and poll `orders/show/{code}`. That needs a browser or webview package (`url_launcher` or `webview_flutter`), which needs team approval.

Conclusion for the plan: card payment stays a **stretch** (CL-C11). The cash flow is complete and testable. If card payment is not built, say so in the README.

---

## 6. Quirks to handle in the data layer

| Quirk | What to do |
|---|---|
| Product objects contain the store owner's private data | Read only `admin.id` and `admin.business_name` |
| Hidden products (`visible: 0`) are returned and accepted everywhere | Filter `visible == 1` in the catalog, and flag them in the cart |
| Cart `store` replaces the quantity | Send the new total, then refetch the cart |
| Cart does not check stock, order does | Clamp the quantity in the app |
| Cart item has no price | Use `product.price`, and send it in the order |
| The server trusts the price in the order | Never send a typed or stale price |
| Order lists are parallel arrays | Build them in one loop, same length |
| Order empties the whole cart | Reset `CartCubit` after a successful order |
| `date` is Cairo time, `created_at` is UTC | Display `created_at` converted to the device time zone (`AppDateFormatter`) |
| `message` is a string or a map (keys like `quantity.0`) | Parse by type, show the first message |
| `payments/process` has no `data` | Read the top-level `url` |
| `orders/pay` returns wrong names and empty phone and email | Fill them from the profile |
| `orders/pay` on a cash order is a 404 | Do not call it for cash |
| Client register did not save address, location or picture (Postman) | Set them through profile update, which saves them |

---

## 7. Not tested yet

- 401 messages for the client (missing token, expired token, wrong password, wrong OTP). Assume they match the Admin ones, then confirm.
- What `payment.paid` and `status` become after a **real** card payment, and which other statuses exist (only `pending` and `processing` seen).
- Calling `orders/pay` twice on the same order.
- The order of `GET /client/orders` (oldest or newest first).
- Whether `quantity` or `price` arrive as strings in any client response.
- `GET /client/products/show/{slug}` for a hidden product.
- Lowercase and uppercase variants of `payment_method` (only lowercase was tested).
