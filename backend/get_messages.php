<?php
require 'config.php';

$user_id = request_int('user_id');

if (!$user_id || $user_id < 1) {
    echo json_encode([]);
    exit;
}

$sql = "SELECT * FROM messages WHERE sender_id = ? OR receiver_id = ? ORDER BY created_at ASC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ii", $user_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

$messages = [];
if ($result) {
    while($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
}

echo json_encode($messages);
$stmt->close();
$conn->close();
?>
