-- OEPEDTSWP_QUALIFY
-- Rolando's qualification test (from the ticket), run against every
-- channel currently active in OEPEDTSWP. A channel only qualifies for
-- blanket auto-release if ALL FOUR come back clean:
--   1. IN_OEPEDTCRD   = 'N'  -- not routed to credit approval at all
--   2. HOLD_ORDER_CNT = 0    -- nothing in this channel is ever held
--   3. (see caution below)   -- no order is ever left deliberately unreleased
--   4. IN_PLPEBDESC   = 'N'  -- not a Pick/Put to Light channel
--
-- WINDOW_DAYS controls how far back checks 2/3 look (OEPTRACK.KEYEDDT).
-- Default 90 -- widen it if a channel doesn't ship often enough for 90
-- days to be "meaningful".
--
-- CAUTION - read before trusting the numbers:
--   a) The join to OEPTRACK goes through OEPBCHK (KEYB#/EDTB#), which is
--      the transient batch header -- rows disappear once a batch finishes
--      processing (EDTB# is reused every 3-5 days per the ticket). That
--      means this can only see orders from batches CURRENTLY still
--      sitting in OEPBCHK, not a true 90-day history. If a channel's
--      batches are usually gone from OEPBCHK within days, ORDER_CNT_IN_
--      WINDOW below will be small and the check is really only covering
--      whatever's in flight right now, not "a meaningful window". If you
--      know of a table that keeps channel + HLDORD/RELEASEDDT for
--      completed orders (something other than OEPORDHST, which doesn't
--      carry either field), point me at it and I'll rewrite this against
--      that instead.
--   b) RELEASEDDT is a native DATE column, so "empty" can't be SQL NULL --
--      it's whatever low/default date your system uses for "never set".
--      MIN_RELEASEDDT is reported per channel instead of a hardcoded
--      threshold so you can see what that sentinel actually looks like
--      before treating a channel as fully-releasing.

WITH channel_orders AS (
  SELECT S.DESC AS CHANNEL_DESC,
         T.ORDNUM,
         T.HLDORD,
         T.RELEASEDDT,
         T.KEYEDDT
    FROM OBJECT.OEPEDTSWP S
    JOIN OBJECT.OEPBCHK   B
      ON UCASE(RTRIM(S.DESC)) = UCASE(RTRIM(B.DESC20))
    JOIN OBJECT.OEPTRACK  T
      ON T.KEYB# = B.KEYB#
     AND T.EDTB# = B.EDTB#
   WHERE S.ACTIVE = 'Y'
     AND T.KEYEDDT >= CURRENT DATE - 90 DAYS
)
SELECT S.DESC,
       CASE WHEN (SELECT COUNT(*) FROM OBJECT.OEPEDTCRD C
                    WHERE UCASE(RTRIM(C.DESC)) = UCASE(RTRIM(S.DESC))) > 0
            THEN 'Y' ELSE 'N' END AS IN_OEPEDTCRD,
       CASE WHEN (SELECT COUNT(*) FROM OBJECT.PLPEBDESC P
                    WHERE UCASE(RTRIM(P.DESC20)) = UCASE(RTRIM(S.DESC))) > 0
            THEN 'Y' ELSE 'N' END AS IN_PLPEBDESC,
       (SELECT COUNT(*) FROM channel_orders CO
          WHERE CO.CHANNEL_DESC = S.DESC
            AND CO.HLDORD IN ('Y','B'))               AS HOLD_ORDER_CNT,
       (SELECT MIN(CO.RELEASEDDT) FROM channel_orders CO
          WHERE CO.CHANNEL_DESC = S.DESC)              AS MIN_RELEASEDDT,
       (SELECT COUNT(*) FROM channel_orders CO
          WHERE CO.CHANNEL_DESC = S.DESC)              AS ORDER_CNT_IN_WINDOW
  FROM OBJECT.OEPEDTSWP S
 WHERE S.ACTIVE = 'Y'
 ORDER BY S.DESC;
