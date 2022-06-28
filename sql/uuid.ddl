CREATE SCHEMA IF NOT EXISTS `hm_uuid` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `hm_uuid`;

CREATE TABLE IF NOT EXISTS uuids
(
  UUID CHAR(32) PRIMARY KEY,
  ENTITY_TYPE VARCHAR(20) NOT NULL,
  TIME_GENERATED TIMESTAMP NOT NULL,
  USER_ID VARCHAR(50) NOT NULL,
  USER_EMAIL VARCHAR(50) NULL
);

CREATE TABLE IF NOT EXISTS uuids_attributes
(
  UUID CHAR(32) PRIMARY KEY,
  BASE_ID VARCHAR(10) NULL /*UNIQUE...replace with explicit INDEX implementation below*/,
  SUBMISSION_ID VARCHAR(170) NULL,
  DESCENDANT_COUNT INT NULL DEFAULT 0
);
CREATE UNIQUE INDEX `UNQ_SUBMISSION_ID` ON uuids_attributes (`SUBMISSION_ID` ASC) ;
CREATE UNIQUE INDEX `UNQ_HUBMAP_BASE_ID` ON uuids_attributes(`BASE_ID` ASC) ;

ALTER TABLE `uuids_attributes`
ADD  FOREIGN KEY (`UUID`) REFERENCES `uuids`(`UUID`) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS ancestors
(
  ANCESTOR_UUID CHAR(32) NOT NULL,
  DESCENDANT_UUID CHAR(32) NOT NULL
);
ALTER TABLE `ancestors`
ADD  FOREIGN KEY (`ANCESTOR_UUID`) REFERENCES `uuids`(`UUID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `ancestors`
ADD  FOREIGN KEY (`DESCENDANT_UUID`) REFERENCES `uuids`(`UUID`) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE UNIQUE INDEX `UNQ_ANC_DEC_UUID` ON ancestors (`ANCESTOR_UUID` ASC, `DESCENDANT_UUID` ASC);
CREATE INDEX `IDX_ANC_UUID` ON ancestors (`ANCESTOR_UUID` ASC);
CREATE INDEX `IDX_DEC_UUID` ON ancestors (`DESCENDANT_UUID` ASC);

CREATE TABLE IF NOT EXISTS organs
(
  DONOR_UUID CHAR(32) PRIMARY KEY,
  ORGAN_CODE VARCHAR(8) NOT NULL,
  ORGAN_COUNT INT NOT NULL DEFAULT 0
);
ALTER TABLE `organs`
ADD  FOREIGN KEY (`DONOR_UUID`) REFERENCES `uuids`(`UUID`) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `IDX_ORGAN_CODE` ON organs (`ORGAN_CODE` ASC);

CREATE TABLE IF NOT EXISTS data_centers
(
  UUID CHAR(32) PRIMARY KEY,
  DC_UUID VARCHAR(40) NOT NULL /*UNIQUE...replace with explicit INDEX implementation below*/,
  DC_CODE VARCHAR(8) NOT NULL /*UNIQUE...replace with explicit INDEX implementation below*/
);

ALTER TABLE `data_centers`
ADD  FOREIGN KEY (`UUID`) REFERENCES `uuids`(`UUID`) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE UNIQUE INDEX `UNQ_DC_UUID` ON data_centers (`DC_UUID` ASC);
CREATE UNIQUE INDEX `UNQ_DC_CODE` ON data_centers (`DC_CODE` ASC);
CREATE INDEX `IDX_DC_All` ON data_centers (`UUID` ASC, `DC_UUID` ASC, `DC_CODE` ASC);

CREATE TABLE IF NOT EXISTS files
(
  UUID CHAR(32) PRIMARY KEY,
  BASE_DIR VARCHAR(50) NOT NULL,
  PATH VARCHAR(65000) NULL, -- Cause warning "1246 Converting column from VARCHAR to TEXT
  CHECKSUM VARCHAR(50) NULL,
  SIZE BIGINT
);

ALTER TABLE `files`
ADD  FOREIGN KEY (`UUID`) REFERENCES `uuids`(`UUID`) ON DELETE CASCADE ON UPDATE CASCADE;
