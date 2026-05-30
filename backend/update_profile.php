<?php
require 'config.php';

$user_id = request_int('user_id');
$name = trim($_POST['name'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$address = trim($_POST['address'] ?? '');
$dob = trim($_POST['dob'] ?? '');
$gender = trim($_POST['gender'] ?? '');

if (!$user_id || $user_id < 1 || empty($name)) {
    echo json_encode(["status" => "error", "message" => "Invalid profile data"]);
    exit;
}

if (empty($phone) || empty($address) || empty($gender)) {
    echo json_encode(["status" => "error", "message" => "Please complete all required profile fields"]);
    exit;
}

$dobValue = $dob === '' ? null : $dob;
$profileCompleted = 1;

$stmt = $conn->prepare("UPDATE users SET name = ?, phone = ?, address = ?, dob = ?, gender = ?, profile_completed = ? WHERE id = ?");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Profile update is not ready. Please run the users table migration."]);
    $conn->close();
    exit;
}

$stmt->bind_param("sssssii", $name, $phone, $address, $dobValue, $gender, $profileCompleted, $user_id);

if ($stmt->execute()) {
    $fetch = $conn->prepare("SELECT id, name, email, role, phone, address, dob, gender, points, is_verified, profile_completed FROM users WHERE id = ?");
    if (!$fetch) {
        echo json_encode(["status" => "error", "message" => "Could not load updated profile"]);
        $stmt->close();
        $conn->close();
        exit;
    }

    $fetch->bind_param("i", $user_id);
    $fetch->execute();
    $result = $fetch->get_result();
    $user = $result->fetch_assoc();
    $fetch->close();

    if (!$user) {
        echo json_encode(["status" => "error", "message" => "User not found"]);
        $stmt->close();
        $conn->close();
        exit;
    }

    echo json_encode(["status" => "success", "message" => "Profile updated", "user" => cravora_user_payload($user)]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update profile"]);
}

$stmt->close();
$conn->close();
?>
