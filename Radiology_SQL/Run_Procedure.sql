USE Radiology_Keys;
GO

/*DROP PROCEDURE Inventory_Keys
GO*/

/*EXEC Inventory_Keys NULL, 'Mary Gates Hall', NULL, NULL*/

/*EXEC Key_Check_Out 5467, 'kazako', 'deese'
EXEC Key_Check_Out 325, 'madman', 'deese'
EXEC Key_Check_Out 325, 'chejk', 'deese'
EXEC Key_Check_Out 325, 'anna6476', 'deese'
EXEC Key_Check_Out 5467, 'anna6476', 'deese'
EXEC Key_Check_Out 325, 'chenjk', 'deese'

SELECT * FROM CheckOutRecord*/

/*EXEC Key_Check_In 5467, 'kazako', 'deese', '07/07/2014'*/

/*EXEC Key_loss 5467, 'anna6476', 'deese', '07/07/2014'*/



SELECT * FROM CheckOutRecord
SELECT * FROM CheckInRecord
SELECT * FROM LossRecord

SELECT * FROM Token
SELECT * FROM KeyAssignment
SELECT * FROM Room
SELECT * FROM Facility
SELECT * FROM Item

/*EXEC Key_Check_Out 5467, 'anna6476', 'deese'
EXEC Key_Check_Out 5467, 'anna6476', 'deese'
EXEC Key_loss 5467, 'anna6476', 'deese', '07/08/2014'
EXEC Key_loss 5467, 'anna6476', 'deese', '07/08/2014'
EXEC Pay_Fee 5467, 'anna6476', '07/08/2014', '07/08/2014'

EXEC Key_loss 5467, 'anna6476', 'deese', '07/07/2014'

EXEC Change_Capacity -7, 5467

EXEC Key_Check_Out 5467, 'anna6476', 'deese'*/


/*EXEC Add_Key 777, metal, 35, 15

/*trying to overwrite assignment 1-1*/
EXEC Rekey 325, 777, 'Mary Gates Hall', 330, 'Desk', NULL*/

/*DECLARE @num VARCHAR (20)
SET @num='hello'

	SELECT *
	FROM KeyAssignment K
		INNER JOIN Item I
		ON I.itemId=K.itemId
			INNER JOIN Room R
			ON I.roomId= R.roomId
				INNER JOIN Facility F
				ON R.facilityId=F.facilityId
		WHERE (K.tokenId=1 AND R.roomNum=330 AND F.facilityName='Mary Gates Hall' AND (I.itemName='Desk'
		AND (I.itemDesc=@num OR (I.itemDesc IS NULL AND @num IS NULL))))*/


		/*UPDATE KeyAssignment
		SET tokenId=1
		WHERE tokenId=7 and itemId=1*/


EXEC Inventory_Keys NULL, NULL, NULL, NULL , NULL

EXEC Change_Capacity 7, 5467

EXEC Employee_Keys 'anna6476'

EXEC Rekey 578, 588, 'Communications Building', 1, 'Cabinet', '15 on the left'
EXEC Add_Key 588, 'metal', 10, 5