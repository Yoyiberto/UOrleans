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
