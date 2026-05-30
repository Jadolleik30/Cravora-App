-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 15, 2026 at 07:31 PM
-- Server version: 8.2.0
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `jad_olleik`
--

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
CREATE TABLE IF NOT EXISTS `cart` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `food_id` int DEFAULT NULL,
  `quantity` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `food_id` (`food_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`id`, `user_id`, `food_id`, `quantity`) VALUES
(1, 1, 7, 1),
(2, 1, 8, 2);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `image`) VALUES
(1, 'Pizza', 'pizza.png'),
(2, 'Burgers', 'burger.png'),
(3, 'Sushi', 'sushi.png'),
(4, 'Platters', NULL),
(5, 'Desserts', NULL),
(6, 'Drinks', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `food_items`
--

DROP TABLE IF EXISTS `food_items`;
CREATE TABLE IF NOT EXISTS `food_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT '0.0',
  `discount` decimal(10,2) DEFAULT '0.00',
  `ingredients` text,
  `calories` int DEFAULT '0',
  `featured_review` text,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `food_items`
--

INSERT INTO `food_items` (`id`, `category_id`, `name`, `description`, `price`, `image`, `rating`, `discount`, `ingredients`, `calories`, `featured_review`, `restaurant_id`) VALUES
(1, 2, 'Duo Beef', 'beef patty, mustard, ketchup, onion, pickles, lettuce, and tomato, served with fries and a soft drink', 10.99, 'https://s7d1.scene7.com/is/image/mcdonalds/mcd-cheeseburger-duo-meal-kw-0623:nutrition-calculator-tile?wid=822&hei=822&dpr=off', 0.0, 0.00, 'beef, mustard, ketchup, onion, pickles, lettuce, tomato', 0, NULL, 1),
(2, 2, 'Duo Chicken', 'chicken portion, lettuce, and mayo sauce served with fries and a soft drink', 9.99, 'https://mcdonalds.com.lb/storage/promotions/November2024/hbR5pBwLaw1ZrcB5PhVL.png', 0.0, 0.00, 'chicken, lettuce, mayo', 0, NULL, 1),
(3, 2, 'Duo Mix', 'one hamburger and one chicken burger, served with fries and a soft drink', 12.99, 'https://s7d1.scene7.com/is/image/mcdonalds/mcd-mix-duo-meal-kw-0623:nutrition-calculator-tile?wid=822&hei=822&dpr=off', 0.0, 0.00, 'beef, chicken', 0, NULL, 1),
(4, 4, 'Crispy Chicken Tenders', '4 pieces, fried chicken tenders, served with honey mustard sauce', 8.50, 'https://www.allrecipes.com/thmb/YwJvX75IUx8uQ7PKz2eTDjCoLvY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/16669-fried-chicken-tenders-DDMFS-4x3-219f03b885be40139c8d93bef21d0a50.jpg', 0.0, 0.00, 'chicken, honey mustard', 0, NULL, 2),
(5, 4, 'Chef Half Salad', 'iceberg, corn, fresh mushroom, cherry tomatoes, turkey, shredded mozzarella cheese, croutons, black olives, boiled egg and topped with strips of chicken breast', 11.00, 'https://thepie.com/media/k2/items/cache/048731097de322302aff7e52151c991d_XL.jpg', 0.0, 0.00, 'iceberg, corn, mushroom, tomato, turkey, cheese, egg, chicken', 0, NULL, 2),
(6, 2, 'Cheddar Blast Burger', 'beef patty, bacon, caramelized onions, lollo rosso, potato chips, melted cheddar cheese and ranch sauce served in a burger bun', 13.50, 'https://images.deliveryhero.io/image/fd-tr/LH/owvh-listing.jpg', 0.0, 0.00, 'beef, bacon, onion, cheese, ranch', 0, NULL, 2),
(7, 6, 'Spanish latte', '', 5.50, 'https://www.mygingergarlickitchen.com/wp-content/rich-markup-images/1x1/1x1-iced-spanish-latte.jpg', 0.0, 0.00, '', 0, NULL, 3),
(8, 6, 'Tiramisu latte', '', 6.00, 'https://recipecontent.fooby.ch/16854_3-2_1920-1280.jpg', 0.0, 0.00, '', 0, NULL, 3),
(9, 6, 'Hot chocolate', '', 4.50, 'https://www.foodandwine.com/thmb/V1OEgtLQGUv_w2Fvm40WMLsJ4rk=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Indulgent-Hot-Chocolate-FT-RECIPE0223-fd36942ef266417ab40440374fc76a15.jpg', 0.0, 0.00, '', 0, NULL, 3),
(10, 6, 'Sugar free ice tea', '', 4.00, 'https://www.torani.com/media/catalog/product/S/u/Sugar_Free_Coconut_Iced_Tea.jpg?optimize=medium&fit=bounds&height=&width=', 0.0, 0.00, '', 0, NULL, 3),
(11, 6, 'Americano', '', 3.50, 'https://www.foodandwine.com/thmb/9JyfZPcxlV9ubEeuSznhO-M4q0w=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Partners-Americano-FT-BLOG0523-b8e18cc340574cc9bed536cceeec7082.jpg', 0.0, 0.00, '', 0, NULL, 4),
(12, 6, 'Flat white', '', 4.50, 'https://www.lavazzausa.com/en/recipes-and-coffee-hacks/how-to-make-flat-white-coffee/_jcr_content/root/cust/customcontainer/image.coreimg.jpeg/1763100623166/d-m-how-to-slot-1-large%402.jpeg', 0.0, 0.00, '', 0, NULL, 4),
(13, 6, 'Cortado', '', 4.00, 'https://gospecialtycoffee.com/medialibrary/2023/07/cortado-gospecialtycoffee.jpg', 0.0, 0.00, '', 0, NULL, 4),
(14, 4, 'Burrito De Carne', 'pulled beef, refried beans, rice, guacamole, tomato salsa, pico de gallo, white cheese, cheddar cheese and crema', 12.00, 'https://comedera.com/wp-content/uploads/sites/9/2023/07/shutterstock_311800970.jpg', 0.0, 0.00, 'beef, beans, rice, guacamole, salsa, cheese, crema', 0, NULL, 5),
(15, 4, 'Burrito De Pollo', 'chicken fillet, refried beans, rice, guacamole, tomato salsa, pico de gallo, white cheese, cheddar cheese and crema', 11.00, 'https://especiasmontero.com/wp-content/uploads/2019/04/Burrito-de-pollo-1.jpg', 0.0, 0.00, 'chicken, beans, rice, guacamole, salsa, cheese, crema', 0, NULL, 5),
(16, 4, 'Burrito De Supremo', 'pulled beef or chicken fillet, refried beans, guacamole, Mexican coleslaw, jalapeños, white cheese, cheddar cheese, rice, grilled onions, grilled bell pepper and crema topped with melted cheddar, crema and sesame seeds', 15.00, 'https://villacocina.com/wp-content/uploads/2023/06/Burrito-Supremo-WEBSITE--scaled.jpg', 0.0, 0.00, 'beef, chicken, beans, guacamole, jalapeños, cheese, rice, onion, pepper', 0, NULL, 5),
(17, 4, 'Calamari Sandwich', 'calamari (3pcs), iceberg, lemon and tartar sauce served in baguette bread', 9.00, 'https://i0.wp.com/spainonafork.com/wp-content/uploads/2019/09/calamari4-1-11.png?fit=750%2C750&ssl=1', 0.0, 0.00, 'calamari, iceberg, lemon, tartar', 0, NULL, 6),
(18, 4, 'Crispy Shrimp Sandwich', 'shrimps (7pcs), iceberg, pickles, tartar sauce and cocktail sauce served in baguette bread', 10.50, 'https://www.simplyrecipes.com/thmb/NWR2yj5F6btUCzcJ9M3r4WsZk0M=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Simply-Recipes-Shrimp-Po-Boy-LEAD-22-33ab39c8d49249d688918b1039f72468.jpg', 0.0, 0.00, 'shrimp, iceberg, pickles, tartar, cocktail', 0, NULL, 6),
(19, 4, 'Crispy Seafood Mix Platter', 'shrimps (8pcs), crispy fillet (3pcs), calamari (1 piece), French fries, pickles, tartar sauce, cocktail sauce and a baby bun', 22.00, 'https://anitalianinmykitchen.com/wp-content/uploads/2019/12/fried-seafood-pic-1-of-1-1024x683.jpg', 0.0, 0.00, 'shrimp, fillet, calamari, fries, pickles, tartar, cocktail', 0, NULL, 6),
(20, 4, 'Loaded Seafood Platter', 'French fries (225g), crab (125g), shrimps (5pcs), BBQ and cocktail sauce', 25.00, 'https://img.taste.com.au/QaJlmTJf/taste/2018/11/seafood-platter-144041-1.jpg', 0.0, 0.00, 'fries, crab, shrimp, bbq, cocktail', 0, NULL, 6),
(21, 5, 'Tray of Mafrouket El Moulouk', 'A combination of pistachio paste, halewet el jeben and kashta topped with roasted pistachios', 30.00, 'https://www.hallab.com.lb/web/image/product.template/78916/image_512/Mafrouket%20Al%20Moulouk?unique=101d51b', 0.0, 0.00, 'pistachio, halewet el jeben, kashta', 0, NULL, 7),
(22, 5, 'Basma Hallab 1 Portion', 'A portion of fried vermicelli dough stuffed with kashta cream and a layer of pistachio paste', 6.50, 'https://www.hallab.com.lb/web/image/product.template/50431/image_512/%5BBasma%20Hallab-Plt%5D%20Osmaliyeh%20El%20Hallab%20Plate?unique=bd796c3', 0.0, 0.00, 'vermicelli, kashta, pistachio', 0, NULL, 7),
(23, 5, 'Tin Box Of Maamoul Bite Mix', 'Dipped In Chocolate (Pre Order 48 Hours)', 20.00, 'https://www.hallab.com.lb/web/image/product.template/78915/image_1024?unique=7e8673d', 0.0, 0.00, 'maamoul, chocolate', 0, NULL, 7);

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int DEFAULT NULL,
  `receiver_id` int DEFAULT '0',
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `receiver_id`, `message`, `created_at`) VALUES
(5, 1, 2, 'Hello, I have a question about my order.', '2026-05-15 17:58:06'),
(6, 2, 1, 'Hello Jad! How can I help you today?', '2026-05-15 17:58:06'),
(7, 1, 2, 'Is McDonald\'s still delivering?', '2026-05-15 17:58:06'),
(8, 2, 1, 'Yes, we are delivering from McDonald\'s until 11 PM.', '2026-05-15 17:58:06'),
(9, 1, 2, 'Great, thank you!', '2026-05-15 17:58:06'),
(10, 2, 1, 'You\'re welcome! Let us know if you need anything else.', '2026-05-15 17:58:06'),
(12, 8, 2, 'Hi, I have a question about my last order.', '2026-05-15 18:04:14'),
(13, 2, 8, 'Hello Nour Haddad, I\'m here to help. What\'s the issue?', '2026-05-15 18:04:14'),
(14, 8, 2, 'The food arrived a bit cold, but the taste was great.', '2026-05-15 18:04:14'),
(15, 2, 8, 'I\'m sorry about that. I\'ve credited a discount to your account for next time.', '2026-05-15 18:04:14'),
(16, 8, 2, 'Thank you so much! Really appreciate the quick support.', '2026-05-15 18:04:14'),
(17, 7, 2, 'Hi, I have a question about my last order.', '2026-05-15 18:04:14'),
(18, 2, 7, 'Hello Hassan Zein, I\'m here to help. What\'s the issue?', '2026-05-15 18:04:14'),
(19, 7, 2, 'The food arrived a bit cold, but the taste was great.', '2026-05-15 18:04:14'),
(20, 2, 7, 'I\'m sorry about that. I\'ve credited a discount to your account for next time.', '2026-05-15 18:04:14'),
(21, 7, 2, 'Thank you so much! Really appreciate the quick support.', '2026-05-15 18:04:14'),
(22, 6, 2, 'Hi, I have a question about my last order.', '2026-05-15 18:04:14'),
(23, 2, 6, 'Hello Maya Khoury, I\'m here to help. What\'s the issue?', '2026-05-15 18:04:14'),
(24, 6, 2, 'The food arrived a bit cold, but the taste was great.', '2026-05-15 18:04:14'),
(25, 2, 6, 'I\'m sorry about that. I\'ve credited a discount to your account for next time.', '2026-05-15 18:04:14'),
(26, 6, 2, 'Thank you so much! Really appreciate the quick support.', '2026-05-15 18:04:14'),
(27, 5, 2, 'Hi, I have a question about my last order.', '2026-05-15 18:04:14'),
(28, 2, 5, 'Hello Rami Chehab, I\'m here to help. What\'s the issue?', '2026-05-15 18:04:14'),
(29, 5, 2, 'The food arrived a bit cold, but the taste was great.', '2026-05-15 18:04:14'),
(30, 2, 5, 'I\'m sorry about that. I\'ve credited a discount to your account for next time.', '2026-05-15 18:04:14'),
(31, 5, 2, 'Thank you so much! Really appreciate the quick support.', '2026-05-15 18:04:14'),
(32, 4, 2, 'Hi, I have a question about my last order.', '2026-05-15 18:04:14'),
(33, 2, 4, 'Hello Laila Mansour, I\'m here to help. What\'s the issue?', '2026-05-15 18:04:14'),
(34, 4, 2, 'The food arrived a bit cold, but the taste was great.', '2026-05-15 18:04:14'),
(35, 2, 4, 'I\'m sorry about that. I\'ve credited a discount to your account for next time.', '2026-05-15 18:04:14'),
(36, 4, 2, 'Thank you so much! Really appreciate the quick support.', '2026-05-15 18:04:14'),
(37, 3, 2, 'Hi, I have a question about my last order.', '2026-05-15 18:04:14'),
(38, 2, 3, 'Hello Ali Hassan, I\'m here to help. What\'s the issue?', '2026-05-15 18:04:14'),
(39, 3, 2, 'The food arrived a bit cold, but the taste was great.', '2026-05-15 18:04:14'),
(40, 2, 3, 'I\'m sorry about that. I\'ve credited a discount to your account for next time.', '2026-05-15 18:04:14'),
(41, 3, 2, 'Thank you so much! Really appreciate the quick support.', '2026-05-15 18:04:14');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `created_at`, `is_read`) VALUES
(1, 1, 'wefewfew', 'ewfewfewef', '2026-05-11 06:26:35', 1),
(2, 1, 'Welcome to Cravora!', 'Thank you for joining our community. Enjoy the best food in town!', '2026-05-11 06:36:46', 1),
(3, 1, 'Lunch Special', 'Get 20% off on all pizzas between 12 PM and 3 PM today!', '2026-05-11 06:36:46', 1),
(4, 1, 'New Restaurant Alert', 'Check out \'The Burger Joint\' now available on Cravora!', '2026-05-11 06:36:46', 1),
(5, 1, 'Flash Sale!', 'Limited time offer: Free delivery on orders above $30.', '2026-05-11 06:36:46', 1),
(6, 1, 'System Test', 'This is a test notification for your account.', '2026-05-11 07:15:59', 1),
(7, 2, 'System Test', 'This is a test notification for your account.', '2026-05-11 07:15:59', 0),
(8, 3, 'Welcome to Cravora!', 'We are excited to have you with us, Ali Hassan!', '2026-05-15 18:03:15', 0),
(9, 4, 'Welcome to Cravora!', 'We are excited to have you with us, Laila Mansour!', '2026-05-15 18:03:15', 0),
(10, 5, 'Welcome to Cravora!', 'We are excited to have you with us, Rami Chehab!', '2026-05-15 18:03:15', 0),
(11, 6, 'Welcome to Cravora!', 'We are excited to have you with us, Maya Khoury!', '2026-05-15 18:03:15', 0),
(12, 7, 'Welcome to Cravora!', 'We are excited to have you with us, Hassan Zein!', '2026-05-15 18:03:15', 0),
(13, 8, 'Welcome to Cravora!', 'We are excited to have you with us, Nour Haddad!', '2026-05-15 18:03:15', 0),
(14, 8, 'Order Dispatched', 'Your order has been picked up and is on its way.', '2026-05-15 18:04:14', 0),
(15, 8, 'Special Discount for You!', 'Use code LEBANON20 for 20% off your next meal.', '2026-05-15 18:04:14', 0),
(16, 8, 'New Restaurant Added', 'Check out the new Lebanese grill restaurant in your area.', '2026-05-15 18:04:14', 0),
(17, 8, 'Your Feedback Matters', 'Tell us how we did on your last order to win a prize.', '2026-05-15 18:04:14', 0),
(18, 8, 'Weekly Recap', 'You saved 5000 LBP this week by using Cravora!', '2026-05-15 18:04:14', 0),
(19, 7, 'Order Dispatched', 'Your order has been picked up and is on its way.', '2026-05-15 18:04:14', 0),
(20, 7, 'Special Discount for You!', 'Use code LEBANON20 for 20% off your next meal.', '2026-05-15 18:04:14', 0),
(21, 7, 'New Restaurant Added', 'Check out the new Lebanese grill restaurant in your area.', '2026-05-15 18:04:14', 0),
(22, 7, 'Your Feedback Matters', 'Tell us how we did on your last order to win a prize.', '2026-05-15 18:04:14', 0),
(23, 7, 'Weekly Recap', 'You saved 5000 LBP this week by using Cravora!', '2026-05-15 18:04:14', 0),
(24, 6, 'Order Dispatched', 'Your order has been picked up and is on its way.', '2026-05-15 18:04:14', 0),
(25, 6, 'Special Discount for You!', 'Use code LEBANON20 for 20% off your next meal.', '2026-05-15 18:04:14', 0),
(26, 6, 'New Restaurant Added', 'Check out the new Lebanese grill restaurant in your area.', '2026-05-15 18:04:14', 0),
(27, 6, 'Your Feedback Matters', 'Tell us how we did on your last order to win a prize.', '2026-05-15 18:04:14', 0),
(28, 6, 'Weekly Recap', 'You saved 5000 LBP this week by using Cravora!', '2026-05-15 18:04:14', 0),
(29, 5, 'Order Dispatched', 'Your order has been picked up and is on its way.', '2026-05-15 18:04:14', 0),
(30, 5, 'Special Discount for You!', 'Use code LEBANON20 for 20% off your next meal.', '2026-05-15 18:04:14', 0),
(31, 5, 'New Restaurant Added', 'Check out the new Lebanese grill restaurant in your area.', '2026-05-15 18:04:14', 0),
(32, 5, 'Your Feedback Matters', 'Tell us how we did on your last order to win a prize.', '2026-05-15 18:04:14', 0),
(33, 5, 'Weekly Recap', 'You saved 5000 LBP this week by using Cravora!', '2026-05-15 18:04:14', 0),
(34, 4, 'Order Dispatched', 'Your order has been picked up and is on its way.', '2026-05-15 18:04:14', 0),
(35, 4, 'Special Discount for You!', 'Use code LEBANON20 for 20% off your next meal.', '2026-05-15 18:04:14', 0),
(36, 4, 'New Restaurant Added', 'Check out the new Lebanese grill restaurant in your area.', '2026-05-15 18:04:14', 0),
(37, 4, 'Your Feedback Matters', 'Tell us how we did on your last order to win a prize.', '2026-05-15 18:04:14', 0),
(38, 4, 'Weekly Recap', 'You saved 5000 LBP this week by using Cravora!', '2026-05-15 18:04:14', 0),
(39, 3, 'Order Dispatched', 'Your order has been picked up and is on its way.', '2026-05-15 18:04:14', 0),
(40, 3, 'Special Discount for You!', 'Use code LEBANON20 for 20% off your next meal.', '2026-05-15 18:04:14', 0),
(41, 3, 'New Restaurant Added', 'Check out the new Lebanese grill restaurant in your area.', '2026-05-15 18:04:14', 0),
(42, 3, 'Your Feedback Matters', 'Tell us how we did on your last order to win a prize.', '2026-05-15 18:04:14', 0),
(43, 3, 'Weekly Recap', 'You saved 5000 LBP this week by using Cravora!', '2026-05-15 18:04:14', 0);

