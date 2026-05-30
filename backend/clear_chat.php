<?php
require 'config.php';

$user_id = $_POST['user_id'];

$sql = "DELETE FROM messages WHERE sender_id = '$user_id' OR receiver_id = '$user_id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
