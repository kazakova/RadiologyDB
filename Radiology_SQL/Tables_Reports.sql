
USE Radiology_Keys;
GO


CREATE PROCEDURE Inventory_Keys
(
@tokenNum VARCHAR(10),
@facilityName VARCHAR(40),
@roomNum VARCHAR (10),
@itemName VARCHAR(10),
@itemDesc VARCHAR (20)
)
AS
BEGIN
	IF (@tokenNum IS NOT NULL)
		BEGIN
		DECLARE @tokenId INT;
		SELECT @tokenId=tokenId 
		FROM Token
		WHERE tokenNum=@tokenNum;

		/*calculate how many keys are currently out*/
		DECLARE @quantityOut  INT;
		SELECT @quantityOut=COUNT(*)
		FROM CheckOutRecord C
		WHERE C.tokenId=@tokenId AND C.returnStatus is NULL;

		/*calculate how many keys are currently in distribuition*/
		DECLARE @quantityUsed INT;
		SELECT  @quantityUsed=COUNT(*)
		FROM CheckOutRecord C
		WHERE C.tokenId=@tokenId AND C.returnStatus is NULL AND C.lossStatus IS NULL;

		/*calculate how many keys are lost*/
		DECLARE @quantityLost INT;
		SELECT @quantityLost=COUNT(*) 
		FROM CheckOutRecord C
		WHERE C.tokenId=@tokenId  AND C.lossStatus IS NOT NULL

		/*put all of the relevant information intoa temporary table*/
		SELECT T.tokenId, T.tokenNum, F.facilityName, F.facilityAbbrev, R.roomNum, R.roomDesc, 
				I.itemName, I.itemDesc, T.tokenCapacity-@quantityOut AS keysIn, @quantityUsed AS keysOut,
				@quantityLost AS keysLost, T.tokenCapacity
		FROM KeyAssignment K
		INNER JOIN Token T
		ON K.tokenId=T.tokenId
		INNER JOIN Item I
		ON K.itemId= I.itemId
			INNER JOIN Room R
			ON I.roomId= R.roomId
				INNER JOIN Facility F
				ON R.facilityId=F.facilityId
		WHERE T.tokenId=@tokenId;
		END;
	ELSE
		/*put all of the relevant information into a temporary table*/
		SELECT T.tokenId, T.tokenNum, F.facilityName, F.facilityAbbrev, R.roomNum, R.roomDesc, 
				I.itemName, I.itemDesc, 
				(T.tokenCapacity-(SELECT COUNT(*)
								FROM CheckOutRecord C
								WHERE C.tokenId=T.tokenId AND C.returnStatus is NULL))
								AS keysIn,
				(SELECT  COUNT(*)
				FROM CheckOutRecord C
				WHERE C.tokenId=T.tokenId AND C.returnStatus is NULL AND C.lossStatus IS NULL)
				AS keysOut,
				(SELECT COUNT(*) 
				FROM CheckOutRecord C
				WHERE C.tokenId=T.tokenId  AND C.lossStatus IS NOT NULL)
				AS keysLost,
				T.tokenCapacity
		FROM KeyAssignment K
		INNER JOIN Token T
		ON K.tokenId=T.tokenId
			INNER JOIN Item I
			ON K.itemId= I.itemId
				INNER JOIN Room R
				ON I.roomId= R.roomId
					INNER JOIN Facility F
					ON R.facilityId=F.facilityId
		WHERE ((@facilityName IS NOT NULL AND F.facilityName=@facilityName)OR (@facilityName IS NULL AND F.facilityName LIKE '%')) 
				AND ((@roomNum IS NOT NULL AND R.roomNum=@roomNum) OR (@roomNum IS NULL AND R.roomNum LIKE '%'))
				AND ((@itemName IS NOT NULL AND I.itemName=@itemName) OR (@itemName IS NULL AND I.itemName LIKE '%')) 
				AND ((@itemDesc IS NOT NULL AND I.itemDesc=@itemDesc) OR (@itemDesc IS NULL AND (I.itemDesc LIKE '%' OR I.itemDesc IS NULL))) 
				AND T.tokenValidity='Y'
		END;


GO


/*Employee_Keys - dislplay all of the keys an employee has or had, including when the key was checked out, checked in, lost, 
and whether it is still valid*/

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

/*Check_Out_Records - Display Check Out Records for a given key over the 
last N-number of days*/

/*Check_In_Records - Display Check In Records for a given key over the 
last N-number of days*/

/*Loss_Records - Display Loss Records for a given key over the 
last N-number of days*/

/*Rekey_Records - Display Loss Records for a given key over the 
last N-number of days*/

/*In_Possesion - Display the netid of every person who owned a given key N days ago*/