-- --------------------------------------------------------

--
-- Table structure for table `notification_reads`
--

DROP TABLE IF EXISTS `notification_reads`;
CREATE TABLE IF NOT EXISTS `notification_reads` (
  `user_id` int NOT NULL,
  `notification_id` int NOT NULL,
  `read_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`notification_id`),
  KEY `notification_id` (`notification_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4  ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `status` enum('pending','confirmed','delivered','cancelled') DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `delivery_address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `total_price`, `status`, `payment_method`, `delivery_address`, `created_at`) VALUES
(1, 1, 9.99, 'pending', 'Cash on Delivery', 'beirut', '2026-05-15 17:57:17'),
(2, 4, 33.00, 'pending', 'Cash on Delivery', 'Saida, El Koulye, Near University', '2026-05-15 18:03:15'),
(3, 6, 60.00, 'pending', 'Cash on Delivery', 'Jounieh, Kaslik, Old Souk', '2026-05-15 18:03:15'),
(4, 8, 74.00, 'pending', 'Cash on Delivery', 'Zahle, Berdawni, Near Cafes', '2026-05-15 18:03:15'),
(5, 8, 83.18, 'pending', 'Wish Money', 'Zahle, Berdawni, Near Cafes', '2026-05-15 18:04:14'),
(6, 8, 55.82, 'pending', 'Wish Money', 'Zahle, Berdawni, Near Cafes', '2026-05-15 18:04:14'),
(7, 8, 113.82, 'pending', 'Credit Card', 'Zahle, Berdawni, Near Cafes', '2026-05-15 18:04:14'),
(8, 8, 25.09, 'pending', 'Cash on Delivery', 'Zahle, Berdawni, Near Cafes', '2026-05-15 18:04:14'),
(9, 8, 23.45, 'pending', 'Cash on Delivery', 'Zahle, Berdawni, Near Cafes', '2026-05-15 18:04:14'),
(10, 7, 101.08, 'pending', 'Credit Card', 'Tyre, Corniche, Al-Jabal Street', '2026-05-15 18:04:14'),
(11, 7, 120.52, 'pending', 'Wish Money', 'Tyre, Corniche, Al-Jabal Street', '2026-05-15 18:04:14'),
(12, 7, 93.87, 'pending', 'Cash on Delivery', 'Tyre, Corniche, Al-Jabal Street', '2026-05-15 18:04:14'),
(13, 7, 117.71, 'pending', 'Cash on Delivery', 'Tyre, Corniche, Al-Jabal Street', '2026-05-15 18:04:14'),
(14, 7, 46.71, 'pending', 'Cash on Delivery', 'Tyre, Corniche, Al-Jabal Street', '2026-05-15 18:04:14'),
(15, 6, 97.21, 'pending', 'Cash on Delivery', 'Jounieh, Kaslik, Old Souk', '2026-05-15 18:04:14'),
(16, 6, 58.57, 'pending', 'Cash on Delivery', 'Jounieh, Kaslik, Old Souk', '2026-05-15 18:04:14'),
(17, 6, 97.11, 'pending', 'Credit Card', 'Jounieh, Kaslik, Old Souk', '2026-05-15 18:04:14'),
(18, 6, 38.52, 'pending', 'Cash on Delivery', 'Jounieh, Kaslik, Old Souk', '2026-05-15 18:04:14'),
(19, 6, 56.40, 'pending', 'Cash on Delivery', 'Jounieh, Kaslik, Old Souk', '2026-05-15 18:04:14'),
(20, 5, 93.99, 'pending', 'Wish Money', 'Tripoli, Mina, Sea Road', '2026-05-15 18:04:14'),
(21, 5, 31.89, 'pending', 'Credit Card', 'Tripoli, Mina, Sea Road', '2026-05-15 18:04:14'),
(22, 5, 70.28, 'pending', 'Credit Card', 'Tripoli, Mina, Sea Road', '2026-05-15 18:04:14'),
(23, 5, 17.78, 'pending', 'Credit Card', 'Tripoli, Mina, Sea Road', '2026-05-15 18:04:14'),
(24, 5, 81.52, 'pending', 'Cash on Delivery', 'Tripoli, Mina, Sea Road', '2026-05-15 18:04:14'),
(25, 4, 69.21, 'pending', 'Cash on Delivery', 'Saida, El Koulye, Near University', '2026-05-15 18:04:14'),
(26, 4, 79.45, 'pending', 'Wish Money', 'Saida, El Koulye, Near University', '2026-05-15 18:04:14'),
(27, 4, 61.46, 'pending', 'Wish Money', 'Saida, El Koulye, Near University', '2026-05-15 18:04:14'),
(28, 4, 86.37, 'pending', 'Wish Money', 'Saida, El Koulye, Near University', '2026-05-15 18:04:14'),
(29, 4, 58.40, 'pending', 'Credit Card', 'Saida, El Koulye, Near University', '2026-05-15 18:04:14'),
(30, 3, 19.44, 'pending', 'Wish Money', 'Beirut, Hamra, Main Street', '2026-05-15 18:04:14'),
(31, 3, 90.80, 'pending', 'Wish Money', 'Beirut, Hamra, Main Street', '2026-05-15 18:04:14'),
(32, 3, 36.26, 'pending', 'Credit Card', 'Beirut, Hamra, Main Street', '2026-05-15 18:04:14'),
(33, 3, 97.75, 'pending', 'Wish Money', 'Beirut, Hamra, Main Street', '2026-05-15 18:04:14'),
(34, 3, 109.40, 'pending', 'Wish Money', 'Beirut, Hamra, Main Street', '2026-05-15 18:04:14'),
(35, 1, 10.99, 'pending', 'Cash on Delivery', 'LB', '2026-05-15 18:44:20');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `food_id` int DEFAULT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `food_id` (`food_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `food_id`, `quantity`, `price`) VALUES
(1, 1, 4, 1, 15.99),
(2, 1, 5, 1, 10.50),
(3, 2, 6, 2, 14.00);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
CREATE TABLE IF NOT EXISTS `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `payment_status` varchar(50) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `order_id`, `payment_status`, `transaction_id`, `amount`, `created_at`) VALUES
(1, 1, 'success', NULL, 26.49, '2026-05-09 21:02:32');

-- --------------------------------------------------------

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
CREATE TABLE IF NOT EXISTS `restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `description` text,
  `rating` decimal(2,1) DEFAULT '0.0',
  `review_count` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `restaurants`
