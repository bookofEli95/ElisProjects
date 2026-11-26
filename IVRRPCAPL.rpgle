     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // IVRRPCAPL
      // IV - Re-run Repricing Apply & Expire
      //**********************************************************************

      //**********************************************************************
      // Program Information
      // ------------------------------------------------------------------
      // Applies approved suggestions, releases CNOs and expires old ones.
      //**********************************************************************

      //**********************************************************************
      // Program History
      // ------------------------------------------------------------------
      // Project   Date     Int Description
      // ------- -------- --- ---------------------------------------------
      // H33979  11/26/26 EFI Fall back to the item's newest queue row
      // RPCSUG  09/21/26 EFI Create re-run repricing apply and expire
      //**********************************************************************

      // Files resolve through the library list (no library named).

      // Input Files
     FIVPRPCCTL IF   E           K DISK
     F                                     PREFIX(CTL_)
     FIVPRPCRUL IF   E           K DISK
     F                                     PREFIX(RUL_)

      // Update / Add Files
     FIVPRPCSUG UF A E           K DISK
     F                                     PREFIX(SUG_)
     FIVPITEMS  UF A E           K DISK
     F                                     PREFIX(ITM_)
     FIVPORRITM UF   E           K DISK
     F                                     PREFIX(ORR_)
     FNOTEPADI  UF A E           K DISK
     F                                     PREFIX(NTE_)
     FMFPUSERS  IF   E           K DISK
     F                                     PREFIX(USR_)
      // Printed price and third-party approval (SOS-2092, SOS-2520).
     FIVPPRTPRT IF   E           K DISK
     F                                     PREFIX(PPR_)

      // Output Files
     FIVPMAINT  O    E           K DISK
     F                                     PREFIX(MNT_)
     FIVPORRMNT O    E           K DISK
     F                                     PREFIX(ORM_)

      //**********************************************************************
      // Data Structures & Variables
      //**********************************************************************
      // Program status DS (SdsUser, SdsProgram).
      /copy qcopysrc,statusds
      // Passes the new price on to the related item and eBooks.
      /copy qcopysrc,ivrudrlitm

      // Entry parameters
     D PrmMode         S              1A
     D PrmCycle        S              6A

      // Suggestion key fetched from the cursor
     D WrkSugItem      S              8S 0 Inz(0)
     D WrkSugCycl      S              6S 0 Inz(0)
     D WrkQueFnd       S              1A   Inz('N')

      // Run settings
     D WrkMode         S              1A   Inz('A')
     D WrkCycle        S              6S 0 Inz(0)
     D WrkCycAll       S              1A   Inz('Y')
     D WrkCurCycl      S              6S 0 Inz(0)
     D WrkToday        S               D
     D WrkUser         S             10A   Inz(*Blanks)

      // Working values
     D WrkNew72        S              9S 2 Inz(0)
     D WrkOld72        S              9S 2 Inz(0)
     D WrkOld112       S              9S 2 Inz(0)
     D WrkCapVal       S             13S 4 Inz(0)
     D WrkAge          S              5S 0 Inz(0)
     D WrkMthSug       S              7S 0 Inz(0)
     D WrkMthCur       S              7S 0 Inz(0)
     D WrkAction       S              1A   Inz(*Blanks)
     D WrkBreach       S              1A   Inz('N')
     D WrkRulFnd       S              1A   Inz('N')
     D WrkOldStat      S              1A   Inz(*Blanks)
     D WrkApplied      S              1A   Inz('N')
     D WrkDirect       S              1A   Inz('N')
     D WrkTpaNo        S              1A   Inz('N')
     D WrkAudAct       S             20A   Inz(*Blanks)
     D WrkStsTok       S             10A   Inz(*Blanks)
     D WrkPrmItm       S              8A   Inz(*Blanks)

      // One note pad page: 13 lines of 34 characters, as in IVRICNO.
     D WrkPad          DS
     D  WrkPart1               1    256
     D  WrkPart2             257    442
     D  WrkLin                 1    442    Dim(13)

     D WrkPg           S                   Like(NTE_RCDNBR) Inz(0)
     D WrkCnoPg        S                   Like(NTE_RCDNBR) Inz(0)
     D WrkLn           S              2S 0 Inz(0)
     D WrkCnoLn        S              2S 0 Inz(0)
     D WrkSepOk        S              1A   Inz('N')
     D WrkEmpty        S              1A   Inz('N')
     D WrkHdr          S             34A   Inz(*Blanks)
     D WrkName         S             17A   Inz(*Blanks)
     D WrkCntCno       S             10I 0 Inz(0)
     D WrkCntCnoFull   S             10I 0 Inz(0)
     D WrkPrmPrc       S              8A   Inz(*Blanks)
      // Same type as NEWPRICE so %Char matches what IVRORRNEWP scans.
     D WrkCnoPrc       S                   Like(ORR_NEWPRICE) Inz(0)
     D WrkNote         S             60A   Inz(*Blanks)
     D WrkFld          S             10A   Inz(*Blanks)
     D WrkBefore       S             29A   Inz(*Blanks)
     D WrkAfter        S             29A   Inz(*Blanks)
     D WrkDel          S             10I 0 Inz(0)

      // Run counters, reported to the job log at end of run
     D WrkCntRead      S             10I 0 Inz(0)
     D WrkCntApplied   S             10I 0 Inz(0)
     D WrkCntAuto      S             10I 0 Inz(0)
     D WrkCntStale     S             10I 0 Inz(0)
     D WrkCntNoItem    S             10I 0 Inz(0)
     D WrkCntHeld      S             10I 0 Inz(0)
     D WrkCntExpired   S             10I 0 Inz(0)
     D WrkCntNoCtl     S             10I 0 Inz(0)
     D WrkCntNoRise    S             10I 0 Inz(0)
     D WrkCntSkip      S             10I 0 Inz(0)
     D WrkCntRejCno    S             10I 0 Inz(0)
     D WrkCntStaged    S             10I 0 Inz(0)
     D WrkCntNoQue     S             10I 0 Inz(0)
     D WrkCntQTaken    S             10I 0 Inz(0)
     D WrkCntNoRrn     S             10I 0 Inz(0)
     D WrkCntCnoPrc    S             10I 0 Inz(0)

      //***********************************************************************
      //* Entry Parameters
      //***********************************************************************
      // PrmMode  'A' apply decisions, 'M' monthly (adds phase 2, expiry)
      // PrmCycle YYYYMM, or blank for every open cycle
      //***********************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PrmMode
     C                   PARM                    PrmCycle

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
      /free

         Exsr Sbr_Init;

         // Open suggestions, plus rejected ones still holding a CNO.
         Exec SQL
            DECLARE CsrSug CURSOR FOR
               SELECT ITMNUM, RPCCYCL
                 FROM IVPRPCSUG
                WHERE ( RPCSTAT IN ('S', 'A', 'O', 'G')
                     OR ( RPCSTAT = 'R' AND RPCCNOFL = 'Y' ) )
                  AND ( :WrkCycAll = 'Y' OR RPCCYCL = :WrkCycle )
                ORDER BY RPCCYCL, ITMNUM;

         Exec SQL OPEN CsrSug;
         If SqlCod < 0;
            Dsply 'Could not open the suggestion cursor.';
            *InLr = *On;
            Return;
         Endif;

         Exec SQL FETCH CsrSug INTO :WrkSugItem, :WrkSugCycl;
         Dow SqlCod = 0;

            WrkCntRead += 1;
            Exsr Sbr_Process_Sugg;

            Exec SQL FETCH CsrSug INTO :WrkSugItem, :WrkSugCycl;
         Enddo;

         Exec SQL CLOSE CsrSug;

         Exsr Sbr_Report;

         *InLr = *On;

      /end-free

      //***********************************************************************
      //* Subroutine: Run settings
      //***********************************************************************
      /free
         Begsr Sbr_Init;

            WrkToday = %Date();
            WrkUser  = SdsUser;
            If WrkUser = *Blanks;
               WrkUser = 'REPRICE';
            Endif;

            WrkCurCycl = (%Subdt(WrkToday : *Y) * 100)
                       + %Subdt(WrkToday : *M);

            WrkMode = 'A';
            If %Parms >= 1;
               If PrmMode = 'M';
                  WrkMode = 'M';
               Endif;
            Endif;

            WrkCycAll = 'Y';
            If %Parms >= 2 And PrmCycle <> *Blanks;
               Monitor;
                  WrkCycle  = %Int(PrmCycle);
                  WrkCycAll = 'N';
               On-Error;
                  WrkCycAll = 'Y';
               Endmon;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Settle one suggestion
      //***********************************************************************
      /free
         Begsr Sbr_Process_Sugg;

            WrkAction = *Blanks;
            WrkBreach = 'N';
            WrkNote   = *Blanks;
            WrkNew72  = 0;

            // Read for update; the lock is taken here only.
            Chain (WrkSugItem : WrkSugCycl) IVPRPCSUG;
            If Not %Found(IVPRPCSUG);
               WrkCntSkip += 1;
               Leavesr;
            Endif;

            // The catalogue's control row decides phase and expiry.
            Chain (SUG_DIVCAT) IVPRPCCTL;
            If Not %Found(IVPRPCCTL);
               Chain (0) IVPRPCCTL;
               If Not %Found(IVPRPCCTL);
                  WrkCntNoCtl += 1;
                  Unlock IVPRPCSUG;
                  Leavesr;
               Endif;
            Endif;

            // Direct to the item if target 'I', or 'P' with no printed price.
            WrkDirect = 'N';
            WrkTpaNo  = 'N';
            Chain (WrkSugItem) IVPPRTPRT;
            If %Found(IVPPRTPRT);
               If PPR_TPAPRV = 'N';
                  WrkTpaNo = 'Y';
               Endif;
               If CTL_RPCAPLTGT = 'P' And PPR_PRTPRC = 'N';
                  WrkDirect = 'Y';
               Endif;
            Endif;
            If CTL_RPCAPLTGT = 'I';
               WrkDirect = 'Y';
            Endif;

            // Attach a CNO to open suggestions, unless the price goes direct.
            If CTL_RPCCNOYN = 'Y' And SUG_RPCCNOFL <> 'Y'
               And WrkDirect = 'N'
               And ( SUG_RPCSTAT = 'S' Or SUG_RPCSTAT = 'G'
                  Or SUG_RPCSTAT = 'A' Or SUG_RPCSTAT = 'O' );
               Exsr Sbr_Attach_CNO;
            Endif;

            // Decide what this row is: applied now, expired, or left.
            Select;
            When SUG_RPCSTAT = 'A';
               WrkAction = 'A';
               WrkNew72  = SUG_RPCSUG72;
            When SUG_RPCSTAT = 'O';
               WrkAction = 'O';
               WrkNew72  = SUG_RPCAPP72;
            // Phase 2 only auto-applies titles known not to need 3rd party OK.
            When SUG_RPCSTAT = 'S' And WrkMode = 'M'
                                   And CTL_RPCPHASE = '2'
                                   And WrkTpaNo = 'Y';
               WrkAction = 'U';
               WrkNew72  = SUG_RPCSUG72;
            When SUG_RPCSTAT = 'R';
               WrkAction = 'C';
            Other;
               WrkAction = 'X';
            Endsl;

            // A rejected row is only here to have its CNO taken off.
            If WrkAction = 'C';
               Exsr Sbr_Clear_Cno_Flag;
               Leavesr;
            Endif;

            // Anything not applied is checked for expiry.
            If WrkAction = 'X';
               Exsr Sbr_Consider_Expiry;
               Leavesr;
            Endif;

            // The item must still exist.
            Chain(N) (WrkSugItem) IVPITEMS;
            If Not %Found(IVPITEMS);
               WrkNote = 'ITEM NOT ON IVPITEMS';
               Exsr Sbr_Reject;
               WrkCntNoItem += 1;
               Leavesr;
            Endif;

            // Reject if the item price changed since the suggestion.
            If ITM_PRICE72 <> SUG_RPCCUR72;
               WrkNote = 'PRICE CHANGED SINCE THE SUGGESTION WAS MADE';
               Exsr Sbr_Reject;
               WrkCntStale += 1;
               Leavesr;
            Endif;

            // A suggestion that is not a rise is not applied.
            If WrkNew72 <= ITM_PRICE72;
               WrkNote = 'SUGGESTED PRICE IS NOT A RISE';
               Exsr Sbr_Reject;
               WrkCntNoRise += 1;
               Leavesr;
            Endif;

            // Check an override against the rule's guardrails.
            If WrkAction = 'O';
               Exsr Sbr_Check_Override;
               If WrkBreach = 'Y';
                  WrkCntHeld += 1;
                  Leavesr;
               Endif;
            Endif;

            Exsr Sbr_Apply;

            If WrkApplied = 'Y';
               If WrkAction = 'U';
                  WrkCntAuto += 1;
               Else;
                  WrkCntApplied += 1;
               Endif;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Guardrails on an editor override
      //***********************************************************************
      /free
         Begsr Sbr_Check_Override;

            // Read the rule that produced the suggestion.
            WrkBreach = 'N';
            WrkRulFnd = 'N';

            Chain (SUG_RPCCATG : SUG_RPCMODEL : SUG_RPCSCEN :
                   SUG_RPCRULSEQ) IVPRPCRUL;
            If %Found(IVPRPCRUL);
               WrkRulFnd = 'Y';

               If RUL_RULCAPPCT > 0;
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
            Endif;

            // A breach the editor accepted (RPCOVRAUT) is allowed.
            If WrkBreach = 'Y' And SUG_RPCOVRAUT = 'Y';
               WrkBreach = 'N';
            Endif;

            If WrkBreach = 'Y';
               SUG_RPCSTAT = 'G';
               SUG_RPCNOTE = 'OVERRIDE PAST THE CATALOGUE CAP - ' +
                             'NEEDS AUTHORISING';
               SUG_RPCACTTS = %Timestamp();
               Update IV$RPCSUG;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Apply the price
      //***********************************************************************
      /free
         Begsr Sbr_Apply;

            // RPCAPLTGT: stage on the queue (NEWPRICE) or write to the item.
            WrkApplied = 'N';

            If WrkDirect = 'Y';
               Exsr Sbr_Apply_Item;
            Else;
               Exsr Sbr_Stage_Queue;
            Endif;

            If WrkApplied = 'N';
               Leavesr;
            Endif;

            Exsr Sbr_Write_Audit;

            // Staged: turn the note into a price note. Direct: remove it.
            If WrkDirect = 'Y';
               Exsr Sbr_Release_CNO;
            Else;
               Exsr Sbr_Price_CNO;
            Endif;

            SUG_RPCSTAT   = 'X';
            SUG_RPCAPP72  = WrkNew72;
            If CTL_RPCP112YN = 'Y';
               SUG_RPCAPP112 = WrkNew72;
            Else;
               SUG_RPCAPP112 = SUG_RPCCUR112;
            Endif;
            SUG_RPCACTTS  = %Timestamp();
            If SUG_RPCEDITR = *Blanks;
               SUG_RPCEDITR = WrkUser;
            Endif;

            Select;
            When WrkDirect = 'N' And WrkAction = 'U';
               SUG_RPCNOTE = 'STAGED AS RE-RUN NEW PRICE - PHASE 2';
            When WrkDirect = 'N';
               SUG_RPCNOTE = 'STAGED AS RE-RUN NEW PRICE';
            When WrkAction = 'U';
               SUG_RPCNOTE = 'APPLIED AUTOMATICALLY - PHASE 2';
            Endsl;
            Update IV$RPCSUG;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Stage the price on the re-run queue
      //***********************************************************************
      /free
         Begsr Sbr_Stage_Queue;

            WrkAudAct = 'Reprice staged';

            // Read the queue row for update.
            Exsr Sbr_Chain_Queue;

            // No queue row: nowhere to stage the price.
            If WrkQueFnd = 'N';
               WrkNote = 'NO RE-RUN QUEUE ROW TO CARRY THE NEW PRICE';
               Exsr Sbr_Reject;
               WrkCntNoQue += 1;
               Leavesr;
            Endif;

            // Reject if the title is no longer being rerun.
            If ORR_RERUNSTS = ' ';
               WrkStsTok = '*BLANK';
            Else;
               WrkStsTok = %Trim(ORR_RERUNSTS);
            Endif;
            If %Trim(CTL_RPCSTSEXC) <> *Blanks
               And %Scan(' ' + %Trim(WrkStsTok) + ' ' :
                         ' ' + %Trim(CTL_RPCSTSEXC) + ' ') > 0;
               Unlock IVPORRITM;
               WrkNote = 'NO LONGER BEING RERUN - STATUS ' + ORR_RERUNSTS;
               Exsr Sbr_Reject;
               WrkCntNoRrn += 1;
               Leavesr;
            Endif;

            // Don't overwrite a different new price someone else set.
            If ORR_NEWPRICE <> 0 And ORR_NEWPRICE <> SUG_RPCCUR72
               And ORR_NEWPRICE <> WrkNew72;
               Unlock IVPORRITM;
               WrkNote = 'QUEUE ALREADY HAS A NEW PRICE OF ' +
                         %Trim(%Char(ORR_NEWPRICE));
               Exsr Sbr_Reject;
               WrkCntQTaken += 1;
               Leavesr;
            Endif;

            // Write back NEWPRICE only.
            ORR_NEWPRICE = WrkNew72;
            Update IV$ORRITM %Fields(ORR_NEWPRICE);

            // No IVPMAINT row: PRICE72 hasn't changed yet.
            WrkApplied = 'Y';
            WrkCntStaged += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Write the price straight to the item
      //***********************************************************************
      /free
         Begsr Sbr_Apply_Item;

            WrkAudAct = 'Reprice applied';

            // Read for update this time. The earlier read took no lock.
            Chain (WrkSugItem) IVPITEMS;
            If Not %Found(IVPITEMS);
               WrkNote = 'ITEM NOT ON IVPITEMS';
               Exsr Sbr_Reject;
               WrkCntNoItem += 1;
               Leavesr;
            Endif;

            WrkOld72  = ITM_PRICE72;
            WrkOld112 = ITM_PRICE112;

            ITM_PRICE72 = WrkNew72;

            // PRICE112 takes the same price.
            If CTL_RPCP112YN = 'Y';
               ITM_PRICE112 = WrkNew72;
            Endif;

            // Update the price fields only.
            Update IVPITEM$ %Fields(ITM_PRICE72 : ITM_PRICE112);

            // One audit row per field that actually moved.
            WrkFld    = 'PRICE72';
            WrkBefore = %Trim(%Char(WrkOld72));
            WrkAfter  = %Trim(%Char(WrkNew72));
            Exsr Sbr_Write_Maint;

            If ITM_PRICE112 <> WrkOld112;
               WrkFld    = 'PRICE112';
               WrkBefore = %Trim(%Char(WrkOld112));
               WrkAfter  = %Trim(%Char(ITM_PRICE112));
               Exsr Sbr_Write_Maint;
            Endif;

            // Pass the new price on to the related item and eBooks.
            WrkPrmItm = %Editc(WrkSugItem : 'X');
            WrkPrmPrc = %Char(WrkNew72);
            Callp IVRUDRLITM(WrkPrmItm : WrkPrmPrc);

            WrkApplied = 'Y';

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Reject a suggestion that can no longer be applied
      //***********************************************************************
      /free
         Begsr Sbr_Reject;

            // Rejecting releases the CNO.
            Exsr Sbr_Release_CNO;

            SUG_RPCSTAT  = 'R';
            SUG_RPCNOTE  = WrkNote;
            SUG_RPCCNOFL = 'N';
            SUG_RPCACTTS = %Timestamp();
            If SUG_RPCEDITR = *Blanks;
               SUG_RPCEDITR = WrkUser;
            Endif;
            Update IV$RPCSUG;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Release the CNO from a rejected suggestion
      //***********************************************************************
      /free
         Begsr Sbr_Clear_Cno_Flag;

            Exsr Sbr_Release_CNO;

            SUG_RPCCNOFL = 'N';
            If SUG_RPCACTTS = *Loval;
               SUG_RPCACTTS = %Timestamp();
            Endif;
            Update IV$RPCSUG;

            WrkCntRejCno += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Expire a suggestion nobody acted on
      //***********************************************************************
      /free
         Begsr Sbr_Consider_Expiry;

            WrkOldStat = SUG_RPCSTAT;

            // Age in months between cycles (integer divide on purpose).
            WrkMthSug = (%Div(%Int(SUG_RPCCYCL) : 100) * 12)
                      + %Rem(%Int(SUG_RPCCYCL) : 100);
            WrkMthCur = (%Div(%Int(WrkCurCycl) : 100) * 12)
                      + %Rem(%Int(WrkCurCycl) : 100);
            WrkAge    = WrkMthCur - WrkMthSug;

            If CTL_RPCEXPCY <= 0 Or WrkAge <= CTL_RPCEXPCY;
               WrkCntSkip += 1;
               Unlock IVPRPCSUG;
               Leavesr;
            Endif;

            // Expire it and release the CNO; the next run can raise it again.
            Exsr Sbr_Release_CNO;

            If WrkOldStat = 'G';
               SUG_RPCNOTE = 'EXPIRED WHILE HELD - CNO RELEASED';
            Else;
               SUG_RPCNOTE = 'EXPIRED UNACTIONED - CNO RELEASED';
            Endif;
            SUG_RPCSTAT  = 'E';
            SUG_RPCCNOFL = 'N';
            SUG_RPCACTTS = %Timestamp();
            Update IV$RPCSUG;

            WrkCntExpired += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Attach the CNO
      //***********************************************************************
      /free
         Begsr Sbr_Attach_CNO;

            // Write a CNO the IVRICNO way; the (IVRRPC) marker finds it again.
            Exsr Sbr_Cno_Find;
            If WrkCnoPg = 0;
               Exsr Sbr_Cno_Gap;
            Endif;

            // No room on any page: go ahead without a CNO.
            If WrkCnoPg = 0 Or WrkCnoLn > 10;
               WrkCntCnoFull += 1;
               Leavesr;
            Endif;

            // No price in the pending lines, so IVRORRNEWP can't mis-match.
            Exsr Sbr_Cno_Header;
            WrkLin(WrkCnoLn)     = WrkHdr;
            WrkLin(WrkCnoLn + 1) = 'Price review pending (IVRRPC)';
            WrkLin(WrkCnoLn + 2) = 'Do not reprint at the current';
            WrkLin(WrkCnoLn + 3) = 'price until new price is set.';
            Exsr Sbr_Cno_Save;
            Exsr Sbr_Cno_Flags_On;

            SUG_RPCCNOFL  = 'Y';
            SUG_RPCCNORCD = WrkCnoPg;
            WrkCntCno += 1;

            // Save the flag, then re-lock the suggestion.
            Update IV$RPCSUG;
            Chain (WrkSugItem : WrkSugCycl) IVPRPCSUG;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Release the CNO
      //***********************************************************************
      /free
         Begsr Sbr_Release_CNO;

            // Blank this process's four lines only, then tidy up.
            If SUG_RPCCNOFL = 'Y';
               Exsr Sbr_Cno_Find;
               If WrkCnoPg > 0;
                  For WrkLn = WrkCnoLn To WrkCnoLn + 3;
                     If WrkLn <= 13;
                        WrkLin(WrkLn) = *Blanks;
                     Endif;
                  Endfor;
                  Exsr Sbr_Cno_Save;
                  WrkDel += 1;
                  Exsr Sbr_Cno_Tidy;
               Endif;
            Endif;

            SUG_RPCCNOFL  = 'N';
            SUG_RPCCNORCD = 0;
            SUG_RPCCNOSET = 'N';

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Turn the pending CNO into a price CNO
      //***********************************************************************
      /free
         Begsr Sbr_Price_CNO;

            // Rewrite the note with PRICE and the new price, for IVRORRNEWP.
            If SUG_RPCCNOFL <> 'Y';
               Leavesr;
            Endif;

            Exsr Sbr_Cno_Find;
            If WrkCnoPg = 0 Or WrkCnoLn > 10;
               SUG_RPCCNOFL  = 'N';
               SUG_RPCCNORCD = 0;
               Leavesr;
            Endif;

            WrkCnoPrc = WrkNew72;
            Exsr Sbr_Cno_Header;
            WrkLin(WrkCnoLn)     = WrkHdr;
            WrkLin(WrkCnoLn + 1) = 'Price change on rerun (IVRRPC)';
            WrkLin(WrkCnoLn + 2) = 'New price ' + %Trim(%Char(WrkCnoPrc));
            WrkLin(WrkCnoLn + 3) = 'Reprint at the new price.';
            Exsr Sbr_Cno_Save;

            WrkCntCnoPrc += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Find this process's correction on the note pad
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Find;

            // Find this process's block by its (IVRRPC) marker line.
            WrkCnoPg = 0;
            WrkCnoLn = 0;
            For WrkPg = 1 To 4;
               Exsr Sbr_Cno_Load;
               For WrkLn = 2 To 13;
                  If %Scan('(IVRRPC' : WrkLin(WrkLn)) > 0;
                     WrkCnoPg = WrkPg;
                     WrkCnoLn = WrkLn - 1;
                     Leave;
                  Endif;
               Endfor;
               If WrkCnoPg > 0;
                  Leave;
               Endif;
            Endfor;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Find room for a new correction
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Gap;

            // First gap of four free lines after a blank line.
            WrkCnoPg = 0;
            WrkCnoLn = 0;
            For WrkPg = 1 To 4;
               Exsr Sbr_Cno_Load;
               For WrkLn = 1 To 10;
                  WrkSepOk = 'Y';
                  If WrkLn > 1;
                     If WrkLin(WrkLn - 1) <> *Blanks;
                        WrkSepOk = 'N';
                     Endif;
                  Endif;
                  If WrkSepOk = 'Y' And WrkLn + 2 <> 8
                     And WrkLin(WrkLn)     = *Blanks
                     And WrkLin(WrkLn + 1) = *Blanks
                     And WrkLin(WrkLn + 2) = *Blanks
                     And WrkLin(WrkLn + 3) = *Blanks;
                     WrkCnoPg = WrkPg;
                     WrkCnoLn = WrkLn;
                     Leave;
                  Endif;
               Endfor;
               If WrkCnoPg > 0;
                  Leave;
               Endif;
            Endfor;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Read one page of the note pad
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Load;

            Chain(N) (WrkSugItem : WrkPg) NOTEPADI;
            If %Found(NOTEPADI);
               WrkPart1 = NTE_NOTE1;
               WrkPart2 = NTE_NOTE2;
            Else;
               Clear WrkPad;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Write the page back
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Save;

            // Write back the page with only this process's lines changed.
            Chain (WrkSugItem : WrkCnoPg) NOTEPADI;
            NTE_NOTE1 = WrkPart1;
            NTE_NOTE2 = WrkPart2;
            If %Found(NOTEPADI);
               NTE_CHGTS   = %Timestamp();
               NTE_CHGUSER = WrkUser;
               Update NOTEPAD$;
            Else;
               NTE_ITMNUM  = WrkSugItem;
               NTE_RCDNBR  = WrkCnoPg;
               NTE_ADDTS   = %Timestamp();
               NTE_ADDUSER = WrkUser;
               NTE_CHGTS   = %Timestamp();
               NTE_CHGUSER = WrkUser;
               Write NOTEPAD$;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Correction header line
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Header;

            // Header built the same way IVRICNO builds it.
            WrkName = WrkUser;
            Chain (WrkUser) MFPUSERS;
            If %Found(MFPUSERS);
               WrkName = USR_USERNAME;
            Endif;

            WrkHdr = 'Correction '
                   + %Subst(%Editc(%Subdt(%Date():*M):'Z'):9:2)
                   + '/'
                   + %Subst(%Char(%Date()):3:2)
                   + ' '
                   + WrkName;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Correction flags on, as IVRICNO sets them
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Flags_On;

            // Set IVPORRITM.CNO only if blank; RPCCNOSET records that we did.
            Exsr Sbr_Chain_Queue;
            If WrkQueFnd = 'Y';
               If ORR_CNO = *Blanks;
                  ORR_CNO = 'M';
                  Update IV$ORRITM %Fields(ORR_CNO);
                  SUG_RPCCNOSET = 'Y';
               Else;
                  Unlock IVPORRITM;
               Endif;
            Endif;

            // IVPITEMS.CORRCD 'C' marks an item with correction notes.
            Chain (WrkSugItem) IVPITEMS;
            If %Found(IVPITEMS);
               If ITM_CORRCD <> 'C';
                  ITM_CORRCD = 'C';
                  Update IVPITEM$ %Fields(ITM_CORRCD);
               Else;
                  Unlock IVPITEMS;
               Endif;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Tidy up after a correction is removed
      //***********************************************************************
      /free
         Begsr Sbr_Cno_Tidy;

            // If all four pages are empty, delete them and clear the flags.
            WrkEmpty = 'Y';
            For WrkPg = 1 To 4;
               Exsr Sbr_Cno_Load;
               If WrkPart1 <> *Blanks Or WrkPart2 <> *Blanks;
                  WrkEmpty = 'N';
               Endif;
            Endfor;

            If WrkEmpty = 'Y';
               For WrkPg = 1 To 4;
                  Delete (WrkSugItem : WrkPg) NOTEPADI;
               Endfor;

               Chain (WrkSugItem) IVPITEMS;
               If %Found(IVPITEMS);
                  If ITM_CORRCD <> ' ';
                     ITM_CORRCD = ' ';
                     Update IVPITEM$ %Fields(ITM_CORRCD);
                  Else;
                     Unlock IVPITEMS;
                  Endif;
               Endif;

               If SUG_RPCCNOSET = 'Y';
                  Exsr Sbr_Chain_Queue;
                  If WrkQueFnd = 'Y';
                     If ORR_CNO = 'M';
                        ORR_CNO = ' ';
                        Update IV$ORRITM %Fields(ORR_CNO);
                     Else;
                        Unlock IVPORRITM;
                     Endif;
                  Endif;
               Endif;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Read this suggestion's re-run queue row, for update
      //***********************************************************************
      /free
         Begsr Sbr_Chain_Queue;

            // Queue row by item + MINQTYDT; no MINQTYDT means no queue row.
            WrkQueFnd = 'N';
            If SUG_RPCMINQDT > D'0001-01-01';
               Chain (WrkSugItem : SUG_RPCMINQDT) IVPORRITM;
               If %Found(IVPORRITM);
                  WrkQueFnd = 'Y';
               Else;
                  // Row re-keyed since: fall back to the item's newest row.
                  Chain (WrkSugItem) IVPORRITM;
                  If %Found(IVPORRITM);
                     WrkQueFnd = 'Y';
                     SUG_RPCMINQDT = ORR_MINQTYDT;
                  Endif;
               Endif;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Field-level audit row
      //***********************************************************************
      /free
         Begsr Sbr_Write_Maint;

            // FLDNAM matches RPCFLDLST; COMMENT names the program.
            Clear IVPMAIN$;
            MNT_ITMNUM    = WrkSugItem;
            MNT_FLDNAM    = WrkFld;
            MNT_MAINTYYYY = %Subdt(WrkToday : *Y);
            MNT_MAINTMM   = %Subdt(WrkToday : *M);
            MNT_MAINTDD   = %Subdt(WrkToday : *D);
            MNT_MAINTWHO  = WrkUser;
            MNT_BEFORE    = WrkBefore;
            MNT_AFTER     = WrkAfter;
            MNT_REPCODE   = 'N';
            MNT_COMMENT   = 'IVRRPCAPL';

            // MAINTNAME: user's name from MFPUSERS, else the user ID.
            MNT_MAINTNAME = %Trim(WrkUser);
            Chain (WrkUser) MFPUSERS;
            If %Found(MFPUSERS);
               MNT_MAINTNAME = %Trim(USR_USERNAME);
            Endif;
            Write IVPMAIN$;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Item history row
      //***********************************************************************
      /free
         Begsr Sbr_Write_Audit;

            Clear IV$ORRMNT;
            ORM_ITMNUM   = WrkSugItem;
            ORM_ACTION   = WrkAudAct;
            ORM_DESC     = %Trim(%Char(SUG_RPCCUR72)) + ' to ' +
                           %Trim(%Char(WrkNew72));
            ORM_MAINTTS  = %Timestamp();
            ORM_MAINTWHO = WrkUser;
            Write IV$ORRMNT;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Report the run to the job log
      //***********************************************************************
      /free
         Begsr Sbr_Report;

            Dsply ('Mode ' + WrkMode + ' cycle ' + %Char(WrkCycle));
            Dsply ('Suggestions read : ' + %Char(WrkCntRead));
            Dsply ('Applied          : ' + %Char(WrkCntApplied));
            Dsply ('Applied phase 2  : ' + %Char(WrkCntAuto));
            Dsply ('Expired          : ' + %Char(WrkCntExpired));
            Dsply ('Held override    : ' + %Char(WrkCntHeld));
            Dsply ('Reject stale     : ' + %Char(WrkCntStale));
            Dsply ('Reject no item   : ' + %Char(WrkCntNoItem));
            Dsply ('Reject no rise   : ' + %Char(WrkCntNoRise));
            Dsply ('No control row   : ' + %Char(WrkCntNoCtl));
            Dsply ('Left open        : ' + %Char(WrkCntSkip));
            Dsply ('Rejected, CNO off: ' + %Char(WrkCntRejCno));
            Dsply ('Staged NEWPRICE  : ' + %Char(WrkCntStaged));
            Dsply ('Reject no queue  : ' + %Char(WrkCntNoQue));
            Dsply ('Reject not rerun : ' + %Char(WrkCntNoRrn));
            Dsply ('Reject priced now: ' + %Char(WrkCntQTaken));
            Dsply ('CNOs released    : ' + %Char(WrkDel));
            Dsply ('CNOs now priced  : ' + %Char(WrkCntCnoPrc));
            Dsply ('CNOs attached    : ' + %Char(WrkCntCno));
            Dsply ('CNO pad full     : ' + %Char(WrkCntCnoFull));

         Endsr;
      /end-free
