-- ====================================================================
-- IVPPRTPRT one-time load - items with no printed price (SOS-2092)
-- ====================================================================
-- US Print's list of items whose price has been removed from the
-- product becomes PRTPRC 'N' in IVPPRTPRT, with an IVPMAINT history
-- row for each, so the change shows in the item's history like any
-- other field change.
--
-- Writes to the test library, H33979: IVPPRTPRT, IVPMAINT and the
-- work table PRTLOAD. Item numbers are checked against production,
-- OBJECT.IVPITEMS. To load production later, change H33979. to
-- OBJECT. on the IVPPRTPRT and IVPMAINT lines.
--
-- STEP 1 - a work table for the list, one item number per row:
--
--   CREATE TABLE H33979.PRTLOAD (ITMNUM DECIMAL(8, 0) NOT NULL)
--
-- STEP 2 - load the list into it. Save the spreadsheet as a CSV with
-- the AS400 item number in the first column and no heading row, put
-- it in the IFS, then:
--
--   CPYFRMIMPF FROMSTMF('/home/ELIASI/repricing/prtload.csv')
--              TOFILE(H33979/PRTLOAD) MBROPT(*REPLACE)
--              RCDDLM(*CRLF) DTAFMT(*DLM) FLDDLM(',')
--
-- STEP 3 - check the list before loading anything. Run these in Run
-- SQL Scripts; RUNSQLSTM does not show the results of a SELECT.
--
--   -- rows on the list, and distinct items
--   SELECT COUNT(*), COUNT(DISTINCT ITMNUM) FROM H33979.PRTLOAD;
--
--   -- item numbers not on AS400 (send these back to US Print)
--   SELECT L.ITMNUM FROM H33979.PRTLOAD L
--    WHERE NOT EXISTS (SELECT 1 FROM OBJECT.IVPITEMS I
--                       WHERE I.ITMNUM = L.ITMNUM);
--
--   -- items that already have a printed-price value, which this load
--   -- leaves alone (someone has set them on the RRN screen already)
--   SELECT P.ITMNUM, P.PRTPRC, P.CHGUSER, P.CHGTS
--     FROM H33979.IVPPRTPRT P
--    WHERE P.ITMNUM IN (SELECT ITMNUM FROM H33979.PRTLOAD)
--      AND P.PRTPRC <> ' ';
--
-- STEP 4 - load:
--
--   RUNSQLSTM SRCSTMF('.../IVPPRTPRT_load.sql') COMMIT(*NONE)
--             NAMING(*SQL)
--
-- What it does, in order:
--
--   1. Every listed item that is on IVPITEMS and has no IVPPRTPRT row
--      gets one, PRTPRC 'N', TPAPRV blank, added by 'SOS2092'.
--   2. Every listed item whose row exists with PRTPRC blank (not yet
--      known) is set to 'N'. A value someone has already set - Y, N
--      or S - is never overwritten.
--   3. Every item changed by 1 or 2 gets one IVPMAINT row: FLDNAM
--      'PRTPRC', before blank, after 'N', COMMENT 'SOS2092'.
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
SELECT DISTINCT L.ITMNUM, 'N', ' ',
       CURRENT TIMESTAMP, 'SOS2092',
       CURRENT TIMESTAMP, 'SOS2092LD'
  FROM H33979.PRTLOAD L
 WHERE EXISTS (SELECT 1 FROM OBJECT.IVPITEMS I WHERE I.ITMNUM = L.ITMNUM)
   AND NOT EXISTS (SELECT 1 FROM H33979.IVPPRTPRT P WHERE P.ITMNUM = L.ITMNUM);

-- 2. Existing rows still blank (not known) become 'N'
UPDATE H33979.IVPPRTPRT P
   SET PRTPRC  = 'N',
       CHGTS   = CURRENT TIMESTAMP,
       CHGUSER = 'SOS2092LD'
 WHERE P.PRTPRC = ' '
   AND P.ITMNUM IN (SELECT ITMNUM FROM H33979.PRTLOAD);

-- 3. One history row per item changed by this run
INSERT INTO H33979.IVPMAINT
        (ITMNUM, FLDNAM, MAINTYYYY, MAINTMM, MAINTDD, MAINTWHO,
         "BEFORE", "AFTER", REPCODE, "COMMENT", MAINTNAME)
SELECT P.ITMNUM, 'PRTPRC',
       YEAR(CURRENT DATE), MONTH(CURRENT DATE), DAY(CURRENT DATE),
       CAST(USER AS CHAR(10)),
       ' ', 'N', 'N', 'SOS2092',
       'US Print list - SOS-2092 load'
  FROM H33979.IVPPRTPRT P
 WHERE P.CHGUSER = 'SOS2092LD';

-- 4. Clear the run marker, so a second run writes no more history
UPDATE H33979.IVPPRTPRT
   SET CHGUSER = 'SOS2092'
 WHERE CHGUSER = 'SOS2092LD';
