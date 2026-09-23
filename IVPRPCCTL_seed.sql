-- ====================================================================
-- IVPRPCCTL seed - default control row
-- ====================================================================
-- DIVCAT 0 is the default row. IVRRPCGEN reads it for the settings it
-- needs before a catalogue is known, and falls back to it for any
-- catalogue without a row of its own.
--
-- It is seeded with RPCPHASE '0' on purpose: nothing is suggested and
-- nothing is repriced until a catalogue is opted in with a row of its
-- own. That is the phased rollout - a catalogue joins by being given a
-- row, not by the programs being changed.
--
-- Two seeded values are placeholders that must be confirmed before any
-- catalogue moves to phase 1 or 2:
--
--   RPCSTSLST  Left blank, which means "do not filter on re-run
--              status". The eligible IVPORRITM.RERUNSTS codes are still
--              not established. Put the real codes here, space
--              delimited, e.g. ' A I Q '. Until then the candidate set
--              is wider than the internal approval queue the Redash
--              report filters to.
--
--   RPCSTSEXC  Statuses to exclude, seeded ' J '. This is established:
--              IVRMAINT sets RERUNSTS to 'J' with a blank Hold to take
--              an item off the online re-run queue ("remove from Online
--              Rerun", history action 'canceled'), and P1VBTCHUP writes
--              'J' for a job it created outside the queue. So 'J' means
--              not in the queue and must stay out even while the
--              inclusion list above is blank.
--
--   RPCFLDLST  The IVPMAINT.FLDNAM values a price change is logged
--              under. Three spellings are in use for the one event, and
--              all three are seeded:
--
--                IVRMAINT   'PRICE '   list price change (Sbr_PriceChg)
--                IVRMAINT2  'PRICE72'  the interactive price screen
--                IVRPRCUPD  'PRICE72' and 'PRICE112'  price upload
--
--              'PRICE' is the one that matters most. IVRMAINT is the
--              main item maintenance program, and leaving its spelling
--              out would make every price change made through it
--              invisible - those titles would read as never repriced,
--              land in the oldest bracket and take the largest uplift.
--
--              MAPPRICE and REFPRICE are deliberately absent: they are
--              the reference price on IVPREFPRC, not the list price.
--              Add them only if a MAP change should reset this clock.
--
-- RPCNOCHDT is the date used when an item has no price-change audit row
-- at all. It must fall inside the oldest rule window so a title that
-- has never been repriced is treated as the most eroded, not skipped.
-- Note the retention risk: if IVPMAINT is purged, a title repriced long
-- ago is indistinguishable from one never repriced, and both land on
-- the oldest bracket. Confirm IVPMAINT retention before phase 2.
-- ====================================================================

INSERT INTO OBJECT/IVPRPCCTL
        (DIVCAT, RPCCATG, RPCPHASE, RPCMODEL, RPCSCEN,
         RPCELGMO, RPCHORIZ, RPCEXPCY,
         RPCCNOYN, RPCCNOCOD, RPCAUTCOD, RPCAUTACT,
         RPCSTSLST, RPCSTSEXC, RPCFLDLST, RPCNOCHDT, RPCP112YN,
         RPCMNTTS, RPCMNTWHO)
VALUES
  (0, '     ', '0', 'B', 'S',
   18, 6, 3,
   'Y', 'CNO', '   ', 'H',
   ' ', ' J ', ' PRICE PRICE72 PRICE112 ', DATE('1900-01-01'), 'Y',
   CURRENT TIMESTAMP, 'SEED');

-- ------------------------------------------------------------------
-- Example of opting one catalogue in to phase 1. DIVCAT is a
-- placeholder: the AS400 catalogue -> catalogue group mapping still
-- has to come from Content, so no real DIVCAT is seeded here.
-- ------------------------------------------------------------------
-- INSERT INTO OBJECT/IVPRPCCTL
--         (DIVCAT, RPCCATG, RPCPHASE, RPCMODEL, RPCSCEN,
--          RPCELGMO, RPCHORIZ, RPCEXPCY,
--          RPCCNOYN, RPCCNOCOD, RPCAUTCOD, RPCAUTACT,
--          RPCSTSLST, RPCSTSEXC, RPCFLDLST, RPCNOCHDT, RPCP112YN,
--          RPCMNTTS, RPCMNTWHO)
-- VALUES
--   (9999999, 'CHO', '1', 'B', 'S',
--    18, 6, 3,
--    'Y', 'CNO', '   ', 'H',
--    ' ', ' J ', ' PRICE PRICE72 PRICE112 ', DATE('1900-01-01'), 'Y',
--    CURRENT TIMESTAMP, 'SEED');
