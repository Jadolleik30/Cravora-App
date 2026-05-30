<?php
require 'config.php';

$user_id = request_int('user_id');

if (!$user_id || $user_id < 1) {
    echo json_encode(["status" => "error", "message" => "Invalid user"]);
    exit;
}

$sql = "DELETE FROM messages WHERE sender_id = ? OR receiver_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ii", $user_id, $user_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to clear chat"]);
}

$stmt->close();
$conn->close();
?>
