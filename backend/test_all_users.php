<?php
require 'config.php';

$res = $conn->query("SELECT id FROM users");
while($u = $res->fetch_assoc()) {
    $uid = $u['id'];
    $stmt = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, 'System Test', 'This is a test notification for your account.')");
    $stmt->bind_param("i", $uid);
    $stmt->execute();
    $stmt->close();
}

echo "Added test notifications for all existing users.";
$conn->close();
?>
