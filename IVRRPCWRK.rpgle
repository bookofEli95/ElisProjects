     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // IVRRPCWRK
      // IV - Work with Repricing Suggestions
      //**********************************************************************

      //**********************************************************************
      // Program Information
      // ------------------------------------------------------------------
      // The editor end of the repricing process. IVRRPCGEN puts up a
      // suggested price; this is where a person approves it, replaces
      // it, or turns it down. Nothing here changes a price: it records
      // the decision on the suggestion and IVRRPCAPL carries it out, so
      // there is one place a price can move from and one audit trail.
      //
      // Options, typed against a line:
      //
      //   2  override - the price typed in the New column is used
      //   4  reject - the price is left alone and the CNO is released
      //   6  approve - the suggested price is used
      //
      // The override guardrail:
      //
      //   An override past the catalogue cap is not refused - editors
      //   know things the rule table does not. It is held on the file at
      //   status 'G' with the cap that it breaks reported back, and
      //   typing 2 again on the held line authorises it. Keeping the
      //   half-made decision on the file rather than in a program flag
      //   means it survives a refresh, a sign-off and a shift change,
      //   and the authorisation is recorded against the editor.
      //
      //   An override below the current price is refused outright: this
      //   process only raises prices, so a reduction typed here is far
      //   more likely to be a slip than an intention.
      //**********************************************************************

      //**********************************************************************
      // Program History
      // ------------------------------------------------------------------
      // Project   Date     Int Description
      // ------- -------- --- ---------------------------------------------
      // RPCSUG  09/21/26 EFI Create work with repricing suggestions
      //**********************************************************************

      // Display File
     FIVVRPCWRK CF   E             WORKSTN EXTFILE('OBJECT/IVVRPCWRK')
     F                                     EXTDESC('OBJECT/IVVRPCWRK')
     F                                     SFILE(RPCSFL1:WrkRrn)

      // Input Files
     FIVPRPCCTL IF   E           K DISK    EXTFILE('OBJECT/IVPRPCCTL')
     F                                     EXTDESC('OBJECT/IVPRPCCTL')
     F                                     PREFIX(CTL_)
     FIVPRPCRUL IF   E           K DISK    EXTFILE('OBJECT/IVPRPCRUL')
     F                                     EXTDESC('OBJECT/IVPRPCRUL')
     F                                     PREFIX(RUL_)
     FIVPITEMS  IF   E           K DISK    EXTFILE('OBJECT/IVPITEMS')
     F                                     EXTDESC('OBJECT/IVPITEMS')
     F                                     PREFIX(ITM_)

      // Update Files
     FIVPRPCSUG UF A E           K DISK    EXTFILE('OBJECT/IVPRPCSUG')
     F                                     EXTDESC('OBJECT/IVPRPCSUG')
     F                                     PREFIX(SUG_)

      //**********************************************************************
      // Data Structures & Variables
      //**********************************************************************
     D SdsUser         SDS
     D                       254    263A

     D WrkRrn          S              4S 0 Inz(0)
     D WrkLoaded       S              5S 0 Inz(0)
     D WrkExit         S              1A   Inz('N')
     D WrkUser         S             10A   Inz(*Blanks)
     D WrkToday        S               D

      // One row of the queue, fetched for the subfile
     D WrkQItem        S              8S 0 Inz(0)
     D WrkQCycl        S              6S 0 Inz(0)

      // Decision being recorded
     D WrkNew72        S              9S 2 Inz(0)
     D WrkNew112       S              9S 2 Inz(0)
     D WrkRatio        S             13S 6 Inz(0)
     D WrkCapVal       S             13S 4 Inz(0)
     D WrkCapPct       S              5S 2 Inz(0)
     D WrkBreach       S              1A   Inz('N')
     D WrkCntAct       S              5S 0 Inz(0)
     D WrkSelStat      S              1A   Inz(*Blanks)
     D WrkSelDiv       S              7S 0 Inz(0)
     D WrkDesc         S             18A   Inz(*Blanks)

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
      /free

         Exsr Sbr_Init;

         Dow WrkExit = 'N';

            Exsr Sbr_Load_Subfile;

            Exfmt RPCCTL1;

            Select;
            When *In03 Or *In12;
               WrkExit = 'Y';
            When *In05;
               WMSG = *Blanks;
            Other;
               Exsr Sbr_Process_Subfile;
            Endsl;

         Enddo;

         *InLr = *On;

      /end-free

      //***********************************************************************
      //* Subroutine: Start up
      //***********************************************************************
      /free
         Begsr Sbr_Init;

            WrkToday = %Date();
            WrkUser  = SdsUser;
            If WrkUser = *Blanks;
               WrkUser = 'REPRICE';
            Endif;

            WDATE   = WrkToday;
            WDIVCAT = 0;
            WSTAT   = *Blanks;
            WMSG    = *Blanks;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Build the subfile from the queue
      //***********************************************************************
      /free
         Begsr Sbr_Load_Subfile;

            // Clear
            *In21 = *Off;
            *In22 = *Off;
            *In23 = *On;
            Write RPCCTL1;
            *In23 = *Off;
            WrkRrn    = 0;
            WrkLoaded = 0;

            // A blank status means everything still waiting on someone:
            // suggested, approved and overridden but not yet applied, and
            // anything held. A status typed in narrows it to one.
            WrkSelStat = WSTAT;
            WrkSelDiv  = WDIVCAT;

            Exec SQL
               DECLARE CsrQue CURSOR FOR
                  SELECT ITMNUM, RPCCYCL
                    FROM IVPRPCSUG
                   WHERE ( :WrkSelDiv = 0 OR DIVCAT = :WrkSelDiv )
                     AND ( ( :WrkSelStat = ' '
                         AND RPCSTAT IN ('S', 'A', 'O', 'G') )
                        OR RPCSTAT = :WrkSelStat )
                   ORDER BY DIVCAT, RPCCYCL, ITMNUM;

            Exec SQL OPEN CsrQue;

            Exec SQL FETCH CsrQue INTO :WrkQItem, :WrkQCycl;
            Dow SqlCod = 0 And WrkRrn < 9999;

               Chain(N) (WrkQItem : WrkQCycl) IVPRPCSUG;
               If %Found(IVPRPCSUG);

                  // Description comes from the item master rather than
                  // being copied on to the suggestion, so the screen
                  // always shows the title as it reads today.
                  WrkDesc = *Blanks;
                  Chain(N) (WrkQItem) IVPITEMS;
                  If %Found(IVPITEMS);
                     WrkDesc = ITM_SDESC;
                  Endif;

                  WrkRrn += 1;
                  SOPT  = *Blanks;
                  SITEM = SUG_ITMNUM;
                  SCYCL = SUG_RPCCYCL;
                  SDESC = WrkDesc;
                  SSTAT = SUG_RPCSTAT;
                  SCUR  = SUG_RPCCUR72;
                  SSUG  = SUG_RPCSUG72;

                  // An override already typed is shown back, so a second
                  // Enter confirms the same number rather than a blank.
                  If SUG_RPCSTAT = 'O' Or SUG_RPCSTAT = 'G';
                     SNEW = SUG_RPCAPP72;
                  Else;
                     SNEW = 0;
                  Endif;

                  SDUE  = SUG_RPCDUEDT;
                  SLSTC = SUG_RPCLSTCHG;
                  Write RPCSFL1;
                  WrkLoaded += 1;
               Endif;

               Exec SQL FETCH CsrQue INTO :WrkQItem, :WrkQCycl;
            Enddo;

            Exec SQL CLOSE CsrQue;

            If WrkLoaded > 0;
               *In21 = *On;
            Endif;
            *In22 = *On;
            *In24 = *On;

            If WrkLoaded = 0 And WMSG = *Blanks;
               WMSG = 'No repricing suggestions to work with.';
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Act on what the editor typed
      //***********************************************************************
      /free
         Begsr Sbr_Process_Subfile;

            WrkCntAct = 0;
            WMSG      = *Blanks;

            Readc RPCSFL1;
            Dow Not %Eof(IVVRPCWRK);

               If SOPT <> *Blanks Or SNEW > 0;
                  Exsr Sbr_Action_Line;
               Endif;

               Readc RPCSFL1;
            Enddo;

            If WMSG = *Blanks And WrkCntAct > 0;
               WMSG = %Char(WrkCntAct) + ' suggestion(s) updated.';
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Act on one subfile line
      //***********************************************************************
      /free
         Begsr Sbr_Action_Line;

            // Keyed off the line's own hidden cycle, not off whatever
            // the record buffer happens to hold from the last read.
            Chain (SITEM : SCYCL) IVPRPCSUG;
            If Not %Found(IVPRPCSUG);
               Exsr Sbr_Find_By_Item;
            Endif;
            If Not %Found(IVPRPCSUG);
               WMSG = 'Item ' + %Char(SITEM) + ' is no longer on file.';
               Leavesr;
            Endif;

            Select;

            // ---- approve -------------------------------------------
            When SOPT = '6';
               SUG_RPCSTAT   = 'A';
               SUG_RPCAPP72  = SUG_RPCSUG72;
               SUG_RPCAPP112 = SUG_RPCSUG112;
               SUG_RPCEDITR  = WrkUser;
               SUG_RPCACTTS  = %Timestamp();
               SUG_RPCNOTE   = 'APPROVED AT THE SUGGESTED PRICE';
               Update IV$RPCSUG;
               WrkCntAct += 1;

            // ---- reject --------------------------------------------
            When SOPT = '4';
               // The CNO is left attached and RPCCNOFL stays 'Y'.
               // IVRRPCAPL releases it on its next run, which keeps
               // every CNO change in one program.
               SUG_RPCSTAT  = 'R';
               SUG_RPCEDITR = WrkUser;
               SUG_RPCACTTS = %Timestamp();
               SUG_RPCNOTE  = 'REJECTED BY THE EDITOR';
               Update IV$RPCSUG;
               WrkCntAct += 1;

            // ---- override ------------------------------------------
            When SOPT = '2' Or SNEW > 0;
               Exsr Sbr_Override;

            Other;
               Unlock IVPRPCSUG;

            Endsl;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Record an override
      //***********************************************************************
      /free
         Begsr Sbr_Override;

            WrkNew72 = SNEW;

            If WrkNew72 <= 0;
               WMSG = 'Type the override price in the New column.';
               Unlock IVPRPCSUG;
               Leavesr;
            Endif;

            // This process raises prices. A reduction typed here is far
            // more likely to be a slip than an intention, so it is
            // refused rather than confirmed.
            If WrkNew72 <= SUG_RPCCUR72;
               WMSG = 'Override must be above the current price of ' +
                      %Trim(%Char(SUG_RPCCUR72)) + '.';
               Unlock IVPRPCSUG;
               Leavesr;
            Endif;

            Exsr Sbr_Check_Cap;

            // An override past the cap is held on the file rather than
            // confirmed in memory. Typing 2 again on the held line, with
            // the same price still showing, is the authorisation - so it
            // survives a refresh, a sign-off and a shift change, and the
            // record shows who gave it.
            If WrkBreach = 'Y';
               If SUG_RPCSTAT <> 'G' Or SUG_RPCAPP72 <> WrkNew72;
                  SUG_RPCSTAT   = 'G';
                  SUG_RPCAPP72  = WrkNew72;
                  SUG_RPCOVRAUT = 'N';
                  SUG_RPCEDITR  = WrkUser;
                  SUG_RPCACTTS  = %Timestamp();
                  SUG_RPCNOTE   = 'OVERRIDE PAST THE CAP - ' +
                                  'NEEDS AUTHORISING';
                  Update IV$RPCSUG;
                  WMSG = 'Item ' + %Trim(%Char(SITEM)) +
                         ' is past the ' + %Trim(%Char(WrkCapPct)) +
                         '% cap and is held. Type 2 again to authorise.';
                  WrkCntAct += 1;
                  Leavesr;
               Endif;
            Endif;

            // Keep the two price lists in step: the second list moves by
            // the same proportion the editor moved the first.
            WrkNew112 = 0;
            If SUG_RPCCUR112 > 0 And SUG_RPCCUR72 > 0;
               Eval(H) WrkRatio  = WrkNew72 / SUG_RPCCUR72;
               Eval(H) WrkNew112 = SUG_RPCCUR112 * WrkRatio;
            Endif;

            SUG_RPCSTAT   = 'O';
            SUG_RPCAPP72  = WrkNew72;
            SUG_RPCAPP112 = WrkNew112;
            SUG_RPCEDITR  = WrkUser;
            SUG_RPCACTTS  = %Timestamp();

            If WrkBreach = 'Y';
               SUG_RPCOVRAUT = 'Y';
               SUG_RPCNOTE   = 'OVERRIDE PAST THE CAP - AUTHORISED BY ' +
                               %Trim(WrkUser);
            Else;
               SUG_RPCOVRAUT = 'N';
               SUG_RPCNOTE   = 'OVERRIDDEN BY THE EDITOR';
            Endif;

            Update IV$RPCSUG;
            WrkCntAct += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Is the override past the catalogue cap
      //***********************************************************************
      /free
         Begsr Sbr_Check_Cap;

            // Judged against the rule that produced the suggestion, read
            // back by the key recorded on it, so the editor is held to
            // the guardrail that was in force when the number was made.
            WrkBreach = 'N';
            WrkCapPct = 0;

            Chain (SUG_RPCCATG : SUG_RPCMODEL : SUG_RPCSCEN :
                   SUG_RPCRULSEQ) IVPRPCRUL;
            If Not %Found(IVPRPCRUL);
               Leavesr;
            Endif;

            If RUL_RULCAPPCT > 0;
               WrkCapPct = RUL_RULCAPPCT;
               Eval(H) WrkCapVal = SUG_RPCCUR72
                             * (1 + (RUL_RULCAPPCT / 100));
               If WrkNew72 > WrkCapVal;
                  WrkBreach = 'Y';
               Endif;
            Endif;

            If RUL_RULCAPAMT > 0
               And (WrkNew72 - SUG_RPCCUR72) > RUL_RULCAPAMT;
               WrkBreach = 'Y';
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Find the open suggestion for an item
      //***********************************************************************
      /free
         Begsr Sbr_Find_By_Item;

            // Only one suggestion per item is ever open at a time -
            // IVRRPCGEN will not add a second - so the open one can be
            // found by item alone.
            WrkQCycl = 0;
            Exec SQL
               SELECT MIN(RPCCYCL) INTO :WrkQCycl
                 FROM IVPRPCSUG
                WHERE ITMNUM = :SITEM
                  AND RPCSTAT IN ('S', 'A', 'O', 'G');

            If WrkQCycl > 0;
               Chain (SITEM : WrkQCycl) IVPRPCSUG;
            Endif;

         Endsr;
      /end-free
