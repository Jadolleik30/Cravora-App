<?php
require 'config.php';

$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Please fill all fields"]);
    exit;
}

$sql = "SELECT * FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        if (isset($user['is_verified']) && (int)$user['is_verified'] !== 1) {
            echo json_encode(["status" => "error", "message" => "Please verify your email before logging in"]);
            exit;
        }

        echo json_encode([
            "status" => "success", 
            "message" => "Login successful", 
            "user" => [
                "id" => $user['id'],
                "name" => $user['name'],
                "email" => $user['email'],
                "role" => $user['role'],
                "phone" => $user['phone'],
                "address" => $user['address'],
                "dob" => $user['dob'],
                "gender" => $user['gender'],
                "points" => $user['points'],
                "is_verified" => $user['is_verified'] ?? 1
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid email or password"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid email or password"]);
}

$stmt->close();
$conn->close();
?>
