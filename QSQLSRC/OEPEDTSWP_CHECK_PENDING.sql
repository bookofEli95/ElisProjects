-- OEPEDTSWP_CHECK_PENDING
-- Shows every OEPBCHK row that AIRRELCTL2's cursor WOULD pick up right
-- now (same filter as the program): matches an active OEPEDTSWP row,
-- is not Mirakl/Amazon (AIRRELCTL owns those).
--
-- BCHSTS 'C' = closed, i.e. waiting for release -- that is the normal
-- state for a batch AIRRELCTL2 should process, so it is NOT filtered.
--
-- If this returns rows and they are still here 15+ minutes later during
-- the 08:30-19:00 window, AIRRELCTL2 is either not being called or is
-- erroring -- check the job log for "AIRRELCTL2" lines.

SELECT B.EDTB#,
       B.KEYB#,
       B.BCHSTS,
       B.PHASE,
       B.DESC20
  FROM OBJECT.OEPBCHK B
 WHERE B.EDTB# <> 0
   AND UCASE(B.DESC20) NOT IN ('MIRAKL EDI', 'AMAZON.COM NOTE')
   AND UCASE(RTRIM(B.DESC20)) IN
       (SELECT UCASE(RTRIM(S.DESC))
          FROM OBJECT.OEPEDTSWP S
         WHERE S.ACTIVE = 'Y')
 ORDER BY B.DESC20, B.EDTB#;
