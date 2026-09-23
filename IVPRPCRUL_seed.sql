-- ====================================================================
-- IVPRPCRUL seed - the published re-run repricing logic as data
-- ====================================================================
-- Sources, transcribed cell for cell:
--
--   RULMODEL 'B'  [2026-07-03] Content. Manual Price Change Brackets
--                 Flat dollar uplift by catalogue x current-price band
--                 x last-price-change window. This is what editors
--                 apply by hand today, so phase 1 suggestions can be
--                 checked against current practice.
--
--   RULMODEL 'P'  [2026-06-22] Content. Evaluating Bulk Reissue Price
--                 Adjustments. Percentage uplift with minimum rises,
--                 increase caps, budget floors, snap to nearest .99 and
--                 the Choral octavo ladder. RULSCEN 'S' is its
--                 Suggested column, 'A' its Aggressive column. The two
--                 rates in each published cell become two rows split on
--                 01/01/2022: the first (stale) rate for items last
--                 repriced before then, the second for items after.
--
-- Deliberate gaps, not omissions:
--
--   * Model 'B' has no EDU rows. The brackets document tables Pop,
--     Classical/Self-Teach, Instrumental and Choral only. If Education
--     and Self-Teach are the same catalogue group here, map those
--     DIVCATs to SFT in IVPRPCCTL; if they are distinct, the brackets
--     for Education still need to be published.
--
--   * Model 'P' has no SFT rows. The evaluating document tables Pop,
--     Classical, Education, Instrumental and Choral. Same question,
--     from the other side.
--
--   An item whose catalogue group has no matching rule gets no
--   suggestion, which is the safe failure: nothing is repriced on a
--   guess.
--
-- Caps, floors and rounding interact in the order documented in
-- IVPRPCRUL.dds: the budget floor is re-asserted last, because the
-- source states "budget floor overrides the hard cap".
-- ====================================================================

