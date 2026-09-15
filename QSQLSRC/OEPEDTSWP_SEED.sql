-- OEPEDTSWP_SEED
-- Seed rows for the AIRRELSWP control file (OEPEDTSWP).
--
-- These two rows reproduce AIRRELCTL's current hardcoded channel list
-- (Mirakl EDI and Amazon.com Note) so that switching AICCRTORD from
-- AIRRELCTL to AIRRELSWP is behavior-neutral on day one.
--
-- To add a channel later: INSERT one row with ACTIVE = 'Y'.
-- To stop sweeping a channel: UPDATE its row to ACTIVE = 'N' (or delete it).
-- The DESC value must match OEPBCHK.DESC20 exactly (case-insensitive,
-- trailing blanks ignored).

INSERT INTO OEPEDTSWP (DESC, ACTIVE)
  VALUES ('MIRAKL EDI', 'Y');

INSERT INTO OEPEDTSWP (DESC, ACTIVE)
  VALUES ('AMAZON.COM NOTE', 'Y');
