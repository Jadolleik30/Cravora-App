<?php
require 'config.php';

$id = $_POST['id'] ?? null;

if (!$id) {
    echo json_encode(["status" => "error", "message" => "ID is required"]);
    exit;
}

$sql = "DELETE FROM notifications WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Notification deleted successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete notification: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
