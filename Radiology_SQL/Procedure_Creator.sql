USE Radiology_Keys
GO

DROP PROCEDURE Employee_Keys
GO 

CREATE PROCEDURE Employee_Keys
(
@netId VARCHAR(15)
)
AS
BEGIN
	SELECT T.tokenNum, O.coDate, I.returnDate, L.lossDate, T.tokenValidity
	FROM CheckOutRecord O
	LEFT OUTER JOIN CheckInRecord I
	ON O.returnStatus=I.ciId
	LEFT OUTER JOIN LossRecord L
	ON O.lossStatus=L.lossId
	INNER JOIN Token T
	ON O.tokenId=T.tokenId
	WHERE O.netId=@netId
END;
GO