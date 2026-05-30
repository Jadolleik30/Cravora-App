<?php
require 'config.php';

$user_id = $_GET['user_id'] ?? null;
$is_admin = isset($_GET['is_admin']) && $_GET['is_admin'] == 'true';

if ($is_admin) {
    require_admin($conn);

    $sql = "SELECT n.*, u.name as user_name FROM notifications n LEFT JOIN users u ON n.user_id = u.id ORDER BY n.created_at DESC";
    $result = $conn->query($sql);
    $notifications = [];
    while ($row = $result->fetch_assoc()) { $notifications[] = $row; }
    echo json_encode(["status" => "success", "data" => $notifications]);
} else {
    if ($user_id === "null" || $user_id === "") $user_id = null;
    
    // Super simple fetch for testing
    $sql = "SELECT * FROM notifications WHERE user_id = ? OR user_id IS NULL ORDER BY created_at DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $notifications = [];
    while ($row = $result->fetch_assoc()) {
        // Manually handle is_read for broadcast
        if ($row['user_id'] === null) {
            $check = $conn->prepare("SELECT COUNT(*) as count FROM notification_reads WHERE notification_id = ? AND user_id = ?");
            $check->bind_param("ii", $row['id'], $user_id);
            $check->execute();
            $cres = $check->get_result()->fetch_assoc();
            $row['is_read'] = $cres['count'] > 0 ? 1 : 0;
            $check->close();
        }
        $notifications[] = $row;
    }
    echo json_encode(["status" => "success", "data" => $notifications]);
    $stmt->close();
}
$conn->close();
?>
