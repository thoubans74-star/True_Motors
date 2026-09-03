# True Motors - API Requirement Document

This document outlines the API endpoints required for each screen/module in the True Motors application. Endpoints that are currently implemented or identified have their `type` IDs noted.

---

## 1. Authentication & Onboarding Module (`login_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Login Screen** | Send OTP to mobile number | `2500` (Implemented) |
| **OTP Screen** | Verify OTP & check profile status | `2501` (Implemented) |
| **Signup Screen** | Register user / Initial profile completion | `2508` (Implemented via Update Profile) |
| **Dealer Registration** | Submit dealer registration details | *Required* (Needs new type) |
| **Dealer Type/Category**| Fetch available dealer types and categories| *Required* |

---

## 2. Menu & Profile Module (`menu_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Profile Information** | Fetch user profile data | `2507` (Implemented) |
| **Profile Information** | Update profile data & profile image | `2508` (Implemented - multipart) |
| **Subscription Screen** | Fetch available subscription plans | `2522` (Implemented) |
| **Subscription Screen** | Create subscription order / Payment intent | *Required* |
| **My Booking Screen** | Fetch user's active/past bookings | *Required* |
| **My Listing Screen** | Fetch vehicles listed by the user | *Required* |
| **Saved Vehicle Screen**| Fetch user's wishlist / saved vehicles | *Required* |
| **Notification Alert** | Fetch user notifications | *Required* |
| **App Drawer** | Logout User | `2502` (Implemented) |

---

## 3. Home & General Module (`app_drawer_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Home Screen** | Fetch home dashboard (Banners, top categories) | *Required* |
| **Location Screen** | Fetch available cities/regions or reverse geocode | *Required* |
| **Search Screen** | Global search for vehicles, brands, or dealers | *Required* |

---

## 4. Used Vehicle Module (`used_vehicle_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Used Vehicle List** | Fetch all used vehicles (with filters/pagination)| `2520` (Present in codebase) |
| **Vehicle Detail** | Fetch detailed info for a specific vehicle | *Required* |
| **Test Drive Booking** | Submit a test drive request | *Required* |
| **Dealers Near You** | Fetch local dealers based on location | *Required* |
| **Dealer Details** | Fetch specific dealer profile and their inventory | *Required* |

---

## 5. Compare Vehicle Module (`compare_vehicle_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Compare Brand** | Fetch list of brands to compare | *Required* |
| **Compare Variant** | Fetch variants for selected brands | *Required* |
| **Compare Result** | Fetch side-by-side spec comparison | *Required* |

---

## 6. Lease & Rental Modules (`lease_module` / `rental_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Lease Dashboard** | Fetch user's leased vehicle stats | *Required* |
| **Add Vehicle (Lease)** | Submit vehicle details for leasing | *Required* |
| **Upload Images** | Upload leased vehicle gallery (multipart) | *Required* |
| **Rental Page** | Fetch available rental vehicles & tariffs | *Required* |
| **Rental Booking** | Submit rental booking (dates, location) | *Required* |
| **Payment Options** | Process payment / Confirm booking | *Required* |

---

## 7. Sell Vehicle Module (`sell_vehicle_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Sell Car Form** | Submit basic vehicle details | *Required* |
| **Sell Car Photo** | Upload vehicle images (multipart) | *Required* |
| **Seller Info** | Submit contact and location details | *Required* |

---

## 8. Service Vehicle Module (`service_vehicle_module`)

| Screen | Required API Action | API `type` / Details |
| :--- | :--- | :--- |
| **Vehicle Service** | Fetch available service centers & packages | *Required* |
| **Confirm Booking** | Submit service booking appointment | *Required* |

---

> [!NOTE] 
> **Standard Request Parameters:** Almost all authenticated endpoints require the following standard payload:
> - `type`: Unique ID for the API
> - `cid`: Client ID (e.g., `21472147`)
> - `f_token`: Session token
> - `device_id`: Device identifier
> - `ln`: Longitude
> - `lt`: Latitude
