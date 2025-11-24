-- Database: greenhouse
-- SQL Queries Answers for TP2

-- 1. What is the name of and which measure unit is used for sensor #1
SELECT sensorName, measureUnit
FROM Sensor
WHERE sensorID = 1;

-- 2. How many sensor types?
SELECT COUNT(*) AS total_sensor_types
FROM SensorType;

-- 3. How many sensors?
SELECT COUNT(*) AS total_sensors
FROM Sensor;

-- 4. Which sensor types have no instances in the DB?
SELECT st.sTypeID, st.sTypeName, st.sTypeDesc
FROM SensorType st
LEFT JOIN Sensor s ON st.sTypeID = s.sTypeID
WHERE s.sensorID IS NULL;

-- 5. Which actuators are of type "heater"?
SELECT a.actuatorID, a.actuatorName, a.actuatorStatus, a.zoneID
FROM Actuator a
JOIN ActuatorType at ON a.aTypeID = at.aTypeID
WHERE at.aTypeName = 'heater';

-- 6. How many measures?
SELECT COUNT(*) AS total_measures
FROM Measure;

-- 7. What is the date time of the oldest measure?
SELECT MIN(measureDate) AS oldest_measure_datetime
FROM Measure;

-- 8. What is the date time of the most recent measure?
SELECT MAX(measureDate) AS most_recent_measure_datetime
FROM Measure;

-- 9. List the logs that concern rule #1
SELECT al.logID, al.actuatorID, al.ruleID, al.logDate, a.actuatorName, r.ruleName
FROM ActionLog al
JOIN Actuator a ON al.actuatorID = a.actuatorID
JOIN Rule r ON al.ruleID = r.ruleID
WHERE al.ruleID = 1;

-- 10. List the logs that concern the "Natural Ventilation" actuator
SELECT al.logID, al.actuatorID, al.ruleID, al.logDate, a.actuatorName, r.ruleName
FROM ActionLog al
JOIN Actuator a ON al.actuatorID = a.actuatorID
JOIN Rule r ON al.ruleID = r.ruleID
WHERE a.actuatorName = 'Natural Ventilation';

-- 11. At which date times do the temperature measures of the 2 thermometers differ?
SELECT DISTINCT 
    m1.measureDate,
    s1.sensorName AS thermometer_1,
    m1.measureValue AS temp_1,
    s2.sensorName AS thermometer_2,
    m2.measureValue AS temp_2
FROM Measure m1
JOIN Measure m2 ON m1.measureDate = m2.measureDate
JOIN Sensor s1 ON m1.sensorID = s1.sensorID
JOIN Sensor s2 ON m2.sensorID = s2.sensorID
WHERE s1.sTypeID = 1 AND s2.sTypeID = 1
    AND m1.sensorID < m2.sensorID
    AND m1.measureValue != m2.measureValue
ORDER BY m1.measureDate;

-- 12. Which is the highest temperature reached in the greenhouse?
SELECT MAX(m.measureValue) AS highest_temperature
FROM Measure m
JOIN Sensor s ON m.sensorID = s.sensorID
WHERE s.sTypeID = 1;

-- 13. Which is the highest temperature reached in the greenhouse, and at which thermometer?
SELECT 
    m.measureValue AS highest_temperature,
    s.sensorName AS thermometer_name,
    m.measureDate,
    z.zoneName
FROM Measure m
JOIN Sensor s ON m.sensorID = s.sensorID
JOIN Zone z ON s.zoneID = z.zoneID
WHERE s.sTypeID = 1
ORDER BY m.measureValue DESC
LIMIT 1;
