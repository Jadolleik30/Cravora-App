<?php
require 'config.php';
require 'mailer.php';

$email = trim($_POST['email'] ?? '');

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["status" => "error", "message" => "Please enter a valid email address"]);
    exit;
}

$stmt = $conn->prepare("SELECT id, is_verified FROM users WHERE email = ? LIMIT 1");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Verification is not ready. Please run the users table migration."]);
    $conn->close();
    exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if (!$result || $result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Account not found"]);
    $stmt->close();
    $conn->close();
    exit;
}

$user = $result->fetch_assoc();
$stmt->close();

if ((int)$user['is_verified'] === 1) {
    echo json_encode(["status" => "success", "message" => "Email is already verified"]);
    $conn->close();
    exit;
}

$verificationCode = (string)random_int(100000, 999999);
$update = $conn->prepare("UPDATE users SET verification_code = ?, is_verified = 0 WHERE id = ?");
if (!$update) {
    echo json_encode(["status" => "error", "message" => "Verification is not ready. Please run the users table migration."]);
    $conn->close();
    exit;
}

$userId = (int)$user['id'];
$update->bind_param("si", $verificationCode, $userId);

if (!$update->execute()) {
    echo json_encode(["status" => "error", "message" => "Could not update verification code"]);
    $update->close();
    $conn->close();
    exit;
}

$update->close();
$mailResult = send_verification_email($email, $verificationCode);

if ($mailResult["success"]) {
    echo json_encode(["status" => "success", "message" => "A new verification code was sent to your email"]);
} else {
    echo json_encode(["status" => "error", "message" => "Verification code updated, but email could not be sent. Check SMTP settings."]);
}

$conn->close();
?>
