-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 03, 2024 at 09:52 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fridge_management`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetExpiringItems` ()   BEGIN
    SELECT * FROM items WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `diary_products`
--

CREATE TABLE `diary_products` (
  `id` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `diary_products`
--

INSERT INTO `diary_products` (`id`, `item_id`) VALUES
(1, 1),
(2, 2),
(3, 15),
(4, 16);

-- --------------------------------------------------------

--
-- Table structure for table `expiry_notifications`
--

CREATE TABLE `expiry_notifications` (
  `id` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL,
  `notification_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expiry_notifications`
--

INSERT INTO `expiry_notifications` (`id`, `item_id`, `notification_date`) VALUES
(1, 1, '2024-03-17'),
(2, 2, '2024-03-22'),
(3, 3, '2024-03-15'),
(4, 4, '2024-03-19'),
(5, 5, '2024-03-16'),
(6, 6, '2024-03-21'),
(15, 15, '2024-03-20'),
(16, 16, '2024-03-17'),
(17, 17, '2024-03-17'),
(18, 18, '2024-03-16');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` enum('diary','vegetable','meat') NOT NULL,
  `quantity` int(11) NOT NULL,
  `expiry_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `name`, `category`, `quantity`, `expiry_date`) VALUES
(1, 'Milk', 'diary', 2, '2024-03-20'),
(2, 'Cheese', 'diary', 1, '2024-03-25'),
(3, 'Carrots', 'vegetable', 3, '2024-03-18'),
(4, 'Broccoli', 'vegetable', 2, '2024-03-22'),
(5, 'Chicken', 'meat', 1, '2024-03-19'),
(6, 'Beef', 'meat', 1, '2024-03-24'),
(15, 'Curd', 'diary', 2, '2024-03-23'),
(16, 'Mayonnaise', 'diary', 1, '2024-03-20'),
(17, 'Prawns', 'meat', 8, '2024-03-20'),
(18, 'Tomato', 'vegetable', 10, '2024-03-19');

--
-- Triggers `items`
--
DELIMITER $$
CREATE TRIGGER `insert_expiry_notification` AFTER INSERT ON `items` FOR EACH ROW BEGIN
    INSERT INTO expiry_notifications (item_id, notification_date)
    VALUES (NEW.id, DATE_SUB(NEW.expiry_date, INTERVAL 3 DAY));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `items_view`
-- (See below for the actual view)
--
CREATE TABLE `items_view` (
`id` int(11)
,`name` varchar(255)
,`category` enum('diary','vegetable','meat')
,`quantity` int(11)
,`expiry_date` date
);

-- --------------------------------------------------------

--
-- Table structure for table `meat_products`
--

CREATE TABLE `meat_products` (
  `id` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `meat_products`
--

INSERT INTO `meat_products` (`id`, `item_id`) VALUES
(1, 5),
(2, 6),
(3, 17);

-- --------------------------------------------------------

--
-- Stand-in structure for view `only_veg`
-- (See below for the actual view)
--
CREATE TABLE `only_veg` (
`id` int(11)
,`name` varchar(255)
,`category` enum('diary','vegetable','meat')
,`quantity` int(11)
,`expiry_date` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `tomato_chicken`
-- (See below for the actual view)
--
CREATE TABLE `tomato_chicken` (
`id` int(11)
,`name` varchar(255)
,`category` enum('diary','vegetable','meat')
,`quantity` int(11)
,`expiry_date` date
);

-- --------------------------------------------------------

--
-- Table structure for table `vegetables`
--

CREATE TABLE `vegetables` (
  `id` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vegetables`
--

INSERT INTO `vegetables` (`id`, `item_id`) VALUES
(1, 3),
(2, 4),
(3, 18);

-- --------------------------------------------------------

--
-- Structure for view `items_view`
--
DROP TABLE IF EXISTS `items_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `items_view`  AS SELECT `items`.`id` AS `id`, `items`.`name` AS `name`, `items`.`category` AS `category`, `items`.`quantity` AS `quantity`, `items`.`expiry_date` AS `expiry_date` FROM `items` ;

-- --------------------------------------------------------

--
-- Structure for view `only_veg`
--
DROP TABLE IF EXISTS `only_veg`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `only_veg`  AS SELECT `items`.`id` AS `id`, `items`.`name` AS `name`, `items`.`category` AS `category`, `items`.`quantity` AS `quantity`, `items`.`expiry_date` AS `expiry_date` FROM `items` WHERE `items`.`category` = 'vegetable' ;

-- --------------------------------------------------------

--
-- Structure for view `tomato_chicken`
--
DROP TABLE IF EXISTS `tomato_chicken`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tomato_chicken`  AS SELECT `items`.`id` AS `id`, `items`.`name` AS `name`, `items`.`category` AS `category`, `items`.`quantity` AS `quantity`, `items`.`expiry_date` AS `expiry_date` FROM `items` WHERE `items`.`name` = 'Tomato' OR `items`.`name` = 'Chicken' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `diary_products`
--
ALTER TABLE `diary_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `expiry_notifications`
--
ALTER TABLE `expiry_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meat_products`
--
ALTER TABLE `meat_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `vegetables`
--
ALTER TABLE `vegetables`
  ADD PRIMARY KEY (`id`),
  ADD KEY `item_id` (`item_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `diary_products`
--
ALTER TABLE `diary_products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `expiry_notifications`
--
ALTER TABLE `expiry_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `meat_products`
--
ALTER TABLE `meat_products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `vegetables`
--
ALTER TABLE `vegetables`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `diary_products`
--
ALTER TABLE `diary_products`
  ADD CONSTRAINT `diary_products_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);

--
-- Constraints for table `expiry_notifications`
--
ALTER TABLE `expiry_notifications`
  ADD CONSTRAINT `expiry_notifications_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);

--
-- Constraints for table `meat_products`
--
ALTER TABLE `meat_products`
  ADD CONSTRAINT `meat_products_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);

--
-- Constraints for table `vegetables`
--
ALTER TABLE `vegetables`
  ADD CONSTRAINT `vegetables_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
