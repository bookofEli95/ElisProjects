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
     FNOTEPADI  UF A E           K DISK    EXTFILE('OBJECT/NOTEPADI')
     F                                     EXTDESC('OBJECT/NOTEPADI')
     F                                     PREFIX(NTE_)
     FMFPUSERS  IF   E           K DISK    EXTFILE('OBJECT/MFPUSERS')
     F                                     EXTDESC('OBJECT/MFPUSERS')
     F                                     PREFIX(USR_)

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

      // One page of the item note pad. A NOTEPADI record is a page, not a
      // note: NOTE1 and NOTE2 together are 13 lines of 34 characters, and
      // one page holds several corrections one after another. This is the
      // same overlay IVRICNO and IVRCNOUPD use (their Tablet structure).
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

            // Every open suggestion gets its correction note (CNO) the
            // first time it passes through here - which, in the monthly
            // job, is minutes after IVRRPCGEN raised it. Held rows get one
            // too: a title waiting on a pricing-authority check is exactly
            // one that must not be reprinted at the old price meanwhile.
            If CTL_RPCCNOYN = 'Y' And SUG_RPCCNOFL <> 'Y'
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
      //* Subroutine: Attach the CNO
      //***********************************************************************
      /free
         Begsr Sbr_Attach_CNO;

            // A correction note (CNO) is written exactly as an editor's is
            // in IVRICNO, and as IVRCNOUPD writes mass corrections: a
            // header line "Correction MM/YY <name>", then body lines of at
            // most 34 characters, placed in the first gap on the first page
            // with room, after one blank separator line. Nothing already on
            // the page moves. Because it is the item's pop-up note pad,
            // anyone who opens the item sees it - which is the alert the
            // release asks for.
            //
            // The second line carries "(IVRRPC)". That marker is how this
            // program finds its own four lines again, and the only lines it
            // will ever change. If an editor removes it, the note is theirs.
            Exsr Sbr_Cno_Find;
            If WrkCnoPg = 0;
               Exsr Sbr_Cno_Gap;
            Endif;

            // No room on any of the four pages. Nobody else's correction is
            // moved to make some. The suggestion goes ahead without one,
            // and once a price is staged IVRORRNEWP reports it to
            // production anyway, since no note carries it.
            If WrkCnoPg = 0 Or WrkCnoLn > 10;
               WrkCntCnoFull += 1;
               Leavesr;
            Endif;

            // No price in these lines, deliberately. IVRORRNEWP treats a
            // change as covered when a note holds the word PRICE and the
            // text of NEWPRICE anywhere in it, so any number here could
            // later match a different NEWPRICE and hide it from production.
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

            // Save the flag now, then take the lock back: every path after
            // this one ends in an Update or an Unlock of the suggestion.
            Update IV$RPCSUG;
            Chain (WrkSugItem : WrkSugCycl) IVPRPCSUG;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Release the CNO
      //***********************************************************************
      /free
         Begsr Sbr_Release_CNO;

            // Blank this process's four lines and nothing else on the page,
            // then tidy up the way IVRICNO does when a note is removed.
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

            // Once a price is decided the same four lines are rewritten as
            // the correction an editor would type: the word PRICE and the
            // new price on one line. That is what IVRORRNEWP recognises as
            // a change production already knows about (history: "Skip
            // printing price change if correction note was added"), so the
            // item is not reported twice. The note then stays, like any
            // other CNO - it is the instruction for the reprint.
            //
            // The price line must not be line 8 of the page: NOTE1 ends
            // part-way through it, and IVRORRNEWP scans NOTE1 and NOTE2
            // separately, so a price split across them would not be found.
            // Sbr_Cno_Gap never places a block that way; one an editor has
            // moved there only costs a duplicate line on that report.
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

            // By its marker line rather than a stored line number, so it is
            // still found if an editor has added or removed lines above it.
            // The header is the line before the marker.
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

            // The first place, page by page, where four lines are free and
            // the line above is blank (or it is the top of the page) - the
            // rule IVRICNO and IVRCNOUPD follow, except that all four lines
            // must actually be free: IVRCNOUPD only checks two at the top
            // of a page and can write over text below them.
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

            // WrkPad still holds the page Sbr_Cno_Find or Sbr_Cno_Gap left
            // it on, with this process's lines changed and nothing else.
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

            // Built exactly as IVRICNO and IVRCNOUPD build it, so a
            // correction from this process reads like anyone else's.
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

            // IVPORRITM.CNO is set to 'M' only if it was blank, as IVRICNO
            // and IVRCNOUPD do. RPCCNOSET records that it was this process
            // that set it, so that it only ever clears a flag it set.
            Chain (WrkSugItem) IVPORRITM;
            If %Found(IVPORRITM);
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

            // IVRICNO's rule when a note is removed: if all four pages are
            // now empty, delete the four records and clear CORRCD;
            // otherwise the item still has corrections and CORRCD stays
            // 'C'. The queue's CNO flag is cleared as well, but only when
            // this process was the one that set it.
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
                  Chain (WrkSugItem) IVPORRITM;
                  If %Found(IVPORRITM);
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
            Dsply ('CNOs attached    : ' + %Char(WrkCntCno));
            Dsply ('CNO pad full     : ' + %Char(WrkCntCnoFull));

         Endsr;
      /end-free
