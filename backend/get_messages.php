<?php
require 'config.php';

$user_id = $_REQUEST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode([]);
    exit;
}

$sql = "SELECT * FROM messages WHERE sender_id = '$user_id' OR receiver_id = '$user_id' ORDER BY created_at ASC";
$result = $conn->query($sql);

$messages = [];
if ($result) {
    while($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
} else {
    // Log error if needed: $conn->error
}

echo json_encode($messages);
$conn->close();
?>
