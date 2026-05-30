<?php
require 'config.php';
require_admin($conn);

$stats = [];

$res = $conn->query("SELECT COUNT(*) as count FROM users");
$stats['users'] = $res->fetch_assoc()['count'];

$res = $conn->query("SELECT COUNT(*) as count FROM restaurants");
$stats['restaurants'] = $res->fetch_assoc()['count'];

$res = $conn->query("SELECT COUNT(*) as count FROM food_items");
$stats['foods'] = $res->fetch_assoc()['count'];

$res = $conn->query("SELECT COUNT(*) as count FROM orders");
$stats['orders'] = $res->fetch_assoc()['count'] ?? 0;

echo json_encode($stats);

$conn->close();
?>
