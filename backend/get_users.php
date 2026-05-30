<?php
require 'config.php';
require_admin($conn);

$res = $conn->query("SELECT id, name, email, role, phone, address FROM users");
$users = [];
while($row = $res->fetch_assoc()) {
    $users[] = $row;
}

echo json_encode($users);
$conn->close();
?>
