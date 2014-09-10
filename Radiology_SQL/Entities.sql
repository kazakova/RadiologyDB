/*CREATE DATABASE Radiology_Keys*/

USE Radiology_Keys

CREATE TABLE Facility
(	
	facilityId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	facilityAbbrev VARCHAR(20),
	facilityName VARCHAR(40) NOT NULL
);

CREATE TABLE Room 
(
	roomId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	facilityId INT NOT NULL FOREIGN KEY REFERENCES Facility(facilityId),
	roomNum VARCHAR(10) NOT NULL,
	roomDesc VARCHAR (50),
);

ALTER TABLE Room
	ADD CONSTRAINT room_uniq_constr UNIQUE (facilityId, roomNum);

CREATE TABLE Item
(
	itemId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	roomId INT FOREIGN KEY REFERENCES  Room(roomId),
	itemName VARCHAR(10) NOT NULL,
	itemDesc VARCHAR(20)
);

ALTER TABLE Item
	ADD CONSTRAINT item_uniq_constr UNIQUE (roomId, itemName, itemDesc);

/*Token - key*/

CREATE TABLE Token
(
	tokenId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	tokenNum VARCHAR(10) UNIQUE NOT NULL,
	tokenType VARCHAR(10) NOT NULL,
	tokenCapacity INT NOT NULL,
	tokenValidity VARCHAR(1) NOT NULL,
	lossFee SMALLMONEY 
);

ALTER TABLE Token 
	ADD CONSTRAINT validity_constr
	CHECK (tokenValidity IN ('Y', 'N'));

ALTER TABLE Token 
	ADD CONSTRAINT capacity_constr
	CHECK (tokenCapacity >=0);

CREATE TABLE KeyAssignment
(
	tokenId INT NOT NULL FOREIGN KEY REFERENCES Token(tokenId),
	itemId INT NOT NULL Foreign KEY REFERENCES Item(itemID)

);

ALTER TABLE KeyAssignment
	ADD CONSTRAINT key_comb_constr UNIQUE (tokenId, itemId);

CREATE TABLE RekeyRecord
(
	tokenId INT NOT NULL FOREIGN KEY REFERENCES Token(tokenId),
	previousTokenId INT NOT NULL FOREIGN KEY REFERENCES Token(tokenId),
	rekeyDate DATE NOT NULL
);

ALTER TABLE RekeyRecord
	ADD CONSTRAINT rekey_constr UNIQUE (tokenId, previousTokenId, rekeyDate);

CREATE TABLE Employee
(
	netId VARCHAR(15) PRIMARY KEY CLUSTERED
);

CREATE TABLE KeyMaster
(
	kmNetId VARCHAR(15) PRIMARY KEY CLUSTERED
);

CREATE TABLE CheckInRecord(
	ciId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	netId VARCHAR(15) NOT NULL FOREIGN KEY REFERENCES Employee(netId),
	kmNetId VARCHAR(15) NOT NULL FOREIGN KEY REFERENCES KeyMaster(kmNetId),
	tokenId INT NOT NULL FOREIGN KEY REFERENCES Token(tokenId),
	returnDate DATE NOT NULL,
);

CREATE TABLE LossRecord(
	lossId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	netId VARCHAR(15) NOT NULL FOREIGN KEY REFERENCES Employee(netId),
	kmNetId VARCHAR(15) NOT NULL FOREIGN KEY REFERENCES KeyMaster(kmNetId),
	tokenId INT NOT NULL FOREIGN KEY REFERENCES Token(tokenId),
	lossDate DATE NOT NULL,
	paid VARCHAR (1),
	foundStatus INT FOREIGN KEY REFERENCES CheckInRecord(ciId),
);

ALTER TABLE LossRecord
	ADD CONSTRAINT paid_constr
	CHECK (paid in ('Y', 'N'));

CREATE TABLE CheckOutRecord(
	coId INT PRIMARY KEY CLUSTERED IDENTITY(1,1),
	netId VARCHAR(15) NOT NULL FOREIGN KEY REFERENCES Employee(netId),
	kmNetId VARCHAR(15) NOT NULL FOREIGN KEY REFERENCES KeyMaster(kmNetId),
	tokenId INT NOT NULL FOREIGN KEY REFERENCES Token(tokenId),
	coDate DATE NOT NULL,
	returnStatus INT FOREIGN KEY REFERENCES CheckInRecord(ciId),
	lossStatus INT FOREIGN KEY REFERENCES LossRecord(lossId)
	/*did not add token validity - can be checked through a query*/
);




