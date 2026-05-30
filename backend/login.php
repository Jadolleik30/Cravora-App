<?php
require 'config.php';

$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Please fill all fields"]);
    exit;
}

$sql = "SELECT id, name, email, password, role, phone, address, dob, gender, points, is_verified, profile_completed FROM users WHERE email = ? LIMIT 1";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Login is not ready. Please run the users table migration."]);
    $conn->close();
    exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        if (isset($user['is_verified']) && (int)$user['is_verified'] !== 1) {
            echo json_encode([
                "status" => "unverified",
                "message" => "Please verify your email first.",
                "email" => $user['email']
            ]);
            exit;
        }

        $payload = cravora_user_payload($user);
        if ((int)$payload['profile_completed'] === 1 && (int)($user['profile_completed'] ?? 0) !== 1) {
            $markProfile = $conn->prepare("UPDATE users SET profile_completed = 1 WHERE id = ?");
            if ($markProfile) {
                $userId = (int)$user['id'];
                $markProfile->bind_param("i", $userId);
                $markProfile->execute();
                $markProfile->close();
            }
        }

        echo json_encode([
            "status" => "success", 
            "message" => "Login successful", 
            "user" => $payload
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
