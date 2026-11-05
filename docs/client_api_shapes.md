# Client API Shapes

This document contains the API response shapes for the EasyShop Client App endpoints.

---

## Authentication Endpoints

### POST /client/register
**Description**: Register a new client account

**Request**: `FormData`
- `name`: string
- `email`: string
- `phone`: string
- `password`: string
- `password_confirmation`: string
- `picture`: file (optional)

**Response**: `200 OK`
```json
{
    "data": {
        "id": 57,
        "name": "Ahmed Elbatal",
        "email": "getrisoboleu-3890@yopmail.com",
        "phone": "+201013114001",
        "address": null,
        "latitude": null,
        "longitude": null,
        "created_at": "2026-11-04T10:41:10.000000Z",
        "updated_at": "2026-11-04T10:41:10.000000Z",
        "picture_url": "https://easylearn.devawy.com/uploads/clients/1250056658.jfif"
    },
    "message": "Account created successfully"
}
```

**Note**: After registration, an OTP is automatically sent to the provided email and phone.

---

### POST /client/login
**Description**: Login with email and password (sends OTP)

**Request**: `application/json`
```json
{
    "email": "getrisoboleu-3890@yopmail.com",
    "password": "password123"
}
```

**Response**: `200 OK`
```json
{
    "data": null,
    "message": "OTP sent to your email and phone"
}
```

**Note**: Does NOT return a token. Token is received after OTP verification.

---

### POST /client/verify-otp
**Description**: Verify OTP code and receive authentication token

**Request**: `application/json`
```json
{
    "email": "getrisoboleu-3890@yopmail.com",
    "otp": "123456"
}
```

**Response**: `200 OK`
```json
{
    "data": {
        "id": 57,
        "name": "Ahmed Elbatal",
        "email": "getrisoboleu-3890@yopmail.com",
        "phone": "+201013114001",
        "address": null,
        "latitude": null,
        "longitude": null,
        "created_at": "2026-11-04T10:41:10.000000Z",
        "updated_at": "2026-11-04T10:43:13.000000Z",
        "picture_url": "https://easylearn.devawy.com/uploads/clients/1250056658.jfif"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "message": "OTP verified successfully"
}
```

**Note**: Save the `token` for authenticated requests.

---

### POST /client/resend-otp
**Description**: Resend OTP code to email

**Request**: `application/json`
```json
{
    "email": "getrisoboleu-3890@yopmail.com"
}
```

**Response**: `200 OK`
```json
{
    "data": null,
    "message": "OTP resent to your email"
}
```

---

### POST /client/logout
**Description**: Logout current client session

**Headers**: 
- `Authorization: Bearer {token}`

**Response**: `200 OK`
```json
{
    "data": null,
    "message": "Account logged out successfully"
}
```

---

## Profile Endpoints

### GET /client/profile
**Description**: Get current client profile information

**Headers**: 
- `Authorization: Bearer {token}`

**Response**: `200 OK`
```json
{
    "data": {
        "id": 61,
        "name": "Ahmed Elbatal",
        "email": "freippeittenetto-6710@yopmail.com",
        "phone": "+201013114003",
        "address": null,
        "latitude": null,
        "longitude": null,
        "created_at": "2026-11-05T14:26:01.000000Z",
        "updated_at": "2026-11-05T14:27:19.000000Z",
        "picture_url": "https://easylearn.devawy.com/uploads/clients/460312601.jfif"
    },
    "message": "Data retrieved successfully"
}
```

---

### PUT /client/profile/update
**Description**: Update client profile information

**Headers**: 
- `Authorization: Bearer {token}`

**Request**: `FormData` (multipart/form-data)
- `name`: string (required)
- `email`: string (required)
- `phone`: string (required)
- `address`: string (optional)
- `latitude`: string (optional)
- `longitude`: string (optional)
- `picture`: file (optional)

**Response - Success**: `200 OK`
```json
{
    "data": {
        "id": 61,
        "name": "Ahmed Elbatal",
        "email": "kemmouftiroza-4817@yopmail.com",
        "phone": "+201013114573",
        "address": "Cairo, Egypt",
        "latitude": "30.033333",
        "longitude": "31.233334",
        "created_at": "2026-11-05T14:26:01.000000Z",
        "updated_at": "2026-11-05T15:10:45.000000Z",
        "picture_url": "https://easylearn.devawy.com/uploads/clients/images.jfif"
    },
    "message": "Profile updated successfully"
}
```

**Response - Validation Error**: `422 Unprocessable Entity`
```json
{
    "data": null,
    "message": {
        "name": [
            "The name field is required."
        ],
        "email": [
            "The email field is required."
        ],
        "phone": [
            "The phone field is required."
        ]
    }
}
```

---

## Notes

- All authenticated endpoints require `Authorization: Bearer {token}` header
- Base URL: `{{baseUrl}}` (configured in environment)
- Date format: ISO 8601 (`YYYY-MM-DDTHH:mm:ss.SSSSSSZ`)
- Nullable fields: `address`, `latitude`, `longitude` (until client sets delivery location)
- File uploads use `multipart/form-data` encoding