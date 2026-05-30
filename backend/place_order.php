<?php
require 'config.php';

$user_id = request_int('user_id');
$address = trim($_POST['address'] ?? '');
$payment_method = trim($_POST['payment_method'] ?? '');
$voucher_code = trim($_POST['voucher_code'] ?? '');
$items_json = $_POST['items'] ?? '';
$items = json_decode($items_json, true);

if (!$user_id || $user_id < 1) {
    echo json_encode(["status" => "error", "message" => "Invalid order data"]);
    exit;
}

$profile_stmt = $conn->prepare("SELECT profile_completed FROM users WHERE id = ? LIMIT 1");
if (!$profile_stmt) {
    echo json_encode(["status" => "error", "message" => "Checkout is not ready. Please run the users table migration."]);
    $conn->close();
    exit;
}

$profile_stmt->bind_param("i", $user_id);
$profile_stmt->execute();
$profile_result = $profile_stmt->get_result();

if (!$profile_result || $profile_result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "User not found"]);
    $profile_stmt->close();
    $conn->close();
    exit;
}

$profile = $profile_result->fetch_assoc();
$profile_stmt->close();

if ((int)($profile['profile_completed'] ?? 0) !== 1) {
    echo json_encode(["status" => "profile_incomplete", "message" => "Please complete your profile before placing an order."]);
    $conn->close();
    exit;
}

if (empty($address) || empty($payment_method) || !is_array($items) || count($items) === 0) {
    echo json_encode(["status" => "error", "message" => "Invalid order data"]);
    exit;
}

try {
    $conn->begin_transaction();

    $subtotal = 0.0;
    $order_items = [];

    $food_stmt = $conn->prepare("SELECT id, price, discount FROM food_items WHERE id = ?");
    if (!$food_stmt) {
        throw new Exception("Could not prepare food lookup");
    }

    foreach ($items as $item) {
        $food_id = filter_var($item['food_id'] ?? $item['id'] ?? null, FILTER_VALIDATE_INT);
        $quantity = filter_var($item['quantity'] ?? 1, FILTER_VALIDATE_INT);

        if (!$food_id || $food_id < 1 || !$quantity || $quantity < 1) {
            throw new Exception("Invalid cart item");
        }

        if ($quantity > 99) {
            $quantity = 99;
        }

        $food_stmt->bind_param("i", $food_id);
        $food_stmt->execute();
        $food_result = $food_stmt->get_result();

        if (!$food_result || $food_result->num_rows === 0) {
            throw new Exception("Food item not found");
        }

        $food = $food_result->fetch_assoc();
        $price = (float)$food['price'];
        $discount = isset($food['discount']) ? (float)$food['discount'] : 0.0;
        $unit_price = ($discount > 0 && $discount < $price) ? $discount : $price;

        $subtotal += $unit_price * $quantity;
        $order_items[] = [
            "food_id" => $food_id,
            "quantity" => $quantity,
            "price" => $unit_price
        ];
    }
    $food_stmt->close();

    $discount_amount = 0.0;
    if ($voucher_code !== '') {
        $voucher_stmt = $conn->prepare("SELECT code, discount_type, discount_value, min_order_value FROM vouchers WHERE code = ? AND is_active = 1 AND (expiry_date IS NULL OR expiry_date >= CURDATE())");
        if (!$voucher_stmt) {
            throw new Exception("Could not prepare voucher lookup");
        }

        $voucher_stmt->bind_param("s", $voucher_code);
        $voucher_stmt->execute();
        $voucher_result = $voucher_stmt->get_result();

        if (!$voucher_result || $voucher_result->num_rows === 0) {
            throw new Exception("Invalid or expired voucher code");
        }

        $voucher = $voucher_result->fetch_assoc();
        if ($subtotal < (float)$voucher['min_order_value']) {
            throw new Exception("Minimum order value for this voucher is $" . $voucher['min_order_value']);
        }

        if ($voucher['discount_type'] === 'percentage') {
            $discount_amount = $subtotal * ((float)$voucher['discount_value'] / 100);
        } else {
            $discount_amount = (float)$voucher['discount_value'];
        }

        if ($discount_amount > $subtotal) {
            $discount_amount = $subtotal;
        }

        $voucher_stmt->close();
    }

    $total_price = round($subtotal - $discount_amount, 2);
    $order_stmt = $conn->prepare("INSERT INTO orders (user_id, total_price, delivery_address, payment_method) VALUES (?, ?, ?, ?)");
    if (!$order_stmt) {
        throw new Exception("Could not prepare order");
    }

    $order_stmt->bind_param("idss", $user_id, $total_price, $address, $payment_method);
    if (!$order_stmt->execute()) {
        throw new Exception("Failed to place order");
    }

    $order_id = $conn->insert_id;
    $order_stmt->close();

    $item_stmt = $conn->prepare("INSERT INTO order_items (order_id, food_id, quantity, price) VALUES (?, ?, ?, ?)");
    if (!$item_stmt) {
        throw new Exception("Could not prepare order items");
    }

    foreach ($order_items as $item) {
        $item_food_id = $item['food_id'];
        $item_quantity = $item['quantity'];
        $item_price = $item['price'];

        $item_stmt->bind_param("iiid", $order_id, $item_food_id, $item_quantity, $item_price);
        if (!$item_stmt->execute()) {
            throw new Exception("Failed to save order items");
        }
    }
    $item_stmt->close();

    $points = (int)$total_price;
    $points_stmt = $conn->prepare("UPDATE users SET points = points + ? WHERE id = ?");
    if (!$points_stmt) {
        throw new Exception("Could not prepare points update");
    }

    $points_stmt->bind_param("ii", $points, $user_id);
    if (!$points_stmt->execute()) {
        throw new Exception("Failed to update reward points");
    }
    $points_stmt->close();

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Order placed successfully! You earned $points points.",
        "order_id" => $order_id,
        "total_price" => $total_price,
        "points" => $points
    ]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}

$conn->close();
?>
