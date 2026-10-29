--=============================================================
-- One-time setup for the PCR batch close/cancel program.
-- Run this BEFORE compiling P1CCANCLBAT / P1VCANCLBAT.
--=============================================================

-- Staging file the CL driver loads the CSV into (Item#/Job#
-- pairs to close). Cleared and reloaded on every run.
CREATE TABLE OBJECT.PCRCANSTG (
   ITMNUM   DECIMAL(8,0),
   JOBNUM7  DECIMAL(7,0)
);

-- Run results - one row per Item#/Job# pair from the staging
-- file, recording what happened to it (CLOSED / SKIPPED /
-- ERROR, with a reason). Cleared and rewritten on every run.
CREATE TABLE OBJECT.PCRCANRSLT (
   ITMNUM   DECIMAL(8,0),
   JOBNUM7  DECIMAL(7,0),
   STATUS   CHAR(10),
   REASON   CHAR(50),
   RUNTS    TIMESTAMP
);
