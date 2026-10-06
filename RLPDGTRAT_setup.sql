--=============================================================
-- Digital royalty rates by contract (Option 1).
--
-- When the monthly run copies a print item's product licence
-- lines (RLPPROD) onto its digital item, RLREBKADPR looks each
-- line up here by royalty library + contract + licence code.
-- If a row is found, the digital item's line gets this rate
-- instead of the print rate. Contracts with no row here keep
-- the print rate, exactly as today.
--
-- One row per contract and licence code, entered once by
-- Royalties - not per item. Every digital item under that
-- contract picks it up on the next monthly run, eBook or
-- download alike (both copy licences through RLREBKADPR).
--
-- The rate columns mirror RLPPROD:
--   PAYRAT  Pay rate          DEC(7,5)
--   PAYRTF  'F' if PAYRAT is a flat amount
--   DSPCRT  Contract rate as displayed (alpha)
-- Enter them the way the same licence line looks on a print
-- item (see Willis_digital_1Oct_check.sql query 4) before go-live.
--
-- Run step 1 BEFORE compiling the new RLREBKADPR.
--=============================================================

--------------------------------------------------------------
-- 1. Digital rate table and the keyed index RLREBKADPR reads
--------------------------------------------------------------
CREATE TABLE OBJECT.RLPDGTRAT (
   ROYLIB    CHAR(2)      NOT NULL,
   CNTRID    CHAR(8)      NOT NULL,
   PLCODE    CHAR(3)      NOT NULL,
   PAYRAT    DECIMAL(7,5) NOT NULL DEFAULT 0,
   PAYRTF    CHAR(1)      NOT NULL DEFAULT '',
   DSPCRT    CHAR(8)      NOT NULL DEFAULT '',
   COMT40    CHAR(40)     NOT NULL DEFAULT '',
   USERID    CHAR(18)     NOT NULL DEFAULT USER,
   DTEADDED  DATE         NOT NULL DEFAULT CURRENT_DATE,
   PRIMARY KEY (ROYLIB, CNTRID, PLCODE)
) RCDFMT RLPDGTRA$;

LABEL ON TABLE OBJECT.RLPDGTRAT IS
   'RL-Digital royalty rates by contract';

LABEL ON COLUMN OBJECT.RLPDGTRAT (
   ROYLIB   IS 'Royalty library: HL AM AP AT CL TM WL',
   CNTRID   IS 'Contract ID',
   PLCODE   IS 'Product License Code',
   PAYRAT   IS 'Digital pay rate',
   PAYRTF   IS '"F" if PAYRAT is flat',
   DSPCRT   IS 'Digital rate displayed (alpha)'
);

CREATE UNIQUE INDEX OBJECT.RLLDGTRAT
   ON OBJECT.RLPDGTRAT (ROYLIB, CNTRID, PLCODE);

LABEL ON INDEX OBJECT.RLLDGTRAT IS
   'RL-Digital rates by lib, contract, lic code';

--------------------------------------------------------------
-- 2. Willis rates - fill in from Royalties once confirmed.
--    ROYLIB 'WL' = WL_ROY. CNTRID / PLCODE values come from
--    Willis_digital_1Oct_check.sql query 4.
--------------------------------------------------------------
-- INSERT INTO OBJECT.RLPDGTRAT
--        (ROYLIB, CNTRID, PLCODE, PAYRAT, PAYRTF, DSPCRT, COMT40)
-- VALUES ('WL', '????????', '???', 0.00000, '', '', 'Willis digital - Publisher'),
--        ('WL', '????????', '???', 0.00000, '', '', 'Willis digital - Name & Likeness');

--------------------------------------------------------------
-- 3. After the next monthly run: digital licence lines whose
--    rate came from this table, next to the print line.
--------------------------------------------------------------
WITH LINKS (KIND, PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT 'EBOOK', ORGITMNUM, ITMNUM FROM IVPEPUBITM
    UNION ALL
    SELECT 'DOWNLOAD', ITMNUM, RELITMNUM FROM IVPRELITM WHERE RELTYPEID = 1
)
SELECT L.KIND, L.PRINT_ITEM, L.DIGITAL_ITEM,
       D.CNTRID, D.PLCODE, D.STMTID,
       P.DSPCRT AS PRINT_RATE_SHOWN,   P.PAYRAT AS PRINT_PAYRAT,
       D.DSPCRT AS DIGITAL_RATE_SHOWN, D.PAYRAT AS DIGITAL_PAYRAT
  FROM LINKS L
  JOIN WL_ROY.RLPPROD D
    ON D.ITMNUM = L.DIGITAL_ITEM
  JOIN OBJECT.RLPDGTRAT R
    ON R.ROYLIB = 'WL' AND R.CNTRID = D.CNTRID AND R.PLCODE = D.PLCODE
  LEFT JOIN WL_ROY.RLPPROD P
    ON P.ITMNUM = L.PRINT_ITEM
   AND P.STMTID = D.STMTID AND P.PLCODE = D.PLCODE
   AND P.COMP#  = D.COMP#  AND P.TERSEQ = D.TERSEQ AND P.TERR = D.TERR
 ORDER BY D.CNTRID, L.PRINT_ITEM, L.DIGITAL_ITEM;