-- Manual Price Change Brackets - Pop (flat dollar uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('POP', 'B', 'S', 11,
   0.01, 9.99, DATE('0001-01-01'), DATE('2014-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 pre-2015 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 12,
   0.01, 9.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 13,
   0.01, 9.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 21,
   10.00, 19.99, DATE('0001-01-01'), DATE('2014-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 pre-2015 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 22,
   10.00, 19.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 23,
   10.00, 19.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 31,
   20.00, 29.99, DATE('0001-01-01'), DATE('2014-12-31'),
   6.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 pre-2015 +$6', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 32,
   20.00, 29.99, DATE('2015-01-01'), DATE('2021-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2015-2021 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 33,
   20.00, 29.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 41,
   30.00, 49.99, DATE('0001-01-01'), DATE('2014-12-31'),
   9.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 pre-2015 +$9', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 42,
   30.00, 49.99, DATE('2015-01-01'), DATE('2021-12-31'),
   6.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2015-2021 +$6', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 43,
   30.00, 49.99, DATE('2022-01-01'), DATE('2025-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2022-2025 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 51,
   50.00, 9999999.99, DATE('0001-01-01'), DATE('2014-12-31'),
   13.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ pre-2015 +$13', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 52,
   50.00, 9999999.99, DATE('2015-01-01'), DATE('2021-12-31'),
   9.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2015-2021 +$9', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'B', 'S', 53,
   50.00, 9999999.99, DATE('2022-01-01'), DATE('2025-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2022-2025 +$7', CURRENT TIMESTAMP, 'SEED');

-- Manual Price Change Brackets - Classical (flat dollar uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CLA', 'B', 'S', 11,
   0.01, 9.99, DATE('0001-01-01'), DATE('2014-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 pre-2015 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 12,
   0.01, 9.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 13,
   0.01, 9.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 21,
   10.00, 19.99, DATE('0001-01-01'), DATE('2014-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 pre-2015 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 22,
   10.00, 19.99, DATE('2015-01-01'), DATE('2021-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2015-2021 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 23,
   10.00, 19.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 31,
   20.00, 29.99, DATE('0001-01-01'), DATE('2014-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 pre-2015 +$7', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 32,
   20.00, 29.99, DATE('2015-01-01'), DATE('2021-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2015-2021 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 33,
   20.00, 29.99, DATE('2022-01-01'), DATE('2025-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2022-2025 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 41,
   30.00, 49.99, DATE('0001-01-01'), DATE('2014-12-31'),
   10.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 pre-2015 +$10', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 42,
   30.00, 49.99, DATE('2015-01-01'), DATE('2021-12-31'),
   8.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2015-2021 +$8', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 43,
   30.00, 49.99, DATE('2022-01-01'), DATE('2025-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2022-2025 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 51,
   50.00, 9999999.99, DATE('0001-01-01'), DATE('2014-12-31'),
   14.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ pre-2015 +$14', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 52,
   50.00, 9999999.99, DATE('2015-01-01'), DATE('2021-12-31'),
   11.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2015-2021 +$11', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'B', 'S', 53,
   50.00, 9999999.99, DATE('2022-01-01'), DATE('2025-12-31'),
   8.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2022-2025 +$8', CURRENT TIMESTAMP, 'SEED');

-- Manual Price Change Brackets - Self-Teach (flat dollar uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('SFT', 'B', 'S', 11,
   0.01, 9.99, DATE('0001-01-01'), DATE('2014-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 pre-2015 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 12,
   0.01, 9.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 13,
   0.01, 9.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 21,
   10.00, 19.99, DATE('0001-01-01'), DATE('2014-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 pre-2015 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 22,
   10.00, 19.99, DATE('2015-01-01'), DATE('2021-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2015-2021 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 23,
   10.00, 19.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 31,
   20.00, 29.99, DATE('0001-01-01'), DATE('2014-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 pre-2015 +$7', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 32,
   20.00, 29.99, DATE('2015-01-01'), DATE('2021-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2015-2021 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 33,
   20.00, 29.99, DATE('2022-01-01'), DATE('2025-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2022-2025 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 41,
   30.00, 49.99, DATE('0001-01-01'), DATE('2014-12-31'),
   10.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 pre-2015 +$10', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 42,
   30.00, 49.99, DATE('2015-01-01'), DATE('2021-12-31'),
   8.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2015-2021 +$8', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 43,
   30.00, 49.99, DATE('2022-01-01'), DATE('2025-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2022-2025 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 51,
   50.00, 9999999.99, DATE('0001-01-01'), DATE('2014-12-31'),
   14.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ pre-2015 +$14', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 52,
   50.00, 9999999.99, DATE('2015-01-01'), DATE('2021-12-31'),
   11.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2015-2021 +$11', CURRENT TIMESTAMP, 'SEED'),
  ('SFT', 'B', 'S', 53,
   50.00, 9999999.99, DATE('2022-01-01'), DATE('2025-12-31'),
   8.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2022-2025 +$8', CURRENT TIMESTAMP, 'SEED');

-- Manual Price Change Brackets - Instrumental (flat dollar uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('INS', 'B', 'S', 11,
   0.01, 9.99, DATE('0001-01-01'), DATE('2014-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 pre-2015 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 12,
   0.01, 9.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 13,
   0.01, 9.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 21,
   10.00, 19.99, DATE('0001-01-01'), DATE('2014-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 pre-2015 +$7', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 22,
   10.00, 19.99, DATE('2015-01-01'), DATE('2021-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2015-2021 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 23,
   10.00, 19.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 31,
   20.00, 29.99, DATE('0001-01-01'), DATE('2014-12-31'),
   11.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 pre-2015 +$11', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 32,
   20.00, 29.99, DATE('2015-01-01'), DATE('2021-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2015-2021 +$7', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 33,
   20.00, 29.99, DATE('2022-01-01'), DATE('2025-12-31'),
   4.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2022-2025 +$4', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 41,
   30.00, 49.99, DATE('0001-01-01'), DATE('2014-12-31'),
   16.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 pre-2015 +$16', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 42,
   30.00, 49.99, DATE('2015-01-01'), DATE('2021-12-31'),
   11.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2015-2021 +$11', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 43,
   30.00, 49.99, DATE('2022-01-01'), DATE('2025-12-31'),
   6.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2022-2025 +$6', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 51,
   50.00, 9999999.99, DATE('0001-01-01'), DATE('2014-12-31'),
   22.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ pre-2015 +$22', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 52,
   50.00, 9999999.99, DATE('2015-01-01'), DATE('2021-12-31'),
   16.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2015-2021 +$16', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'B', 'S', 53,
   50.00, 9999999.99, DATE('2022-01-01'), DATE('2025-12-31'),
   10.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2022-2025 +$10', CURRENT TIMESTAMP, 'SEED');

-- Manual Price Change Brackets - Choral (flat dollar uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CHO', 'B', 'S', 11,
   0.01, 9.99, DATE('0001-01-01'), DATE('2014-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 pre-2015 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 12,
   0.01, 9.99, DATE('2015-01-01'), DATE('2021-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2015-2021 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 13,
   0.01, 9.99, DATE('2022-01-01'), DATE('2025-12-31'),
   1.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   'under $10 2022-2025 +$1', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 21,
   10.00, 19.99, DATE('0001-01-01'), DATE('2014-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 pre-2015 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 22,
   10.00, 19.99, DATE('2015-01-01'), DATE('2021-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2015-2021 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 23,
   10.00, 19.99, DATE('2022-01-01'), DATE('2025-12-31'),
   2.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$10-19.99 2022-2025 +$2', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 31,
   20.00, 29.99, DATE('0001-01-01'), DATE('2014-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 pre-2015 +$7', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 32,
   20.00, 29.99, DATE('2015-01-01'), DATE('2021-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2015-2021 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 33,
   20.00, 29.99, DATE('2022-01-01'), DATE('2025-12-31'),
   3.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$20-29.99 2022-2025 +$3', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 41,
   30.00, 49.99, DATE('0001-01-01'), DATE('2014-12-31'),
   11.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 pre-2015 +$11', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 42,
   30.00, 49.99, DATE('2015-01-01'), DATE('2021-12-31'),
   8.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2015-2021 +$8', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 43,
   30.00, 49.99, DATE('2022-01-01'), DATE('2025-12-31'),
   5.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$30-49.99 2022-2025 +$5', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 51,
   50.00, 9999999.99, DATE('0001-01-01'), DATE('2014-12-31'),
   17.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ pre-2015 +$17', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 52,
   50.00, 9999999.99, DATE('2015-01-01'), DATE('2021-12-31'),
   12.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2015-2021 +$12', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'B', 'S', 53,
   50.00, 9999999.99, DATE('2022-01-01'), DATE('2025-12-31'),
   7.00, 0, 0, 0, 0, 0, 0, 'NONE', '',
   '$50+ 2022-2025 +$7', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Pop Suggested (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('POP', 'P', 'S', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 10.00, 1.50, 18.00, 0, 5.99, 0, '99', 'KILLCAND',
   'under $20 pre-2022 +10%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'S', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 7.00, 1.00, 18.00, 0, 5.99, 0, '99', 'KILLCAND',
   'under $20 2022 on +7%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'S', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 0, 5.99, 0, '99', 'KILLCAND',
   '$20-40 pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'S', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 0, 5.99, 0, '99', 'KILLCAND',
   '$20-40 2022 on +9%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'S', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 10.00, 5.99, 0, '99', 'KILLCAND',
   '$40+ pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'S', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 8.00, 5.99, 0, '99', 'KILLCAND',
   '$40+ 2022 on +9%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Pop Aggressive (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('POP', 'P', 'A', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 2.00, 25.00, 0, 6.99, 0, '99', 'KILLCAND',
   'under $20 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'A', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 13.00, 2.00, 25.00, 0, 6.99, 0, '99', 'KILLCAND',
   'under $20 2022 on +13%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'A', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 25.00, 0, 6.99, 0, '99', 'KILLCAND',
   '$20-40 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'A', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 25.00, 0, 6.99, 0, '99', 'KILLCAND',
   '$20-40 2022 on +14%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'A', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 15.00, 0, 25.00, 0, 6.99, 0, '99', 'KILLCAND',
   '$40+ pre-2022 +15%', CURRENT TIMESTAMP, 'SEED'),
  ('POP', 'P', 'A', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 12.00, 0, 25.00, 0, 6.99, 0, '99', 'KILLCAND',
   '$40+ 2022 on +12%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Classical Suggested (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CLA', 'P', 'S', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 1.50, 20.00, 0, 3.99, 0, '99', 'WATCH',
   'under $20 pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'S', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 1.00, 20.00, 0, 3.99, 0, '99', 'WATCH',
   'under $20 2022 on +9%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'S', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 15.00, 0, 20.00, 0, 3.99, 0, '99', 'WATCH',
   '$20-40 pre-2022 +15%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'S', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 11.00, 0, 20.00, 0, 3.99, 0, '99', 'WATCH',
   '$20-40 2022 on +11%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'S', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 20.00, 0, 3.99, 0, '99', 'WATCH',
   '$40+ pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'S', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 20.00, 0, 3.99, 0, '99', 'WATCH',
   '$40+ 2022 on +9%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Classical Aggressive (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CLA', 'P', 'A', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 2.00, 28.00, 0, 4.99, 0, '99', 'WATCH',
   'under $20 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'A', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 1.50, 28.00, 0, 4.99, 0, '99', 'WATCH',
   'under $20 2022 on +14%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'A', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 22.00, 0, 28.00, 0, 4.99, 0, '99', 'WATCH',
   '$20-40 pre-2022 +22%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'A', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 17.00, 0, 28.00, 0, 4.99, 0, '99', 'WATCH',
   '$20-40 2022 on +17%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'A', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 28.00, 0, 4.99, 0, '99', 'WATCH',
   '$40+ pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('CLA', 'P', 'A', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 28.00, 0, 4.99, 0, '99', 'WATCH',
   '$40+ 2022 on +14%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Education Suggested (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('EDU', 'P', 'S', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 10.00, 1.50, 18.00, 0, 4.99, 0, '99', 'CULLREV',
   'under $20 pre-2022 +10%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'S', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 7.00, 1.00, 18.00, 0, 4.99, 0, '99', 'CULLREV',
   'under $20 2022 on +7%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'S', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 0, 4.99, 0, '99', 'CULLREV',
   '$20-40 pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'S', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 0, 4.99, 0, '99', 'CULLREV',
   '$20-40 2022 on +9%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'S', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 0, 4.99, 0, '99', 'CULLREV',
   '$40+ pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'S', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 0, 4.99, 0, '99', 'CULLREV',
   '$40+ 2022 on +9%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Education Aggressive (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('EDU', 'P', 'A', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 2.00, 25.00, 0, 5.99, 0, '99', 'CULLREV',
   'under $20 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'A', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 13.00, 2.00, 25.00, 0, 5.99, 0, '99', 'CULLREV',
   'under $20 2022 on +13%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'A', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 25.00, 0, 5.99, 0, '99', 'CULLREV',
   '$20-40 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'A', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 25.00, 0, 5.99, 0, '99', 'CULLREV',
   '$20-40 2022 on +14%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'A', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 15.00, 0, 25.00, 0, 5.99, 0, '99', 'CULLREV',
   '$40+ pre-2022 +15%', CURRENT TIMESTAMP, 'SEED'),
  ('EDU', 'P', 'A', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 12.00, 0, 25.00, 0, 5.99, 0, '99', 'CULLREV',
   '$40+ 2022 on +12%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Instrumental Suggested (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('INS', 'P', 'S', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 20.00, 0, 0, 5.00, '99', 'REVIEW',
   'under $20 pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'S', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 20.00, 0, 0, 5.00, '99', 'REVIEW',
   'under $20 2022 on +9%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'S', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 15.00, 0, 20.00, 0, 0, 5.00, '99', 'REVIEW',
   '$20-40 pre-2022 +15%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'S', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 11.00, 0, 20.00, 0, 0, 5.00, '99', 'REVIEW',
   '$20-40 2022 on +11%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'S', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 14.00, 0, 20.00, 0, 0, 5.00, '99', 'REVIEW',
   '$40+ pre-2022 +14%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'S', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 10.00, 0, 20.00, 0, 0, 5.00, '99', 'REVIEW',
   '$40+ 2022 on +10%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Instrumental Aggressive (percentage uplift)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('INS', 'P', 'A', 11,
   0.01, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 30.00, 0, 0, 5.00, '99', 'REVIEW',
   'under $20 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'A', 12,
   0.01, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 30.00, 0, 0, 5.00, '99', 'REVIEW',
   'under $20 2022 on +14%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'A', 21,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 22.00, 0, 30.00, 0, 0, 5.00, '99', 'REVIEW',
   '$20-40 pre-2022 +22%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'A', 22,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 17.00, 0, 30.00, 0, 0, 5.00, '99', 'REVIEW',
   '$20-40 2022 on +17%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'A', 31,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 20.00, 0, 30.00, 0, 0, 5.00, '99', 'REVIEW',
   '$40+ pre-2022 +20%', CURRENT TIMESTAMP, 'SEED'),
  ('INS', 'P', 'A', 32,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 15.00, 0, 30.00, 0, 0, 5.00, '99', 'REVIEW',
   '$40+ 2022 on +15%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Choral Suggested (ladder under $5, pct above)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CHO', 'P', 'S', 5,
   0.01, 4.99, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 6.00, 0, 15.00, 0, 0, 0, 'LADR', 'REVIEW',
   'octavo ladder step >=+6%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'S', 21,
   5.00, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 0, 0, 0, '99', 'REVIEW',
   '$5-20 pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'S', 22,
   5.00, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 0, 0, 0, '99', 'REVIEW',
   '$5-20 2022 on +9%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'S', 31,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 0, 0, 0, '99', 'REVIEW',
   '$20-40 pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'S', 32,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 0, 0, 0, '99', 'REVIEW',
   '$20-40 2022 on +9%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'S', 41,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 12.00, 0, 18.00, 0, 0, 0, '99', 'REVIEW',
   '$40+ pre-2022 +12%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'S', 42,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 9.00, 0, 18.00, 0, 0, 0, '99', 'REVIEW',
   '$40+ 2022 on +9%', CURRENT TIMESTAMP, 'SEED');

-- Evaluating Bulk Reissue - Choral Aggressive (ladder under $5, pct above)
INSERT INTO OBJECT/IVPRPCRUL
        (RULCATG, RULMODEL, RULSCEN, RULSEQ, RULPRCFR, RULPRCTO,
         RULCHGFR, RULCHGTO, RULUPLAMT, RULUPLPCT, RULMINAMT,
         RULCAPPCT, RULCAPAMT, RULFLOOR, RULEXCLMN, RULROUND,
         RULDISP, RULTEXT, RULMNTTS, RULMNTWHO)
VALUES
  ('CHO', 'P', 'A', 5,
   0.01, 4.99, DATE('0001-01-01'), DATE('9999-12-31'),
   0, 15.00, 0, 30.00, 0, 0, 0, 'LADR', 'REVIEW',
   'octavo ladder step >=+15%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'A', 21,
   5.00, 19.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 28.00, 0, 0, 0, '99', 'REVIEW',
   '$5-20 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'A', 22,
   5.00, 19.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 28.00, 0, 0, 0, '99', 'REVIEW',
   '$5-20 2022 on +14%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'A', 31,
   20.00, 39.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 28.00, 0, 0, 0, '99', 'REVIEW',
   '$20-40 pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'A', 32,
   20.00, 39.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 28.00, 0, 0, 0, '99', 'REVIEW',
   '$20-40 2022 on +14%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'A', 41,
   40.00, 9999999.99, DATE('0001-01-01'), DATE('2021-12-31'),
   0, 18.00, 0, 28.00, 0, 0, 0, '99', 'REVIEW',
   '$40+ pre-2022 +18%', CURRENT TIMESTAMP, 'SEED'),
  ('CHO', 'P', 'A', 42,
   40.00, 9999999.99, DATE('2022-01-01'), DATE('9999-12-31'),
   0, 14.00, 0, 28.00, 0, 0, 0, '99', 'REVIEW',
   '$40+ 2022 on +14%', CURRENT TIMESTAMP, 'SEED');

-- ====================================================================
-- OPTIONAL GUARDRAIL - Choral octavos under the bracket model
-- ====================================================================
-- Left commented out on purpose: the rows above are a faithful
-- transcription of the published brackets, and this is not in them.
--
-- The brackets table has one band for everything under $10 and applies
-- a flat +$3 to it in the oldest window. On a per-copy choral octavo
-- that is not a small rise:
--
--     Noel                       $2.50  ->  $5.50   (+120%)
--     Cheap Thrills              $2.99  ->  $5.99   (+100%)
--     The Night Will Never Stay  $3.50  ->  $6.50   (+86%)
--
-- The other document handles exactly these titles with the ladder
-- instead, moving them to $2.65 / $3.25 / $3.75, and warns why per-copy
-- pricing needs the lighter touch: "a $2.99 octavo rising to $3.25 is
-- trivial per copy, but across a 50-copy choir order it's roughly +$13
-- on the invoice."
--
-- So if Choral is ever set to RULMODEL 'B', it needs either these
-- capped rows or a decision that octavos always price off the ladder.
-- Until one of those happens, keep Choral on RULMODEL 'P', where the
-- ladder rows already cover everything under $5.
--
-- UPDATE OBJECT/IVPRPCRUL
--    SET RULCAPPCT = 15.00, RULMNTTS = CURRENT TIMESTAMP,
--        RULMNTWHO = 'GUARD'
--  WHERE RULCATG = 'CHO' AND RULMODEL = 'B' AND RULPRCTO <= 9.99;
-- ====================================================================
