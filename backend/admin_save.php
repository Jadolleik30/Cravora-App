<?php
require 'config.php';

$table = $_POST['table'];
$id = $_POST['id'] ?? null;
$data = $_POST;
unset($data['table'], $data['id']);

if ($table == 'users' && isset($data['password'])) {
    $data['password'] = password_hash($data['password'], PASSWORD_DEFAULT);
}

$fields = [];
$values = [];
$updates = [];

foreach ($data as $key => $val) {
    $val_esc = $conn->real_escape_string($val);
    $fields[] = $key;
    $values[] = "'$val_esc'";
    $updates[] = "$key = '$val_esc'";
}

if ($id && $id != "null" && $id != "") {
    // Update
    $sql = "UPDATE $table SET " . implode(", ", $updates) . " WHERE id = $id";
} else {
    // Insert
    $sql = "INSERT INTO $table (" . implode(", ", $fields) . ") VALUES (" . implode(", ", $values) . ")";
}

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
