<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/mailer.php';

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$rawPassword = $_POST['password'] ?? '';

if ($name === '' || $email === '' || $rawPassword === '') {
    echo json_encode([
        'status' => 'error',
        'account_created' => false,
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Please fill all fields',
    ]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'status' => 'error',
        'account_created' => false,
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Please enter a valid email address',
    ]);
    exit;
}

$check = $conn->prepare('SELECT id, is_verified FROM users WHERE email = ? LIMIT 1');
if (!$check) {
    cravora_log('signup_email_check_prepare_failed', ['db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'account_created' => false,
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Registration is not ready. Please run the users table migration.',
    ]);
    $conn->close();
    exit;
}

$check->bind_param('s', $email);
$check->execute();
$result = $check->get_result();

if ($result && $result->num_rows > 0) {
    $existingUser = $result->fetch_assoc();
    $check->close();

    if ((int)($existingUser['is_verified'] ?? 0) !== 1) {
        echo json_encode([
            'status' => 'unverified',
            'account_created' => false,
            'email_sent' => false,
            'requires_verification' => true,
            'message' => 'This email is already registered but not verified. Please verify your account.',
            'email' => $email,
        ]);
        $conn->close();
        exit;
    }

    echo json_encode([
        'status' => 'error',
        'account_created' => false,
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'This email is already registered',
    ]);
    $conn->close();
    exit;
}

$check->close();

$password = password_hash($rawPassword, PASSWORD_DEFAULT);
$verificationCode = (string)random_int(100000, 999999);

$sql = 'INSERT INTO users
        (name, email, password, verification_code, is_verified, profile_completed)
        VALUES (?, ?, ?, ?, 0, 0)';

$stmt = $conn->prepare($sql);

if (!$stmt) {
    cravora_log('signup_insert_prepare_failed', ['db_error' => $conn->error]);
    echo json_encode([
        'status' => 'error',
        'account_created' => false,
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Registration is not ready. Please run the users table migration.',
    ]);
    $conn->close();
    exit;
}

$stmt->bind_param('ssss', $name, $email, $password, $verificationCode);

if (!$stmt->execute()) {
    cravora_log('signup_insert_failed', ['email' => $email, 'db_error' => $stmt->error]);
    echo json_encode([
        'status' => 'error',
        'account_created' => false,
        'email_sent' => false,
        'requires_verification' => false,
        'message' => 'Something went wrong',
    ]);
    $stmt->close();
    $conn->close();
    exit;
}

$mailResult = send_verification_email($email, $verificationCode);

if ($mailResult['success']) {
    echo json_encode([
        'status' => 'success',
        'account_created' => true,
        'email_sent' => true,
        'requires_verification' => true,
        'message' => 'Account created. Verification code sent.',
        'email' => $email,
    ]);
} else {
    cravora_log('signup_verification_email_failed', [
        'email' => $email,
        'reason' => $mailResult['message'] ?? 'unknown',
    ]);

    echo json_encode([
        'status' => 'success',
        'account_created' => true,
        'email_sent' => false,
        'requires_verification' => true,
        'message' => 'Account created, but email could not be sent. Please press Resend Code.',
        'email' => $email,
    ]);
}

$stmt->close();
$conn->close();
?>
