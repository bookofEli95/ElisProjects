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
--   RPCSTSLST  ' *BLANK A K B I P ' - every IVPORRITM.RERUNSTS value
--              that existing programs treat as a live re-run:
--                *BLANK     hit minimum qty, not yet actioned - the
--                           population of the Min Qty Online report
--                           (IVRORRIVP2 selects RERUNSTS = ' ')
--                A K B I P  approved / active - the population of the
--                           Items with New Price report (IVRORRNEWP)
--              Blank is written *BLANK because a blank cannot be a
--              token in a space-delimited list.
--
--              Individual meanings of A, K, B, I and P are not stated
--              anywhere read so far - only that IVRORRNEWP treats them
--              as one approved set. P has a wrinkle: IVRORRNEWP only
--              counts it when ORR_DEPT = 'BO', a routing rule for which
--              report it prints on. It is included here unconditionally;
--              drop it from this list if P means the job is already too
--              far along for a price change.
--
--   RPCSTSEXC  ' J N ' - statuses that mean the title is not going to
--              be reprinted:
--                J  taken off the queue. IVRMAINT sets it with a blank
--                   Hold ("remove from Online Rerun", action 'canceled')
--                   and P1VBTCHUP writes it for a job made outside it.
--                N  not to be rerun. IVRORRNBR reports exactly these.
--              Redundant with the inclusion list above while that is
--              set, but it keeps the two out if the list is ever
--              cleared.
--
--   RPCCNOYN   'N' and RPCCNOCOD blank - the CNO is switched OFF.
--              The mechanism written so far adds an item code to
--              IVPITMCODE, and IVRORRNEWP shows that is not what a CNO
--              is: a correction note is a record on NOTEPADI (up to four
--              per item, keyed on item and RCDNBR, text in NOTE1 and
--              NOTE2), and a price CNO is recognised by its text holding
--              the word PRICE and the new price. Writing IVPITMCODE rows
--              would pollute a real file for nothing, so it stays off
--              until it is pointed at NOTEPADI - which needs that file's
--              field list, because the name of its item field and its
--              record format have not been visible in any program yet.
--
--   RPCAPLTGT  'Q' - an approved price is staged on the re-run queue
--              as IVPORRITM.NEWPRICE, not written to the item.
--              IVRORRNEWP treats NEWPRICE as a price change waiting for
--              the new printing: it compares it to PRICE72 and reports
--              it to production unless a CNO already carries it. While
--              the price is still printed on the book, raising PRICE72
--              before the new printing exists would put the system price
--              out of step with the cover on every copy in stock. 'I'
--              writes IVPITEMS directly and is there for a phase in
--              which that no longer matters.
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
         RPCAPLTGT, RPCMNTTS, RPCMNTWHO)
VALUES
  (0, '     ', '0', 'B', 'S',
   18, 6, 3,
   'N', '   ', '   ', 'H',
   ' *BLANK A K B I P ', ' J N ', ' PRICE PRICE72 PRICE112 ',
   DATE('1900-01-01'), 'Y',
   'Q', CURRENT TIMESTAMP, 'SEED');

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
--          RPCAPLTGT, RPCMNTTS, RPCMNTWHO)
-- VALUES
--   (9999999, 'CHO', '1', 'P', 'S',
--    18, 6, 3,
--    'N', '   ', '   ', 'H',
--    ' *BLANK A K B I P ', ' J N ', ' PRICE PRICE72 PRICE112 ',
--    DATE('1900-01-01'), 'Y',
--    'Q', CURRENT TIMESTAMP, 'SEED');
