<?php
require 'config.php';

$sql = "SELECT u.id as user_id, u.name, u.email, MAX(m.id) as last_msg_id
        FROM users u
        JOIN messages m ON (m.sender_id = u.id OR m.receiver_id = u.id)
        WHERE u.role != 'admin'
        GROUP BY u.id
        ORDER BY last_msg_id DESC";
$res = $conn->query($sql);

$chats = [];
if ($res) {
    while($row = $res->fetch_assoc()) {
        $chats[] = $row;
    }
} else {
    // Log error if needed
}

echo json_encode($chats);
$conn->close();
?>
