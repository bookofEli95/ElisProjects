     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // P1VCANCL2
      // PCR: Batch Close/Cancel PCRs
      //**********************************************************************
      // Reads a CSV-staged list of Item#/Job# pairs and, for each one,
      // calls the existing P1VCANCL (the same worker program the F8
      // Close/Cancel PCR screen calls) with fixed parameters matching
      // the "Close" workflow:
      //    Close/Cancel = 'Close'
      //    POP This Item = 'N'
      //    Item Status (Permot) = 'D'
      //
      // This deliberately reuses P1VCANCL rather than reimplementing its
      // logic - that program touches ~15 files and calls two further
      // programs (ACRAEBLDFL, P1RSNDCL) under certain conditions, and
      // re-deriving all of that by hand risks silently dropping a rule.
      //
      // Before calling P1VCANCL, this program replicates the two
      // pre-checks the screen programs (P1RCANCEL/P1VCANCEL) and
      // P1VCANCL itself perform:
      //   - already closed/cancelled (PCPMAIN.CANWHO not blank)
      //   - item or job is a component of another job's kit - P1VCANCL
      //     shows an interactive screen in this case (Exfmt Screen),
      //     which cannot run in batch, so these rows are skipped here
      //     instead of being sent into that call at all.
      //
      // Every row's outcome (closed / skipped+reason / error) is written
      // to PCRCANRSLT so a run can be reviewed afterward. Re-running the
      // same CSV is safe: already-closed rows are skipped again by the
      // "already closed" check above, so nothing gets double-processed.
      //**********************************************************************

      // Input Files
     FPCRCANSTG IF   E             DISK    EXTFILE('OBJECT/PCRCANSTG')
     F                                     EXTDESC('OBJECT/PCRCANSTG')
     F                                     PREFIX(STG_)
     F                                     RENAME(PCRCANSTG:PCRCANST$)
     FPCLMAIN08 IF   E           K DISK    EXTFILE('OBJECT/PCLMAIN08')
     F                                     EXTDESC('OBJECT/PCLMAIN08')
     F                                     PREFIX(Mn8_)
     F                                     RENAME(PCPMAIN$:PC$MAIN08)
     FPCLKITFL4 IF   E           K DISK    EXTFILE('OBJECT/PCLKITFL4')
     F                                     EXTDESC('OBJECT/PCLKITFL4')
     F                                     PREFIX(Kf4_)
     F                                     RENAME(PCPKITF$:PC$KITFL4)
     FPCLKITF2  IF   E           K DISK    EXTFILE('OBJECT/PCLKITF2')
     F                                     EXTDESC('OBJECT/PCLKITF2')
     F                                     PREFIX(Kf2_)
     F                                     RENAME(PCPKITF$:PC$KITFL2)
     FPCPMAIN   IF   E           K DISK    EXTFILE('OBJECT/PCPMAIN')
     F                                     EXTDESC('OBJECT/PCPMAIN')
     F                                     PREFIX(Pmn_)
     F                                     RENAME(PCPMAIN$:PC$MAIN)

      // Run results are written via embedded SQL INSERT (inline at
      // each call site below) rather than a native F-spec -
      // PCRCANRSLT is a plain SQL-created table whose record format
      // name collides with its own file name (RNF2121/RNF7261 when
      // accessed as an externally described output file), so SQL
      // sidesteps that entirely.

      //***********************************************************************
      // Prototypes
      //***********************************************************************
     D P1VCANCL        PR                  EXTPGM('OBJECT/P1VCANCL')
     D  PrmItmnum                     8    Const
     D  PrmJobnum7                    7    Const
     D  PrmPop                        1    Const
     D  PrmCloseCan                  10    Const
     D  PrmPermot                     1    Const

      //***********************************************************************
      // Variables
      //***********************************************************************
     D WrkItmnum       S                   Like(Mn8_@Itm)
     D WrkJobnum7      S                   Like(Mn8_Jobnum7)
     D WrkCount        S              5S 0 Inz(0)
     D WrkTotal        S              7S 0 Inz(0)
     D WrkClosed       S              7S 0 Inz(0)
     D WrkSkipped      S              7S 0 Inz(0)
     D WrkErrors       S              7S 0 Inz(0)
     D WrkMsg          S            200A    Inz(*Blanks)
     D WrkStatus        S             10A    Inz(*Blanks)

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
      /free

         Read PCRCANSTG;
         Dow Not %Eof(PCRCANSTG);

            // Skip blank/incomplete rows (e.g. trailing blank CSV lines)
            If STG_ITMNUM = 0 And STG_JOBNUM7 = 0;
               Read PCRCANSTG;
               Iter;
            Endif;

            WrkTotal += 1;
            WrkItmnum  = STG_ITMNUM;
            WrkJobnum7 = STG_JOBNUM7;

            // Pre-check 1: does a PCR even exist for this Item/Job?
            Chain (WrkItmnum : WrkJobnum7) PCLMAIN08;
            If Not %Found(PCLMAIN08);
               WrkSkipped += 1;
               WrkStatus = 'SKIPPED';
               WrkMsg = 'No PCR found for this Item/Job';
               Exec SQL
                  INSERT INTO PCRCANRSLT (ITMNUM, JOBNUM7, STATUS, REASON, RUNTS)
                  VALUES (:WrkItmnum, :WrkJobnum7, :WrkStatus, :WrkMsg,
                          CURRENT_TIMESTAMP);
               Read PCRCANSTG;
               Iter;
            Endif;

            // Pre-check 2: already closed/cancelled?
            If Mn8_Canwho <> *Blanks;
               WrkSkipped += 1;
               WrkStatus = 'SKIPPED';
               WrkMsg = 'Already closed/cancelled';
               Exec SQL
                  INSERT INTO PCRCANRSLT (ITMNUM, JOBNUM7, STATUS, REASON, RUNTS)
                  VALUES (:WrkItmnum, :WrkJobnum7, :WrkStatus, :WrkMsg,
                          CURRENT_TIMESTAMP);
               Read PCRCANSTG;
               Iter;
            Endif;

            // Pre-check 3: is the JOB a component of another job's kit?
            // (mirrors P1VCANCL's own check - any row at all blocks it)
            WrkCount = 0;
            Setll (WrkJobnum7) PCLKITFL4;
            Dow 1 = 1;
               Reade (WrkJobnum7) PCLKITFL4;
               If %Eof(PCLKITFL4);
                  Leave;
               Endif;
               WrkCount += 1;
            Enddo;

            // Pre-check 4: is the ITEM a component of another, not-yet-
            // cancelled job's kit? (same rule P1VCANCL applies - a
            // component of an ALREADY-cancelled kit doesn't block)
            If WrkCount = 0;
               Setll (WrkItmnum) PCLKITF2;
               Dow 1 = 1;
                  Reade (WrkItmnum) PCLKITF2;
                  If %Eof(PCLKITF2);
                     Leave;
                  Endif;
                  Setgt (Kf2_Kit#) PCPMAIN;
                  Readpe (Kf2_Kit#) PCPMAIN;
                  If Not %Eof(PCPMAIN) And Pmn_Canwho <> *Blanks;
                     // kit itself already cancelled - doesn't block
                  Else;
                     WrkCount += 1;
                  Endif;
               Enddo;
            Endif;

            If WrkCount > 0;
               WrkSkipped += 1;
               WrkStatus = 'SKIPPED';
               WrkMsg = 'Item/Job is a component of another job''s kit';
               Exec SQL
                  INSERT INTO PCRCANRSLT (ITMNUM, JOBNUM7, STATUS, REASON, RUNTS)
                  VALUES (:WrkItmnum, :WrkJobnum7, :WrkStatus, :WrkMsg,
                          CURRENT_TIMESTAMP);
               Read PCRCANSTG;
               Iter;
            Endif;

            // All pre-checks passed - call the same worker program the
            // F8 Close/Cancel PCR screen calls, with the fixed "Close"
            // workflow values.
            Monitor;
               Callp P1VCANCL( %Char(WrkItmnum)
                              : %Char(WrkJobnum7)
                              : 'N'
                              : 'Close'
                              : 'D' );
               WrkClosed += 1;
               WrkStatus = 'CLOSED';
               WrkMsg = *Blanks;
               Exec SQL
                  INSERT INTO PCRCANRSLT (ITMNUM, JOBNUM7, STATUS, REASON, RUNTS)
                  VALUES (:WrkItmnum, :WrkJobnum7, :WrkStatus, :WrkMsg,
                          CURRENT_TIMESTAMP);
            On-Error;
               WrkErrors += 1;
               WrkStatus = 'ERROR';
               WrkMsg = 'P1VCANCL call failed - review manually';
               Exec SQL
                  INSERT INTO PCRCANRSLT (ITMNUM, JOBNUM7, STATUS, REASON, RUNTS)
                  VALUES (:WrkItmnum, :WrkJobnum7, :WrkStatus, :WrkMsg,
                          CURRENT_TIMESTAMP);
            Endmon;

            Read PCRCANSTG;
         Enddo;

         DSPLY ('Total: ' + %Char(WrkTotal)
              + '  Closed: ' + %Char(WrkClosed)
              + '  Skipped: ' + %Char(WrkSkipped)
              + '  Errors: ' + %Char(WrkErrors));
         *InLR = *On;

      /end-free
