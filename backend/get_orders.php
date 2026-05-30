<?php
require 'config.php';

$sql = "SELECT o.*, u.name as user_name FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.id DESC";
$res = $conn->query($sql);

$orders = [];
if ($res) {
    while($row = $res->fetch_assoc()) {
        $orders[] = $row;
    }
}

echo json_encode($orders);
$conn->close();
?>
