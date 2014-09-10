
USE Radiology_Keys;
GO

/*Key_Check_Out - make a chekout record given the number of the key, netid of the employee
and the key master's netid*/
CREATE PROCEDURE Key_Check_Out
(
	@tokenNum VARCHAR(10),
	@netId VARCHAR(15),
	@kmNetId VARCHAR(15)
)
/*I do not perform any check on the validity of the netids or keynum
since I assume it is going to be passed through a "select appropriate key" input
netid will be provided by peoplepicker*/
AS
BEGIN
	DECLARE @tokenId INT;
	DECLARE @capacity INT;
	DECLARE @numberKeysOut INT;
	
	/*check how many keys left*/
	/*find capacity*/
	SELECT @tokenId=tokenId, @capacity=tokenCapacity 
	FROM Token
	WHERE tokenNum = @tokenNum;

	/*find how many keys are out or lost*/
	SELECT @numberKeysOut=COUNT (*)
	FROM CheckOutRecord C
	WHERE C.tokenId=@tokenId AND C.returnStatus is NULL

	IF (@capacity-@numberKeysOut=0)
	BEGIN
		/*should not I rather return a special code to be read by the applications? likw THROW 101????*/
		PRINT 'There are no more '+@tokenNum+' keys in the inventory';
		RETURN ;
	END;

	/*create a record*/
	INSERT INTO CheckOutRecord (netId, kmNetId, tokenId, coDate)
	VALUES (@netId, @kmNetId, @tokenId, GETDATE());
END;
GO


/*Key_Check_In - create a check in record given a key number, a netId of an employee, 
a key master's netid and the date when the key was checked out*/



CREATE PROCEDURE Key_Check_In
(
	@tokenNum VARCHAR(10),
	@netId VARCHAR(15),
	@kmNetId VARCHAR(15),
	@coDate DATE
)
AS
BEGIN
	DECLARE @tokenId INT

	/*find the id of the given key*/
	SELECT @tokenId=tokenId FROM Token
	WHERE tokenNum = @tokenNum;

	/*make a check in record*/
	INSERT INTO CheckInRecord(netId, kmNetId, tokenId, returnDate)
	VALUES (@netId, @kmNetId, @tokenId, GETDATE());

	/*update the foreign key for "check in" in the checkout record to SCOPE_IDENTITY()
	since we know  that the last record made was the insert record*/

	UPDATE CheckOutRecord
	SET returnStatus= SCOPE_IDENTITY()
	/*Since theoretically mulyiple keys could be checkedout on the same day
	we want to select the one whose returnstatus is NULL*/
	WHERE tokenId=@tokenId AND netId=@netId AND coDate=@coDate AND returnStatus IS NULL;

END;
GO


/*Key_Loss - given a specific checkout record make a loss record of the key
that was checked out. Mark the status of they key in the CheckOutRecord as "lost"*/
CREATE PROCEDURE Key_Loss
(
	@tokenNum VARCHAR(10),
	@netId VARCHAR(15),
	@kmNetId VARCHAR(15),
	@coDate DATE
)
AS
BEGIN
	DECLARE @tokenId INT

	/*find the id of the given key*/
	SELECT @tokenId=tokenId FROM Token
	WHERE tokenNum = @tokenNum;

	/*find the corresponding checkout record, in case there are multiple with the same key on the same day
	by the same person pick the one with the smaller coId*/
	DECLARE @coId INT
	SELECT @coId=MIN(A.coId)
	FROM	(SELECT C.coId 
			FROM CheckOutRecord C
			WHERE tokenId=@tokenId AND netId=@netId AND coDate=@coDate 
			AND lossStatus IS NULL AND returnStatus IS NULL) A

	IF (@coId IS NULL)
		PRINT 'The key you selected is no longer outstanding';
		RETURN;

	
	/*make a loss record*/
	INSERT INTO LossRecord(netId, kmNetId, tokenId, lossDate)
	VALUES (@netId, @kmNetId, @tokenId, GETDATE());

	/*update the checkout record with a corresponding foreign key*/
	UPDATE CheckOutRecord
	SET lossStatus= SCOPE_IDENTITY()
	WHERE coId=@coId;

END;
GO



/*Change_Capacity - allows the keymaster to add or reduce the number of keys in the inventory*/

CREATE PROCEDURE Pay_Fee
(
@tokenNum VARCHAR(10),
@netid VARCHAR(15),
@coDate DATE,
@lossDate DATE
)
AS
BEGIN 
	DECLARE @tokenId INT
	/*find the id of the given key*/
	SELECT @tokenId=tokenId FROM Token
	WHERE tokenNum = @tokenNum;

	/*If there many keys of the same number that were given out and lost on the same date
	and are still not paid - get the one with minimum loss id*/

	DECLARE @lossId INT
	SELECT @lossId=MIN(A.lossId)
	FROM	(SELECT L.lossId 
			FROM LossRecord L
			INNER JOIN CheckOutRecord C
			ON L.lossId=C.lossStatus
			WHERE L.tokenId=@tokenId AND L.lossDate=@lossDate
				 AND L.netId=@netId AND L.paid IS NULL AND C.coDate=@coDate) A

	/*set the "paid field" for the record with that lossId to 'Y'*/
	UPDATE LossRecord
	SET paid='Y'
	WHERE lossId=@lossId;

