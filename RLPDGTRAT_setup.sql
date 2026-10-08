--=============================================================
-- Digital royalty rates by payee (Option 1).
--
-- When the monthly run copies a print item's product licence
-- lines (RLPPROD) onto its digital item, RLREBKADPR looks each
-- line up here by royalty library + payee (STMTID) + contract.
-- A row for the exact contract wins; a row with a blank
-- contract applies to every contract for that payee. If a row
-- is found, the digital item's line gets this rate instead of
-- the print rate. Payees with no row keep the print rate,
-- exactly as today.
--
-- Entered once per payee by Royalties - never per item. Every
-- digital item (eBook or download) picks it up on the next
-- monthly run, or straight away from an on-demand run
-- (RLCEBKUPD). That run is also the bulk correction of the
-- digital items that already exist.
--
-- The rate columns mirror RLPPROD:
--   PAYRAT  Pay rate          DEC(7,5)
--   PAYRTF  'F' if PAYRAT is a flat amount
--   DSPCRT  Contract rate as displayed (alpha)
-- Enter them exactly as a gross-receipts line is stored today
-- (step 0 shows how) before go-live.
--
-- Run step 1 BEFORE compiling the new RLREBKADPR.
--=============================================================

--------------------------------------------------------------
-- 0. How is a gross-receipts ("G") rate stored on a licence
--    line, and where do WILLISUK lines live? Use the result to
--    fill in step 2.
--------------------------------------------------------------
SELECT 'OBJECT' AS LIB, DSPCRT, PAYRTF, PAYRAT, COUNT(*) AS LINES
  FROM OBJECT.RLPPROD
 WHERE DSPCRT LIKE '%G%'
 GROUP BY DSPCRT, PAYRTF, PAYRAT
UNION ALL
SELECT 'WL_ROY', DSPCRT, PAYRTF, PAYRAT, COUNT(*)
  FROM WL_ROY.RLPPROD
 WHERE DSPCRT LIKE '%G%'
 GROUP BY DSPCRT, PAYRTF, PAYRAT
 ORDER BY LINES DESC;

SELECT 'OBJECT' AS LIB, STMTID, CNTRID, DSPCRT, PAYRTF, PAYRAT, COUNT(*) AS LINES
  FROM OBJECT.RLPPROD
 WHERE STMTID = 'WILLISUK'
 GROUP BY STMTID, CNTRID, DSPCRT, PAYRTF, PAYRAT
UNION ALL
SELECT 'WL_ROY', STMTID, CNTRID, DSPCRT, PAYRTF, PAYRAT, COUNT(*)
  FROM WL_ROY.RLPPROD
 WHERE STMTID = 'WILLISUK'
 GROUP BY STMTID, CNTRID, DSPCRT, PAYRTF, PAYRAT
 ORDER BY LIB, CNTRID, LINES DESC;

--------------------------------------------------------------
-- 1. Digital rate table and the keyed index RLREBKADPR reads
--------------------------------------------------------------
CREATE TABLE OBJECT.RLPDGTRAT (
   ROYLIB    CHAR(2)      NOT NULL,
   STMTID    CHAR(8)      NOT NULL,
   CNTRID    CHAR(8)      NOT NULL DEFAULT '',
   PAYRAT    DECIMAL(7,5) NOT NULL DEFAULT 0,
   PAYRTF    CHAR(1)      NOT NULL DEFAULT '',
   DSPCRT    CHAR(8)      NOT NULL DEFAULT '',
   COMT40    CHAR(40)     NOT NULL DEFAULT '',
   USERID    CHAR(18)     NOT NULL DEFAULT USER,
   DTEADDED  DATE         NOT NULL DEFAULT CURRENT_DATE,
   PRIMARY KEY (ROYLIB, STMTID, CNTRID)
) RCDFMT RLPDGTRA$;

LABEL ON TABLE OBJECT.RLPDGTRAT IS
   'RL-Digital royalty rates by payee';

LABEL ON COLUMN OBJECT.RLPDGTRAT (
   ROYLIB   IS 'Royalty library: HL AM AP AT CL TM WL',
   STMTID   IS 'Statement ID (payee)',
   CNTRID   IS 'Contract ID, blank = all contracts',
   PAYRAT   IS 'Digital pay rate',
   PAYRTF   IS '"F" if PAYRAT is flat',
   DSPCRT   IS 'Digital rate displayed (alpha)'
);

CREATE UNIQUE INDEX OBJECT.RLLDGTRAT
   ON OBJECT.RLPDGTRAT (ROYLIB, STMTID, CNTRID);

LABEL ON INDEX OBJECT.RLLDGTRAT IS
   'RL-Digital rates by lib, payee, contract';

--------------------------------------------------------------
-- 2. WILLISUK: 50 on gross receipts for every digital item,
--    all contracts. Replace the ??? with the PAYRAT / PAYRTF /
--    DSPCRT a 50 G line has in step 0. Add a 'HL' row too if
--    step 0 shows WILLISUK lines in OBJECT.
--------------------------------------------------------------
-- INSERT INTO OBJECT.RLPDGTRAT
--        (ROYLIB, STMTID, CNTRID, PAYRAT, PAYRTF, DSPCRT, COMT40)
-- VALUES ('WL', 'WILLISUK', '', ???, '?', '????????',
--         'Willis digital - 50 gross receipts');

--------------------------------------------------------------
-- 3. After the run: WILLISUK lines on digital items, next to
--    the print line they were copied from.
--------------------------------------------------------------
WITH LINKS (KIND, PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT 'EBOOK', ORGITMNUM, ITMNUM FROM OBJECT.IVPEPUBITM
    UNION ALL
    SELECT 'DOWNLOAD', ITMNUM, RELITMNUM FROM OBJECT.IVPRELITM WHERE RELTYPEID = 1
)
SELECT L.KIND, L.PRINT_ITEM, L.DIGITAL_ITEM,
       D.STMTID, D.CNTRID, D.PLCODE,
       P.DSPCRT AS PRINT_RATE_SHOWN,   P.PAYRAT AS PRINT_PAYRAT,
       D.DSPCRT AS DIGITAL_RATE_SHOWN, D.PAYRAT AS DIGITAL_PAYRAT
  FROM LINKS L
  JOIN WL_ROY.RLPPROD D
    ON D.ITMNUM = L.DIGITAL_ITEM
   AND D.STMTID = 'WILLISUK'
  LEFT JOIN WL_ROY.RLPPROD P
    ON P.ITMNUM = L.PRINT_ITEM
   AND P.STMTID = D.STMTID AND P.PLCODE = D.PLCODE
   AND P.COMP#  = D.COMP#  AND P.TERSEQ = D.TERSEQ AND P.TERR = D.TERR
 ORDER BY L.PRINT_ITEM, L.DIGITAL_ITEM;
