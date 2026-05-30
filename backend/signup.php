<?php
require 'config.php';

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
$verification_code = rand(100000, 999999);

// Insert new user
$sql = "INSERT INTO users
(name, email, password, verification_code, is_verified)
VALUES (?, ?, ?, ?, 0)";

$stmt = $conn->prepare($sql);

$stmt->bind_param(
    "ssss",
    $name,
    $email,
    $password,
    $verification_code
);

if ($stmt->execute()) {

    echo json_encode([
        "status" => "success",
        "message" => "Account created. Verify your email.",
        "code" => $verification_code
    ]);

} else {

    echo json_encode([
        "status" => "error",
        "message" => "Something went wrong"
    ]);
}

$stmt->close();
$conn->close();
?>
