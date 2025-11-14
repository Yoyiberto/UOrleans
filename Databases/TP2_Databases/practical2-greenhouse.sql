-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : dim. 09 nov. 2025 à 17:01
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `greenhouse`
--

-- --------------------------------------------------------

--
-- Structure de la table `ActionLog`
--

CREATE TABLE `ActionLog` (
  `logID` int(11) NOT NULL,
  `actuatorID` int(11) NOT NULL,
  `ruleID` int(11) NOT NULL,
  `logDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `ActionLog`
--

INSERT INTO `ActionLog` (`logID`, `actuatorID`, `ruleID`, `logDate`) VALUES
(1, 3, 1, '2025-11-08 13:00:00'),
(2, 3, 2, '2025-11-08 15:00:00');

-- --------------------------------------------------------

--
-- Structure de la table `Actuator`
--

CREATE TABLE `Actuator` (
  `actuatorID` int(11) NOT NULL,
  `actuatorName` varchar(50) NOT NULL,
  `aTypeID` int(11) DEFAULT NULL,
  `zoneID` int(11) DEFAULT NULL,
  `actuatorStatus` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `Actuator`
--

INSERT INTO `Actuator` (`actuatorID`, `actuatorName`, `aTypeID`, `zoneID`, `actuatorStatus`) VALUES
(1, 'Roof Lamps', 5, 5, 'OFF'),
(2, 'Global Sprinkler irrigation', 1, 5, 'OFF'),
(3, 'Natural Ventilation', 3, 5, 'OFF'),
(4, 'Roof IR Warming unit', 4, 5, 'OFF'),
(5, 'SWWarming', 4, 4, 'ON'),
(6, 'SWWarming', 4, 4, 'ON');

-- --------------------------------------------------------

--
-- Structure de la table `ActuatorType`
--

CREATE TABLE `ActuatorType` (
  `aTypeID` int(11) NOT NULL,
  `aTypeName` varchar(30) NOT NULL,
  `aTypeDesc` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `ActuatorType`
--

INSERT INTO `ActuatorType` (`aTypeID`, `aTypeName`, `aTypeDesc`) VALUES
(1, 'sprinkler', 'for a whole water irrigation'),
(2, 'fertilizer display', 'to add a dose of fertilizer'),
(3, 'roof window', 'to let air in and out'),
(4, 'heater', 'for fresh days'),
(5, 'lightning', 'Lightning');

-- --------------------------------------------------------

--
-- Structure de la table `Measure`
--

CREATE TABLE `Measure` (
  `measureID` int(11) NOT NULL,
  `sensorID` int(11) DEFAULT NULL,
  `measureValue` float NOT NULL,
  `measureDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `Measure`
--

INSERT INTO `Measure` (`measureID`, `sensorID`, `measureValue`, `measureDate`) VALUES
(1, 7, 20, '2025-11-08 08:00:00'),
(2, 7, 30, '2025-11-08 09:00:00'),
(3, 7, 40, '2025-11-08 10:00:00'),
(4, 7, 20, '2025-11-08 11:00:00'),
(5, 1, 18, '2025-11-08 08:00:00'),
(6, 1, 19, '2025-11-08 09:00:00'),
(7, 1, 20, '2025-11-08 10:00:00'),
(8, 1, 22, '2025-11-08 11:00:00'),
(9, 1, 24, '2025-11-08 12:00:00'),
(10, 1, 26, '2025-11-08 13:00:00'),
(11, 1, 22, '2025-11-08 14:00:00'),
(12, 1, 17, '2025-11-08 15:00:00'),
(13, 2, 18, '2025-11-08 08:00:00'),
(14, 2, 19, '2025-11-08 09:00:00'),
(15, 2, 20, '2025-11-08 10:00:00'),
(16, 2, 22, '2025-11-08 11:00:00'),
(17, 2, 24, '2025-11-08 12:00:00'),
(18, 2, 25, '2025-11-08 13:00:00'),
(19, 2, 21, '2025-11-08 14:00:00'),
(20, 2, 20, '2025-11-08 15:00:00');

-- --------------------------------------------------------

--
-- Structure de la table `Rule`
--

CREATE TABLE `Rule` (
  `ruleID` int(11) NOT NULL,
  `ruleName` varchar(50) NOT NULL,
  `rulecond` varchar(200) NOT NULL,
  `ruleAction` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `Rule`
--

INSERT INTO `Rule` (`ruleID`, `ruleName`, `rulecond`, `ruleAction`) VALUES
(1, 'overheating', 'value>25 AND sTypeID=1', '{\'actuatorID\' : 3, \'status\' : \'ON\'}'),
(2, 'tooCold', 'value<18 AND sTypeID=1', '{\'actuatorID\' : 4, \'status\' : \'ON\'}'),
(3, 'tooDry', 'value<20 and sTypeID=2', '{\'actuatorID\' : 2, \'status\' : \'ON\'}'),
(4, 'tooWet', 'value>80 and sTypeID=2', '{\'actuatorID\' : 2, \'status\' : \'OFF\'}');

-- --------------------------------------------------------

--
-- Structure de la table `Sensor`
--

CREATE TABLE `Sensor` (
  `sensorID` int(11) NOT NULL,
  `sensorName` varchar(40) NOT NULL,
  `sTypeID` int(11) DEFAULT NULL,
  `zoneID` int(11) DEFAULT NULL,
  `measureUnit` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `Sensor`
--

INSERT INTO `Sensor` (`sensorID`, `sensorName`, `sTypeID`, `zoneID`, `measureUnit`) VALUES
(1, 'SWTemp', 1, 4, '°C'),
(2, 'SETemp', 1, 3, '°C'),
(3, 'NWTemp', 1, 2, '°C'),
(4, 'NETemp', 1, 1, '°C'),
(5, 'roofLight', 3, 5, 'lux'),
(6, 'GroundLight', 3, 7, 'lux'),
(7, 'Ground Humidity', 2, 7, '%'),
(8, 'Wind Speed', 4, 5, 'm.s-1');

-- --------------------------------------------------------

--
-- Structure de la table `SensorType`
--

CREATE TABLE `SensorType` (
  `sTypeID` int(11) NOT NULL,
  `sTypeName` varchar(50) NOT NULL,
  `sTypeDesc` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `SensorType`
--

INSERT INTO `SensorType` (`sTypeID`, `sTypeName`, `sTypeDesc`) VALUES
(1, 'thermometer', 'get temperature'),
(2, 'hygrometer', 'get humidity'),
(3, 'luxmeter', 'to evaluate light'),
(4, 'anemometer', 'for outside wind');

-- --------------------------------------------------------

--
-- Structure de la table `Zone`
--

CREATE TABLE `Zone` (
  `zoneID` int(11) NOT NULL,
  `zoneName` varchar(30) NOT NULL,
  `zoneDesc` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `Zone`
--

INSERT INTO `Zone` (`zoneID`, `zoneName`, `zoneDesc`) VALUES
(1, 'northeast quarter', ''),
(2, 'northwest quarter', ''),
(3, 'southeast quarter', ''),
(4, 'southwest quarter', ''),
(5, 'roof', ''),
(6, 'entry airlock', ''),
(7, 'Ground', 'Ground');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `ActionLog`
--
ALTER TABLE `ActionLog`
  ADD PRIMARY KEY (`logID`);

--
-- Index pour la table `Actuator`
--
ALTER TABLE `Actuator`
  ADD PRIMARY KEY (`actuatorID`),
  ADD KEY `FKAID` (`aTypeID`),
  ADD KEY `FKAZID` (`zoneID`);

--
-- Index pour la table `ActuatorType`
--
ALTER TABLE `ActuatorType`
  ADD PRIMARY KEY (`aTypeID`);

--
-- Index pour la table `Measure`
--
ALTER TABLE `Measure`
  ADD PRIMARY KEY (`measureID`),
  ADD KEY `sensorID` (`sensorID`);

--
-- Index pour la table `Rule`
--
ALTER TABLE `Rule`
  ADD PRIMARY KEY (`ruleID`);

--
-- Index pour la table `Sensor`
--
ALTER TABLE `Sensor`
  ADD PRIMARY KEY (`sensorID`),
  ADD KEY `FKSID` (`sTypeID`),
  ADD KEY `FKSZID` (`zoneID`);

--
-- Index pour la table `SensorType`
--
ALTER TABLE `SensorType`
  ADD PRIMARY KEY (`sTypeID`);

--
-- Index pour la table `Zone`
--
ALTER TABLE `Zone`
  ADD PRIMARY KEY (`zoneID`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `ActionLog`
--
ALTER TABLE `ActionLog`
  MODIFY `logID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `Actuator`
--
ALTER TABLE `Actuator`
  MODIFY `actuatorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `ActuatorType`
--
ALTER TABLE `ActuatorType`
  MODIFY `aTypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `Measure`
--
ALTER TABLE `Measure`
  MODIFY `measureID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `Rule`
--
ALTER TABLE `Rule`
  MODIFY `ruleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `Sensor`
--
ALTER TABLE `Sensor`
  MODIFY `sensorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `SensorType`
--
ALTER TABLE `SensorType`
  MODIFY `sTypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `Zone`
--
ALTER TABLE `Zone`
  MODIFY `zoneID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `ActionLog`
--
ALTER TABLE `ActionLog`
  ADD CONSTRAINT `ActionLog_ibfk_1` FOREIGN KEY (`actuatorID`) REFERENCES `Actuator` (`actuatorID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `ActionLog_ibfk_2` FOREIGN KEY (`ruleID`) REFERENCES `Rule` (`ruleID`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Contraintes pour la table `Actuator`
--
ALTER TABLE `Actuator`
  ADD CONSTRAINT `FKAID` FOREIGN KEY (`aTypeID`) REFERENCES `ActuatorType` (`aTypeID`) ON DELETE SET NULL ON UPDATE NO ACTION,
  ADD CONSTRAINT `FKAZID` FOREIGN KEY (`zoneID`) REFERENCES `Zone` (`zoneID`);

--
-- Contraintes pour la table `Measure`
--
ALTER TABLE `Measure`
  ADD CONSTRAINT `Measure_ibfk_1` FOREIGN KEY (`sensorID`) REFERENCES `Sensor` (`sensorID`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Contraintes pour la table `Sensor`
--
ALTER TABLE `Sensor`
  ADD CONSTRAINT `FKSID` FOREIGN KEY (`sTypeID`) REFERENCES `SensorType` (`sTypeID`) ON DELETE SET NULL ON UPDATE NO ACTION,
  ADD CONSTRAINT `FKSZID` FOREIGN KEY (`zoneID`) REFERENCES `Zone` (`zoneID`) ON DELETE SET NULL ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
