<?php
require 'config.php';

$is_admin = isset($_GET['is_admin']) && $_GET['is_admin'] === 'true';

if ($is_admin) {
    require_admin($conn);

    $sql = "SELECT o.*, u.name as user_name FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.id DESC";
    $stmt = $conn->prepare($sql);
} else {
    $user_id = request_int('user_id');
    if (!$user_id || $user_id < 1) {
        echo json_encode([]);
        $conn->close();
        exit;
    }

    $sql = "SELECT o.*, u.name as user_name FROM orders o JOIN users u ON o.user_id = u.id WHERE o.user_id = ? ORDER BY o.id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
}

$stmt->execute();
$res = $stmt->get_result();

$orders = [];
if ($res) {
    while($row = $res->fetch_assoc()) {
        $orders[] = $row;
    }
}

echo json_encode($orders);
$stmt->close();
$conn->close();
?>
