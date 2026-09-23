     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // IVRRPCGEN
      // IV - Re-run Repricing Suggestion Generator
      //**********************************************************************

      //**********************************************************************
      // Program Information
      // ------------------------------------------------------------------
      // Generates one repricing suggestion per item per cycle for
      // items due for re-run, so an editor approves or overrides a
      // number rather than working one out from a spreadsheet.
      //
      // Nothing here decides pricing policy. The policy lives in
      // IVPRPCRUL as data - one row per catalogue group, price band
      // and last-price-change window - and this program only matches
      // an item to a row and does the arithmetic. Both published
      // models are expressed in that table:
      //
      //   Manual Price Change Brackets ...... RULMODEL B, flat $
      //   Evaluating Bulk Reissue Price Adj .. RULMODEL P, percent
      //
      // A catalogue takes part by having a row in IVPRPCCTL with
      // RPCPHASE 1 or 2. With no row, or phase 0, it is left alone,
      // which is how the rollout is phased without changing code.
      //**********************************************************************

      //**********************************************************************
      // Program History
      // ------------------------------------------------------------------
      // Project   Date     Int Description
      // ------- -------- --- ---------------------------------------------
      // RPCSUG  09/21/26 EFI Create re-run repricing suggestion
      //                      generator
      //**********************************************************************

      // Input Files
     FIVPRPCCTL IF   E           K DISK    EXTFILE('OBJECT/IVPRPCCTL')
     F                                     EXTDESC('OBJECT/IVPRPCCTL')
     F                                     PREFIX(CTL_)
     FIVPRPCRUL IF   E           K DISK    EXTFILE('OBJECT/IVPRPCRUL')
     F                                     EXTDESC('OBJECT/IVPRPCRUL')
     F                                     PREFIX(RUL_)
     FIVPRPCLAD IF   E           K DISK    EXTFILE('OBJECT/IVPRPCLAD')
     F                                     EXTDESC('OBJECT/IVPRPCLAD')
     F                                     PREFIX(LAD_)
     FIVPITEMS  IF   E           K DISK    EXTFILE('OBJECT/IVPITEMS')
     F                                     EXTDESC('OBJECT/IVPITEMS')
     F                                     PREFIX(ITM_)
     FIVPORRITM IF   E           K DISK    EXTFILE('OBJECT/IVPORRITM')
     F                                     EXTDESC('OBJECT/IVPORRITM')
     F                                     PREFIX(ORR_)

      // Update / Add Files
     FIVPRPCSUG UF A E           K DISK    EXTFILE('OBJECT/IVPRPCSUG')
     F                                     EXTDESC('OBJECT/IVPRPCSUG')
     F                                     PREFIX(SUG_)

      // Output Files
     FIVPITMCODEO    E           K DISK    EXTFILE('OBJECT/IVPITMCODE')
     F                                     EXTDESC('OBJECT/IVPITMCODE')
     F                                     PREFIX(COD_)
     FIVPORRMNT O    E           K DISK    EXTFILE('OBJECT/IVPORRMNT')
     F                                     EXTDESC('OBJECT/IVPORRMNT')
     F                                     PREFIX(ORM_)

      //**********************************************************************
      // Data Structures & Variables
      //**********************************************************************
      // The shared program status data structure, which is where every
      // other program in this library gets SdsUser and SdsProgram from.
      // Declaring one here by hand is how you end up writing the program
      // name into MAINTWHO: naming the structure SdsUser makes the name
      // resolve to positions 1-10, not the user profile at 254-263.
      /copy qcopysrc,statusds

      // Entry parameters
     D PrmCycle        S              6A
     D PrmDivcat       S              7A
     D PrmMode         S              1A

      // The rule table is small and is read once into memory, so a
      // run does no I/O per item against it. Parallel arrays rather
      // than a qualified data structure, to match the rest of this
      // source.
     D WrkMaxRul       C                   Const(300)
     D WrkMaxLad       C                   Const(200)
     D RulCatg         S              5A   Dim(WrkMaxRul)
     D RulModel        S              1A   Dim(WrkMaxRul)
     D RulScen         S              1A   Dim(WrkMaxRul)
     D RulSeq          S              3S 0 Dim(WrkMaxRul)
     D RulPrcFr        S              9S 2 Dim(WrkMaxRul)
     D RulPrcTo        S              9S 2 Dim(WrkMaxRul)
     D RulChgFr        S               D   Dim(WrkMaxRul)
     D RulChgTo        S               D   Dim(WrkMaxRul)
     D RulUplAmt       S              9S 2 Dim(WrkMaxRul)
     D RulUplPct       S              5S 2 Dim(WrkMaxRul)
     D RulMinAmt       S              9S 2 Dim(WrkMaxRul)
     D RulCapPct       S              5S 2 Dim(WrkMaxRul)
     D RulCapAmt       S              9S 2 Dim(WrkMaxRul)
     D RulFlr          S              9S 2 Dim(WrkMaxRul)
     D RulExcl         S              9S 2 Dim(WrkMaxRul)
     D RulRnd          S              4A   Dim(WrkMaxRul)
     D RulDisp         S             10A   Dim(WrkMaxRul)
     D RulText         S             30A   Dim(WrkMaxRul)
     D RulCnt          S              5S 0 Inz(0)

     D LadCatg         S              5A   Dim(WrkMaxLad)
     D LadPrice        S              9S 2 Dim(WrkMaxLad)
     D LadCnt          S              5S 0 Inz(0)

      // Candidate row fetched from the cursor
     D WrkCndItem      S              8S 0 Inz(0)
     D WrkCndDue8      S              8S 0 Inz(0)
     D WrkCndJob       S              7S 0 Inz(0)

      // Selection settings taken from the default control row
     D WrkStsChk       S              1A   Inz('N')
     D WrkStsPad       S             22A   Inz(*Blanks)
     D WrkExcChk       S              1A   Inz('N')
     D WrkExcPad       S             22A   Inz(*Blanks)
     D WrkFldPad       S             62A   Inz(*Blanks)
     D WrkHoriz8       S              8S 0 Inz(0)
     D WrkFrom8        S              8S 0 Inz(0)
     D WrkDftHoriz     S              3S 0 Inz(6)

      // Working values for the item in hand
     D WrkCycle        S              6S 0 Inz(0)
     D WrkSelDivcat    S              7S 0 Inz(0)
     D WrkSelAll       S              1A   Inz('Y')
     D WrkToday        S               D
     D WrkDueDt        S               D
     D WrkFromDt       S               D
     D WrkLstChg       S               D
     D WrkLstChg8      S              8S 0 Inz(0)
     D WrkHorizDt      S               D
     D WrkBasePrc      S              9S 2 Inz(0)
     D WrkNewPrc       S              9S 2 Inz(0)
     D WrkRaw          S             13S 4 Inz(0)
     D WrkCapVal       S             13S 4 Inz(0)
     D WrkTgt          S             13S 4 Inz(0)
     D WrkLow          S             13S 4 Inz(0)
     D WrkHigh         S             13S 4 Inz(0)
     D WrkWhole        S             11S 0 Inz(0)
     D WrkSug72        S              9S 2 Inz(0)
     D WrkSug112       S              9S 2 Inz(0)
     D WrkCapFl        S              1A   Inz('N')
     D WrkFlrFl        S              1A   Inz('N')
     D WrkAuthHld      S              1A   Inz('N')
     D WrkRulIdx       S              5S 0 Inz(0)
     D WrkIdx          S              5S 0 Inz(0)
     D WrkCount        S             10I 0 Inz(0)
     D WrkOpen         S             10I 0 Inz(0)
     D WrkPhase        S              1A   Inz(*Blanks)
     D WrkNote         S             60A   Inz(*Blanks)
     D WrkCnoFl        S              1A   Inz('N')
     D WrkMode         S              1A   Inz('P')
     D WrkUser         S             10A   Inz(*Blanks)

      // Run counters, reported to the job log at end of run
     D WrkCntRead      S             10I 0 Inz(0)
     D WrkCntNoItem    S             10I 0 Inz(0)
     D WrkCntNoCtl     S             10I 0 Inz(0)
     D WrkCntPhase     S             10I 0 Inz(0)
     D WrkCntNoGrp     S             10I 0 Inz(0)
     D WrkCntNoPrc     S             10I 0 Inz(0)
     D WrkCntHoriz     S             10I 0 Inz(0)
     D WrkCntFresh     S             10I 0 Inz(0)
     D WrkCntDup       S             10I 0 Inz(0)
     D WrkCntNoRule    S             10I 0 Inz(0)
     D WrkCntExcl      S             10I 0 Inz(0)
     D WrkCntNoRise    S             10I 0 Inz(0)
     D WrkCntAuth      S             10I 0 Inz(0)
     D WrkCntWrote     S             10I 0 Inz(0)
     D WrkCntCno       S             10I 0 Inz(0)
     D WrkCntQNew      S             10I 0 Inz(0)
     D WrkCntNoQue     S             10I 0 Inz(0)
     D WrkQueRow       S              1A   Inz('N')

      //***********************************************************************
      //* Entry Parameters
      //***********************************************************************
      // PrmCycle   YYYYMM to generate for. Blank means the current month.
      // PrmDivcat  A single catalogue, or blank / *ALL for every one.
      // PrmMode    'R' reports what it would do and writes nothing.
      //            Anything else generates.
      //
      // All three are optional. %Parms is checked before any of them is
      // referenced, because an unpassed parameter has no storage behind it.
      //***********************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PrmCycle
     C                   PARM                    PrmDivcat
     C                   PARM                    PrmMode

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
      /free

         Exsr Sbr_Init;
         Exsr Sbr_Load_Rules;
         Exsr Sbr_Load_Ladder;

         // Candidates are the items due for re-run inside the horizon,
         // taken from both places AS400 records one, with the earlier of
         // the two dates winning:
         //
         //   IVPORRITM  the online re-run queue. The date is ESTBODT,
         //              the estimated back-order date the Min Qty
         //              Online report prints (IVRORRIVP2) - a forecast of
         //              when stock runs out, which is what the pricing
         //              documents mean by due ("stock depletes ... within
         //              6 months"). MINQTYDT, the date stock reached its
         //              minimum, is only the fallback: it is almost
         //              always already past for anything in the queue,
         //              so on its own it cannot tell 1 month from 12.
         //              A past date means more due, not less, so no
         //              lower bound is applied on this side.
         //
         //              RERUNSTS is matched with a blank written as
         //              *BLANK, because the Min Qty Online population -
         //              the earliest point a title can be priced - is
         //              exactly the rows with a blank status.
         //
         //   RERUN8     the planned production finish date. Completed
         //              jobs keep their old dates, so this side is
         //              bounded by WrkFrom8 to keep history out.
         Exec SQL
            DECLARE CsrCand CURSOR FOR
               SELECT CND.ITMNUM, MIN(CND.DUE8), MAX(CND.JOB7)
                 FROM ( SELECT O.ITMNUM AS ITMNUM,
                               CASE WHEN O.ESTBODT IS NOT NULL
                                     AND O.ESTBODT > DATE('0001-01-01')
                                    THEN YEAR(O.ESTBODT) * 10000
                                       + MONTH(O.ESTBODT) * 100
                                       + DAY(O.ESTBODT)
                                    ELSE YEAR(O.MINQTYDT) * 10000
                                       + MONTH(O.MINQTYDT) * 100
                                       + DAY(O.MINQTYDT)
                               END AS DUE8,
                               O.JOBNUM7 AS JOB7
                          FROM IVPORRITM O
                         WHERE O."HOLD" = ' '
                           AND ( :WrkStsChk = 'N'
                              OR LOCATE(' ' CONCAT
                                   CASE WHEN O.RERUNSTS = ' '
                                        THEN '*BLANK'
                                        ELSE TRIM(O.RERUNSTS) END
                                   CONCAT ' ', :WrkStsPad) > 0 )
                           AND ( :WrkExcChk = 'N'
                              OR LOCATE(' ' CONCAT
                                   CASE WHEN O.RERUNSTS = ' '
                                        THEN '*BLANK'
                                        ELSE TRIM(O.RERUNSTS) END
                                   CONCAT ' ', :WrkExcPad) = 0 )
                        UNION ALL
                        SELECT R.ITEM# AS ITMNUM,
                               R.FINISHYYYY * 10000
                             + R.FINISHMM * 100
                             + R.FINISHDD AS DUE8,
                               R.JOBNUM7 AS JOB7
                          FROM RERUN8 R
                         WHERE R."DELETE" = ' '
                           AND R.FINISHYYYY >= 1900
                           AND R.FINISHMM BETWEEN 1 AND 12
                           AND R.FINISHDD BETWEEN 1 AND 31
                           AND R.FINISHYYYY * 10000
                             + R.FINISHMM * 100
                             + R.FINISHDD >= :WrkFrom8
                      ) AS CND
                WHERE CND.DUE8 <= :WrkHoriz8
                GROUP BY CND.ITMNUM
                ORDER BY 1;

         Exec SQL OPEN CsrCand;
         If SqlCod < 0;
            Dsply 'Could not open the candidate cursor.';
            *InLr = *On;
            Return;
         Endif;

         Exec SQL FETCH CsrCand
                    INTO :WrkCndItem, :WrkCndDue8, :WrkCndJob;
         Dow SqlCod = 0;

            WrkCntRead += 1;
            Exsr Sbr_Process_Item;

            Exec SQL FETCH CsrCand
                       INTO :WrkCndItem, :WrkCndDue8, :WrkCndJob;
         Enddo;

         Exec SQL CLOSE CsrCand;

         Exsr Sbr_Report;

         *InLr = *On;

      /end-free

      //***********************************************************************
      //* Subroutine: Run settings, cycle and horizon
      //***********************************************************************
      /free
         Begsr Sbr_Init;

            WrkToday = %Date();
            WrkUser  = SdsUser;
            If WrkUser = *Blanks;
               WrkUser = 'REPRICE';
            Endif;

            // Cycle to generate for, from the parameter or this month.
            WrkCycle = 0;
            If %Parms >= 1 And PrmCycle <> *Blanks;
               Monitor;
                  WrkCycle = %Int(PrmCycle);
               On-Error;
                  WrkCycle = 0;
               Endmon;
            Endif;
            If WrkCycle = 0;
               WrkCycle = (%Subdt(WrkToday : *Y) * 100)
                        + %Subdt(WrkToday : *M);
            Endif;

            // Catalogue filter.
            WrkSelAll = 'Y';
            If %Parms >= 2 And PrmDivcat <> *Blanks
                          And %Trim(PrmDivcat) <> '*ALL';
               Monitor;
                  WrkSelDivcat = %Int(PrmDivcat);
                  WrkSelAll    = 'N';
               On-Error;
                  WrkSelAll    = 'Y';
               Endmon;
            Endif;

            // Report-only mode.
            WrkMode = 'P';
            If %Parms >= 3;
               If PrmMode = 'R';
                  WrkMode = 'R';
               Endif;
            Endif;

            // The default control row carries everything needed before a
            // catalogue is known. Without it there is nothing to run on.
            Chain (0) IVPRPCCTL;
            If Not %Found(IVPRPCCTL);
               Dsply 'IVPRPCCTL row for DIVCAT 0 is missing.';
               *InLr = *On;
               Return;
            Endif;

            // Re-run statuses to select on. Blank means no filter, which
            // is wider than the internal approval queue the Redash report
            // shows - safe only while catalogues are still at phase 0.
            If %Trim(CTL_RPCSTSLST) = *Blanks;
               WrkStsChk = 'N';
               WrkStsPad = *Blanks;
            Else;
               WrkStsChk = 'Y';
               WrkStsPad = ' ' + %Trim(CTL_RPCSTSLST) + ' ';
            Endif;

            // IVPMAINT field names that count as a price change, padded
            // so they can be matched as whole tokens.
            // Statuses that mean the item is not in the online re-run
            // queue at all. RERUNSTS 'J' is one: IVRMAINT sets it, with
            // a blank Hold, to take an item off the queue. Excluding it
            // matters most while the inclusion list is still blank.
            If %Trim(CTL_RPCSTSEXC) = *Blanks;
               WrkExcChk = 'N';
               WrkExcPad = *Blanks;
            Else;
               WrkExcChk = 'Y';
               WrkExcPad = ' ' + %Trim(CTL_RPCSTSEXC) + ' ';
            Endif;

            WrkFldPad = ' ' + %Trim(CTL_RPCFLDLST) + ' ';

            // Candidate window. The widest horizon of any catalogue would
            // be the strictly correct bound here; the default row's
            // horizon is used to keep the cursor simple, and each item is
            // re-checked against its own catalogue's horizon later.
            WrkDftHoriz = CTL_RPCHORIZ;
            If WrkDftHoriz <= 0;
               WrkDftHoriz = 6;
            Endif;
            WrkHorizDt = WrkToday + %Months(WrkDftHoriz);
            WrkHoriz8  = (%Subdt(WrkHorizDt : *Y) * 10000)
                       + (%Subdt(WrkHorizDt : *M) * 100)
                       + %Subdt(WrkHorizDt : *D);

            // Look-back for planned re-run dates that have just passed.
            WrkFromDt = WrkToday - %Days(30);
            WrkFrom8  = (%Subdt(WrkFromDt : *Y) * 10000)
                      + (%Subdt(WrkFromDt : *M) * 100)
                      + %Subdt(WrkFromDt : *D);

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Load the rule table into memory
      //***********************************************************************
      /free
         Begsr Sbr_Load_Rules;

            RulCnt = 0;
            Setll *Loval IVPRPCRUL;
            Read IVPRPCRUL;
            Dow Not %Eof(IVPRPCRUL) And RulCnt < WrkMaxRul;
               RulCnt += 1;
               RulCatg(RulCnt)   = RUL_RULCATG;
               RulModel(RulCnt)  = RUL_RULMODEL;
               RulScen(RulCnt)   = RUL_RULSCEN;
               RulSeq(RulCnt)    = RUL_RULSEQ;
               RulPrcFr(RulCnt)  = RUL_RULPRCFR;
               RulPrcTo(RulCnt)  = RUL_RULPRCTO;
               RulChgFr(RulCnt)  = RUL_RULCHGFR;
               RulChgTo(RulCnt)  = RUL_RULCHGTO;
               RulUplAmt(RulCnt) = RUL_RULUPLAMT;
               RulUplPct(RulCnt) = RUL_RULUPLPCT;
               RulMinAmt(RulCnt) = RUL_RULMINAMT;
               RulCapPct(RulCnt) = RUL_RULCAPPCT;
               RulCapAmt(RulCnt) = RUL_RULCAPAMT;
               RulFlr(RulCnt)    = RUL_RULFLOOR;
               RulExcl(RulCnt)   = RUL_RULEXCLMN;
               RulRnd(RulCnt)    = RUL_RULROUND;
               RulDisp(RulCnt)   = RUL_RULDISP;
               RulText(RulCnt)   = RUL_RULTEXT;
               Read IVPRPCRUL;
            Enddo;

            If RulCnt = 0;
               Dsply 'IVPRPCRUL is empty - no pricing rules loaded.';
            Endif;
            If RulCnt >= WrkMaxRul;
               Dsply 'IVPRPCRUL is larger than WrkMaxRul - truncated.';
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Load the price ladder into memory
      //***********************************************************************
      /free
         Begsr Sbr_Load_Ladder;

            LadCnt = 0;
            Setll *Loval IVPRPCLAD;
            Read IVPRPCLAD;
            Dow Not %Eof(IVPRPCLAD) And LadCnt < WrkMaxLad;
               LadCnt += 1;
               LadCatg(LadCnt)  = LAD_LADCATG;
               LadPrice(LadCnt) = LAD_LADPRICE;
               Read IVPRPCLAD;
            Enddo;

            If LadCnt >= WrkMaxLad;
               Dsply 'IVPRPCLAD is larger than WrkMaxLad - truncated.';
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Consider one candidate item
      //***********************************************************************
      /free
         Begsr Sbr_Process_Item;

            WrkCapFl   = 'N';
            WrkFlrFl   = 'N';
            WrkAuthHld = 'N';
            WrkCnoFl   = 'N';
            WrkNote    = *Blanks;

            // 1. Item master
            Chain (WrkCndItem) IVPITEMS;
            If Not %Found(IVPITEMS);
               WrkCntNoItem += 1;
               Leavesr;
            Endif;

            // 2. Catalogue filter from the parameter
            If WrkSelAll = 'N' And ITM_DIVCAT <> WrkSelDivcat;
               Leavesr;
            Endif;

            // 2b. Somebody has already priced this re-run by hand. A
            //     NEWPRICE on the queue row that differs from PRICE72 is
            //     a price change waiting for the new printing - it is
            //     exactly what IVRORRNEWP reports to production - so a
            //     suggestion now would ask an editor to redo a decision
            //     already made, or worse, overwrite it on approval.
            Chain (WrkCndItem) IVPORRITM;
            WrkQueRow = 'N';
            If %Found(IVPORRITM);
               WrkQueRow = 'Y';
            Endif;
            If WrkQueRow = 'Y' And ORR_NEWPRICE <> 0
               And ORR_NEWPRICE <> ITM_PRICE72;
               WrkCntQNew += 1;
               Leavesr;
            Endif;

            // 3. This catalogue's control row, falling back to the
            //    default row so an unlisted catalogue is still governed
            //    rather than silently taking part.
            Chain (ITM_DIVCAT) IVPRPCCTL;
            If Not %Found(IVPRPCCTL);
               Chain (0) IVPRPCCTL;
               If Not %Found(IVPRPCCTL);
                  WrkCntNoCtl += 1;
                  Leavesr;
               Endif;
            Endif;

            // 3b. When approved prices are staged on the re-run queue
            //     (RPCAPLTGT 'Q'), a title with no queue row - one that
            //     came from RERUN8 alone - has nowhere for its price to
            //     wait, so a suggestion would be a dead end at approval.
            //     RERUN8 still earns its place: for a title on both, its
            //     date can be the earlier.
            If CTL_RPCAPLTGT <> 'I' And WrkQueRow = 'N';
               WrkCntNoQue += 1;
               Leavesr;
            Endif;

            // 4. Phase 0, or anything unrecognised, is out of scope
            WrkPhase = CTL_RPCPHASE;
            If WrkPhase <> '1' And WrkPhase <> '2';
               WrkCntPhase += 1;
               Leavesr;
            Endif;

            // 5. The catalogue has to be mapped to a rule group before
            //    any rule can be found for it
            If CTL_RPCCATG = *Blanks;
               WrkCntNoGrp += 1;
               Leavesr;
            Endif;

            // 6. Price to work from
            WrkBasePrc = ITM_PRICE72;
            If WrkBasePrc <= 0;
               WrkCntNoPrc += 1;
               Leavesr;
            Endif;

            // 7. Due date, re-checked against this catalogue's own
            //    horizon, which may be shorter than the default one the
            //    cursor selected on
            Monitor;
               WrkDueDt = %Date(WrkCndDue8 : *ISO);
            On-Error;
               WrkCntHoriz += 1;
               Leavesr;
            Endmon;
            If CTL_RPCHORIZ > 0
               And WrkDueDt > WrkToday + %Months(CTL_RPCHORIZ);
               WrkCntHoriz += 1;
               Leavesr;
            Endif;

            // 8. Last price change, then the eligibility gate: a title
            //    repriced recently is left alone
            Exsr Sbr_Last_Price_Change;
            If CTL_RPCELGMO > 0
               And %Diff(WrkToday : WrkLstChg : *Months) < CTL_RPCELGMO;
               WrkCntFresh += 1;
               Leavesr;
            Endif;

            // 9. Never suggest twice for the same item in one cycle, and
            //    never while an earlier suggestion is still open - the
            //    editor would be asked the same question twice and the
            //    CNO would be attached twice
            Chain(N) (WrkCndItem : WrkCycle) IVPRPCSUG;
            If %Found(IVPRPCSUG);
               WrkCntDup += 1;
               Leavesr;
            Endif;

            WrkOpen = 0;
            Exec SQL
               SELECT COUNT(*) INTO :WrkOpen
                 FROM IVPRPCSUG
                WHERE ITMNUM = :WrkCndItem
                  AND RPCSTAT IN ('S', 'A', 'O', 'G');
            If WrkOpen > 0;
               WrkCntDup += 1;
               Leavesr;
            Endif;

            // 10. Pricing authority. A title we may not be free to
            //     reprice under a third party agreement is either held
            //     for review or passed over, per the control row.
            If CTL_RPCAUTCOD <> *Blanks;
               Exsr Sbr_Check_Authority;
               If WrkAuthHld = 'S';
                  WrkCntAuth += 1;
                  Leavesr;
               Endif;
            Endif;

            // 11. Match a rule, then do the arithmetic
            Exsr Sbr_Match_Rule;
            If WrkRulIdx = 0;
               WrkCntNoRule += 1;
               Leavesr;
            Endif;

            If RulExcl(WrkRulIdx) > 0
               And WrkBasePrc < RulExcl(WrkRulIdx);
               WrkCntExcl += 1;
               Leavesr;
            Endif;

            Exsr Sbr_Compute_Price;
            WrkSug72 = WrkNewPrc;

            If WrkSug72 <= WrkBasePrc;
               WrkCntNoRise += 1;
               Leavesr;
            Endif;

            // PRICE112 is not a second price to work out - it is the
            // same price in a second field. Both programs that change a
            // list price set them together from one number: IVRMAINT2
            // does Itm_PRICE72 = Itm_PRICE112 = the entered price, and
            // IVRPRCUPD does the same from the uploaded MSRP. The
            // suggestion follows that rather than repricing 112 on its
            // own, which would drift the two apart.
            WrkSug112 = 0;
            If CTL_RPCP112YN = 'Y';
               WrkSug112 = WrkSug72;
            Endif;

            // 12. A report-only run stops here having written nothing
            If WrkMode = 'R';
               WrkCntWrote += 1;
               Leavesr;
            Endif;

            // The CNO goes on before the suggestion is written, so the
            // suggestion records truthfully whether the item is flagged.
            If CTL_RPCCNOYN = 'Y' And CTL_RPCCNOCOD <> *Blanks;
               Exsr Sbr_Attach_CNO;
            Endif;

            Exsr Sbr_Write_Suggestion;
            WrkCntWrote += 1;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Date of the last price change
      //***********************************************************************
      /free
         Begsr Sbr_Last_Price_Change;

            // The price history is the field-level audit in IVPMAINT.
            // Which FLDNAM values count as a price change is control
            // data, matched as whole tokens so that PRICE72 cannot match
            // inside PRICE112 by accident.
            //
            // Three spellings are in use for one event, so all three
            // have to be in RPCFLDLST:
            //   IVRMAINT   writes 'PRICE '  on a list price change
            //   IVRMAINT2  writes 'PRICE72'
            //   IVRPRCUPD  writes 'PRICE72' and 'PRICE112'
            // Matching is case-insensitive because the same library
            // writes both 'HLCOST' and 'HLCost' for one field.
            //
            // MAPPRICE and REFPRICE are deliberately not in that list:
            // they are the reference price on IVPREFPRC, not the list
            // price, so changing one does not reset this clock.
            WrkLstChg8 = 0;
            Exec SQL
               SELECT COALESCE(MAX(MAINTYYYY * 10000
                                 + MAINTMM * 100
                                 + MAINTDD), 0)
                 INTO :WrkLstChg8
                 FROM IVPMAINT
                WHERE ITMNUM = :WrkCndItem
                  AND MAINTYYYY >= 1900
                  AND MAINTMM BETWEEN 1 AND 12
                  AND MAINTDD BETWEEN 1 AND 31
                  AND LOCATE(' ' CONCAT UPPER(TRIM(FLDNAM)) CONCAT ' ',
                             UPPER(:WrkFldPad)) > 0;

            // No audit row means the item has either never been repriced
            // or was repriced before the retention IVPMAINT keeps. Both
            // land on RPCNOCHDT, which has to sit inside the oldest rule
            // window, so such a title is treated as the most eroded.
            WrkLstChg = CTL_RPCNOCHDT;
            If WrkLstChg8 > 0;
               Monitor;
                  WrkLstChg = %Date(WrkLstChg8 : *ISO);
               On-Error;
                  WrkLstChg = CTL_RPCNOCHDT;
               Endmon;
            Endif;
            If WrkLstChg = *Loval;
               WrkLstChg = %Date('1900-01-01' : *ISO);
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Pricing authority check
      //***********************************************************************
      /free
         Begsr Sbr_Check_Authority;

            // Which marker identifies a title whose price we are not
            // free to raise is control data (RPCAUTCOD), because the
            // field that carries it in AS400 is not yet confirmed. An
            // item code is used as the hook since that is the only
            // per-item marker of this kind in use. Blank disables the
            // check, and RPCAUTACT decides between passing the title
            // over ('S') and holding a suggestion for review ('H').
            WrkCount = 0;
            Exec SQL
               SELECT COUNT(*) INTO :WrkCount
                 FROM IVPITMCODE
                WHERE ITMNUM = :WrkCndItem
                  AND ITMCODE = :CTL_RPCAUTCOD;

            If WrkCount > 0;
               If CTL_RPCAUTACT = 'S';
                  WrkAuthHld = 'S';
               Else;
                  WrkAuthHld = 'H';
               Endif;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Find the rule that covers this item
      //***********************************************************************
      /free
         Begsr Sbr_Match_Rule;

            // The first row whose price band and last-change window both
            // contain the item wins. The table was read in key order, so
            // RULSEQ decides precedence wherever bands overlap.
            WrkRulIdx = 0;
            For WrkIdx = 1 To RulCnt;
               If RulCatg(WrkIdx)   = CTL_RPCCATG
              And RulModel(WrkIdx)  = CTL_RPCMODEL
              And RulScen(WrkIdx)   = CTL_RPCSCEN
              And WrkBasePrc       >= RulPrcFr(WrkIdx)
              And WrkBasePrc       <= RulPrcTo(WrkIdx)
              And WrkLstChg        >= RulChgFr(WrkIdx)
              And WrkLstChg        <= RulChgTo(WrkIdx);
                  WrkRulIdx = WrkIdx;
                  Leave;
               Endif;
            Endfor;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Work out the suggested price
      //***********************************************************************
      /free
         Begsr Sbr_Compute_Price;

            // Order of operations, taken from the source documents:
            //   1. raw = price + flat uplift, or price * (1 + percent)
            //   2. minimum rise applied           ("min $1.50")
            //   3. rise capped by percent, then by amount
            //                                     ("+18%", "cap $10")
            //   4. rounded - nearest .99, or on to a ladder rung
            //   5. budget floor re-asserted last, because the source
            //      states the budget floor overrides the hard cap
            WrkNewPrc = WrkBasePrc;

            If RulRnd(WrkRulIdx) = 'LADR';
               Exsr Sbr_Ladder_Price;
            Else;
               If RulUplAmt(WrkRulIdx) <> 0;
                  WrkRaw = WrkBasePrc + RulUplAmt(WrkRulIdx);
               Else;
                  Eval(H) WrkRaw = WrkBasePrc
                                 * (1 + (RulUplPct(WrkRulIdx) / 100));
               Endif;

               If RulMinAmt(WrkRulIdx) > 0
                  And (WrkRaw - WrkBasePrc) < RulMinAmt(WrkRulIdx);
                  WrkRaw = WrkBasePrc + RulMinAmt(WrkRulIdx);
               Endif;

               If RulCapPct(WrkRulIdx) > 0;
                  Eval(H) WrkCapVal = WrkBasePrc
                                * (1 + (RulCapPct(WrkRulIdx) / 100));
                  If WrkRaw > WrkCapVal;
                     WrkRaw   = WrkCapVal;
                     WrkCapFl = 'Y';
                  Endif;
               Endif;

               If RulCapAmt(WrkRulIdx) > 0
                  And (WrkRaw - WrkBasePrc) > RulCapAmt(WrkRulIdx);
                  WrkRaw   = WrkBasePrc + RulCapAmt(WrkRulIdx);
                  WrkCapFl = 'Y';
               Endif;

               If RulRnd(WrkRulIdx) = '99';
                  Exsr Sbr_Round_99;
               Else;
                  Eval(H) WrkNewPrc = WrkRaw;
               Endif;
            Endif;

            If RulFlr(WrkRulIdx) > 0 And WrkNewPrc < RulFlr(WrkRulIdx);
               WrkNewPrc = RulFlr(WrkRulIdx);
               WrkFlrFl  = 'Y';
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Snap to the nearest price ending .99
      //***********************************************************************
      /free
         Begsr Sbr_Round_99;

            // An exact midpoint rounds up. This is a price rise, and
            // rounding a tie down can cancel out the minimum rise the
            // rule has just applied.
            WrkWhole = %Int(WrkRaw);
            WrkLow   = WrkWhole + 0.99;
            If WrkLow > WrkRaw;
               WrkLow -= 1;
            Endif;
            WrkHigh = WrkLow + 1;

            If (WrkRaw - WrkLow) < (WrkHigh - WrkRaw);
               WrkNewPrc = WrkLow;
            Else;
               WrkNewPrc = WrkHigh;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Step up the price ladder
      //***********************************************************************
      /free
         Begsr Sbr_Ladder_Price;

            // A laddered band moves to the first rung at or above the
            // rule percentage, which is how the Choral octavo bands are
            // written ("ladder step >= +6%") rather than as a percentage
            // to two decimal places.
            //
            // If the next rung would break the cap, no suggestion is
            // made at all: a capped price that is not a rung would
            // defeat the point of a ladder, so the decision goes to the
            // editor instead.
            Eval(H) WrkTgt = WrkBasePrc
                           * (1 + (RulUplPct(WrkRulIdx) / 100));

            WrkNewPrc = WrkBasePrc;
            For WrkIdx = 1 To LadCnt;
               If LadCatg(WrkIdx)   = CTL_RPCCATG
              And LadPrice(WrkIdx) >= WrkTgt;
                  WrkNewPrc = LadPrice(WrkIdx);
                  Leave;
               Endif;
            Endfor;

            If RulCapPct(WrkRulIdx) > 0;
               Eval(H) WrkCapVal = WrkBasePrc
                             * (1 + (RulCapPct(WrkRulIdx) / 100));
               If WrkNewPrc > WrkCapVal;
                  WrkNewPrc = WrkBasePrc;
                  WrkCapFl  = 'Y';
               Endif;
            Endif;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Attach the CNO to a re-run candidate
      //***********************************************************************
      /free
         Begsr Sbr_Attach_CNO;

            //-------------------------------------------------------------
            // WRONG TARGET - SWITCHED OFF BY THE SEED (RPCCNOYN 'N')
            //-------------------------------------------------------------
            // This writes an item code to IVPITMCODE. IVRORRNEWP shows
            // that is not what a CNO is: a correction note is a record on
            // NOTEPADI, up to four per item keyed on item and RCDNBR,
            // with the text in NOTE1 and NOTE2. A price CNO is one whose
            // text holds the word PRICE and the new price, which is how
            // IVRORRNEWP decides a price change is already covered.
            //
            // Repointing this at NOTEPADI needs that file's field list:
            // no program read so far names its item field or its record
            // format, and guessing either would write bad notes to a file
            // production reads. Until then the seed keeps this off.
            //
            // What it is for is unchanged: an item with a repricing
            // review open must not be reprinted at the old price.
            // IVRRPCAPL releases it again when the suggestion is applied,
            // rejected or expired.
            //-------------------------------------------------------------
            WrkCount = 0;
            Exec SQL
               SELECT COUNT(*) INTO :WrkCount
                 FROM IVPITMCODE
                WHERE ITMNUM = :WrkCndItem
                  AND ITMCODE = :CTL_RPCCNOCOD;

            If WrkCount = 0;
               Clear IV$ITMCODE;
               COD_ITMNUM  = WrkCndItem;
               COD_ITMCODE = CTL_RPCCNOCOD;
               Write IV$ITMCODE;
               WrkCntCno += 1;
            Endif;
            WrkCnoFl = 'Y';

            Exsr Sbr_Write_Audit;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Write the suggestion
      //***********************************************************************
      /free
         Begsr Sbr_Write_Suggestion;

            Clear IV$RPCSUG;
            SUG_ITMNUM    = WrkCndItem;
            SUG_RPCCYCL   = WrkCycle;
            SUG_DIVCAT    = ITM_DIVCAT;
            SUG_RPCCATG   = CTL_RPCCATG;
            SUG_RPCPHASE  = WrkPhase;
            SUG_RPCMODEL  = CTL_RPCMODEL;
            SUG_RPCSCEN   = CTL_RPCSCEN;
            SUG_RPCRULSEQ = RulSeq(WrkRulIdx);
            SUG_RPCCUR72  = ITM_PRICE72;
            SUG_RPCCUR112 = ITM_PRICE112;
            SUG_RPCSUG72  = WrkSug72;
            SUG_RPCSUG112 = WrkSug112;
            SUG_RPCAPP72  = 0;
            SUG_RPCAPP112 = 0;
            SUG_RPCUPLAMT = WrkSug72 - ITM_PRICE72;

            If ITM_PRICE72 > 0;
               Eval(H) SUG_RPCUPLPCT = ((WrkSug72 - ITM_PRICE72)
                                     / ITM_PRICE72) * 100;
            Else;
               SUG_RPCUPLPCT = 0;
            Endif;

            SUG_RPCROUND  = RulRnd(WrkRulIdx);
            SUG_RPCCAPFL  = WrkCapFl;
            SUG_RPCFLRFL  = WrkFlrFl;
            SUG_RPCDISP   = RulDisp(WrkRulIdx);
            SUG_RPCLSTCHG = WrkLstChg;
            SUG_RPCDUEDT  = WrkDueDt;
            SUG_RPCJOB7   = WrkCndJob;
            SUG_RPCCNOFL  = WrkCnoFl;
            SUG_RPCGENTS  = %Timestamp();
            SUG_RPCACTTS  = *Loval;
            SUG_RPCEDITR  = *Blanks;

            // A title awaiting the pricing-authority check is written
            // held rather than suggested, so that it cannot be approved
            // as a matter of routine.
            If WrkAuthHld = 'H';
               SUG_RPCSTAT = 'G';
               SUG_RPCNOTE = 'PRICING AUTHORITY CHECK REQUIRED';
            Else;
               SUG_RPCSTAT = 'S';
               SUG_RPCNOTE = RulText(WrkRulIdx);
            Endif;

            Write IV$RPCSUG;

         Endsr;
      /end-free

      //***********************************************************************
      //* Subroutine: Audit the review against the item
      //***********************************************************************
      /free
         Begsr Sbr_Write_Audit;

            Clear IV$ORRMNT;
            ORM_ITMNUM   = WrkCndItem;
            ORM_ACTION   = 'Reprice review';
            ORM_DESC     = 'Suggest ' + %Trim(%Char(WrkSug72)) +
                           ' was ' + %Trim(%Char(ITM_PRICE72));
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

            Dsply ('Cycle ' + %Char(WrkCycle) + ' mode ' + WrkMode);
            Dsply ('Candidates read : ' + %Char(WrkCntRead));
            Dsply ('Suggestions     : ' + %Char(WrkCntWrote));
            Dsply ('CNOs attached   : ' + %Char(WrkCntCno));
            Dsply ('Skip no item    : ' + %Char(WrkCntNoItem));
            Dsply ('Skip no control : ' + %Char(WrkCntNoCtl));
            Dsply ('Skip phase 0    : ' + %Char(WrkCntPhase));
            Dsply ('Skip no group   : ' + %Char(WrkCntNoGrp));
            Dsply ('Skip no price   : ' + %Char(WrkCntNoPrc));
            Dsply ('Skip horizon    : ' + %Char(WrkCntHoriz));
            Dsply ('Skip repriced   : ' + %Char(WrkCntFresh));
            Dsply ('Skip open sugg  : ' + %Char(WrkCntDup));
            Dsply ('Skip no rule    : ' + %Char(WrkCntNoRule));
            Dsply ('Skip under min  : ' + %Char(WrkCntExcl));
            Dsply ('Skip no rise    : ' + %Char(WrkCntNoRise));
            Dsply ('Skip authority  : ' + %Char(WrkCntAuth));
            Dsply ('Skip priced now : ' + %Char(WrkCntQNew));
            Dsply ('Skip no queue   : ' + %Char(WrkCntNoQue));

         Endsr;
      /end-free
