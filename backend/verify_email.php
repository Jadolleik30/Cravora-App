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

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !preg_match('/^\d{6}$/', $code)) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid verification data"
    ]);
    exit;
}

$sql = "SELECT id FROM users
        WHERE email = ?
        AND verification_code = ?
        LIMIT 1";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Verification is not ready. Please run the users table migration."
    ]);
    $conn->close();
    exit;
}

$stmt->bind_param("ss", $email, $code);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $verifiedUser = $result->fetch_assoc();
    $userId = (int)$verifiedUser['id'];

    $update = $conn->prepare(
        "UPDATE users
         SET is_verified = 1,
             verification_code = NULL
         WHERE id = ?"
    );

    $update->bind_param("i", $userId);
    if (!$update->execute()) {
        echo json_encode([
            "status" => "error",
            "message" => "Could not verify email"
        ]);
        $update->close();
        $conn->close();
        exit;
    }
    $update->close();

    $fetch = $conn->prepare("SELECT id, name, email, role, phone, address, dob, gender, points, is_verified, profile_completed FROM users WHERE id = ?");
    if (!$fetch) {
        echo json_encode([
            "status" => "error",
            "message" => "Verification completed, but profile status is not ready. Please run the users table migration."
        ]);
        $conn->close();
        exit;
    }

    $fetch->bind_param("i", $userId);
    $fetch->execute();
    $userResult = $fetch->get_result();
    $user = $userResult->fetch_assoc();
    $fetch->close();

    echo json_encode([
        "status" => "success",
        "message" => "Email verified successfully",
        "user" => $user
    ]);

} else {

    echo json_encode([
        "status" => "error",
        "message" => "Invalid verification code"
    ]);
}

$conn->close();
?>
