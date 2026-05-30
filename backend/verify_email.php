<?php
require 'config.php';

$email = trim($_POST['email'] ?? '');
$code = trim($_POST['code'] ?? '');

if (empty($email) || empty($code)) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing data"
    ]);
    exit;
}

$sql = "SELECT id FROM users
        WHERE email = ?
        AND verification_code = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $email, $code);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows > 0) {

    $update = $conn->prepare(
        "UPDATE users
         SET is_verified = 1,
             verification_code = NULL
         WHERE email = ?"
    );

    $update->bind_param("s", $email);
    $update->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Email verified successfully"
    ]);

} else {

    echo json_encode([
        "status" => "error",
        "message" => "Invalid verification code"
    ]);
}

$conn->close();
?>
