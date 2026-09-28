-- OEPEDTSWP_CHECK_PENDING
-- Shows every OEPBCHK row that AIRRELCTL's cursor WOULD pick up right now
-- (same join/filter as the program uses) -- i.e. matches an active
-- OEPEDTSWP row and is still open (BCHSTS <> 'C').
--
-- If this returns rows: AIRRELCTL should release them on its next pass
-- (within ~15 min, during the 08:30-19:00 window) -- if they're still
-- open after that, AIRRELCTL is erroring, not skipping them, so check
-- the AICCRTORD/API_CRTORD job log next.
--
-- If this returns NOTHING but you still see rows on the Credit Release
-- screen for these channels: that screen isn't filtering the same way
-- this query assumes (BCHSTS <> 'C') -- tell me what status/phase those
-- on-screen rows actually show and I'll adjust the comparison.

SELECT B.EDTB#,
       B.KEYB#,
       B.BCHSTS,
       B.DESC20,
       S.DESC AS MATCHED_CONTROL_DESC
  FROM OBJECT.OEPBCHK B
  JOIN OBJECT.OEPEDTSWP S
    ON UCASE(RTRIM(S.DESC)) = UCASE(RTRIM(B.DESC20))
   AND S.ACTIVE = 'Y'
 WHERE B.EDTB# <> 0
   AND B.BCHSTS <> 'C'
 ORDER BY B.DESC20, B.EDTB#;
