<?php
require 'config.php';
require_admin($conn);

$user_id = $_POST['user_id'] ?? null; // Can be null for "all"
$title = $_POST['title'] ?? '';
$message = $_POST['message'] ?? '';

if (empty($title) || empty($message)) {
    echo json_encode(["status" => "error", "message" => "Title and message are required"]);
    exit;
}

// Convert "null" string to actual null if passed as string
if ($user_id === "null" || $user_id === "") {
    $user_id = null;
} else {
    $user_id = filter_var($user_id, FILTER_VALIDATE_INT);
    if (!$user_id || $user_id < 1) {
        echo json_encode(["status" => "error", "message" => "Invalid user"]);
        exit;
    }
}

$sql = "INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iss", $user_id, $title, $message);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Notification added successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to add notification: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
