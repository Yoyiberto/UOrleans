INSERT
UPDATE country set countryname='Deutschland', off='de' where countrycode='D';
DELETE FROM country WHERE countryname='Deutschland'
`SET cityPop=cityPop*1.02;`
Display all cityName+countryname?

SELECT poiName, contName
FROM POI poi JOIN Contributor c ON poi.propID=c.contID
JOIN City ci ON poi.cityID=ci.cityID;