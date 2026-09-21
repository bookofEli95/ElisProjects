     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // IVRRPCAPL
      // IV - Re-run Repricing Apply & Expire
      //**********************************************************************

      //**********************************************************************
      // Program Information
      // ------------------------------------------------------------------
      // Applies actioned repricing suggestions to the item master and
      // releases the CNO. This is the only program that changes a
      // price, so every price movement from this process passes through
      // one place and leaves one audit trail.
      //
      // What it acts on:
      //
      //   RPCSTAT 'A'  approved - the suggested price is applied
      //   RPCSTAT 'O'  overridden - the editor's price is applied, once
      //                it has passed the catalogue guardrails
      //   RPCSTAT 'S'  only in mode 'M', and only for a phase 2
      //                catalogue, which is what "applies automatically"
      //                means
      //
      // What it refuses:
      //
      //   A suggestion whose item price has moved since it was made is
      //   rejected, not applied. The number was worked out from a price
      //   that no longer exists, so applying it would silently reprice
      //   from a base nobody reviewed.
      //
      //   An override past the catalogue cap is held, not applied,
      //   unless the editor accepted the breach (RPCOVRAUT).
      //
      // Expiry matters as much as applying. A suggestion nobody acts on
      // would otherwise keep its CNO attached for ever, and the CNO stops
      // the book being reprinted at the old price - so an abandoned
      // review would quietly block production. Past RPCEXPCY cycles the
      // suggestion is expired and the CNO released, which also lets the
      // next run raise it again rather than forget it.
      //**********************************************************************

      //**********************************************************************
      // Program History
      // ------------------------------------------------------------------
      // Project   Date     Int Description
      // ------- -------- --- ---------------------------------------------
      // RPCSUG  09/21/26 EFI Create re-run repricing apply and expire
      //**********************************************************************

      // Input Files
     FIVPRPCCTL IF   E           K DISK    EXTFILE('OBJECT/IVPRPCCTL')
     F                                     EXTDESC('OBJECT/IVPRPCCTL')
     F                                     PREFIX(CTL_)
     FIVPRPCRUL IF   E           K DISK    EXTFILE('OBJECT/IVPRPCRUL')
     F                                     EXTDESC('OBJECT/IVPRPCRUL')
     F                                     PREFIX(RUL_)

      // Update / Add Files
     FIVPRPCSUG UF A E           K DISK    EXTFILE('OBJECT/IVPRPCSUG')
     F                                     EXTDESC('OBJECT/IVPRPCSUG')
     F                                     PREFIX(SUG_)
     FIVPITEMS  UF A E           K DISK    EXTFILE('OBJECT/IVPITEMS')
     F                                     EXTDESC('OBJECT/IVPITEMS')
     F                                     PREFIX(ITM_)

      // Output Files
     FIVPMAINT  O    E           K DISK    EXTFILE('OBJECT/IVPMAINT')
     F                                     EXTDESC('OBJECT/IVPMAINT')
     F                                     PREFIX(MNT_)
     FIVPORRMNT O    E           K DISK    EXTFILE('OBJECT/IVPORRMNT')
     F                                     EXTDESC('OBJECT/IVPORRMNT')
     F                                     PREFIX(ORM_)

      //**********************************************************************
      // Data Structures & Variables
      //**********************************************************************
     D SdsUser         SDS
     D                       254    263A

      // Entry parameters
     D PrmMode         S              1A
     D PrmCycle        S              6A

      // Suggestion key fetched from the cursor
     D WrkSugItem      S              8S 0 Inz(0)
     D WrkSugCycl      S              6S 0 Inz(0)

      // Run settings
     D WrkMode         S              1A   Inz('A')
     D WrkCycle        S              6S 0 Inz(0)
     D WrkCycAll       S              1A   Inz('Y')
     D WrkCurCycl      S              6S 0 Inz(0)
     D WrkToday        S               D
     D WrkUser         S             10A   Inz(*Blanks)

      // Working values
     D WrkNew72        S              9S 2 Inz(0)
     D WrkNew112       S              9S 2 Inz(0)
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

      //***********************************************************************
      //* Entry Parameters
      //***********************************************************************
      // PrmMode   'A' applies what editors have actioned.
      //           'M' is the monthly run: the same, plus auto-apply for
      //               phase 2 catalogues, plus expiry.
      //           Anything else, or no parameter, behaves as 'A'.
      // PrmCycle  A single cycle YYYYMM, or blank for every open cycle.
      //***********************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PrmMode
     C                   PARM                    PrmCycle

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
      /free

         Exsr Sbr_Init;

         // Everything still open, oldest cycle first so that if two
         // cycles are somehow open for one item the older is settled
         // first.
         //
         // Rejected rows are included while they still hold a CNO. An
         // editor rejecting a suggestion does not release it there,
         // because then three programs would be able to change a CNO;
         // instead the row is picked up here once, the CNO is released,
         // RPCCNOFL goes to 'N' and it drops out of this cursor for good.
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
            WrkNew112 = 0;

            // Read for update. The cursor gave a key rather than the row
            // so the record is locked here and nowhere else.
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

            // Decide what this row is: applied now, expired, or left.
            Select;
            When SUG_RPCSTAT = 'A';
               WrkAction = 'A';
               WrkNew72  = SUG_RPCSUG72;
               WrkNew112 = SUG_RPCSUG112;
            When SUG_RPCSTAT = 'O';
               WrkAction = 'O';
               WrkNew72  = SUG_RPCAPP72;
               WrkNew112 = SUG_RPCAPP112;
            When SUG_RPCSTAT = 'S' And WrkMode = 'M'
                                   And CTL_RPCPHASE = '2';
               WrkAction = 'U';
               WrkNew72  = SUG_RPCSUG72;
               WrkNew112 = SUG_RPCSUG112;
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

            // Anything not being applied is a candidate for expiry, so
            // that an abandoned review cannot hold its CNO for ever.
            If WrkAction = 'X';
               Exsr Sbr_Consider_Expiry;
               Leavesr;
            Endif;

            // The item still has to exist.
            Chain (WrkSugItem) IVPITEMS;
            If Not %Found(IVPITEMS);
               WrkNote = 'ITEM NOT ON IVPITEMS';
               Exsr Sbr_Reject;
               WrkCntNoItem += 1;
               Leavesr;
            Endif;

            // The price the suggestion was worked out from must still be
            // the price on the item. If it is not, somebody has repriced
            // in the meantime and this number is answering a question
            // about a price that no longer exists.
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

            // An override is checked against the guardrails of the rule
            // that produced the suggestion.
            If WrkAction = 'O';
               Exsr Sbr_Check_Override;
               If WrkBreach = 'Y';
                  WrkCntHeld += 1;
                  Leavesr;
               Endif;
            Endif;

            Exsr Sbr_Apply;

            If WrkAction = 'U';
               WrkCntAuto += 1;
            Else;
               WrkCntApplied += 1;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Guardrails on an editor override
      //***********************************************************************
      /free
         Begsr Sbr_Check_Override;

            // The rule that produced the suggestion is read back by the
            // key recorded on it, so an override is judged against the
            // guardrail that was in force when the number was made, not
            // whatever the rule table says today.
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

            // The guardrail is advisory: an editor may go past it, but
            // only on purpose. Accepting the breach is recorded on the
            // suggestion, against the editor who accepted it.
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

            WrkOld72  = ITM_PRICE72;
            WrkOld112 = ITM_PRICE112;

            ITM_PRICE72 = WrkNew72;

            // The second list only moves when the control row says the
            // two move together and the suggestion carried a figure for
            // it. Otherwise it is left exactly as it was.
            If CTL_RPCP112YN = 'Y' And WrkNew112 > 0;
               ITM_PRICE112 = WrkNew112;
            Endif;

            Update IVPITEM$;

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

            Exsr Sbr_Write_Audit;
            Exsr Sbr_Release_CNO;

            SUG_RPCSTAT   = 'X';
            SUG_RPCAPP72  = WrkNew72;
            SUG_RPCAPP112 = ITM_PRICE112;
            SUG_RPCCNOFL  = 'N';
            SUG_RPCACTTS  = %Timestamp();
            If SUG_RPCEDITR = *Blanks;
               SUG_RPCEDITR = WrkUser;
            Endif;
            If WrkAction = 'U';
               SUG_RPCNOTE = 'APPLIED AUTOMATICALLY - PHASE 2';
            Endif;
            Update IV$RPCSUG;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Reject a suggestion that can no longer be applied
      //***********************************************************************
      /free
         Begsr Sbr_Reject;

            // Rejecting releases the CNO. The reason the book was held
            // back has gone away, so holding production back with it
            // would be wrong.
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

            // Cycles are YYYYMM, so compare them as a count of months.
            // Integer divide on purpose: a decimal divide here would
            // put the month count out by the fraction of a year.
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

            // Past its window the suggestion is expired and the CNO
            // released, which also lets the next generator run raise it
            // again - the title is not forgotten, it goes back in the
            // queue with a fresh number.
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
      //* Subroutine: Release the CNO
      //***********************************************************************
      /free
         Begsr Sbr_Release_CNO;

            //-------------------------------------------------------------
            // PROVISIONAL MECHANISM - matches Sbr_Attach_CNO in IVRRPCGEN
            //-------------------------------------------------------------
            // Deleted through SQL rather than by record key, so that no
            // assumption is made about the key order of IVPITMCODE. When
            // the real CNO process is confirmed, this subroutine and
            // RPCCNOCOD are the only things that change.
            //-------------------------------------------------------------
            If CTL_RPCCNOCOD = *Blanks;
               Leavesr;
            Endif;

            Exec SQL
               DELETE FROM IVPITMCODE
                WHERE ITMNUM = :WrkSugItem
                  AND ITMCODE = :CTL_RPCCNOCOD;

            If SqlCod >= 0;
               WrkDel += 1;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Field-level audit row
      //***********************************************************************
      /free
         Begsr Sbr_Write_Maint;

            // FLDNAM has to be one of the names IVRRPCGEN looks for when
            // it works out when a title was last repriced (RPCFLDLST),
            // or this process cannot see its own history.
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
            MNT_COMMENT   = *Blanks;
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
            ORM_ACTION   = 'Reprice applied';
            ORM_DESC     = %Trim(%Char(WrkOld72)) + ' to ' +
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
            Dsply ('CNOs released    : ' + %Char(WrkDel));

         Endsr;
      /end-free
