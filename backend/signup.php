<?php
require 'config.php';
require 'mailer.php';

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$rawPassword = $_POST['password'] ?? '';

if (empty($name) || empty($email) || empty($rawPassword)) {
    echo json_encode([
        "status" => "error",
        "message" => "Please fill all fields"
    ]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => "error",
        "message" => "Please enter a valid email address"
    ]);
    exit;
}

$password = password_hash($rawPassword, PASSWORD_DEFAULT);

// Check if email already exists
$check = $conn->prepare("SELECT id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$result = $check->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        "status" => "error",
        "message" => "This email is already registered"
    ]);
    exit();
}

// Generate verification code
$verification_code = (string)random_int(100000, 999999);

// Insert new user
$sql = "INSERT INTO users
(name, email, password, verification_code, is_verified, profile_completed)
VALUES (?, ?, ?, ?, 0, 0)";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Registration is not ready. Please run the users table migration."
    ]);
    $conn->close();
    exit;
}

$stmt->bind_param(
    "ssss",
    $name,
    $email,
    $password,
    $verification_code
);

if ($stmt->execute()) {
    $mailResult = send_verification_email($email, $verification_code);

    if ($mailResult["success"]) {
        echo json_encode([
            "status" => "success",
            "message" => "Account created. Please check your email for the verification code.",
            "email" => $email
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Account created, but the verification email could not be sent. Configure SMTP and use Resend Code.",
            "email" => $email
        ]);
    }

} else {

    echo json_encode([
        "status" => "error",
        "message" => "Something went wrong"
    ]);
}

$stmt->close();
$conn->close();
?>
