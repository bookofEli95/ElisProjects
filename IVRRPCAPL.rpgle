     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // IVRRPCAPL
      // IV - Re-run Repricing Apply & Expire
      //**********************************************************************

      //**********************************************************************
      // Program Information
      // ------------------------------------------------------------------
      // Carries out actioned repricing suggestions and releases the CNO.
      // By default an approved price is staged on the re-run queue as
      // IVPORRITM.NEWPRICE, where production already looks for it, rather
      // than written to the item - see Sbr_Apply. This is the only
      // program in the process that writes a price anywhere, so every
      // price movement passes through one place and leaves one trail.
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
     FIVPORRITM UF   E           K DISK    EXTFILE('OBJECT/IVPORRITM')
     F                                     EXTDESC('OBJECT/IVPORRITM')
     F                                     PREFIX(ORR_)
     FNOTEPADI  UF   E           K DISK    EXTFILE('OBJECT/NOTEPADI')
     F                                     EXTDESC('OBJECT/NOTEPADI')
     F                                     PREFIX(NTE_)

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
      // The shared program status data structure - SdsUser and
      // SdsProgram come from here, as in every other program in this
      // library. A hand-rolled structure named SdsUser resolves to
      // positions 1-10, the program name, not the user profile.
      /copy qcopysrc,statusds
      // Price propagation to the related item and every eBook - see
      // Sbr_Apply_Item.
      /copy qcopysrc,ivrudrlitm

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
     D WrkAudAct       S             20A   Inz(*Blanks)
     D WrkStsTok       S             10A   Inz(*Blanks)
     D WrkPrmItm       S              8A   Inz(*Blanks)
     D WrkPrmPrc       S              8A   Inz(*Blanks)
      // The new price in the same type as IVPORRITM.NEWPRICE, so %Char of
      // it is character for character what IVRORRNEWP scans a note for.
      // Formatting it from a field of a different length or scale could
      // produce 13.9900 where the report looks for 13.99, or the reverse,
      // and the report would then print a change the note already covers.
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
            When SUG_RPCSTAT = 'O';
               WrkAction = 'O';
               WrkNew72  = SUG_RPCAPP72;
            When SUG_RPCSTAT = 'S' And WrkMode = 'M'
                                   And CTL_RPCPHASE = '2';
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

            // Anything not being applied is a candidate for expiry, so
            // that an abandoned review cannot hold its CNO for ever.
            If WrkAction = 'X';
               Exsr Sbr_Consider_Expiry;
               Leavesr;
            Endif;

            // The item still has to exist. Read without a lock: only the
            // 'I' apply path writes the item, and it takes its own lock.
            Chain(N) (WrkSugItem) IVPITEMS;
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

            // Where an approved price goes is control data (RPCAPLTGT):
            //
            //   Q  staged on the re-run queue as IVPORRITM.NEWPRICE. This
            //      is the default, and the house process: IVRORRNEWP
            //      treats NEWPRICE as a price change waiting for the new
            //      printing and reports it to production. PRICE72 moves
            //      when the new printing does, through whatever moves it
            //      today - so the system price never runs ahead of the
            //      price printed on the copies still in stock.
            //
            //   I  written straight to IVPITEMS. For a phase in which the
            //      price is no longer printed on the book.
            WrkApplied = 'N';

            If CTL_RPCAPLTGT = 'I';
               Exsr Sbr_Apply_Item;
            Else;
               Exsr Sbr_Stage_Queue;
            Endif;

            If WrkApplied = 'N';
               Leavesr;
            Endif;

            Exsr Sbr_Write_Audit;
            Exsr Sbr_Price_CNO;

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
            When CTL_RPCAPLTGT <> 'I' And WrkAction = 'U';
               SUG_RPCNOTE = 'STAGED AS RE-RUN NEW PRICE - PHASE 2';
            When CTL_RPCAPLTGT <> 'I';
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

            // Read for update: this row is the one being written.
            Chain (WrkSugItem) IVPORRITM;

            // No queue row, so nowhere for a pending price to wait. The
            // row can go between suggestion and approval - IVRORRCLN's
            // satellites show items leave the queue routinely - so this
            // is checked here even though IVRRPCGEN will not raise a
            // suggestion for an item without one.
            If Not %Found(IVPORRITM);
               WrkNote = 'NO RE-RUN QUEUE ROW TO CARRY THE NEW PRICE';
               Exsr Sbr_Reject;
               WrkCntNoQue += 1;
               Leavesr;
            Endif;

            // The title has since been marked not to be reprinted, or
            // taken off the queue. A pending price on a book that is not
            // going to press is noise for production.
            //
            // Matched as a whole token, spaces included, so that a status
            // of 'A' or 'K' cannot match inside *BLANK.
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

            // Somebody has put a different new price on the queue since
            // the suggestion was made. A person's decision stands over
            // this one, so it is not overwritten.
            If ORR_NEWPRICE <> 0 And ORR_NEWPRICE <> SUG_RPCCUR72
               And ORR_NEWPRICE <> WrkNew72;
               Unlock IVPORRITM;
               WrkNote = 'QUEUE ALREADY HAS A NEW PRICE OF ' +
                         %Trim(%Char(ORR_NEWPRICE));
               Exsr Sbr_Reject;
               WrkCntQTaken += 1;
               Leavesr;
            Endif;

            // Only NEWPRICE is written back, so nothing else on a row the
            // production screens are using can be undone.
            ORR_NEWPRICE = WrkNew72;
            Update IV$ORRITM %Fields(ORR_NEWPRICE);

            // No IVPMAINT row here, on purpose: the list price has not
            // moved yet. A 'PRICE72' row now would tell IVRRPCGEN the
            // title had just been repriced, and it would restart the
            // eligibility clock on a price nobody has printed. The row
            // gets written by whatever moves PRICE72 at the new printing.
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

            // PRICE112 takes the same number, not a separately worked
            // out one. IVRMAINT2 sets Itm_PRICE72 and Itm_PRICE112 from
            // the one price an editor types, and IVRPRCUPD does the same
            // from the uploaded MSRP, so they are one price in two
            // fields and must not be allowed to drift apart here.
            If CTL_RPCP112YN = 'Y';
               ITM_PRICE112 = WrkNew72;
            Endif;

            // Only the price fields are written back, the way IVRMAINT2
            // and IVRPRCUPD do it, so a full-record update cannot undo
            // another job's change to an unrelated field.
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

            // The related item and every eBook follow a hardgood's price,
            // and in this library that is IVRUDRLITM's job: IVRMAINT's
            // history reads "Remove Subroutine for eBook price update,
            // now done in IVRUDRLITM". It gives the related item the same
            // price and each eBook the same price - less 20% for an HL
            // digital book - and writes their IVPMAINT rows. Without it
            // the eBooks would keep the old price.
            //
            // If IVPITEMS turns out to carry a trigger that already calls
            // it, this call only adds a duplicate audit row for the
            // related item; eBooks at the right price are left alone.
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

            // The CNO is the NOTEPADI record IVRRPCGEN wrote, whose
            // RCDNBR is kept on the suggestion. It is only deleted while it
            // is still recognisably ours: if an editor has rewritten it
            // and the "(IVRRPC" marker is gone, it has become their note
            // and it stays.
            If SUG_RPCCNORCD = 0;
               SUG_RPCCNOFL = 'N';
               Leavesr;
            Endif;

            Chain (WrkSugItem : SUG_RPCCNORCD) NOTEPADI;
            If %Found(NOTEPADI);
               If %Scan('(IVRRPC' : NTE_NOTE1) > 0;
                  Delete NOTEPAD$;
                  WrkDel += 1;
               Else;
                  Unlock NOTEPADI;
               Endif;
            Endif;

            SUG_RPCCNOFL  = 'N';
            SUG_RPCCNORCD = 0;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Turn the pending CNO into a price CNO
      //***********************************************************************
      /free
         Begsr Sbr_Price_CNO;

            // Once a price is decided, the "review pending" note is
            // rewritten as the note an editor would write by hand: the
            // word PRICE and the new price. That is the form IVRORRNEWP
            // recognises as a change production already knows about
            // (history: "Skip printing price change if correction note
            // was added"), so the item is not reported twice. The note is
            // left in place afterwards, like any other CNO - it is now
            // the instruction for the reprint.
            //
            // No note of ours on the item - the CNO was switched off, or
            // all four note records were taken - means nothing to
            // rewrite. The staged NEWPRICE then puts the item on the
            // Items with New Price report instead, which is the house
            // fallback for a change with no CNO.
            If SUG_RPCCNORCD = 0;
               SUG_RPCCNOFL = 'N';
               Leavesr;
            Endif;

            Chain (WrkSugItem : SUG_RPCCNORCD) NOTEPADI;
            If Not %Found(NOTEPADI);
               SUG_RPCCNOFL  = 'N';
               SUG_RPCCNORCD = 0;
               Leavesr;
            Endif;
            If %Scan('(IVRRPC' : NTE_NOTE1) = 0;
               // An editor has made this note their own. Leave it.
               Unlock NOTEPADI;
               SUG_RPCCNOFL  = 'N';
               SUG_RPCCNORCD = 0;
               Leavesr;
            Endif;

            // The new price is the only number in the note. IVRORRNEWP
            // matches %Char(NEWPRICE) anywhere in the text, so a second
            // number - the old price, say - could later be matched by a
            // different NEWPRICE and hide a real change from production.
            //
            // That scan has one weakness this cannot remove: it matches
            // substrings, so if NEWPRICE is later changed by hand to 3.99
            // the 13.99 in this note still "covers" it. The same is true
            // of every hand-typed CNO. The fix belongs in IVRORRNEWP.
            WrkCnoPrc   = WrkNew72;
            NTE_NOTE1   = 'PRICE CHANGE ON RERUN (IVRRPCAPL) - ' +
                          'NEW PRICE ' + %Trim(%Char(WrkCnoPrc));
            NTE_NOTE2   = *Blanks;
            NTE_CHGTS   = %Timestamp();
            NTE_CHGUSER = WrkUser;
            Update NOTEPAD$;

            SUG_RPCCNOFL = 'Y';
            WrkCntCnoPrc += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Field-level audit row
      //***********************************************************************
      /free
         Begsr Sbr_Write_Maint;

            // FLDNAM has to be one of the names IVRRPCGEN looks for
            // when it works out when a title was last repriced
            // (RPCFLDLST), or this process cannot see its own history.
            // 'PRICE72' and 'PRICE112' are what IVRPRCUPD writes for the
            // same change, so these rows read the same as an upload's.
            //
            // COMMENT carries the program name, which is how IVRPRCUPD
            // and IVRITEMSM4 make an audit row traceable to what wrote
            // it.
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

         Endsr;
      /end-free
