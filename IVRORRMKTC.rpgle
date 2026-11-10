     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO)
       //***********************************************************************
       //* IVRORRMKTC
       //* Online Rerun System: Marketing Change Screen
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Will not write to the Item/Comments file until user presses F11.
       // F5=If # of months is entered will display Calc RRN QTY
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33979  11/10/26 EFI Show the suggested price; add printed price and
       //                      3rd party approval flags (SOS-2092, SOS-2520)
       // H26932  07/18/22 KMS Add field to adjust code price on Milwaukee rerun
       //                       screens - Add a check for price changes to promp
       //                      t a code price change to so they dont forget to d
       //                      o it
       // H26932  07/11/22 KMS Add field to adjust code price on Milwaukee rerun
       //                       screens - Change MKTC screen to show code price1
       //                       from IVPMSTOV
       // H26932  06/29/22 KMS Add field to adjust code price on Milwaukee rerun
       //                       screens - Add ability to enter code prices on ch
       //                      ange screen for IVRORRMKT
       // H24702  10/09/20 SRK Price Changes - IVPITEMS:PRICE72 not updated
       // FIX     06/20/19 CMN Change which field it first goes to
       // H16167  06/14/19 CMN Clear the MINQTYUSG field='Y' on all POP/NOP item
       //                      s, & other items as appropriate.
       // FIX     10/22/18 SRK RPG - Variable Might not be used
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // H10747  12/12/15 SMM We would like an option on the Milw screens that
       //                      would allow them to flag if an item should now be
       //                      POD.
       // I31193  10/11/12 CMN [DP] Increase Roref#/Pblshr# - Royalty
       // H2495   10/10/12 SMM Fix the Standards error "Prototype for Program Ne
       //                      eded"
       // I31187  04/19/12 DRS [DP] Increase Roref#/Pblshr# - Inventory
       // I28732  07/14/11 SRK [DP] Source Management Phase III - Statusds
       // MISC    04/27/10 CMN code review errors
       // I25477  04/26/10 CMN [DP] Job number field: Navision and Online Rerun
       // I22027  12/09/09 SRK [CS] Increase size of price field - IVPITEMS
       // I22027  11/15/09 CMN [CS] Increase size of price field
       // I21794  03/11/09 TRO [DP] Online Rerun - create new Purchasing screen
       // I21794  02/24/09 TRO [DP] Online Rerun - create new Purchasing screen
       // SA00644 11/06/05 KCS Online Rerun System - Production (7/7)
       // SA00644 10/12/04 CMN Don't update MinQtyUsg if < 6 months old
       // FIX     09/27/04 CMN If apprrqty=0/estrrqty = 0, unapprove
       // SA00644 09/27/04 KCS Online Rerun System: Marketing approvals
       //***********************************************************************

       // Screen File
     FIVSORRMKTCCF   E             WORKSTN Prefix(Scn_)

       // Input Files
     FMFPUSERS  IF   E           K DISK    Prefix(Usr_)
     FIVLOWNPU1 IF   E           K DISK    Prefix(Own_)
     FIVPMSTOV  IF   E           K DISK    Prefix(Mcp_)

       // Update Files
     FIVPITEMS  UF   E           K DISK    Prefix(Itm_)

       // Update/Add Files
     FIVPWPCMT  UF A E           K DISK    Prefix(Wcm_)
     FIVPMAINT  UF A E           K DISK    Prefix(Mnt_)
     FIVPMAINTDTUF A E           K DISK    Prefix(Mnd_)
     FIVPORRITM UF   E           K DISK    Prefix(Orr_)
     FIVPORRMNT UF A E           K DISK    Prefix(Orm_)
     FIVPPRTPRT UF A E           K DISK    Prefix(Ppr_)
     FIVPRPCSUG UF   E           K DISK    Prefix(Sug_)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,dayofweek
      /copy qcopysrc,ivrorrmktc

       //***********************************************************************
       //* Entry Parameters *
       //********************
     D IVRORRMKTC      PI
     D PrmItmnum                      8A   const
     D PrmMinQtyDt                     D
     D PrmOrrMilw                     1A   const

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds

     D Scn_TtlLine2    DS
     D  WrkTtlTime             1      8T   Timfmt(*USA)
     D  WrkTtlDayofWk         10     18
     D  WrkTtlSubTtl          20     60    Inz('Change Screen')
     D  WrkTtlUser            70     79

     D WrkDateISO      S               D   Datfmt(*ISO)
     D Scn_TtlText     S             57A   Inz('On-line Rerun System')
     D WrkLen          S              2S 0
     D WrkBlanks       S            132A   Inz
     D WrkChange       S              1A
     D WrkItmNum       S              8S 0
     D WrkLRQty        S                   Like(Itm_LRQty)
     D WrkNewPriceF    S              1A   Inz
     D SavAppRRQty     S                   Like(Orr_AppRRQty)
     D SavQuotePrc     S                   Like(Orr_QuotePrc)
     D SavMinQtyOvr    S                   Like(Scn_MinQtyOvr)
     D SavMinQtyUsg    S                   Like(Scn_MinQtyUsg)
     D SavNewPrice     S                   Like(Orr_NewPrice)
     D SavNote1        S                   Like(Orr_Note1)
     D SavNote2        S                   Like(Orr_Note2)
     D SavNote3        S                   Like(Orr_Note3)
     D SavNote4        S                   Like(Orr_Note4)
     D SavWpComt       S                   Like(Wcm_WpComt)
     D SavFlipToPOD    S              1A
     D SavPrtPrc       S              1A
     D SavTpAprv       S              1A
     D WrkPprFnd       S              1A
     D WrkOldPrt       S              1A
     D WrkOldTpa       S              1A
     D WrkMntName      S            100A   Varying
     D WrkSugFnd       S              1A   Inz('N')
     D WrkSugFill      S              1A   Inz('N')
     D WrkSugCycl      S              6S 0
     D WrkSugNewSt     S              1A


       //***********************************************************************
       //* MainLine **
       //*************
       Exsr Sbr_Setup;

       // ...Load fields for screen
       Scn_ItmNum = WrkItmNum;
       Scn_WpComt = *Blanks;
       WrkNewPriceF = 'Y';

       Chain Scn_ItmNum IVPORRITM;
       If %Found(IVPORRITM);
          Scn_StartDt   = Orr_StartDt;
          Scn_EstRRQty  = Orr_EstRRQty;
          Scn_QuotePrc  = Orr_QuotePrc;
          Scn_QuoteDt   = Orr_QuoteDt;
          Scn_EmailDate = Orr_EmailDate;
          Scn_QtyAvail  = Orr_QtyAvail;
          Scn_EstBODt   = Orr_EstBODt;
          Scn_ApprrQty  = Orr_ApprrQty;
          Scn_NewPrice  = Orr_NewPrice;
          Scn_QuoteWho  = Orr_QuoteWho;
          Scn_MktCoord  = Orr_MktCoord;
          If Orr_FlipToPOD = ' ';
             Scn_FlipToPOD = 'N';
          Else;
             Scn_FlipToPOD = Orr_FlipToPOD;
          EndIf;
          Scn_MinQtyOvr = 0;
          Scn_MinQty = Orr_MinQty;

          Chain(N) Scn_ItmNum IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Price72 = Itm_Price72;
             Scn_SDesc = Itm_SDesc;
             Scn_BOQty = Itm_BOQty;
             Scn_MinQtyUsg = Itm_MinQtyUsg;
          Endif;

          Chain Orr_EmailId MFPUSERS;
          If %Found(MFPUSERS);
             Scn_EmailedTo = Usr_UserName;
          Else;
             Scn_EmailedTo = Orr_EmailID;
          Endif;

          // Get Wip Comments
          Chain Scn_ItmNum IVPWPCMT;
          If %Found(IVPWPCMT);
             Scn_WpComt = Wcm_WpComt;
          Endif;
          // Get Roref Desc
          If Itm_Cntrtp = 'A'
                 Or Itm_Cntrtp = 'C'
                 Or Itm_Cntrtp = 'J';
             Chain Itm_RorefNum IVLOWNPU1;
             If %Found(IVLOWNPU1);
                Scn_Owner@ = Own_Owner@;
             Endif;
          Else;
             Scn_Owner@ = *Blanks;
          Endif;

          // Get Data to fill screen
          Scn_Note1 = Orr_Note1;
          Scn_Note2 = Orr_Note2;
          Scn_Note3 = Orr_Note3;
          Scn_Note4 = Orr_Note4;

          Chain Scn_ItmNum IVPMSTOV;
          If %Found(IVPMSTOV);
             Scn_CodPr172 = Mcp_Roy1OV72;
          Endif;
          Scn_CodPr272 = Orr_CodPr272;
          // Printed price / third-party approval (SOS-2092, SOS-2520)
          Scn_PrtPrc = *Blanks;
          Scn_TpAprv = *Blanks;
          Chain(N) Scn_ItmNum IVPPRTPRT;
          If %Found(IVPPRTPRT);
             Scn_PrtPrc = Ppr_PrtPrc;
             Scn_TpAprv = Ppr_TpAprv;
          Endif;

          // Suggested price (re-run repricing). Shown on line 12; when no
          // new price has been set yet it is put in New Price for the user
          // to keep, change or blank. Not in the Milwaukee views, where New
          // Price is protected, and not while the suggestion is held.
          Exsr Sbr_Get_Suggestion;
          If WrkSugFnd = 'Y' And Sug_RpcStat = 'S'
             And Scn_NewPrice = *Zeros
             And PrmOrrMilw <> 'Y' And PrmOrrMilw <> 'X';
             Scn_NewPrice = Sug_RpcSug72;
             WrkSugFill   = 'Y';
             Scn_Msg = 'New Price filled in with the suggested price.';
          Endif;

       Else;
          Clear SCREEN1;
       Endif;

       // Display the window until F12 or update
       Dow 1 = 1;
          SavAppRRQty = Scn_AppRRQty;
          SavNewPrice = Scn_NewPrice;
          SavQuotePrc = Scn_QuotePrc;
          SavNote1    = Scn_Note1;
          SavNote2    = Scn_Note2;
          SavNote3    = Scn_Note3;
          SavNote4    = Scn_Note4;
          SavMinQtyOvr = Scn_MinQtyOvr;
          SavMinQtyUsg = Scn_MinQtyUsg;
          SavWpComt   = Scn_WpComt;
          SavFlipToPOD = Scn_FlipToPOD;
          SavPrtPrc    = Scn_PrtPrc;
          SavTpAprv    = Scn_TpAprv;
          // A filled-in suggestion counts as a change the first time round,
          // so it is never saved without the user confirming it.
          If WrkSugFill = 'Y';
             SavNewPrice = *Zeros;
             WrkSugFill  = 'N';
          Endif;

          // Check if RR Qty is > 15% of Last Run Qty or < .85 of Last Run Qty
          If Itm_WLRQtyNew = 0;
             WrkLRQty = Itm_LRQty;
          Else;
             WrkLRQty = Itm_WLRQtyNew;
          Endif;

          Exsr SbrUpdDtTm;
          If PrmOrrMilw = 'Y' or PrmOrrMilw = 'X';
             *In51 = *On;
          Else;
             *In51 = *Off;
          Endif;
          If PrmOrrMilw = 'X';
             *In52 = *On;
          Else;
             *In52 = *Off;
          Endif;
          // Output and read the screen
          Exfmt SCREEN1;

          Scn_Msg = *Blanks;
          *In50 = *Off;
          *In54 = *Off;
          *In55 = *Off;
          *In56 = *Off;
          *In57 = *Off;
          *In58 = *Off;
          *In59 = *Off;
          *In61 = *Off;
          // 70 - there is some type of error
          *In70 = *Off;
          // 80 Code Price 2 flag
          *In80 = *Off;

          // Check for function keys
          If *In12 = *On;
             WrkChange = 'N';
             Leave;
          Endif;

          // F5 = Calculate
          If *In05 = *On;
             If Scn_NumMonths <> *Zeros;
                Eval(H) Scn_CalcRRQty = (Orr_EstRRQty / 12) *
                    Scn_NumMonths;
             Else;
                Scn_Msg = 'Please enter the number of '
                    + 'months.';
                *In50 = *On;
             Endif;
          Endif;

          // All other function keys
          If *In26 = *On;
             WrkChange = 'N';
             Iter;
          Endif;

          // Check for valid entries

          If Scn_AppRRQty < 0;
             Scn_Msg = 'Approved Rerun Quantity must be postive';
             *In55 = *On;
             *In70 = *On;
             Iter;
          EndIf;
          If Scn_NewPrice < 0;
             Scn_Msg = 'New Price must be postive';
             *In56 = *On;
             *In70 = *On;
             Iter;
          EndIf;
          If Scn_MinQtyOvr < 0;
             Scn_Msg = 'Minimum Quantity Override must be postive';
             *In57 = *On;
             *In70 = *On;
             Iter;
          EndIf;
          If Scn_MinQtyUsg <> *Blanks
             and Scn_MinQtyUsg <> 'Y';
             Scn_Msg = 'Invalid override flag (blank, Y)';
             *In54 = *On;
             *In70 = *On;
             Iter;
          EndIf;
          If Scn_MinQtyUsg <> *Blanks
             and SavMinQtyUsg = *Blanks
             and Scn_MinQtyOvr = *Zero;
             Scn_Msg = 'Override Qty must be > 0 if flag set';
             *In54 = *On;
             *In57 = *On;
             *In70 = *On;
             Iter;
          Endif;
          If Scn_MinQtyUsg = 'Y'
             and SavMinQtyUsg <> 'Y'
             and Orr_Flg6Mo = 'Y';
             Scn_Msg = 'Not allowed to override in first 6 months';
             *In54 = *On;
             *In57 = *On;
             *In70 = *On;
             Iter;
          Endif;
          If Scn_QuotePrc < 0;
             Scn_Msg = 'Quote Price must be postive';
             *In58 = *On;
             *In70 = *On;
             Iter;
          EndIf;
          If   Scn_FlipToPOD <> 'N'
           and Scn_FlipToPOD <> 'Y';
             Scn_Msg = 'Invalid Flip to Pod - Must be N or Y';
             *In59 = *On;
             *In70 = *On;
             Iter;
          EndIf;
          If Scn_MinQtyOvr <> 0;
             Scn_MinQtyUsg = 'Y';
          Endif;
          // Do a check to see if new price is change
       // If new price is entered check to see if Codeprice 2 has record in it
          If Scn_NewPrice <> *Zeros
             and Scn_CodPr272 = *Zeros
             and Scn_Codpr172 <> *Zeros
             and Scn_CodPr272F = *Blanks;
             Scn_Msg = 'Is a new code price needed?';
             *In80 = *On;
             Iter;
          Endif;

          // If screen has changed, get confirmation before updating
          If Scn_AppRRQty <> SavAppRRQty
                 Or Scn_NewPrice <> SavNewPrice
                 Or Scn_MinQtyOvr <> SavMinQtyOvr
                 Or Scn_MinQtyUsg <> SavMinQtyUsg
                 Or Scn_QuotePrc <> SavQuotePrc
                 Or Scn_Note1    <> SavNote1
                 Or Scn_Note2    <> SavNote2
                 Or Scn_Note3    <> SavNote3
                 Or Scn_Note4    <> SavNote4
                 Or Scn_WpComt   <> SavWpComt
                 Or Scn_FlipToPOD <> SavFlipToPOD
                 Or Scn_PrtPrc    <> SavPrtPrc
                 Or Scn_TpAprv    <> SavTpAprv;
             Scn_Msg = 'Press Enter to confirm change.';
             Iter;
          Endif;

          // Update the record
          Chain WrkItmnum IVPORRITM;
          If %Found(IVPORRITM);
             // Check if new quote price entered
             If Orr_QuotePrc <> Scn_QuotePrc;
                Orr_QuoteDt = %Date();
                Orm_Itmnum = Scn_ItmNum;
                Orm_Action ='Quote price';
                Orm_Desc   = 'from '
                    + %Trim(%Editc(Orr_QuotePrc:'3'))
                    + ' to '
                    + %Trim(%Editc(Scn_QuotePrc:'3'));
                Orm_MaintTs = %Timestamp();
                Orm_MaintWho = SdsUser;
                Write IV$ORRMNT;
             Endif;
             If Orr_NewPrice    <> Scn_NewPrice;
                Orm_Itmnum = Scn_ItmNum;
                Orm_Action ='New price';
                If Orr_NewPrice = 0;
                   Orm_Desc   = 'from ' + %Trim(%Editc(Itm_Price72:'3'));
                Else;
                   Orm_Desc   = 'from ' + %Trim(%Editc(Orr_NewPrice:'3'));
                Endif;
                Orm_Desc   = %Trim(Orm_Desc)
                    + ' to '
                    + %Trim(%Editc(Scn_NewPrice:'3'));
                Orm_MaintTs = %Timestamp();
                Orm_MaintWho = SdsUser;
                Write IV$ORRMNT;
             Endif;
             If Orr_Note1       <> Scn_Note1
                    or Orr_Note2    <> Scn_Note2
                    or Orr_Note3    <> Scn_Note3
                    or Orr_Note4    <> Scn_Note4;
                Orm_Itmnum = Scn_ItmNum;
                Orm_Action ='Mkt comments';
                Orm_Desc   = *Blanks;
                Orm_MaintTs = %Timestamp();
                Orm_MaintWho = SdsUser;
                Write IV$ORRMNT;
             Endif;
             If Orr_AppRRQty    <> Scn_AppRRQty;
                Orm_Itmnum = Scn_ItmNum;
                Orm_Action ='Rerun qty';
                If Orr_AppRRQty = 0;
                   Orm_Desc   = 'from ' + %Trim(%Editc(Orr_EstRRQty:'3'));
                Else;
                   Orm_Desc   = 'from ' + %Trim(%Editc(Orr_AppRRQty:'3'));
                Endif;
                Orm_Desc   = %Trim(Orm_Desc)
                    + ' to '
                    + %Trim(%Editc(Scn_AppRRQty:'3'));
                Orm_MaintTs = %Timestamp();
                Orm_MaintWho = SdsUser;
                Write IV$ORRMNT;
             Endif;
             Orr_AppRRQty     = Scn_AppRRQty;
             If Orr_AppRRQty     = 0
                    and Orr_EstRRQty = 0
                    and Orr_Rerunsts = 'A';
                Orr_RerunSts     = ' ';
             Endif;
             If Orr_CODPR272 <> Scn_CODPR272;
                Orm_Itmnum = Scn_ItmNum;
                Orm_Action ='Code Price Change';
                Orm_Desc   = *Blanks;
                Orm_MaintTs = %Timestamp();
                Orm_MaintWho = SdsUser;
                Write IV$ORRMNT;
             Endif;

             Orr_NewPrice     = Scn_NewPrice;
             Orr_QuotePrc     = Scn_QuotePrc;
             Orr_Note1        = Scn_Note1;
             Orr_Note2        = Scn_Note2;
             Orr_Note3        = Scn_Note3;
             Orr_Note4        = Scn_Note4;
             Orr_FlipToPOD    = Scn_FlipToPOD;
             Orr_CodPr172     = Scn_CodPr172;
             Orr_CodPr272     = Scn_CodPr272;
             If Orr_FlipToPOD = 'Y';
                Orr_NoteRecd  = 'N';
             EndIf;
             Update IV$ORRITM;
             Exsr Sbr_Upd_Price_Flags;
             Exsr Sbr_Upd_Suggestion;
             // If changing the MinQty Override Quantity, update IVPITEMS and
             // add maintenance records
             If Scn_MinQtyOvr   <> 0;
                Chain Scn_ItmNum IVPITEMS;
                Mnt_Itmnum       = Scn_Itmnum;
                Mnt_MaintMM   = SdsJobDateMM;
                Mnt_MaintDD   = SdsJobDateDD;
                Mnt_MaintYYYY = SdsJobDateYY;
                Mnt_MaintWho  = SdsUser;
                Mnt_Fldnam    = 'MINQTY';
                EvalR Mnt_Before    = %Editc(Itm_MinQty:'X');
                Mnt_After = %Trim(%Editc(Scn_MinQtyOvr:'X'));
                Mnt_RepCode   = 'N';
                Write IVPMAIN$;
                If Orr_Flg6Mo <> 'Y';
                   Mnt_Fldnam    = 'MINQTYUSG';
                   EvalR Mnt_Before    = %Trim(Itm_MinQtyUsg);
                   Mnt_After     = 'Y';
                   Write IVPMAIN$;
                   Chain (Scn_Itmnum : Mnt_Fldnam) IVPMAINTDT;
                   If %Found(IVPMAINTDT);
                      Mnd_MaintDt = %Date();
                      Update IV$MAINTDT %Fields(Mnd_MaintDt);
                   Else;
                      // only write as maint record if we are setting the field
                      Mnd_Itmnum = Scn_Itmnum;
                      Mnd_FldNam = Mnt_Fldnam;
                      Mnd_MaintDt = %Date();
                      Write IV$MAINTDT;
                   Endif;
                Endif;
                Itm_MinQty       = Scn_MinQtyOvr;
                If Orr_Flg6Mo <> 'Y';
                   Itm_MinQtyUsg    = 'Y';
                Endif;
                Update IVPITEM$ %Fields(Itm_MinQty : Itm_MinQtyUsg);
             Endif;

             // this applies only if they cleared the flag
             Chain(N) Scn_ItmNum IVPITEMS;
             If Scn_MinQtyUsg <> Itm_MinQtyUsg
                and Scn_MinQtyUsg = *Blanks;
                Chain Scn_ItmNum IVPITEMS;
                Mnt_Itmnum    = Scn_Itmnum;
                Mnt_Fldnam    = 'MINQTYUSG';
                Mnt_MaintMM   = SdsJobDateMM;
                Mnt_MaintDD   = SdsJobDateDD;
                Mnt_MaintYYYY = SdsJobDateYY;
                Mnt_MaintWho  = SdsUser;
                Mnt_Before    = %Trim(Itm_MinQtyUsg);
                Mnt_After     = %Trim(Scn_MinQtyUsg);
                Mnt_RepCode   = 'N';
                Write IVPMAIN$;
                Chain (Scn_Itmnum : Mnt_Fldnam) IVPMAINTDT;
                If %Found(IVPMAINTDT);
                   Delete IV$MAINTDT;
                Endif;
                Itm_MinQtyUsg    = Scn_MinQtyUsg;
                Update IVPITEM$ %Fields(Itm_MinQtyUsg);
             Endif;

             WrkChange = 'Y';
          Else;
             Scn_Msg = 'Record not found for update.';
             *In50 = *On;
             *In70 = *On;
             Iter;
          Endif;
          Leave;

       Enddo;
       Scn_Msg = *Blanks;
       *InLr = *On;
       //********************
       //* End of MainLine **
       //***********************************************************************

       // /****************************************************************\ *
       //<                           SUBROUTINES                            >*
       // \****************************************************************/ *

       //***********************************************************************
       //* Save printed price / third-party approval, with history **
       //***********************************************************************
       Begsr Sbr_Upd_Price_Flags;

          Chain Scn_ItmNum IVPPRTPRT;
          If %Found(IVPPRTPRT);
             WrkPprFnd = 'Y';
             WrkOldPrt = Ppr_PrtPrc;
             WrkOldTpa = Ppr_TpAprv;
          Else;
             WrkPprFnd = 'N';
             WrkOldPrt = *Blanks;
             WrkOldTpa = *Blanks;
          Endif;

          // Nothing changed - leave the file and the history alone
          If Scn_PrtPrc = WrkOldPrt and Scn_TpAprv = WrkOldTpa;
             If WrkPprFnd = 'Y';
                Unlock IVPPRTPRT;
             Endif;
             Leavesr;
          Endif;

          // MAINTNAME, the full name, as most history rows carry one:
          // the user's name from MFPUSERS, or the user ID.
          WrkMntName = %Trim(SdsUser);
          Chain SdsUser MFPUSERS;
          If %Found(MFPUSERS);
             WrkMntName = %Trim(Usr_UserName);
          Endif;

          // One IVPMAINT row per flag changed, as for any item field.
          // Every field is filled, the way P1VBTCHUP and IVRRPCAPL do:
          // cleared first so nothing is left over from the MINQTY rows
          // this program writes, and COMMENT names the program.
          If Scn_PrtPrc <> WrkOldPrt;
             Clear IVPMAIN$;
             Mnt_Itmnum    = Scn_Itmnum;
             Mnt_Fldnam    = 'PRTPRC';
             Mnt_MaintYYYY = %Subdt(%Date() : *Y);
             Mnt_MaintMM   = %Subdt(%Date() : *M);
             Mnt_MaintDD   = %Subdt(%Date() : *D);
             Mnt_MaintWho  = SdsUser;
             Mnt_Before    = WrkOldPrt;
             Mnt_After     = Scn_PrtPrc;
             Mnt_RepCode   = 'N';
             Mnt_Comment   = 'IVRORRMKTC';
             Mnt_MaintName = WrkMntName;
             Write IVPMAIN$;
          Endif;
          If Scn_TpAprv <> WrkOldTpa;
             Clear IVPMAIN$;
             Mnt_Itmnum    = Scn_Itmnum;
             Mnt_Fldnam    = 'TPAPRV';
             Mnt_MaintYYYY = %Subdt(%Date() : *Y);
             Mnt_MaintMM   = %Subdt(%Date() : *M);
             Mnt_MaintDD   = %Subdt(%Date() : *D);
             Mnt_MaintWho  = SdsUser;
             Mnt_Before    = WrkOldTpa;
             Mnt_After     = Scn_TpAprv;
             Mnt_RepCode   = 'N';
             Mnt_Comment   = 'IVRORRMKTC';
             Mnt_MaintName = WrkMntName;
             Write IVPMAIN$;
          Endif;

          Ppr_PrtPrc  = Scn_PrtPrc;
          Ppr_TpAprv  = Scn_TpAprv;
          Ppr_ChgTs   = %Timestamp();
          Ppr_ChgUser = SdsUser;
          If WrkPprFnd = 'Y';
             Update IV$PRTPRT %Fields(Ppr_PrtPrc : Ppr_TpAprv
                                    : Ppr_ChgTs : Ppr_ChgUser);
          Else;
             Ppr_Itmnum  = Scn_Itmnum;
             Ppr_AddTs   = %Timestamp();
             Ppr_AddUser = SdsUser;
             Write IV$PRTPRT;
          Endif;

       Endsr;

       //***********************************************************************
       //* Find the open price suggestion for the item **
       //***********************************************************************
       Begsr Sbr_Get_Suggestion;

          WrkSugFnd    = 'N';
          Scn_SugPrice = *Zeros;
          Scn_SugNote  = *Blanks;
          *In63        = *Off;

          // Newest cycle first. Only one suggestion is open for an item
          // at a time.
          Setgt WrkItmNum IVPRPCSUG;
          Readpe(N) WrkItmNum IVPRPCSUG;
          Dow Not %Eof(IVPRPCSUG);
             If Sug_RpcStat = 'S' Or Sug_RpcStat = 'G'
                Or Sug_RpcStat = 'A' Or Sug_RpcStat = 'O';
                WrkSugFnd  = 'Y';
                WrkSugCycl = Sug_RpcCycl;
                Leave;
             Endif;
             Readpe(N) WrkItmNum IVPRPCSUG;
          Enddo;

          If WrkSugFnd = 'Y';
             *In63 = *On;
             If Sug_RpcStat = 'O';
                Scn_SugPrice = Sug_RpcApp72;
             Else;
                Scn_SugPrice = Sug_RpcSug72;
             Endif;
             Scn_SugNote = Sug_RpcNote;
          Endif;

       Endsr;

       //***********************************************************************
       //* Record the price decision on the suggestion **
       //***********************************************************************
       Begsr Sbr_Upd_Suggestion;

          // New Price is protected in the Milwaukee views, so no price
          // decision was made there.
          If WrkSugFnd <> 'Y'
             Or PrmOrrMilw = 'Y' Or PrmOrrMilw = 'X';
             Leavesr;
          Endif;

          Chain (WrkItmNum : WrkSugCycl) IVPRPCSUG;
          If Not %Found(IVPRPCSUG);
             Leavesr;
          Endif;

          // A held suggestion waits on a third party, or on an override
          // being authorised - neither of which this screen gives.
          If Sug_RpcStat <> 'S' And Sug_RpcStat <> 'A'
             And Sug_RpcStat <> 'O';
             Unlock IVPRPCSUG;
             Leavesr;
          Endif;

          Select;
          When Scn_NewPrice = Sug_RpcSug72;
             WrkSugNewSt = 'A';
          When Scn_NewPrice > Sug_RpcCur72;
             WrkSugNewSt = 'O';
          Other;
             WrkSugNewSt = 'R';
          Endsl;

          // Nothing new to record
          If WrkSugNewSt = Sug_RpcStat
             And (WrkSugNewSt <> 'O' Or Sug_RpcApp72 = Scn_NewPrice);
             Unlock IVPRPCSUG;
             Leavesr;
          Endif;

          Sug_RpcStat  = WrkSugNewSt;
          Sug_RpcEditr = SdsUser;
          Sug_RpcActTs = %Timestamp();
          Select;
          When WrkSugNewSt = 'A';
             Sug_RpcApp72  = Sug_RpcSug72;
             Sug_RpcApp112 = Sug_RpcSug112;
             Sug_RpcNote   = 'APPROVED ON THE RERUN SCREEN';
          When WrkSugNewSt = 'O';
             // PRICE112 takes the same number, as IVRRPCWRK does. A price
             // typed here is deliberate, so a cap breach is authorised.
             Sug_RpcApp72  = Scn_NewPrice;
             Sug_RpcApp112 = Scn_NewPrice;
             Sug_RpcOvrAut = 'Y';
             Sug_RpcNote   = 'NEW PRICE SET ON THE RERUN SCREEN';
          Other;
             Sug_RpcNote   = 'NO PRICE CHANGE - RERUN SCREEN';
          Endsl;
          Update IV$RPCSUG;

       Endsr;
       //***********************************************************************
       //* Update Date/Time/DayOfWeek  **
       //********************************
       Begsr SbrUpdDtTm;

          //...Get time and date and day of week for screen
          WrkDateISO  = %Date();
          Scn_TtlDate = %Date();
          Callp DayofWeek (WrkDateISO:WrkTtlDayOfWk);

          WrkTtlTime  = %Time();
       Endsr;

       //***********************************************************************
       //* *INZSR   **
       //*************

       Begsr Sbr_Setup;
          WrkItmNum = %Int(PrmItmNum);

          WrkTtlUser  = SdsUser;
          Scn_TtlPgm  = SdsProgram;

          //...Center the title of the screen
          WrkLen = (%Len(Scn_TtlText) - %Len(%Trim(Scn_TtlText)))/2;
          Scn_TtlText = %Subst(WrkBlanks:1:WrkLen) + Scn_TtlText;

          //...Center the Text in the Title line 2
          WrkLen = (%Len(WrkTtlSubTtl) - %Len(%Trim(WrkTtlSubTtl)))/2;
          WrkTtlSubTtl = %Subst(WrkBlanks:1:WrkLen) + WrkTtlSubTtl;

          WrkChange = 'Y';
       Endsr;
