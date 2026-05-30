<?php
require 'config.php';

// 1. Create restaurants table
$sql = "CREATE TABLE IF NOT EXISTS restaurants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image VARCHAR(255),
    description TEXT,
    rating DECIMAL(2,1) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
$conn->query($sql);

// 2. Add restaurant_id to food_items if not exists
$check = $conn->query("SHOW COLUMNS FROM food_items LIKE 'restaurant_id'");
if ($check->num_rows == 0) {
    $conn->query("ALTER TABLE food_items ADD COLUMN restaurant_id INT");
    $conn->query("ALTER TABLE food_items ADD FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)");
}

// 3. Insert sample restaurant
$conn->query("INSERT IGNORE INTO restaurants (id, name, image, description, rating, review_count) VALUES 
(1, 'Lebanese Restaurant', 'https://images.unsplash.com/photo-1541544741938-0af808871cc0', 'Authentic Lebanese cuisine with fresh ingredients.', 4.8, 120)");

// 4. Update existing food items to belong to this restaurant
$conn->query("UPDATE food_items SET restaurant_id = 1 WHERE restaurant_id IS NULL");

echo "Database updated successfully with Restaurants.";
$conn->close();
?>
