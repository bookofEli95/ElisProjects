-- ====================================================================
-- IVPRPCRUL brackets update - the completed Manual Price Change Brackets
-- ====================================================================
-- Source: [2026-07-03] Content. Manual Price Change Brackets, the
-- completed version (Education and the new Choral table added).
--
-- Run after IVPRPCRUL_seed.sql. Against that seed:
--
--   Pop, Classical, Self-Teach  unchanged - the seed already matches
--                               the completed document cell for cell.
--   Instrumental                unchanged - priced from the full product
--                               list (IVPRPCRUL_band_seed.sql).
--   Education                   new: the six-band grid below.
--   Choral                      new table. Under $12.99 a title moves to
--                               the set price for its current-price band;
--                               from $12.99 up the flat uplifts stand.
--
-- A set price is a rule with no uplift and the set price as its budget
-- floor: IVRRPCGEN raises the price to the floor, and a title already
-- at the set price has no rise and gets no suggestion. These rows have
-- no last-change window - the table does not split by age - but the
-- catalogue's eligibility months (RPCELGMO) still apply.
--
-- A current price no rule covers gets no suggestion: $6.51-$6.94 and
-- $11.96-$12.98 in Choral are not in the document.
--
-- Not done here, pending Content - see REPRICING.md, Completed brackets:
--   Choral CDs to $29.99, the $11.99 collections cap, digital tiers,
--   and every Education exclusion and EE rule (Faber, Digital Agency,
--   2025 EE held, legacy EE prices, EE caps, the code-price rise).
--
-- Writes to the test library, H33979. To load production later,
-- change H33979. to OBJECT. throughout.
--
--   RUNSQLSTM SRCSTMF('.../IVPRPCRUL_brackets_update.sql') COMMIT(*NONE)
--             NAMING(*SQL)
--
-- The inserts are keyed UNIQUE: a second run fails on duplicate keys
-- (SQL0803) and adds nothing.
-- ====================================================================

-- Education (flat dollar uplift)
INSERT INTO H33979.IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('EDU', 'B', 'S', 11,
   0.01, 4.99, DATE('0001-01-01'), DATE('2014-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $5 pre-2015 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 12,
   0.01, 4.99, DATE('2015-01-01'), DATE('2021-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $5 2015-2021 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 13,
   0.01, 4.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $5 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 16,
   5.00, 9.99, DATE('0001-01-01'), DATE('2014-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$5-9.99 pre-2015 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 17,
   5.00, 9.99, DATE('2015-01-01'), DATE('2021-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$5-9.99 2015-2021 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 18,
   5.00, 9.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$5-9.99 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 21,
   10.00, 19.99, DATE('0001-01-01'), DATE('2014-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 pre-2015 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 22,
   10.00, 19.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 23,
   10.00, 19.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 31,
   20.00, 29.99, DATE('0001-01-01'), DATE('2014-12-31'),
   6.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 pre-2015 +$6', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 32,
   20.00, 29.99, DATE('2015-01-01'), DATE('2021-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2015-2021 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 33,
   20.00, 29.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 41,
   30.00, 49.99, DATE('0001-01-01'), DATE('2014-12-31'),
   9.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 pre-2015 +$9', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 42,
   30.00, 49.99, DATE('2015-01-01'), DATE('2021-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2015-2021 +$7', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 43,
   30.00, 49.99, DATE('2022-01-01'), DATE('2025-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2022-2025 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 51,
   50.00, 9999999.99, DATE('0001-01-01'), DATE('2014-12-31'),
   13.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ pre-2015 +$13', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 52,
   50.00, 9999999.99, DATE('2015-01-01'), DATE('2021-12-31'),
   10.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2015-2021 +$10', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'B', 'S', 53,
   50.00, 9999999.99, DATE('2022-01-01'), DATE('2025-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2022-2025 +$7', CURRENT TIMESTAMP, 'SEED');

-- Choral: the old under-$10 rows go - the set prices replace them
DELETE FROM H33979.IVPRPCRUL
 WHERE RULCATG = 'CHO' AND RULMODEL = 'B' AND RULSCEN = 'S'
   AND RULSEQ IN (11, 12, 13);

-- Choral: the first uplift band now starts at $12.99
UPDATE H33979.IVPRPCRUL
   SET RULPRCFR  = 12.99,
       RULTEXT   = CASE RULSEQ
                     WHEN 21 THEN '$12.99-19.99 pre-2015 +$5'
                     WHEN 22 THEN '$12.99-19.99 2015-2021 +$3'
                     ELSE         '$12.99-19.99 2022-2025 +$2'
                   END,
       RULMNTTS  = CURRENT TIMESTAMP,
       RULMNTWHO = 'BRACKETS'
 WHERE RULCATG = 'CHO' AND RULMODEL = 'B' AND RULSCEN = 'S'
   AND RULSEQ IN (21, 22, 23);

-- Choral: set price by current-price band (octavos, then collections,
-- cantatas and resources)
INSERT INTO H33979.IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CHO', 'B', 'S', 101,
   0.01, 2.75, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 2.75, 0, 'NONE', '',
   '$.01-2.75 set $2.75', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 102,
   2.76, 2.95, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 2.95, 0, 'NONE', '',
   '$2.76-2.95 set $2.95', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 103,
   2.96, 3.25, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 3.25, 0, 'NONE', '',
   '$2.96-3.25 set $3.25', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 104,
   3.26, 3.50, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 3.50, 0, 'NONE', '',
   '$3.26-3.50 set $3.50', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 105,
   3.51, 3.65, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 3.65, 0, 'NONE', '',
   '$3.51-3.65 set $3.65', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 106,
   3.66, 3.75, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 3.75, 0, 'NONE', '',
   '$3.66-3.75 set $3.75', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 107,
   3.76, 3.95, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 3.95, 0, 'NONE', '',
   '$3.76-3.95 set $3.95', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 108,
   3.96, 4.50, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 4.50, 0, 'NONE', '',
   '$3.96-4.50 set $4.50', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 109,
   4.51, 4.75, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 4.75, 0, 'NONE', '',
   '$4.51-4.75 set $4.75', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 110,
   4.76, 5.50, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 5.50, 0, 'NONE', '',
   '$4.76-5.50 set $5.50', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 111,
   5.51, 6.50, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 6.50, 0, 'NONE', '',
   '$5.51-6.50 set $6.50', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 121,
   6.95, 9.95, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 10.95, 0, 'NONE', '',
   '$6.95-9.95 set $10.95', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 122,
   9.96, 11.95, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 0, 0, 0, 0, 11.95, 0, 'NONE', '',
   '$9.96-11.95 set $11.95', CURRENT TIMESTAMP, 'SEED');

-- Choral catalogues price from these brackets from now on (they were on
-- the percentage model, RPCMODEL 'P', for its octavo ladder).
UPDATE H33979.IVPRPCCTL
   SET RPCMODEL  = 'B',
       RPCMNTTS  = CURRENT TIMESTAMP,
       RPCMNTWHO = 'BRACKETS'
 WHERE RPCCATG = 'CHO';
