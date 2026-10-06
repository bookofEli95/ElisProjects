--=============================================================
-- Digital items exempt from the monthly royalty refresh.
--
-- RLCEBKUPDM runs on the 1st of every month and, for every
-- digital item linked to a print item, deletes the digital
-- item's royalty set-up and copies the print item's again:
--   eBooks    - RLREBKDLT / RLREBKUPD   (link file IVPEPUBITM)
--   Downloads - RLRDIGDLT / RLRDIGUPD   (link file IVPRELITM)
-- A digital item listed in RLPDGTEXC is skipped by all four
-- programs, so the royalty set-up entered on it is kept.
--
-- Note: an exempt item gets NO set-up from the monthly run at
-- all, including its first one. Let a new digital item go
-- through one run first, then exempt it and correct its rates.
--
-- Run steps 1 and 2 BEFORE compiling the four programs.
--
-- LATER - once digital rates come from the contract (RLPDGTRAT),
-- take the Willis items back off so they follow print again
-- (except for the rate). Do not run until then:
--   DELETE FROM OBJECT.RLPDGTEXC
--    WHERE COMT40 LIKE 'WILLIS - until digital rates live%';
--=============================================================

--------------------------------------------------------------
-- 1. Exemption table and the keyed index the programs read
--------------------------------------------------------------
CREATE TABLE OBJECT.RLPDGTEXC (
   ITMNUM    DECIMAL(8,0) NOT NULL,
   COMT40    CHAR(40)     NOT NULL DEFAULT '',
   USERID    CHAR(18)     NOT NULL DEFAULT USER,
   DTEADDED  DATE         NOT NULL DEFAULT CURRENT_DATE,
   PRIMARY KEY (ITMNUM)
) RCDFMT RLPDGTEX$;

LABEL ON TABLE OBJECT.RLPDGTEXC IS
   'RL-Digital items exempt from monthly refresh';

CREATE UNIQUE INDEX OBJECT.RLLDGTEXC
   ON OBJECT.RLPDGTEXC (ITMNUM);

LABEL ON INDEX OBJECT.RLLDGTEXC IS
   'RL-Digital refresh exemptions by item';

--------------------------------------------------------------
-- 2. The seven eBooks that were hard-coded in RLREBKDLT and
--    RLREBKUPD ("Do not change these items per Karla").
--    Must be loaded before the new programs go live, or these
--    items will be refreshed from print on the next run.
--------------------------------------------------------------
INSERT INTO OBJECT.RLPDGTEXC (ITMNUM, COMT40) VALUES
   (314900, 'Was hard-coded in RLREBKUPD (per Karla)'),
   (318122, 'Was hard-coded in RLREBKUPD (per Karla)'),
   (108014, 'Was hard-coded in RLREBKUPD (per Karla)'),
   (318362, 'Was hard-coded in RLREBKUPD (per Karla)'),
   (319036, 'Was hard-coded in RLREBKUPD (per Karla)'),
   (333284, 'Was hard-coded in RLREBKUPD (per Karla)'),
   (318385, 'Was hard-coded in RLREBKUPD (per Karla)');

--------------------------------------------------------------
-- 3. Willis digital items, until digital rates are applied
--    automatically from the contract (RLPDGTRAT).
--    eBooks found by Willis_digital_1Oct_check.sql query 1;
--    add the Willis downloads once query 1 has been re-run.
--    Royalties correct the rates only AFTER this insert.
--------------------------------------------------------------
INSERT INTO OBJECT.RLPDGTEXC (ITMNUM, COMT40) VALUES
   (1827066, 'WILLIS - until digital rates live'),
   (1827067, 'WILLIS - until digital rates live'),
   (1869588, 'WILLIS - until digital rates live'),
   (1869589, 'WILLIS - until digital rates live'),
   (1938568, 'WILLIS - until digital rates live'),
   (1938569, 'WILLIS - until digital rates live'),
   (2247867, 'WILLIS - until digital rates live'),
   (2247868, 'WILLIS - until digital rates live'),
   (2247869, 'WILLIS - until digital rates live'),
   (2375717, 'WILLIS - until digital rates live'),
   (2376162, 'WILLIS - until digital rates live'),
   (2377552, 'WILLIS - until digital rates live'),
   (2377788, 'WILLIS - until digital rates live');

--------------------------------------------------------------
-- 4. Check what is exempt
--------------------------------------------------------------
SELECT E.ITMNUM, I.SDESC, E.COMT40, E.USERID, E.DTEADDED
  FROM OBJECT.RLPDGTEXC E
  LEFT JOIN OBJECT.IVPITEMS I
    ON I.ITMNUM = E.ITMNUM
 ORDER BY E.DTEADDED, E.ITMNUM;
