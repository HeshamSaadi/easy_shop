#### POST /admin/register — tested 2026-10-17
- Response envelope: `{ "data": ..., "message": ... }`
- Success: **201**. `message` is a String ("Account created successfully").
```json
  {
    "data": {
      "id": 34,
      "name": "Ahmed Khalil",
      "email": "ahmed@example.com",
      "phone": "+201000000000",
      "national_id": "<14 digits>",
      "business_name": "My Store",
      "address": "Cairo, Egypt",
      "latitude": "30.033333",
      "longitude": "31.233334",
      "picture_url": "<url>",
      "commercial_register_url": "<url>",
      "tax_card_url": "<url>",
      "created_at": "2026-10-17T09:36:48.000000Z",
      "updated_at": "2026-10-17T09:36:48.000000Z"
    },
    "message": "Account created successfully"
  }
```
- No token in the response.
- `latitude` / `longitude` come back as **Strings**.
- Optional fields (`address`, `latitude`, `longitude`, files) are `null` or a default image URL when omitted.
- Validation error: **422**. `message` is a **Map** of field -> list of messages.
```json
  { "data": null, "message": { "email": ["The email has already been taken."] } }
```
- Rules found: required `name`, `email`, `phone`, `password`, `national_id`, `business_name`; email must be valid; password min 6 and must match `password_confirmation`; `national_id` has a format rule (exact rule: TODO); `email`, `phone`, `national_id` must be unique.
- TODO: does register send an OTP email? Do uploaded files appear in `*_url` after register or only after profile update? File type/size limits.

#### POST /admin/login — tested 2026-10-17
1- before verification
{
    "data": null,
    "message": "OTP sent to your email and phone"
}
2- after verification
{
    "data": null,
    "message": "OTP sent to your email and phone"
}


#### POST /admin/OTP/verify — tested 2026-10-17
1- verification
{
    "data": {
        "id": 36,
        "name": "Mohamed Ali",
        "email": "ragoquetteupo-7606@yopmail.com",
        "phone": "+201234569400",
        "national_id": "20402154599882",
        "business_name": "Koko&S",
        "address": "Cairo, Egypt",
        "latitude": 30.033333,
        "longitude": 31.233334,
        "created_at": "2026-10-17T09:45:03.000000Z",
        "updated_at": "2026-10-17T09:47:59.000000Z",
        "picture_url": "https://easylearn.devawy.com/assets/images/default.png",
        "commercial_register_url": "https://easylearn.devawy.com/assets/images/default.png",
        "tax_card_url": "https://easylearn.devawy.com/assets/images/default.png"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Vhc3lsZWFybi5kZXZhd3kuY29tL2FwaS9hZG1pbi9vdHAvdmVyaWZ5IiwiaWF0IjoxNzkyMjMwNDc5LCJleHAiOjE3OTIyMzQwNzksIm5iZiI6MTc5MjIzMDQ3OSwianRpIjoiTkJGWWVrVnRtVG00NUd2QSIsInN1YiI6IjM2IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.qpkdJxp9fBvhg_PjqWdwUvqbQei1FMPIXVLkaR7bGCc",
    "message": "OTP verified successfully"
}