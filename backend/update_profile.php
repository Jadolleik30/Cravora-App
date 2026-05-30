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

$dobValue = $dob === '' ? null : $dob;

$stmt = $conn->prepare("UPDATE users SET name = ?, phone = ?, address = ?, dob = ?, gender = ? WHERE id = ?");
$stmt->bind_param("sssssi", $name, $phone, $address, $dobValue, $gender, $user_id);

if ($stmt->execute()) {
    $fetch = $conn->prepare("SELECT id, name, email, role, phone, address, dob, gender, points, is_verified FROM users WHERE id = ?");
    $fetch->bind_param("i", $user_id);
    $fetch->execute();
    $result = $fetch->get_result();
    $user = $result->fetch_assoc();
    $fetch->close();

    echo json_encode(["status" => "success", "message" => "Profile updated", "user" => $user]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update profile"]);
}

$stmt->close();
$conn->close();
?>
