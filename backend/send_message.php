<?php
require 'config.php';

$sender_id = filter_var($_POST['sender_id'] ?? null, FILTER_VALIDATE_INT);
$receiver_id = $_POST['receiver_id'] ?? null;
$message = trim($_POST['message'] ?? '');

if (!$sender_id || !$message) {
    echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    exit;
}

// If receiver_id is not provided, find the first user with 'admin' role
if ($receiver_id === null || $receiver_id === '') {
    $admin_stmt = $conn->prepare("SELECT id FROM users WHERE role = 'admin' LIMIT 1");
    $admin_stmt->execute();
    $admin_res = $admin_stmt->get_result();
    if ($admin_res && $admin_row = $admin_res->fetch_assoc()) {
        $receiver_id = $admin_row['id'];
    } else {
        $receiver_id = 2; // Fallback to 2 if no admin found
    }
    $admin_stmt->close();
} else {
    $receiver_id = filter_var($receiver_id, FILTER_VALIDATE_INT);
    if (!$receiver_id || $receiver_id < 1) {
        echo json_encode(["status" => "error", "message" => "Invalid receiver"]);
        exit;
    }
}

$sql = "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iis", $sender_id, $receiver_id, $message);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to send message"]);
}

$stmt->close();
$conn->close();
?>
