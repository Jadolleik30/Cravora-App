<?php
require 'config.php';

$table = $_POST['table'];
$id = $_POST['id'];

// Prevent deleting self
if ($table == 'users' && $id == 1) {
    echo json_encode(["status" => "error", "message" => "Cannot delete primary admin"]);
    exit;
}

$sql = "DELETE FROM $table WHERE id = $id";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
