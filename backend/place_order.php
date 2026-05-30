<?php
require 'config.php';

$user_id = $_POST['user_id'] ?? '';
$total_price = $_POST['total_price'] ?? '';
$address = $_POST['address'] ?? '';
$payment_method = $_POST['payment_method'] ?? '';

if (empty($user_id) || empty($total_price)) {
    echo json_encode(["status" => "error", "message" => "Invalid order data"]);
    exit;
}

$sql = "INSERT INTO orders (user_id, total_price, delivery_address, payment_method) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("idss", $user_id, $total_price, $address, $payment_method);

if ($stmt->execute()) {
    // Award 1 point for every $1 spent
    $points = (int) $total_price;
    $conn->query("UPDATE users SET points = points + $points WHERE id = '$user_id'");
    
    echo json_encode(["status" => "success", "message" => "Order placed successfully! You earned $points points."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to place order"]);
}

$stmt->close();
$conn->close();
?>
