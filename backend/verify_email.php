<?php
require_once __DIR__ . '/config.php';

$email = trim($_POST['email'] ?? '');
$code = trim($_POST['code'] ?? '');

if ($email === '' || $code === '') {
    echo json_encode([
        'status' => 'error',
        'requires_verification' => true,
        'message' => 'Missing data',
    ]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !preg_match('/^\d{6}$/', $code)) {
    echo json_encode([
        'status' => 'error',
        'requires_verification' => true,
        'message' => 'Invalid verification data',
    ]);
    exit;
}

$sql = 'SELECT id
        FROM users
        WHERE email = ?
          AND verification_code = ?
          AND is_verified = 0
        LIMIT 1';

$stmt = $conn->prepare($sql);
if (!$stmt) {
    cravora_log('verify_lookup_prepare_failed', ['db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'requires_verification' => true,
        'message' => 'Verification is not ready. Please run the users table migration.',
    ]);
    $conn->close();
    exit;
}

$stmt->bind_param('ss', $email, $code);
$stmt->execute();
$result = $stmt->get_result();

if (!$result || $result->num_rows === 0) {
    echo json_encode([
        'status' => 'error',
        'requires_verification' => true,
        'message' => 'Invalid verification code',
    ]);
    $stmt->close();
    $conn->close();
    exit;
}

$verifiedUser = $result->fetch_assoc();
$userId = (int)$verifiedUser['id'];
$stmt->close();

$update = $conn->prepare(
    'UPDATE users
     SET is_verified = 1,
         verification_code = NULL
     WHERE id = ?'
);

if (!$update) {
    cravora_log('verify_update_prepare_failed', ['email' => $email, 'db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'requires_verification' => true,
        'message' => 'Could not verify email',
    ]);
    $conn->close();
    exit;
}

$update->bind_param('i', $userId);
if (!$update->execute()) {
    cravora_log('verify_update_failed', ['email' => $email, 'db_error' => $update->error]);
    echo json_encode([
        'status' => 'error',
        'requires_verification' => true,
        'message' => 'Could not verify email',
    ]);
    $update->close();
    $conn->close();
    exit;
}
$update->close();

$fetch = $conn->prepare('SELECT id, name, email, role, phone, address, dob, gender, points, is_verified, profile_completed FROM users WHERE id = ?');
if (!$fetch) {
    cravora_log('verify_fetch_user_prepare_failed', ['email' => $email, 'db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'requires_verification' => false,
        'message' => 'Verification completed, but profile status is not ready. Please run the users table migration.',
    ]);
    $conn->close();
    exit;
}

$fetch->bind_param('i', $userId);
$fetch->execute();
$userResult = $fetch->get_result();
$user = $userResult ? $userResult->fetch_assoc() : null;
$fetch->close();

if (!$user) {
    cravora_log('verify_fetch_user_failed', ['email' => $email, 'user_id' => $userId]);
    echo json_encode([
        'status' => 'error',
        'requires_verification' => false,
        'message' => 'Could not load verified user',
    ]);
    $conn->close();
    exit;
}

$payload = cravora_user_payload($user);

if ((int)$payload['profile_completed'] !== (int)($user['profile_completed'] ?? 0)) {
    $markProfile = $conn->prepare('UPDATE users SET profile_completed = ? WHERE id = ?');
    if ($markProfile) {
        $profileCompleted = (int)$payload['profile_completed'];
        $markProfile->bind_param('ii', $profileCompleted, $userId);
        $markProfile->execute();
        $markProfile->close();
    }
}

echo json_encode([
    'status' => 'success',
    'requires_verification' => false,
    'message' => 'Email verified successfully',
    'user' => $payload,
]);

$conn->close();
?>
