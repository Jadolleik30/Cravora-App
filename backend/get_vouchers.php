<?php
require 'config.php';

$sql = "SELECT * FROM vouchers WHERE is_active = 1 AND (expiry_date IS NULL OR expiry_date >= CURDATE())";
$res = $conn->query($sql);
$vouchers = [];
while($row = $res->fetch_assoc()) {
    $vouchers[] = $row;
}

echo json_encode($vouchers);
$conn->close();
?>
