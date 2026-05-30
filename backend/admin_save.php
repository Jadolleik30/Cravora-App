<?php
require 'config.php';
require_admin($conn);

$allowedColumns = [
    'users' => ['name', 'email', 'role', 'password', 'phone', 'address', 'dob', 'gender', 'points', 'is_verified', 'profile_completed'],
    'restaurants' => ['name', 'image', 'description', 'rating', 'review_count'],
    'food_items' => ['category_id', 'name', 'description', 'price', 'image', 'rating', 'discount', 'ingredients', 'calories', 'featured_review', 'restaurant_id'],
];

$table = $_POST['table'] ?? '';
$id = request_int('id');
$data = $_POST;
unset($data['table'], $data['id'], $data['admin_id']);

if (!isset($allowedColumns[$table])) {
    echo json_encode(["status" => "error", "message" => "Invalid table"]);
    exit;
}

if ($table == 'users' && array_key_exists('password', $data)) {
    if (trim($data['password']) === '') {
        unset($data['password']);
    } else {
        $data['password'] = password_hash($data['password'], PASSWORD_DEFAULT);
    }
}

if ($table == 'users' && !$id && empty($data['password'])) {
    echo json_encode(["status" => "error", "message" => "Password is required for new users"]);
    exit;
}

$filtered = [];
foreach ($data as $key => $val) {
    if (in_array($key, $allowedColumns[$table], true)) {
        $filtered[$key] = $val;
    }
}

if (empty($filtered)) {
    echo json_encode(["status" => "error", "message" => "No valid fields to save"]);
    exit;
}

function bind_params($stmt, $types, &$values) {
    $params = [$types];
    foreach ($values as $key => &$value) {
        $params[] = &$value;
    }
    return call_user_func_array([$stmt, 'bind_param'], $params);
}

$fields = array_keys($filtered);
$values = array_values($filtered);

if ($id && $id > 0) {
    // Update
    $updates = array_map(function($field) {
        return "`$field` = ?";
    }, $fields);
    $sql = "UPDATE `$table` SET " . implode(", ", $updates) . " WHERE id = ?";
    $values[] = $id;
    $types = str_repeat("s", count($fields)) . "i";
} else {
    // Insert
    $columns = implode(", ", array_map(function($field) {
        return "`$field`";
    }, $fields));
    $placeholders = implode(", ", array_fill(0, count($fields), "?"));
    $sql = "INSERT INTO `$table` ($columns) VALUES ($placeholders)";
    $types = str_repeat("s", count($fields));
}

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Could not prepare save"]);
    $conn->close();
    exit;
}

bind_params($stmt, $types, $values);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Save failed"]);
}

$stmt->close();
$conn->close();
?>
