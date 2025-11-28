-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 26, 2025 at 08:59 AM
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
-- Database: `tripttrip`
--

-- --------------------------------------------------------

--
-- Table structure for table `city`
--

CREATE TABLE `city` (
  `cityID` int(11) NOT NULL,
  `cityName` varchar(255) NOT NULL,
  `cityPop` int(11) NOT NULL,
  `regionID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `city`
--

INSERT INTO `city` (`cityID`, `cityName`, `cityPop`, `regionID`) VALUES
(0, 'Orleans', 10000, 1);

-- --------------------------------------------------------

--
-- Table structure for table `contributor`
--

CREATE TABLE `contributor` (
  `contId` int(11) NOT NULL,
  `contName` varchar(255) NOT NULL,
  `registerDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contributor`
--

INSERT INTO `contributor` (`contId`, `contName`, `registerDate`) VALUES
(1, 'Simon Templer', '2025-11-07');

-- --------------------------------------------------------

--
-- Table structure for table `country`
--

CREATE TABLE `country` (
  `countryCode` varchar(5) NOT NULL,
  `countryName` varchar(255) NOT NULL,
  `officialLanguage` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `country`
--

INSERT INTO `country` (`countryCode`, `countryName`, `officialLanguage`) VALUES
('FR', 'France', 'Francais');

-- --------------------------------------------------------

--
-- Table structure for table `poi`
--

CREATE TABLE `poi` (
  `poiID` int(11) NOT NULL,
  `poiName` varchar(255) NOT NULL,
  `poiLon` float NOT NULL,
  `poiLat` float NOT NULL,
  `cityID` int(11) DEFAULT NULL,
  `propID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `region`
--

CREATE TABLE `region` (
  `regionID` int(11) NOT NULL,
  `regionName` varchar(255) NOT NULL,
  `countryCode` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `region`
--

INSERT INTO `region` (`regionID`, `regionName`, `countryCode`) VALUES
(1, 'Central Val de Loire', 'FR');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `city`
--
ALTER TABLE `city`
  ADD PRIMARY KEY (`cityID`);

--
-- Indexes for table `contributor`
--
ALTER TABLE `contributor`
  ADD PRIMARY KEY (`contId`);

--
-- Indexes for table `country`
--
ALTER TABLE `country`
  ADD PRIMARY KEY (`countryCode`);

--
-- Indexes for table `poi`
--
ALTER TABLE `poi`
  ADD PRIMARY KEY (`poiID`),
  ADD KEY `FK_PoiCity` (`cityID`),
  ADD KEY `FK_PoiContrib` (`propID`);

--
-- Indexes for table `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`regionID`),
  ADD KEY `FK_region` (`countryCode`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `contributor`
--
ALTER TABLE `contributor`
  MODIFY `contId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `poi`
--
ALTER TABLE `poi`
  MODIFY `poiID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `region`
--
ALTER TABLE `region`
  MODIFY `regionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `poi`
--
ALTER TABLE `poi`
  ADD CONSTRAINT `FK_PoiCity` FOREIGN KEY (`cityID`) REFERENCES `city` (`cityID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_PoiContrib` FOREIGN KEY (`propID`) REFERENCES `contributor` (`contId`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Constraints for table `region`
--
ALTER TABLE `region`
  ADD CONSTRAINT `FK_region` FOREIGN KEY (`countryCode`) REFERENCES `country` (`countryCode`) ON DELETE SET NULL ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
