# Cravora Browser Flow Test

## Prerequisites

- Start XAMPP Apache and MySQL.
- Confirm the backend responds at `http://localhost/code/backend/`.
- Confirm the `users` table has `verification_code`, `is_verified`, and `profile_completed` columns. If not, run `user_verification_profile_migration.sql`.

## Web Preview

Run the Flutter web preview from the project root:

```powershell
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=7357
```

Open:

```text
http://127.0.0.1:7357
```

The app keeps Android emulator compatibility through `Config.baseUrl`: web uses `http://localhost/code/backend/`, while Android uses `http://10.0.2.2/code/backend/`.

## Test Data

Use a generated local-only email such as:

```text
cravora.e2e.<timestamp>@example.test
```

Use a dummy password for local testing only.

For local verification testing, read the verification code directly from the local database. Do not expose this code in the Flutter UI or any PHP API response.

```powershell
C:\xampp\mysql\bin\mysql.exe -uroot -D jad_olleik -N -e "SELECT verification_code FROM users WHERE email = 'cravora.e2e.<timestamp>@example.test' LIMIT 1;"
```

## Browser Steps

1. Open `/home` and confirm the app renders.
2. Navigate to signup.
3. Register with the generated name, email, and password.
4. Confirm the verification page appears.
5. Sign in before verification and confirm the app returns to the verification page.
6. Enter the locally read verification code.
7. Confirm the incomplete user is redirected to `/profile`.
8. Attempt browser back navigation and drawer navigation while incomplete; the profile page should remain active and show `Complete your profile to continue using Cravora.`
9. Fill name, phone, address, date of birth, and gender.
10. Save the profile and confirm redirect to `/delivery`.
11. Sign out, sign back in with the same now-complete user, and confirm direct navigation to `/delivery`.
12. Open `/delivery` and `/delivery_food` and confirm both load the browse menu without route errors.

## JSON Endpoint Checks

These endpoints should return valid JSON without PHP warnings or HTML:

```powershell
Invoke-WebRequest -UseBasicParsing http://localhost/code/backend/get_food.php
Invoke-WebRequest -UseBasicParsing http://localhost/code/backend/get_restaurants.php
Invoke-WebRequest -UseBasicParsing http://localhost/code/backend/get_categories.php
```

## Observed Local Result

Validated on the Flutter web-server preview at `http://127.0.0.1:7357`:

- Signup opened the verification page.
- Login before verification returned to the verification page.
- Verification redirected the incomplete user to `/profile`.
- Back navigation stayed on the profile page while the profile was incomplete, and the warning banner was visible.
- Saving name, phone, address, date of birth, and gender redirected to `/delivery`.
- Logging in again with the completed user went directly to `/delivery`.
- `/delivery` and `/delivery_food` both loaded the browse menu.
- Browser console checks did not show JSON parse errors.