--

INSERT INTO `restaurants` (`id`, `name`, `image`, `description`, `rating`, `review_count`, `created_at`) VALUES
(1, 'McDonald\'s', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/mcdonalds.png', 'The world\'s largest fast food restaurant chain.', 4.5, 100, '2026-05-15 17:49:46'),
(2, 'Anthony\'s', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/anthonys.png', 'Casual dining with a variety of delicious options.', 4.5, 100, '2026-05-15 17:49:46'),
(3, 'Coffee feers', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/feers.png', 'Premium coffee and beverages.', 4.5, 100, '2026-05-15 17:49:46'),
(4, 'Coffee latte art', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/latte_art.png', 'Artisan coffee with beautiful latte art.', 4.5, 100, '2026-05-15 17:49:46'),
(5, 'Los sabores', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/mexican.png', 'Authentic Mexican flavors.', 4.5, 100, '2026-05-15 17:49:46'),
(6, 'Chahine seafood', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/seafood.png', 'Fresh and delicious seafood.', 4.5, 100, '2026-05-15 17:49:46'),
(7, 'Hallab 1881', 'http://localhost/wamp_LIU_students/csci490_senior_project/jad%20olleik/code/backend/images/hallab.png', 'Traditional Lebanese sweets since 1881.', 4.5, 100, '2026-05-15 17:49:46');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `food_id` int DEFAULT NULL,
  `rating` int DEFAULT NULL,
  `comment` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `food_id` (`food_id`)
) ;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `user_id`, `food_id`, `rating`, `comment`, `created_at`) VALUES
(1, 1, 4, 5, 'Absolutely loved the pizza!', '2026-05-09 21:02:32'),
(2, 1, 5, 4, 'Great burger, very juicy.', '2026-05-09 21:02:32');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `profile_pic` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `dob` date DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'user',
  `points` int DEFAULT '0',
  `verification_code` varchar(10) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '1',
  `profile_completed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `address`, `profile_pic`, `created_at`, `dob`, `gender`, `role`, `points`, `verification_code`, `is_verified`, `profile_completed`) VALUES
(1, 'Jad Olleik', 'jad.olleik@example.com', '$2y$10$wZaj84ETSXoLtSRyHgRS9.P.3KhEaakfyhheLL4hvq3o/Lne41jfu', '+961 70 123 456', 'Beirut, Lebanon', NULL, '2026-05-09 21:02:32', '1985-05-08', 'Male', 'user', 10, NULL, 1, 1),
(2, 'Cravora Admin', 'admin@cravora.com', '$2y$10$wZaj84ETSXoLtSRyHgRS9.P.3KhEaakfyhheLL4hvq3o/Lne41jfu', NULL, NULL, NULL, '2026-05-10 07:50:38', NULL, NULL, 'admin', 0, NULL, 1, 1),
(3, 'Ali Hassan', 'ali.hassan@example.lb', '$2y$10$xK4HO6gUGq3IEGZgTcIk9u0MVXLZs31cFQIstebNvbZMtIriBka5S', '+961 70 123 456', 'Beirut, Hamra, Main Street', NULL, '2026-05-15 18:03:15', '1995-05-15', 'Male', 'user', 0, NULL, 1, 1),
(4, 'Laila Mansour', 'laila.mansour@example.lb', '$2y$10$Z7vT2483KBiVPYde.C1I7eP24QcxZIeHTDhGxbfM6K.d70LyQ9T5e', '+961 71 234 567', 'Saida, El Koulye, Near University', NULL, '2026-05-15 18:03:15', '1998-08-20', 'Female', 'user', 0, NULL, 1, 1),
(5, 'Rami Chehab', 'rami.chehab@example.lb', '$2y$10$Msqto2mvwwRSgyvPpaIhLO4IjKYkvIUj9WVbhpqc97S0RIrVnQ3jW', '+961 06 345 678', 'Tripoli, Mina, Sea Road', NULL, '2026-05-15 18:03:15', '1992-03-10', 'Male', 'user', 0, NULL, 1, 1),
(6, 'Maya Khoury', 'maya.khoury@example.lb', '$2y$10$4qZF.Hw8aBgKGyLfsIFzCeR9oLhoSzmUu2XAuI/LUm1wmqqaPiaay', '+961 09 456 789', 'Jounieh, Kaslik, Old Souk', NULL, '2026-05-15 18:03:15', '1996-11-25', 'Female', 'user', 0, NULL, 1, 1),
(7, 'Hassan Zein', 'hassan.zein@example.lb', '$2y$10$4iPpnJGdrJYynJj7SblHMuT07hbXbGCVOrpR53cAsEjnaBy2HXYAy', '+961 07 567 890', 'Tyre, Corniche, Al-Jabal Street', NULL, '2026-05-15 18:03:15', '1990-07-05', 'Male', 'user', 0, NULL, 1, 1),
(8, 'Nour Haddad', 'nour.haddad@example.lb', '$2y$10$nCh4MDfXEf3z.Ju6QnzStusc8EpX40fR.bWHYHrZt/zYF2Zg5fy3.', '+961 08 678 901', 'Zahle, Berdawni, Near Cafes', NULL, '2026-05-15 18:03:15', '1994-01-30', 'Female', 'user', 0, NULL, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
CREATE TABLE IF NOT EXISTS `vouchers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `discount_type` enum('fixed','percentage') NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_value` decimal(10,2) DEFAULT '0.00',
  `expiry_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4  ;

--
-- Dumping data for table `vouchers`
--

INSERT INTO `vouchers` (`id`, `code`, `discount_type`, `discount_value`, `min_order_value`, `expiry_date`, `is_active`) VALUES
(1, 'LEBANON20', 'percentage', 20.00, 50.00, '2026-12-31', 1),
(2, 'FREE_DELIVERY', 'fixed', 5.00, 20.00, '2026-12-31', 1),
(3, 'WELCOME10', 'fixed', 10.00, 30.00, '2026-12-31', 1);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
