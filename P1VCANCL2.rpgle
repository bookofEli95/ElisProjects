     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // P1VCANCL2
       // PCR Batch Cancel
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Batch-closes ~50 PCRs at a time via CSV, calling the existing
       // P1VCANCL worker (same as the F8 Close/Cancel PCR screen) per row.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33975  09/24/26 EFI PCR Upload Spreadsheet

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
     D WrkStatus       S             10A    Inz(*Blanks)

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
               Exsr Sbr_Write_Result;
               Read PCRCANSTG;
               Iter;
            Endif;

            // Pre-check 2: already closed/cancelled?
            If Mn8_Canwho <> *Blanks;
               WrkSkipped += 1;
               WrkStatus = 'SKIPPED';
               WrkMsg = 'Already closed/cancelled';
               Exsr Sbr_Write_Result;
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
               Exsr Sbr_Write_Result;
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
               Exsr Sbr_Write_Result;
            On-Error;
               WrkErrors += 1;
               WrkStatus = 'ERROR';
               WrkMsg = 'P1VCANCL call failed - review manually';
               Exsr Sbr_Write_Result;
            Endmon;

            Read PCRCANSTG;
         Enddo;

         DSPLY ('Total: ' + %Char(WrkTotal)
              + '  Closed: ' + %Char(WrkClosed)
              + '  Skipped: ' + %Char(WrkSkipped)
              + '  Errors: ' + %Char(WrkErrors));
         *InLR = *On;

      /end-free

      //***********************************************************************
      //* Subroutines
      //***********************************************************************
      /free
         Begsr Sbr_Write_Result;
            Exec SQL
               INSERT INTO PCRCANRSLT (ITMNUM, JOBNUM7, STATUS, REASON, RUNTS)
               VALUES (:WrkItmnum, :WrkJobnum7, :WrkStatus, :WrkMsg,
                       CURRENT_TIMESTAMP);
         Endsr;
      /end-free
