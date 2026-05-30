<?php
require 'config.php';

$sender_id = $_POST['sender_id'] ?? null;
$receiver_id = $_POST['receiver_id'] ?? null;
$message = $_POST['message'] ?? null;

if (!$sender_id || !$message) {
    echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    exit;
}

// If receiver_id is not provided, find the first user with 'admin' role
if ($receiver_id === null) {
    $admin_res = $conn->query("SELECT id FROM users WHERE role = 'admin' LIMIT 1");
    if ($admin_res && $admin_row = $admin_res->fetch_assoc()) {
        $receiver_id = $admin_row['id'];
    } else {
        $receiver_id = 2; // Fallback to 2 if no admin found
    }
}

$message = $conn->real_escape_string($message);
$sql = "INSERT INTO messages (sender_id, receiver_id, message) VALUES ('$sender_id', '$receiver_id', '$message')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
