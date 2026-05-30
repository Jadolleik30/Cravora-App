<?php
require 'config.php';

$user_id = $_POST['user_id'] ?? null;
$notification_id = $_POST['notification_id'] ?? null;
$all = isset($_POST['all']) && $_POST['all'] == 'true';

if (!$user_id) {
    echo json_encode(["status" => "error", "message" => "User ID required"]);
    exit;
}

if ($all) {
    // Mark all as read
    // 1. Mark personal ones
    $sql1 = "UPDATE notifications SET is_read = 1 WHERE user_id = ?";
    $stmt1 = $conn->prepare($sql1);
    $stmt1->bind_param("i", $user_id);
    $stmt1->execute();
    $stmt1->close();

    // 2. Mark broadcast ones (insert into notification_reads if not exists)
    $sql2 = "INSERT IGNORE INTO notification_reads (user_id, notification_id) 
             SELECT ?, id FROM notifications WHERE user_id IS NULL";
    $stmt2 = $conn->prepare($sql2);
    $stmt2->bind_param("i", $user_id);
    $stmt2->execute();
    $stmt2->close();

    echo json_encode(["status" => "success", "message" => "All notifications marked as read"]);
} else {
    if (!$notification_id) {
        echo json_encode(["status" => "error", "message" => "Notification ID required"]);
        exit;
    }

    // Check if it's personal or broadcast
    $check_sql = "SELECT user_id FROM notifications WHERE id = ?";
    $c_stmt = $conn->prepare($check_sql);
    $c_stmt->bind_param("i", $notification_id);
    $c_stmt->execute();
    $res = $c_stmt->get_result()->fetch_assoc();
    $c_stmt->close();

    if ($res['user_id'] !== null) {
        // Personal
        $sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ii", $notification_id, $user_id);
    } else {
        // Broadcast
        $sql = "INSERT IGNORE INTO notification_reads (user_id, notification_id) VALUES (?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ii", $user_id, $notification_id);
    }

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Notification marked as read"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to mark as read"]);
    }
    $stmt->close();
}

$conn->close();
?>
