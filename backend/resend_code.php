<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/mailer.php';

$email = trim($_POST['email'] ?? '');

if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'status' => 'error',
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Please enter a valid email address',
    ]);
    exit;
}

$stmt = $conn->prepare('SELECT id, is_verified FROM users WHERE email = ? LIMIT 1');
if (!$stmt) {
    cravora_log('resend_lookup_prepare_failed', ['db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Verification is not ready. Please run the users table migration.',
    ]);
    $conn->close();
    exit;
}

$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();

if (!$result || $result->num_rows === 0) {
    echo json_encode([
        'status' => 'error',
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Account not found',
    ]);
    $stmt->close();
    $conn->close();
    exit;
}

$user = $result->fetch_assoc();
$stmt->close();

if ((int)$user['is_verified'] === 1) {
    echo json_encode([
        'status' => 'success',
        'message' => 'Email is already verified',
        'email_sent' => false,
        'requires_verification' => false,
    ]);
    $conn->close();
    exit;
}

$verificationCode = (string)random_int(100000, 999999);
$update = $conn->prepare('UPDATE users SET verification_code = ?, is_verified = 0 WHERE id = ?');
if (!$update) {
    cravora_log('resend_update_prepare_failed', ['db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'email_sent' => false,
        'requires_verification' => true,
        'message' => 'Verification is not ready. Please run the users table migration.',
    ]);
    $conn->close();
    exit;
}

$userId = (int)$user['id'];
$update->bind_param('si', $verificationCode, $userId);

if (!$update->execute()) {
    cravora_log('resend_update_failed', ['email' => $email, 'db_error' => $update->error]);
    echo json_encode([
        'status' => 'error',
        'email_sent' => false,
        'requires_verification' => true,
        'message' => 'Could not update verification code',
    ]);
    $update->close();
    $conn->close();
    exit;
}

$update->close();
$mailResult = send_verification_email($email, $verificationCode);

if ($mailResult['success']) {
    echo json_encode([
        'status' => 'success',
        'message' => 'A new verification code was sent to your email',
        'email_sent' => true,
        'requires_verification' => true,
    ]);
} else {
    cravora_log('resend_verification_email_failed', [
        'email' => $email,
        'reason' => $mailResult['message'] ?? 'unknown',
    ]);

    echo json_encode([
        'status' => 'error',
        'message' => $mailResult['public_message'] ?? cravora_public_email_error(),
        'email_sent' => false,
        'requires_verification' => true,
    ]);
}

$conn->close();
?>
