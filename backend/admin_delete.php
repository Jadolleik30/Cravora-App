<?php
require 'config.php';
require_admin($conn);

$allowedTables = ['users', 'restaurants', 'food_items'];
$table = $_POST['table'] ?? '';
$id = request_int('id');
$admin_id = request_int('admin_id');

if (!in_array($table, $allowedTables, true) || !$id || $id < 1) {
    echo json_encode(["status" => "error", "message" => "Invalid delete request"]);
    exit;
}

// Prevent deleting self
if ($table == 'users' && ($id == 1 || $id == $admin_id)) {
    echo json_encode(["status" => "error", "message" => "Cannot delete this admin account"]);
    exit;
}

$sql = "DELETE FROM `$table` WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Delete failed"]);
}

$stmt->close();
$conn->close();
?>
