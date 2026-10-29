--=============================================================
-- Fixes RNF2121 (duplicate/stale record format) by dropping and
-- cleanly recreating PCRCANSTG and PCRCANRSLT. Safe to run -
-- nothing else references these tables yet.
--=============================================================

DROP TABLE OBJECT.PCRCANSTG;
DROP TABLE OBJECT.PCRCANRSLT;

CREATE TABLE OBJECT.PCRCANSTG (
   ITMNUM   DECIMAL(8,0),
   JOBNUM7  DECIMAL(7,0)
);

CREATE TABLE OBJECT.PCRCANRSLT (
   ITMNUM   DECIMAL(8,0),
   JOBNUM7  DECIMAL(7,0),
   STATUS   CHAR(10),
   REASON   CHAR(50),
   RUNTS    TIMESTAMP
);

--------------------------------------------------------------
-- Verify each table shows exactly ONE record format
--------------------------------------------------------------
SELECT TABLE_NAME, COUNT(*) AS FORMAT_COUNT
  FROM QSYS2.SYSCOLUMNS
 WHERE TABLE_SCHEMA = 'OBJECT'
   AND TABLE_NAME IN ('PCRCANSTG','PCRCANRSLT')
 GROUP BY TABLE_NAME;
