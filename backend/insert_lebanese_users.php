<?php
require 'config.php';

$users = [
    [
        'name' => 'Ali Hassan',
        'email' => 'ali.hassan@example.lb',
        'password' => password_hash('password123', PASSWORD_DEFAULT),
        'phone' => '+961 70 123 456',
        'address' => 'Beirut, Hamra, Main Street',
        'dob' => '1995-05-15',
        'gender' => 'Male',
        'role' => 'user'
    ],
    [
        'name' => 'Laila Mansour',
        'email' => 'laila.mansour@example.lb',
        'password' => password_hash('password123', PASSWORD_DEFAULT),
        'phone' => '+961 71 234 567',
        'address' => 'Saida, El Koulye, Near University',
        'dob' => '1998-08-20',
        'gender' => 'Female',
        'role' => 'user'
    ],
    [
        'name' => 'Rami Chehab',
        'email' => 'rami.chehab@example.lb',
        'password' => password_hash('password123', PASSWORD_DEFAULT),
        'phone' => '+961 06 345 678',
        'address' => 'Tripoli, Mina, Sea Road',
        'dob' => '1992-03-10',
        'gender' => 'Male',
        'role' => 'user'
    ],
    [
        'name' => 'Maya Khoury',
        'email' => 'maya.khoury@example.lb',
        'password' => password_hash('password123', PASSWORD_DEFAULT),
        'phone' => '+961 09 456 789',
        'address' => 'Jounieh, Kaslik, Old Souk',
        'dob' => '1996-11-25',
        'gender' => 'Female',
        'role' => 'user'
    ],
    [
        'name' => 'Hassan Zein',
        'email' => 'hassan.zein@example.lb',
        'password' => password_hash('password123', PASSWORD_DEFAULT),
        'phone' => '+961 07 567 890',
        'address' => 'Tyre, Corniche, Al-Jabal Street',
        'dob' => '1990-07-05',
        'gender' => 'Male',
        'role' => 'user'
    ],
    [
        'name' => 'Nour Haddad',
        'email' => 'nour.haddad@example.lb',
        'password' => password_hash('password123', PASSWORD_DEFAULT),
        'phone' => '+961 08 678 901',
        'address' => 'Zahle, Berdawni, Near Cafes',
        'dob' => '1994-01-30',
        'gender' => 'Female',
        'role' => 'user'
    ]
];

foreach ($users as $u) {
    $stmt = $conn->prepare("INSERT INTO users (name, email, password, phone, address, dob, gender, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssss", $u['name'], $u['email'], $u['password'], $u['phone'], $u['address'], $u['dob'], $u['gender'], $u['role']);
    $stmt->execute();
    $uid = $conn->insert_id;

    // Add a welcome notification
    $stmt_notif = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, 'Welcome to Cravora!', 'We are excited to have you with us, ' || ? || '!')");
    // SQLite syntax || used accidentally in thought, using MySQL CONCAT or just PHP string
    $welcome_msg = "We are excited to have you with us, " . $u['name'] . "!";
    $stmt_notif = $conn->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, 'Welcome to Cravora!', ?)");
    $stmt_notif->bind_param("is", $uid, $welcome_msg);
    $stmt_notif->execute();

    // Add a sample order for some users
    if ($uid % 2 == 0) {
        $total = rand(20, 100);
        $stmt_order = $conn->prepare("INSERT INTO orders (user_id, total_price, delivery_address, payment_method) VALUES (?, ?, ?, 'Cash on Delivery')");
        $stmt_order->bind_param("ids", $uid, $total, $u['address']);
        $stmt_order->execute();
    }
}

echo "6 users and their data inserted successfully.";
$conn->close();
?>
