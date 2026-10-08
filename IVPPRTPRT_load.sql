-- ====================================================================
-- IVPPRTPRT list load - printed price from a spreadsheet (SOS-2092)
-- ====================================================================
-- Loads a list of items and their printed-price value into IVPPRTPRT,
-- with an IVPMAINT history row for each, so the change shows in the
-- item's history like any other field change. One script for every
-- list US Print sends:
--
--   N  no price printed on the product (the 35,000+ removals list)
--   Y  price printed on the product
--   S  stickered with US information on arrival (foreign publishers)
--
-- Blank - not known - is never loaded; it is what an item has until
-- someone says otherwise.
--
-- Writes to the test library, H33979: IVPPRTPRT, IVPMAINT and the
-- work table PRTLOAD. Item numbers are checked against production,
-- OBJECT.IVPITEMS. To load production later, change H33979. to
-- OBJECT. on the IVPPRTPRT and IVPMAINT lines.
--
-- STEP 1 - a work table for the list (once; clear it between lists):
--
--   CREATE TABLE H33979.PRTLOAD
--         (ITMNUM DECIMAL(8, 0) NOT NULL,
--          PRTPRC CHAR(1)       NOT NULL)
--
-- STEP 2 - load the list into it. Save the spreadsheet as a CSV with
-- no heading row: column 1 the AS400 item number, column 2 the value
-- (N, Y or S). Put it in the IFS, then:
--
--   CPYFRMIMPF FROMSTMF('/home/ELIASI/repricing/prtload.csv')
--              TOFILE(H33979/PRTLOAD) MBROPT(*REPLACE)
--              RCDDLM(*CRLF) DTAFMT(*DLM) FLDDLM(',')
--
-- STEP 3 - check the list before loading anything. Run these in Run
-- SQL Scripts; RUNSQLSTM does not show the results of a SELECT.
--
--   -- rows, distinct items, and how many of each value
--   SELECT PRTPRC, COUNT(*), COUNT(DISTINCT ITMNUM)
--     FROM H33979.PRTLOAD GROUP BY PRTPRC;
--
--   -- values other than N, Y or S (these are skipped)
--   SELECT * FROM H33979.PRTLOAD WHERE PRTPRC NOT IN ('N', 'Y', 'S');
--
--   -- item numbers not on AS400 (send these back to US Print)
--   SELECT L.ITMNUM FROM H33979.PRTLOAD L
--    WHERE NOT EXISTS (SELECT 1 FROM OBJECT.IVPITEMS I
--                       WHERE I.ITMNUM = L.ITMNUM);
--
--   -- items listed with two different values (these are skipped)
--   SELECT ITMNUM FROM H33979.PRTLOAD
--    GROUP BY ITMNUM HAVING COUNT(DISTINCT PRTPRC) > 1;
--
--   -- items that already have a value, which this load leaves alone
--   SELECT P.ITMNUM, P.PRTPRC, L.PRTPRC AS LISTED, P.CHGUSER, P.CHGTS
--     FROM H33979.IVPPRTPRT P
--     JOIN H33979.PRTLOAD L ON L.ITMNUM = P.ITMNUM
--    WHERE P.PRTPRC <> ' ';
--
-- STEP 4 - load:
--
--   RUNSQLSTM SRCSTMF('.../IVPPRTPRT_load.sql') COMMIT(*NONE)
--             NAMING(*SQL)
--
-- STEP 5 - empty the work table before the next list:
--
--   DELETE FROM H33979.PRTLOAD
--
-- What it does, in order:
--
--   1. Every listed item that is on IVPITEMS, has one valid value on
--      the list and no IVPPRTPRT row gets one with that value, TPAPRV
--      blank, added by 'SOS2092'.
--   2. Every such item whose row exists with PRTPRC blank (not yet
--      known) gets the listed value. A value already set - by an
--      earlier list or on the RRN screen - is never overwritten, so the
--      N list loaded first is not undone by a Y list after it.
--   3. Every item changed by 1 or 2 gets one IVPMAINT row: FLDNAM
--      'PRTPRC', before blank, after the value, COMMENT 'SOS2092'.
--
-- Safe to run twice: the second run finds nothing left to change and
-- writes no further history, because step 3 only covers items marked
-- by this run (CHGUSER 'SOS2092LD') and clears the mark afterwards.
--
-- IVPMAINT is filled field for field as P1VBTCHUP and IVRRPCAPL fill
-- it. MAINTNAME, the full name, says where the change came from - the
-- person running the load is in MAINTWHO. BEFORE, AFTER and COMMENT
-- are SQL keywords, so they are quoted.
-- ====================================================================

-- 1. New rows for listed items with no IVPPRTPRT row yet
INSERT INTO H33979.IVPPRTPRT
        (ITMNUM, PRTPRC, TPAPRV, ADDTS, ADDUSER, CHGTS, CHGUSER)
SELECT L.ITMNUM, MAX(L.PRTPRC), ' ',
       CURRENT TIMESTAMP, 'SOS2092',
       CURRENT TIMESTAMP, 'SOS2092LD'
  FROM H33979.PRTLOAD L
 WHERE L.PRTPRC IN ('N', 'Y', 'S')
   AND EXISTS (SELECT 1 FROM OBJECT.IVPITEMS I WHERE I.ITMNUM = L.ITMNUM)
   AND NOT EXISTS (SELECT 1 FROM H33979.IVPPRTPRT P
                    WHERE P.ITMNUM = L.ITMNUM)
 GROUP BY L.ITMNUM
HAVING COUNT(DISTINCT L.PRTPRC) = 1;

-- 2. Existing rows still blank (not known) take the listed value
UPDATE H33979.IVPPRTPRT P
   SET PRTPRC  = (SELECT MAX(L.PRTPRC) FROM H33979.PRTLOAD L
                   WHERE L.ITMNUM = P.ITMNUM),
       CHGTS   = CURRENT TIMESTAMP,
       CHGUSER = 'SOS2092LD'
 WHERE P.PRTPRC = ' '
   AND P.ITMNUM IN (SELECT L.ITMNUM FROM H33979.PRTLOAD L
                     WHERE L.PRTPRC IN ('N', 'Y', 'S')
                     GROUP BY L.ITMNUM
                    HAVING COUNT(DISTINCT L.PRTPRC) = 1);

-- 3. One history row per item changed by this run
INSERT INTO H33979.IVPMAINT
        (ITMNUM, FLDNAM, MAINTYYYY, MAINTMM, MAINTDD, MAINTWHO,
         "BEFORE", "AFTER", REPCODE, "COMMENT", MAINTNAME)
SELECT P.ITMNUM, 'PRTPRC',
       YEAR(CURRENT DATE), MONTH(CURRENT DATE), DAY(CURRENT DATE),
       CAST(USER AS CHAR(10)),
       ' ', P.PRTPRC, 'N', 'SOS2092',
       'US Print list - SOS-2092 load'
  FROM H33979.IVPPRTPRT P
 WHERE P.CHGUSER = 'SOS2092LD';

-- 4. Clear the run marker, so a second run writes no more history
UPDATE H33979.IVPPRTPRT
   SET CHGUSER = 'SOS2092'
 WHERE CHGUSER = 'SOS2092LD';
