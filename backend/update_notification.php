<?php
require 'config.php';

$id = $_POST['id'] ?? null;
$user_id = $_POST['user_id'] ?? null;
$title = $_POST['title'] ?? '';
$message = $_POST['message'] ?? '';

if (!$id || empty($title) || empty($message)) {
    echo json_encode(["status" => "error", "message" => "ID, title, and message are required"]);
    exit;
}

if ($user_id === "null" || $user_id === "") {
    $user_id = null;
}

$sql = "UPDATE notifications SET user_id = ?, title = ?, message = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issi", $user_id, $title, $message, $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Notification updated successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update notification: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
