-- ====================================================================
-- IVPRPCLAD seed - Choral octavo price ladder
-- ====================================================================
-- The rungs published in [2026-06-22] Content. Evaluating Bulk Reissue
-- Price Adjustments:
--
--   "Choral ladder rungs: 2.10 / 2.25 / 2.35 / 2.50 / 2.65 / 2.75 /
--    2.99 / 3.25 / 3.50 / 3.75 / 3.99 / 4.25 / 4.50 / 4.75 / 4.99 /
--    5.50 / 5.99."
--
-- A rule carrying RULROUND 'LADR' lands on the first rung at or above
-- the rule percentage, so an octavo moves one or more rungs rather than
-- to an arbitrary .99 price. LADSEQ must ascend with LADPRICE.
-- ====================================================================

INSERT INTO OBJECT/IVPRPCLAD
        (LADCATG, LADSEQ, LADPRICE, LADMNTTS, LADMNTWHO)
VALUES
  ('CHO',  10, 2.10, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  20, 2.25, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  30, 2.35, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  40, 2.50, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  50, 2.65, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  60, 2.75, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  70, 2.99, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  80, 3.25, CURRENT TIMESTAMP, 'SEED'),
  ('CHO',  90, 3.50, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 100, 3.75, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 110, 3.99, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 120, 4.25, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 130, 4.50, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 140, 4.75, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 150, 4.99, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 160, 5.50, CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 170, 5.99, CURRENT TIMESTAMP, 'SEED');
