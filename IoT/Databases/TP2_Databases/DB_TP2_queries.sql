# Firs create DB called greenhouse 
# then import sql file

#Q2
select count(*) from SensorType;
#Q3

#Q4
select sTypeID from sensorType where sTypeID not in (
    select DISTINCT sTypeID from sensor);

#Q5
SELECT A.actuatorName
FROM ActuatorType ATT
    JOIN Actuator A ON A.aTypeID = ATT.aTypeID
WHERE ATT.aTypeName = 'heater';

#Q6

*
select avg(measurevalue) from `Measure` 
where sensorID=1;

#Q9

#Q10
SELECT A.logDate
from log 
actuatorID
actuatorName
WHERE actuatorName='Natural Ventilation';

JOIN A

select * from ActionLog AL
    JOIN Actuator AC on AL.actuatorID=AC.actuatorID
WHERE AC.actuatorName='Natural Ventilation';    

##---------
1. Need DoctoralStudent table
2.Laboratory, Researcher

#Q6. How many measures ?
SELECT COUNT(*) from measure

## Nov 24 
# Q7 What is the date time of the oldest measure ?
SELECT * FROM Measure WHERE measureDate...
# simpler
SELECT MIN(measureDate) FROM measure

#Q8 What is the date time of the most recent measure ?
SELECT MAX(MeasureDate) from measure

#Q9. List the logs that concern rule # 1
SELECT * FROM actionlog WHERE ruleID=1;

#Q10. List the logs that concern the “Natural Ventilation” actuator
SELECT AL.*
FROM actionlog AL JOIN Actuator AC 
ON AL.actuatorID=AC.actuatorID
WHERE actuatorName='Natural Ventilation'

#Q11. At which date times do the temperature measures of the 2 thermometers differ ?
#sensor type->sensor->measure
sTypeID
thermometer
measure
sensorID

SELECT DISTINCT S.sensorID
FROM SensorType ST
    JOIN Sensor S ON ST.sTypeID=S.sTypeID
    JOIN Measure M ON M.sensorID=S.sensorID 
WHERE sTypeName='thermometer';

SELECT M1.measureDate, M1.measureValue, M2.measureValue
FROM Measure M1, Measure M2
WHERE M1.sensorID=1
    M2.sensorID=2
    M1.measureDate=M1.measureDate
    M1.measureValue<>M2.measureValue


#Q12. Which is the highest temperature reached in the greenhouse ?

SELECT DISTINCT MAX(M.measureValue)
FROM SensorType ST
    JOIN Sensor S ON ST.sTypeID=S.sTypeID
    JOIN Measure M ON M.sensorID=S.sensorID 
WHERE sTypeName='thermometer';

#Q13. Which is the highest temperature reached in the greenhouse, and at which thermometer ?

SELECT DISTINCT MAX(M.measureValue)
FROM SensorType ST
    JOIN Sensor S ON ST.sTypeID=S.sTypeID
    JOIN Measure M ON M.sensorID=S.sensorID 
WHERE sTypeName='thermometer';