-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 15, 2023 at 01:04 PM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `Makebookings` (IN `name` VARCHAR(100), IN `check_in` DATE, IN `check_out` DATE, IN `rooms` INT)   BEGIN
    DECLARE room_available INT;

    -- Check if the room is available during the specified period
    SELECT COUNT(*) INTO room_available
    FROM bookings
    WHERE rooms = rooms
    AND ((check_in_date BETWEEN check_in AND check_out)
        OR (check_out_date BETWEEN check_in AND check_));

    -- If room is not available, signal an error
    IF room_available > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room not available for the specified period';
    END IF;

    -- If room is available, insert the reservation
    INSERT INTO reservations (guest_name, check_in_date, check_out_date, room_number)
    VALUES (guest_name, check_in_date, check_out_date, room_number);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBooking` (IN `p_booking_id` INT, IN `gueast_name` VARCHAR(255), IN `p_check_in` DATE, IN `p_check_out` DATE, IN `p_rooms` INT)   BEGIN
    UPDATE bookings
    SET
        guest_name = guest_name,
        check_in = p_check_in,
        check_out = p_check_out,
        rooms = p_rooms
    WHERE
        booking_id = p_booking_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(20) NOT NULL,
  `admin_name` varchar(20) NOT NULL,
  `password` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `admin_name`, `password`) VALUES
(1, 'admin', '6216f8a75fd5bb3d5f22b6f9958cdede3fc086c2');

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
  `user_id` int(11) NOT NULL,
  `guest_name` varchar(50) NOT NULL,
  `guest_email` varchar(50) NOT NULL,
  `guest_number` varchar(10) NOT NULL,
  `rooms` int(1) NOT NULL,
  `check_in` varchar(10) NOT NULL,
  `check_out` varchar(10) NOT NULL,
  `adults` int(1) NOT NULL,
  `childs` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `guest_name`, `guest_email`, `guest_number`, `rooms`, `check_in`, `check_out`, `adults`, `childs`) VALUES
(1, 0, 'Rai', 'raizademiguel@gmail.com', '1341513363', 1, '2023-12-30', '2023-12-31', 2, 1),
(2, 0, 'raiza', 'rai@gmail.com', '0985611721', 1, '2023-12-22', '2023-12-23', 1, 0),
(3, 0, 'Christine', 'tiintin@gmail.com', '0950241413', 1, '2023-12-15', '2023-12-16', 1, 0),
(4, 0, 'Christine juju', 'tintinl@gmail.com', '0985635245', 1, '2023-12-16', '2023-12-17', 1, 0);

--
-- Triggers `bookings`
--
DELIMITER $$
CREATE TRIGGER `after_booking_insert` BEFORE INSERT ON `bookings` FOR EACH ROW BEGIN
    INSERT INTO booking_events (booking_id, event_message)
    VALUES (NEW.booking_id, 'New booking created');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_bookings_delete` AFTER DELETE ON `bookings` FOR EACH ROW BEGIN
    INSERT INTO audit_log (user_id, action, table_name, record_id, field_name, old_value, new_value, created_at)
    VALUES (
        USER(),
        'delete',
        'bookings',
        OLD.booking_id,
        'guest_name',
        OLD.guest_name,
        NULL,
        NOW()
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_check_in_update` AFTER UPDATE ON `bookings` FOR EACH ROW BEGIN
    IF NEW.check_in != OLD.check_in THEN
        INSERT INTO audit_log (user_id, action, table_name, record_id, field_name, old_value, new_value)
        VALUES (
            USER(),
            'update',
            'bookings',
            NEW.booking_id,
            'check_in',
            OLD.check_in,
            NEW.check_in
        );
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_check_out_update` BEFORE UPDATE ON `bookings` FOR EACH ROW BEGIN
    IF NEW.check_out != OLD.check_out THEN
        INSERT INTO audit_log (user_id, action, table_name, record_id, field_name, old_value, new_value)
        VALUES (
            USER(),
            'update',
            'bookings',
            NEW.booking_id,
            'check_out',
            OLD.check_out,
            NEW.check_out
        );
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `upcoming_booking_event` BEFORE INSERT ON `bookings` FOR EACH ROW BEGIN
    DECLARE booking_date DATE;
    DECLARE today_date DATE;

    SET booking_date = NEW.check_in;
    SET today_date = CURRENT_DATE();

    IF booking_date = today_date + INTERVAL 1 DAY THEN
        INSERT INTO booking_events (booking_id, event_message)
        VALUES (NEW.booking_id, 'Reminder: Your booking for room ' || NEW.rooms || ' is tomorrow. Enjoy your stay!');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `bookings_view`
-- (See below for the actual view)
--
CREATE TABLE `bookings_view` (
`booking_id` int(20)
,`guest_name` varchar(50)
,`check_in` varchar(10)
,`check_out` varchar(10)
,`rooms` int(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `past_bookings_view`
-- (See below for the actual view)
--
CREATE TABLE `past_bookings_view` (
`booking_id` int(20)
,`guest_name` varchar(50)
,`check_in` varchar(10)
,`check_out` varchar(10)
,`rooms` int(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `upcoming_bookings_view`
-- (See below for the actual view)
--
CREATE TABLE `upcoming_bookings_view` (
`booking_id` int(20)
,`guest_name` varchar(50)
,`check_in` varchar(10)
,`check_out` varchar(10)
,`rooms` int(1)
);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `users_id` bigint(20) NOT NULL,
  `guest_name` varchar(50) NOT NULL,
  `guest_email` varchar(50) NOT NULL,
  `guest_number` varchar(10) NOT NULL,
  `guest_message` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`users_id`, `guest_name`, `guest_email`, `guest_number`, `guest_message`) VALUES
(1, 'Rai', 'raizademiguel@gmail.com', '1412414242', 'dfgdfncvggervgtth');

-- --------------------------------------------------------

--
-- Structure for view `bookings_view`
--
DROP TABLE IF EXISTS `bookings_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bookings_view`  AS SELECT `bookings`.`booking_id` AS `booking_id`, `bookings`.`guest_name` AS `guest_name`, `bookings`.`check_in` AS `check_in`, `bookings`.`check_out` AS `check_out`, `bookings`.`rooms` AS `rooms` FROM `bookings``bookings`  ;

-- --------------------------------------------------------

--
-- Structure for view `past_bookings_view`
--
DROP TABLE IF EXISTS `past_bookings_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `past_bookings_view`  AS SELECT `bookings`.`booking_id` AS `booking_id`, `bookings`.`guest_name` AS `guest_name`, `bookings`.`check_in` AS `check_in`, `bookings`.`check_out` AS `check_out`, `bookings`.`rooms` AS `rooms` FROM `bookings` WHERE `bookings`.`check_out` < curdate()  ;

-- --------------------------------------------------------

--
-- Structure for view `upcoming_bookings_view`
--
DROP TABLE IF EXISTS `upcoming_bookings_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `upcoming_bookings_view`  AS SELECT `bookings`.`booking_id` AS `booking_id`, `bookings`.`guest_name` AS `guest_name`, `bookings`.`check_in` AS `check_in`, `bookings`.`check_out` AS `check_out`, `bookings`.`rooms` AS `rooms` FROM `bookings` WHERE `bookings`.`check_in` >= curdate()  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`);

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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`users_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `users_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `upcoming_bookings_reminder` ON SCHEDULE EVERY 1 DAY STARTS '2023-12-08 10:24:34' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- Send reminders for upcoming reservations
    INSERT INTO reminder_log (booking_id, reminder_date, message)
    SELECT
        booking_id,
        CURRENT_DATE() + INTERVAL 1 DAY, -- Assuming you want to send reminders one day before check-in
        CONCAT('Reminder: Your reservation for room ', rooms, ' is tomorrow. Enjoy your stay!')
    FROM
        bookings
    WHERE
        check_in = CURRENT_DATE() + INTERVAL 1 DAY; -- Adjust the condition based on your reminder criteria
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
