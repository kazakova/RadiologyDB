USE Radiology_Keys

BULK INSERT Employee
FROM 'C:\Users\kazako\Desktop\Radiology\Data\Employee.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
SELECT * FROM Employee


BULK INSERT Facility
FROM 'C:\Users\kazako\Desktop\Radiology\Data\Facility.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
SELECT * FROM Facility


BULK INSERT Room
FROM 'C:\Users\kazako\Desktop\Radiology\Data\Room.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
SELECT * FROM Room

BULK INSERT Item
FROM 'C:\Users\kazako\Desktop\Radiology\Data\Item.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
SELECT * FROM Item


BULK INSERT Token
FROM 'C:\Users\kazako\Desktop\Radiology\Data\Token.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
SELECT * FROM Token

BULK INSERT KeyAssignment
FROM 'C:\Users\kazako\Desktop\Radiology\Data\KeyAssignment.txt'
WITH
(
FIRSTROW=2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
SELECT * FROM KeyAssignment