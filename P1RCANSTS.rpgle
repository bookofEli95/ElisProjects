     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO)

       //***********************************************************************
       // P1RCANSTS
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Returns the label for the cancel line on the PCR General
       // Information screen: Closed or Cancelled, and whether the item
       // has been POP'd. P1VCANCL records a close and a cancel the same
       // way in PCPMAIN, so a close is recognised by the PERMOT change
       // (S/B/D/Y) it logs to IVPMAINT on the same day by the same user.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33975  09/30/26 EFI Show Closed/Cancelled and POP on PCR

      //*****************************************************************
      // Prototypes
      //*****************************************************************
      /copy qcopysrc,p1rcansts

      //*****************************************************************
      // Entry Parameters
      //*****************************************************************
     D P1RCANSTS       PI
     D  PrmItmnum                     8S 0 Const
     D  PrmJobnum7                    7S 0 Const
     D  PrmLabel                     15A

      //*****************************************************************
      // Variables
      //*****************************************************************
     D WrkCanWho       S             10A
     D WrkCanDate      S               D
     D WrkPermot       S              1A
     D WrkClosed       S             10I 0

      //*****************************************************************
      // MainLine
      //*****************************************************************
      /free

         Exec SQL SET OPTION COMMIT = *NONE;

         PrmLabel = 'Cancelled . . :';

         WrkCanWho = *Blanks;
         Exec SQL
            SELECT COALESCE(CANWHO, ' '),
                   COALESCE(CANCELDT, DATE('0001-01-01'))
              INTO :WrkCanWho, :WrkCanDate
              FROM PCPMAIN
             WHERE @ITM = :PrmItmnum
               AND JOBNUM7 = :PrmJobnum7;

         If SQLCODE <> 0 Or WrkCanWho = *Blanks;
            *InLR = *On;
            Return;
         Endif;

         // A close logs the new PERMOT (S/B/D/Y) in position 29 of AFTER;
         // a cancel only logs PERMOT when it POPs the item ('P')
         WrkClosed = 0;
         Exec SQL
            SELECT COUNT(*)
              INTO :WrkClosed
              FROM IVPMAINT
             WHERE ITMNUM    = :PrmItmnum
               AND FLDNAM    = 'PERMOT'
               AND MAINTWHO  = :WrkCanWho
               AND MAINTYYYY = YEAR(:WrkCanDate)
               AND MAINTMM   = MONTH(:WrkCanDate)
               AND MAINTDD   = DAY(:WrkCanDate)
               AND SUBSTR(AFTER, 29, 1) IN ('S', 'B', 'D', 'Y');

         WrkPermot = *Blanks;
         Exec SQL
            SELECT PERMOT
              INTO :WrkPermot
              FROM IVPITEMS
             WHERE ITMNUM = :PrmItmnum;

         Select;
         When WrkClosed > 0 And WrkPermot = 'P';
            PrmLabel = 'Closed/POP. . :';
         When WrkClosed > 0;
            PrmLabel = 'Closed. . . . :';
         When WrkPermot = 'P';
            PrmLabel = 'Cancelled/POP :';
         Other;
            PrmLabel = 'Cancelled . . :';
         Endsl;

         *InLR = *On;

      /end-free
