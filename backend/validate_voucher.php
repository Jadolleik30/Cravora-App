<?php
require 'config.php';

$code = $_POST['code'] ?? '';
$order_value = $_POST['order_value'] ?? 0;

if (empty($code)) {
    echo json_encode(["status" => "error", "message" => "Please enter a voucher code"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM vouchers WHERE code = ? AND is_active = 1 AND (expiry_date IS NULL OR expiry_date >= CURDATE())");
$stmt->bind_param("s", $code);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $voucher = $result->fetch_assoc();
    
    if ($order_value < $voucher['min_order_value']) {
        echo json_encode([
            "status" => "error", 
            "message" => "Minimum order value for this voucher is $" . $voucher['min_order_value']
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "discount_type" => $voucher['discount_type'],
            "discount_value" => (float)$voucher['discount_value'],
            "code" => $voucher['code']
        ]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid or expired voucher code"]);
}

$stmt->close();
$conn->close();
?>
