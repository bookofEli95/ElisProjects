-- OEPEDTSWP_CHECK_MISMATCH
-- Diagnostic: find OEPBCHK batches that AIRRELCTL's cursor would NOT pick
-- up, because their DESC20 doesn't match any active row in OEPEDTSWP.
--
-- Same join AIRRELCTL uses (ucase/rtrim on both sides), but as a LEFT JOIN
-- so unmatched OEPBCHK rows survive with S.DESC = NULL. LENGTH() is shown
-- to help spot a trailing/embedded space or punctuation difference that
-- RTRIM alone won't fix (e.g. a double space or a stray character).

SELECT B.EDTB#,
       B.KEYB#,
       B.BCHSTS,
       B.DESC20,
       LENGTH(RTRIM(B.DESC20)) AS DESC20_LEN,
       S.DESC                  AS MATCHED_CONTROL_DESC
  FROM OBJECT.OEPBCHK B
  LEFT JOIN OBJECT.OEPEDTSWP S
    ON UCASE(RTRIM(S.DESC)) = UCASE(RTRIM(B.DESC20))
   AND S.ACTIVE = 'Y'
 WHERE B.EDTB# <> 0
   AND S.DESC IS NULL
 ORDER BY B.DESC20, B.EDTB#;

-- For comparison, what's actually sitting in the control file:
SELECT DESC,
       LENGTH(RTRIM(DESC)) AS DESC_LEN,
       ACTIVE
  FROM OBJECT.OEPEDTSWP
 ORDER BY DESC;