END;

GO
	
CREATE PROCEDURE Change_Capacity
(
@deltaCapacity INT,
@tokenNum VARCHAR(10)
)
AS
BEGIN
	DECLARE @tokenId INT
	DECLARE @currentCapacity INT
	DECLARE @keysOut INT

	/*find the id of the given key*/
	SELECT @tokenId=tokenId, @currentCapacity=tokenCapacity 
	FROM Token
	WHERE tokenNum = @tokenNum;

	/*capacity cannot be negative and it cannot be less than the sum of the keys
	that are currently in circulation  or lost*/

	/*find the number of keys that are currently in circulation*/
	SELECT @keysOut=COUNT (*)
	FROM CheckOutRecord
	WHERE tokenId=@tokenId AND returnStatus IS NULL
	
	/*check that the update will not set the capacity to the number that violates the rule*/

	IF ((@currentCapacity+@deltaCapacity)<@keysOut) OR ((@currentCapacity+@deltaCapacity)<0)
	BEGIN
		/*should not I rather return a special code to be read by the applications? likw THROW 102????*/
		PRINT 'Incorrect change in quantity';
		RETURN;
	END;

	/*update capacity*/
	UPDATE Token
	SET tokenCapacity=tokenCapacity+@deltaCapacity
	WHERE tokenId=@tokenId;

END;
GO


/*Rekey*/

CREATE PROCEDURE Rekey
(
@oldTokenNum VARCHAR(10),
@newTokenNum VARCHAR(10),
@facilityName VARCHAR(40),
@roomNum VARCHAR(10),
@itemName VARCHAR(10),
@itemDesc VARCHAR(20)
)
AS
BEGIN
	DECLARE @newTokenId INT

	/*check if the key number already exists in the database*/
	SELECT @newTokenId=tokenId
	FROM Token
	WHERE tokenNum=@newTokenNum


	IF (@newTokenId IS NULL)
		BEGIN
		/*should not I rather return a special code to be read by the applications? likw THROW 103????*/
		PRINT 'Please add this keys to the inventory before assinging it to a location';
		RETURN;
		END;
		
	/*now we know that the info about the new key is in the system and we can proceed*/
	
	/*check if we are about to replace the last(or the only) assignment of a given token
	in that case we need to mark the token as invalid*/

	PRINT 'new token id = '+@newTokenId;

	DECLARE @oldTokenId INT

	SELECT @oldTokenId=tokenId
	FROM Token
	WHERE tokenNum=@oldTokenNum

	PRINT 'old token id = '+@oldTokenId;

	/*cound how many items are left under the old key*/

	DECLARE @oldTokenAssignNum INT

	SELECT @oldTokenAssignNum=COUNT(*)
	FROM KeyAssignment K
	WHERE K.tokenId=@oldTokenId

	PRINT 'number of assignments to old key = '+@oldTokenAssignNum;


	/*find the id of the item that needs to be reassigned*/
	DECLARE @itemId INT

	SELECT @itemId=itemId
	FROM Item I
	INNER JOIN Room R
	ON I.roomId= R.roomId
			INNER JOIN Facility F
			ON R.facilityId=F.facilityId
	WHERE (R.roomNum=@roomNum AND F.facilityName=@facilityName AND (I.itemName=@itemName
	AND (I.itemDesc=@itemDesc OR (I.itemDesc IS NULL AND @itemDesc IS NULL))));
	PRINT 'item id = '+@itemId;

	/*reassign*/
	UPDATE KeyAssignment 
	SET tokenId=@newTokenId
	WHERE tokenId=@oldTokenId AND itemId=@itemId;

	PRINT 'reassigned'

	/*make sure that token validity is set to Y*/
	UPDATE Token
	SET tokenValidity='Y'
	WHERE tokenId=@newTokenId
	IF (@oldTokenAssignNum=1)
		BEGIN
		UPDATE Token
		SET tokenValidity='N'
		WHERE tokenId=@oldTokenId
		END;
END;
GO


/*Add_Key*/
 CREATE PROCEDURE Add_Key
 (
 @tokenNum VARCHAR(10),
 @tokenType VARCHAR(10),
 @tokeCapacity INT, 
 @lossFee SMALLMONEY
 )
 AS
 BEGIN
 INSERT INTO Token
 VALUES (@tokenNum, @tokenType, @tokeCapacity, 'Y', @lossFee)
 END;
GO

/*Add_Location*/