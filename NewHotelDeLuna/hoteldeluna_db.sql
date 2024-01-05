-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 05, 2024 at 05:51 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotel_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBooking` (IN `p_name` VARCHAR(255), IN `p_check_in` DATE, IN `p_check_out` DATE, IN `p_rooms` INT)   BEGIN
  -- Declare variables to store the result
  DECLARE new_booking_id INT;

  -- Start a transaction
  START TRANSACTION;

  -- Insert the new booking
  INSERT INTO bookings (name, check_in, check_out, rooms)
  VALUES (p_name, p_check_in, p_check_out, p_rooms);

  -- Get the auto-generated booking_id
  SET new_booking_id = LAST_INSERT_ID();

  -- Commit the transaction
  COMMIT;

  -- Return the new booking_id
  SELECT new_booking_id AS new_booking_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteBookingsByStatus` (IN `p_status` VARCHAR(255))   BEGIN
  -- Start a transaction
  START TRANSACTION;

  -- Delete bookings based on the provided status
  DELETE FROM bookings
  WHERE status = p_status;

  -- Commit the transaction
  COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertBooking` (IN `p_user_id` INT, IN `p_name` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_number` VARCHAR(20), IN `p_rooms` INT, IN `p_check_in` DATE, IN `p_check_out` DATE, IN `p_adults` INT, IN `p_childs` INT)   BEGIN
    INSERT INTO bookings (user_id, guest_name, guest_email, guest_number, rooms, check_in, check_out, adults, childs)
    VALUES (p_user_id, p_guest_name, p_guest_email, p_guest_number, p_rooms, p_check_in, p_check_out, p_adults, p_childs);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` varchar(20) NOT NULL,
  `name` varchar(20) NOT NULL,
  `password` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `password`) VALUES
('EQYJaB96HcaTtxag6J7d', 'admin', '6216f8a75fd5bb3d5f22b6f9958cdede3fc086c2');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `log_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `record_id` int(11) DEFAULT NULL,
  `field_name` varchar(50) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `number` varchar(10) NOT NULL,
  `rooms` int(1) NOT NULL,
  `check_in` varchar(10) NOT NULL,
  `check_out` varchar(10) NOT NULL,
  `adults` int(1) NOT NULL,
  `childs` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `name`, `email`, `number`, `rooms`, `check_in`, `check_out`, `adults`, `childs`) VALUES
(1, 1, 'Rai', 'raizademiguel@gmail.com', '1341513363', 1, '2023-12-30', '2023-12-31', 2, 1),
(2, 2, 'Rai', 'raizademiguel@gmail.com', '0963545553', 1, '2024-01-12', '2024-01-13', 1, 0),
(3, 2, 'Rai', 'raizademiguel@gmail.com', '0964354525', 1, '2024-01-12', '2024-01-13', 1, 0);

-- --------------------------------------------------------

--
-- Stand-in structure for view `current_bookings`
-- (See below for the actual view)
--
CREATE TABLE `current_bookings` (
`booking_id` int(20)
,`name` varchar(50)
,`check_in` varchar(10)
,`check_out` varchar(10)
,`rooms` int(1)
);

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `number` varchar(10) NOT NULL,
  `message` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `name`, `email`, `number`, `message`) VALUES
(1, 'Rai', 'raizademiguel@gmail.com', '1412414242', 'dfgdfncvggervgtth');

-- --------------------------------------------------------

--
-- Stand-in structure for view `past_bookings`
-- (See below for the actual view)
--
CREATE TABLE `past_bookings` (
`booking_id` int(20)
,`name` varchar(50)
,`check_in` varchar(10)
,`check_out` varchar(10)
,`rooms` int(1)
);

-- --------------------------------------------------------

--
-- Structure for view `current_bookings`
--
DROP TABLE IF EXISTS `current_bookings`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `current_bookings`  AS SELECT `bookings`.`booking_id` AS `booking_id`, `bookings`.`name` AS `name`, `bookings`.`check_in` AS `check_in`, `bookings`.`check_out` AS `check_out`, `bookings`.`rooms` AS `rooms` FROM `bookings` WHERE `bookings`.`check_out` >= curdate()  ;

-- --------------------------------------------------------

--
-- Structure for view `past_bookings`
--
DROP TABLE IF EXISTS `past_bookings`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `past_bookings`  AS SELECT `bookings`.`booking_id` AS `booking_id`, `bookings`.`name` AS `name`, `bookings`.`check_in` AS `check_in`, `bookings`.`check_out` AS `check_out`, `bookings`.`rooms` AS `rooms` FROM `bookings` WHERE `bookings`.`check_out` < curdate()  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `UpdateBookingStatus` ON SCHEDULE EVERY 1 DAY STARTS '2024-01-05 12:45:09' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
  -- Update the status of completed bookings
  UPDATE bookings
  SET status = 'completed'
  WHERE check_out < CURDATE();
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
