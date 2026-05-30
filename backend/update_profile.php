<?php
require 'config.php';

$user_id = $_POST['user_id'];
$name = $_POST['name'];
$phone = $_POST['phone'];
$address = $_POST['address'];
$dob = $_POST['dob'];
$gender = $_POST['gender'];

$sql = "UPDATE users SET name='$name', phone='$phone', address='$address', dob='$dob', gender='$gender' WHERE id='$user_id'";

if ($conn->query($sql) === TRUE) {
    // Fetch updated user to get email and other fields
    $result = $conn->query("SELECT * FROM users WHERE id='$user_id'");
    $user = $result->fetch_assoc();
    echo json_encode(["status" => "success", "message" => "Profile updated", "user" => $user]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
