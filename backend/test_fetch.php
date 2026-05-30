<?php
require 'config.php';
require_cli_or_admin($conn);
$user_id = 1;
$sql = "SELECT n.*, 
        CASE 
            WHEN n.user_id IS NOT NULL THEN n.is_read
            ELSE (SELECT COUNT(*) FROM notification_reads nr WHERE nr.notification_id = n.id AND nr.user_id = ?)
        END as is_read
        FROM notifications n 
        WHERE n.user_id = ? OR n.user_id IS NULL 
        ORDER BY n.created_at DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ii", $user_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();
$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}
echo json_encode($notifications);
$stmt->close();
$conn->close();
?>
