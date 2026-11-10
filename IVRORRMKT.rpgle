     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO)
       //***********************************************************************
       // IVRORRMKT
       // Online Rerun System: Marketing
       //***********************************************************************


       // **********************************************************************
       // ** IF CHANGE ARE MADE TO THIS PROGRAM YOU MIGHT ALSO NEED TO CHANGE **
       // **                            IVVORRMKT                             **
       // **********************************************************************


       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Allow Mkt Coord to approve or cancel the rerun of items
       // F3 if there are any items in the file for this Mkt Coord w/ a RRN
       // status <> blank and not "E" or "Q" and ApprDate=*Loval show
       // confirmation screen (IVRORRMKT2) (Or SdsUser = OthUser)
       // F4 will toggle between Summary/Detail Views
       // F9 will toggle between sort of MktCoord/Start Date & Start Date/Item
       // F12 will exit completely out of the program
       // Entering an Exp Code will take you to Inventory Inquiry for the item
       // "A" next to an item updates RRN Status to A & highlights all fields
       // "D" next to an item updates RRN Status to D & highlights all fields
       // "E" next to an item calls email pgm IVRORRMKTE
       // "Q" next to an item calls quote pgm IVRORRMKTQ
       // "C" next to an item calls change pgm IVRORRMKTC
       // "V" next to an item updates the status flag to blanks
       // "H" next to an item toggles the MKTHOLD field
       // "R" next to an item will display a window asking for delete confirm
       // *In80 & 81 toggles between MktCoord & StartDt sort
       // *In84 if on allows user to toggle between MktCoord and StartDt sort
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33979  11/10/26 EFI Show printed price, 3rd party approval and the
       //                      suggested price (SOS-2092, SOS-2520)
       // SOS2366 08/26/26 PHB CNS QTY PEPPER to CNS QTY TOTAL
       // H22581  06/27/22 CMN Convert MI reorder process to more closely mirror
       //                       the HL traditional rerun system
       // H27742  05/30/22 KMS Auto populate the New Price field in the rerun pr
       //                      ogram for items needing price increases - Flip th
       //                      e color of the price if it is using the new price
       //                       field in IVPORRITM
       // FIX     05/30/22 KMS Quick Fix- Mandatory Errors
       // H27251  05/30/22 KMS Changes to Rerun program
       // MISC    11/20/20 SRK Fix Source Errors
       // H24702  10/09/20 SRK Price Changes - IVPITEMS:PRICE72 not updated
       // H25474  08/10/20 CMN Add date of last price increase to approvers' rer
       //                      un screens
       // H23057  08/27/19 CJR Under online rerun system - Marketing, can a colu
       //                      mn be added for a "kit"?
       // FIX     07/24/19 CMN Watch for too big negative numbers
       // FIX     02/21/19 CMN Clear Prod dept if NBR
       // FIX     09/17/18 SRK Fix Cspec
       // FIX     07/17/17 CMN Date/timestamp invalid if loval and MDY
       // H11555  08/27/15 RAT Add BO quantity to the rerun Marketing screen.
       // H10275  06/30/15 NAH Rerun: add to the screen either an indicator or t
       //                      he consignment quantity from Pepper's two consign
       //                      ment locations.
       // H6966   04/26/15 CMN In the rerun system, for all items with a specifi
       //                      ed medium, create a pop-up that requires the user
       //                      to choose whether to: 1. keep the currentmedium &
       //                      add download code, 2. remove the current medium &
       //                      add download code or 3. rerun as is. If they choo
       //                      se option 1 or 2, write the information to a file
       //                      .
       // H3653   03/29/13 SRK Investigate: do we need the file DPPISEMP anymore
       //                      or can we change programs to use a filtered logic
       //                      al on MFPUSERS userdept = IS?  We will also need
       //                      to determine if there is still a reason why we ne
       //                      ed the deleted records in DPPISEMP.
       // H2495   10/10/12 SMM Fix the Standards error "Prototype for Program Ne
       //                      eded"
       // I31192  08/13/12 JFH [DP] Increase Roref#/Pblshr# - Online Rerun
       // H1528   05/30/12 JFH Change print file created using F21 to email a PD
       //                      F to the user.
       // I31192  05/10/12 JFH [DP] Increase Roref#/Pblshr# - Online Rerun
       // I31192  05/10/12 JFH [DP] Increase Roref#/Pblshr# - Online Rerun
       // FIX     11/15/11 CMN no such dept as RO
       // I28732  05/20/11 SRK [DP] Source Management Phase III - Missinge Displ
       //                      ayio
       // I25471  03/12/11 CMN [DP] Job number field: Main files
       // I27926  02/07/11 KKW [PC] Agency purchasing move to Teri J
       // FIX     05/19/10 CMN Clearing BO field if on hold
       // I25477  04/26/10 CMN [DP] Job number field: Navision and Online Rerun
       // I21547  03/29/10 DRS [CA] New Permot Code
       // I25471  03/24/10 KCS [DP] Job number field: Main files
       // I22027  11/15/09 CMN [CS] Increase size of price field
       // I23128  07/22/09 JFH [IV] Inventory Inquiry - cost screen and mult job
       //                      s
       // I22869  03/26/09 DRS [IV] Online Rerun: DeHaske reprints
       // I23025  03/21/09 CMN [DP] fix ORR - field size too small
       // I22869  03/19/09 DRS [IV] Online Rerun: DeHaske reprints
       // I21794  02/24/09 TRO [DP] Online Rerun - create new Purchasing screen
       // I15231  09/09/07 TRO [RO] Add new owner/publisher fields
       // I14586  08/20/07 DRS [SA] Create new permot code (NYP)
       // I9287   07/10/06 TAK When returning from the email screen, keep cursor
       //                      on same line selected for email
       // I1661   03/27/06 TRO RO930-Change Online Rerun for Amadeus/Limelight
       // PC00330 11/23/05 CMN New Yamaha item cross reference file
       // FIX     11/16/05 CMN Fix hold code and how it shows on screen
       // PC00330 11/06/05 CMN Online Rerun System - Production (7/7)
       // FIX     05/23/05 KCS Cursor positioning on Detail Screen
       // FIX     02/18/05 CMN Don't show items with status J, O, etc.
       // BB00003 02/15/05 KCS Inventory/Online Rerun changes for Betty
       // MISC    11/15/04 CMN Change report layout
       // FIX     10/04/04 CMN Fix removal of items from screen
       // SA00644 09/27/04 KCS Online Rerun System: Marketing approvals
       //***********************************************************************

       // Screen File
     FIVSORRMKT CF   E             WORKSTN Prefix(Scn_)
     F                                     SFILE(SFL1:WrkRrn)
     F                                     SFILE(SFL2:WrkRrn2)

       // Input Files
     FMFLUSERS20IF   E           K DISK    Prefix(ISE_)
     FIVPORRUSRSIF   E           K DISK    Prefix(Usr_)
     FIVPSLS2Y  IF   E           K DISK    Prefix(Sl2_)
     FIVPCNSIV  IF   E           K DISK    Prefix(Cns_)
     FIVPWPCMT  IF   E           K DISK    Prefix(Wcm_)
     FIVLMAINT2 IF   E           K DISK    Prefix(Mnt_)
     FNOTEPADI  IF   E           K DISK    Prefix(Not_)
     FIVPYAMXRF IF   E           K DISK    Prefix(Yam_)
     FIVLOWNPU1 IF   E           K DISK    Prefix(Own_)
     FIVPORRQDTLIF   E           K DISK    Prefix(Quo_)
     FIVPDGTPMT IF   E           K DISK    Prefix(Dgt_)
     FB#KITFIL  IF   E           K DISK    Prefix(Kit_)
     FIVPITSPC  IF   E           K DISK    Prefix(Spc_)
     FIVPPRTPRT IF   E           K DISK    Prefix(Ppr_)

       // Update Files
     FIVPITEMS  UF   E           K DISK    Prefix(Itm_)
     FIVLORRITM1UF   E           K DISK    Prefix(Orr_)
     F                                     Rename(IV$ORRITM:IV$ORRITM1)
     FIVLORRITM5UF   E           K DISK    Prefix(Orr_)
     F                                     Rename(IV$ORRITM:IV$ORRITM5)
     FIVPORRITM UF   E           K DISK    Prefix(Orr_)

       // Update/Add Files
     FIVPORRMNT UF A E           K DISK    Prefix(Orm_)
     FRERUN8    UF A E           K DISK    Prefix(Rrn_)

       // Printer Files
     FHPL198N8_1O    F  198        PRINTER OFLIND(*INOF)
     F                                     Usropn

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,dayofweek
      /copy qcopysrc,ivcorrmkt2
      /copy qcopysrc,ivrdrivr
      /copy qcopysrc,ivrorrmktc
      /copy qcopysrc,ivrorrmkte
      /copy qcopysrc,ivrorrmktq
      /copy qcopysrc,ivrorrmkt2
      /copy qcopysrc,ivrorrmkt
      /copy qcopysrc,ivrorrmktd

       //***********************************************************************
       //* Entry Parameters *
       //********************
     D IVRORRMKT       PI
     D  PrmUser                      10A

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds
      /copy qcopysrc,scn132ttl2

     D WrkTitle        S            149A   Inz('Items Up for ReRun')
     D WrkSubTitle     S            149A
     D WrkLen1         S              2S 0
     D WrkBlanks1      S            149A   Inz
     D PrmDay          S              9A
     D WrkTimeofday    S               T
     D WrkAsterisk     S            198A   Inz(*All'*')
     D WrkDateISO      S               D   Datfmt(*ISO)
     D WrkExit         S              1
     D WrkLen          S              2S 0
     D WrkBlanks       S            132A   Inz
     D WrkRrn          S              6S 0
     D WrkRrn2         S              6S 0
     D WrkSavLow       S              6S 0
     D WrkStartFld     S                   Like(Scn_StartFld)
     D WrkView         S              1A
     D WrkCount        S              7S 0
     D WrkCount2       S              7S 0
     D WrkLYSls        S              7S 0
     D WrkPYSls        S              7S 0
     D WrkMSls         S              7S 0
     D WrkLRDate       S              7A
     D WrkFRunDt       S              7A
     D WrkLRQty        S                   Like(Itm_LRQty)
     D WrkItmNum       S              8S 0
     D WrkPprItm       S              8S 0
     D WrkSugItm       S              8S 0
     D WrkSugStat      S              1A
     D WrkSugPrc       S              9S 2
     D WrkSugNote      S             60A
     D WrkJobNum7      S                   Like(Rrn_JobNum7) Inz(0000000)
     D WrkLoc          S              2A
     D WrkLeave        S              1A
     D WrkSavOpt       S                   Like(Scn_Option)
     D WrkToggle       S              1A   Inz('1')
     D WrkViewAll      S              1A
     D WrkClSf         S              1A
     D WrkIndex        S              3  0
     D X               S              2  0
     D                 DS
     D WrkMaintDate            1      8  0
     D WrkMaintYYYY            1      4  0
     D WrkMaintMM              5      6  0
     D WrkMaintDD              7      8  0
     D WrkPriceDt      S               D   Datfmt(*ISO)
     D WrkPriceDt72    S               D   Datfmt(*ISO)

       // Parameters
     D PrmCmd          S              2A
     D PrmOrrMilw      S              1A   Inz('N')
     D PrmItmNum       S              8A
     D PrmRtnCd        S              2A

     D                 DS
     D Orr_StartDt                     D
     D  StartYY                3      4A
     D  StartMM                6      7A
     D  StartDD                9     10A

     D                 DS
     D Orr_EstBODt                     D
     D  BOYY                   3      4A
     D  BOMM                   6      7A
     D  BODD                   9     10A

     D                 DS
     D Orr_MinQtyDt                    D
     D  MinYY                  3      4A
     D  MinMM                  6      7A
     D  MinDD                  9     10A

     D                 DS
     D WrkTodayDt                      D
     D WrkTodayYY              1      4  0
     D WrkTodayMM              6      7  0
     D WrkTodayDD              9     10  0

     D                 DS
     D Itm_LstRunYY                   4  0
     D WrkLstRunYY             3      4A

     D                 DS
     D Itm_WLstRunYY                  4  0
     D WrkWLstRunYY            3      4A

     D                 DS
     D Itm_FrstRunYY                  4  0
     D WrkFrstRunYY            3      4A

       // Arrays
     D ArrTynq         S              7  0 DIM(12)
     D ArrLynq         S              7  0 DIM(12)
     D Arr24nq         S              7  0 DIM(24)
     D ArrPynq         S              7  0 DIM(12)


     D Ivdinq        E DS                  EXTNAME(IVDINQRY) Dtaara(IVDINQRY)
     D  $Data                  1     36

     IIVPITEM$
     I              Tynq01                      ArrTynq(01)
     I              Tynq02                      ArrTynq(02)
     I              Tynq03                      ArrTynq(03)
     I              Tynq04                      ArrTynq(04)
     I              Tynq05                      ArrTynq(05)
     I              Tynq06                      ArrTynq(06)
     I              Tynq07                      ArrTynq(07)
     I              Tynq08                      ArrTynq(08)
     I              Tynq09                      ArrTynq(09)
     I              Tynq10                      ArrTynq(10)
     I              Tynq11                      ArrTynq(11)
     I              Tynq12                      ArrTynq(12)

     I              Lynq01                      ArrLynq(01)
     I              Lynq02                      ArrLynq(02)
     I              Lynq03                      ArrLynq(03)
     I              Lynq04                      ArrLynq(04)
     I              Lynq05                      ArrLynq(05)
     I              Lynq06                      ArrLynq(06)
     I              Lynq07                      ArrLynq(07)
     I              Lynq08                      ArrLynq(08)
     I              Lynq09                      ArrLynq(09)
     I              Lynq10                      ArrLynq(10)
     I              Lynq11                      ArrLynq(11)
     I              Lynq12                      ArrLynq(12)
     IIV$SLS2Y
     I              Pynq01                      ArrPynq(01)
     I              Pynq02                      ArrPynq(02)
     I              Pynq03                      ArrPynq(03)
     I              Pynq04                      ArrPynq(04)
     I              Pynq05                      ArrPynq(05)
     I              Pynq06                      ArrPynq(06)
     I              Pynq07                      ArrPynq(07)
     I              Pynq08                      ArrPynq(08)
     I              Pynq09                      ArrPynq(09)
     I              Pynq10                      ArrPynq(10)
     I              Pynq11                      ArrPynq(11)
     I              Pynq12                      ArrPynq(12)

       //***********************************************************************
       //* MainLine *
       //************
       Exsr Sbr_Setup;

       Dow 1 = 1;
          If WrkExit = 'Y';
             Leave;
          Endif;

          Exsr Sbr_Load_Subfile;
          Exsr Sbr_Process;
       Enddo;

       *InLr = *On;
       //*******************
       //* End of MainLine *
       //***********************************************************************

       // /****************************************************************\ *
       //<                           SUBROUTINES                            >*
       // \****************************************************************/ *

       //***********************************************************************
       //* Fill the Subfile *
       //********************
       Begsr Sbr_Load_Subfile;
          Scn_Option = ' ';
          WrkRrn = *Zeros;
          WrkRrn2 = *Zeros;
          *In77 = *On;
          *In33 = *On;
          Write SFLCTL1;
          Write SFLCTL2;
          *In31 = *Off;
          *In32 = *Off;
          *In33 = *Off;
          // Check which view to display
          If WrkView = 'N';
             Exsr SbrSummary;
          Else;
             Exsr SbrDetail;
          Endif;
       Endsr;

       //***********************************************************************
       //* View Summary *
       //****************
       Begsr SbrSummary;

          Scn_NbrWait = 0;
          Scn_MktCoord = PrmUser;
          If WrkViewAll = 'Y';
             *In84 = *On;
             If *In80 = *On;
                Setll *Loval IVLORRITM1;
             Endif;
             If *In81 = *On;
                Setll *Loval IVLORRITM5;
             Endif;
          Else;
             *In84 = *Off;
             If *In80 = *On;
                Setll PrmUser IVLORRITM1;
             Endif;
          Endif;
          // Get Data to fill screen
          Dow 1 = 1;
             If WrkViewAll = 'Y';
                If *In80 = *On;
                   Read(N) IVLORRITM1;
                Endif;
                If *In80 = *On;
                   Read(N) IVLORRITM5;
                Endif;
             Else;
                Reade(N) PrmUser IVLORRITM1;
             Endif;

             If WrkRrn = 9999;
                *In33 = *On;
                Write SflCtl1;
                *In33 = *Off;
                WrkRrn = 1;
                Scn_Rrn = 1;
                Clear Sfl1;
                Scn_StartDt = *Loval;
                SCn_SDesc = '**Too Many Results**';
                SCn_NbrWait = *Zeros;
                Scn_BOQty = *Zeros;
                Write Sfl1;
                WrkClSf = 'Y';
                Leave;
             EndIf;
             // Check for end of file
             Select;
                When *In80 = *On;
                   If %Eof(IVLORRITM1);
                      Leave;
                   Endif;
                When *In81 = *On;
                   If %Eof(IVLORRITM5);
                      Leave;
                   Endif;
             Endsl;

             //*** Show Records NOT on Hold first ******************************
             If Orr_Hold <> *Blanks;
                Iter;
             Endif;

             // Skip items where the job has been created, the item has been ord
             // or the item has been scheduled for rerun
             If Orr_RerunSts <> *Blanks
                and Orr_RerunSts <> 'A'
                and Orr_RerunSts <> 'E'
                and Orr_RerunSts <> 'Q'
                and Orr_RerunSts <> 'N'
                and Orr_RerunSts <> 'R';
                Iter;
             Endif;

             If (Orr_RerunSts = 'A'
                or Orr_RerunSts = 'N')
                and Orr_ApprvDt <> *Loval;
                Iter;
             Endif;
             //...Load hidden fields from owner/publisher file...
             Chain Orr_RorefNum IVLOWNPU1;
             If %Found(IVLOWNPU1);
                Scn_Imported = Own_Imported;
                Scn_RoyAprv  = Own_RoyAprv;
                Scn_PrtQuote = Own_PrtQuote;
             Else;
                Scn_Imported = *Blanks;
                Scn_RoyAprv  = *Blanks;
                Scn_PrtQuote = *Blanks;
             Endif;
             // Show Approved RR Qty on screen if it has been entered
             If Orr_AppRRQty = 0;
                // HI/RI if 6 Mo Flag = Y
                If Orr_Flg6Mo = 'Y';
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'4');
                Else;
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'3');
                Endif;
             Else;
                Scn_EstRRQty = %Editc(Orr_AppRRQty:'4');
             Endif;
             // Higlight if Sts is A or D
             If Orr_RerunSts = 'A'
             Or Orr_RerunSts = 'N'
             Or Orr_RerunSts = 'R';
                *In50 = *On;
             Else;
                *In50 = *Off;
             Endif;
             // Special formatting if Yamaha item with no Xref item#
             *In60 = *Off;
             If Orr_MktCoord = 'YAMAHA';
                Chain Orr_Itmnum IVPYAMXRF;
                If Not %Found(IVPYAMXRF);
                   *In60 = *On;
                Endif;
             Endif;
             //...Display Items needing a quote as turquoise...
             *In62 = *Off;
             If Scn_PrtQuote = 'Y';
                Chain (Orr_Itmnum:Orr_MinQtyDt) IVPORRQDTL;
                If Not %Found(IVPORRQDTL);
                   *In62 = *On;
                Else;
                   Scn_PrtQuote = *Blanks;
                Endif;
             Endif;
             // Only show items with no approval date
             If Orr_ApprvDt = *Loval;
                Scn_Option  = *Blank;
                WrkRrn      = WrkRrn + 1;
                Scn_ExpCd   = *Blank;
                Scn_RerunSts = Orr_RerunSts;
                Scn_ItmNum = Orr_ItmNum;

                Chain(N) Scn_ItmNum IVPITEMS;
                If %Found(IVPITEMS);
                   Scn_SDesc = Itm_SDesc;
                Else;
                   Scn_SDesc = *Blanks;
                Endif;

                If %Found(IVPITEMS)
                And Itm_Cntrtp = 'A'
                Or Itm_Cntrtp = 'C'
                Or Itm_Cntrtp = 'J';
                   Scn_Cntrtp = Itm_Cntrtp;
                Else;
                   Scn_Cntrtp = *Blanks;
                Endif;
                // not enough room on screen - if we make the screen 132-wide
                // we can use the whole field
                Select;
                   When Orr_QtyAvail > 99999;
                      Scn_QtyAvail = 99999;
                   When Orr_QtyAvail < -99999;
                      Scn_QtyAvail = -99999;
                   Other;
                      Monitor;
                         Scn_QtyAvail = Orr_QtyAvail;
                      On-Error;
                         Scn_QtyAvail = 0;
                      Endmon;
                Endsl;

                Scn_StartDt = Orr_StartDt;
                // If New Price entered show New Price HI/else show IVPITEMS pri
                If Orr_NewPrice <> *Zeros;
                   Scn_Price72 = Orr_NewPrice;
                   *In52 = *On;
                Else;
                   Scn_Price72 = Itm_Price72;
                   *In52 = *Off;
                Endif;
                // Check if Permot is B
                //    Orr_ItmNum    Chain     IVPITEMS
                Select;
                   When Itm_Permot = 'B' or Itm_Permot = 'Y';
                      Scn_Permot = 'BO';
                   // Check if Permot is H
                   When Itm_Permot = 'H';
                      Scn_Permot = 'HD';
                   Other;
                      Scn_Permot = *Blanks;
                Endsl;
                If Itm_BOQty > 0;
                   Scn_BOQty = Itm_BOQty;
                EndIf;
                // Hidden field
                Scn_MinQtyDt = Orr_MinQtyDt;

                // RI/Red if past start date
                If Scn_StartDt < WrkTodayDt;
                   *In53 = *On;
                Else;
                   *In53 = *Off;
                Endif;
                Scn_NbrWait += 1;
                // Check if Correction Notes
                Chain Scn_ItmNum NOTEPADI;
                If %Found(NOTEPADI)
                And Not_Note1 <> *Blanks;
                   Scn_CNO = 'Y';
                Else;
                   Scn_CNO = ' ';
                Endif;

                // Check if Correction Notes
                Chain Scn_ItmNum B#KITFIL;
                If %Found(B#KITFIL);
                   Scn_Sf1Kit = 'Yes';
                Else;
                   Scn_Sf1Kit = *Blanks;
                Endif;

                //...consignment quanity in pepper...
                // WrkLoc = '68';
                // Chain (Scn_ItmNum:WrkLoc) IVPCNSIV;
                // If %Found(IVPCNSIV);
                   // Scn_CnsQty = Cns_CnsQty - Cns_CnsBil
                   // + Cns_CnsShp + Cns_Cnssd;
                // Else;
                   // Scn_CnsQty = 0;
                // EndIf;

                // WrkLoc = '69';
                // Chain (Scn_ItmNum:WrkLoc) IVPCNSIV;
                // If %Found(IVPCNSIV);
                   // Scn_CnsQty += Cns_CnsQty - Cns_CnsBil
                      // + Cns_CnsShp + Cns_Cnssd;
                // Else;
                   // Scn_CnsQty += 0;
                // EndIf;

                // SOS-2366 Change ConQty to Total;
                // used sql to avoid conflict reading due to
                // one open cursor/odp with multiple active chain
                Exec Sql
                Select Coalesce(Sum(CnsQty - CnsBil + CnsShp + Cnssd), 0)
                Into :Scn_CnsQty
                From IVPCNSIV
                Where ItmNum = :Scn_ItmNum;

                If Scn_CnsQty > 0;
                   *In54 = *On;
                Else;
                   *In54 = *Off;
                EndIf;

                // File for Pages and Binding Info
                Chain Scn_ItmNum IVPITSPC;
                If %Found(IVPITSPC);
                   // Binding info
                   Scn_Bindng = Spc_Bindng;

                   // Pages info
                   Scn_Pages = Spc_Pages;
                Endif;

                 WrkPprItm = Scn_ItmNum;
                 Exsr Sbr_Get_Price_Flags;
                 WrkSugItm = Scn_ItmNum;
                 Exsr Sbr_Get_Suggestion;
                Exsr Sbr_Get_Last_Price_Change_Date;

                Write SFL1;
                Scn_BOQty = *Zeros;
                // If Scan field was filled, position cursor to nearest match
                If Scn_Rrn = 0
                And Scn_ItmNum = WrkStartFld;
                   Scn_Rrn = WrkRrn;
                Endif;
             Endif;
          Enddo;
          //*** Show on Hold records at bottom of subfile **********************

          If WrkViewAll = 'Y';
             *In84 = *On;
             If *In80 = *On;
                Setll *Loval IVLORRITM1;
             Endif;
             If *In81 = *On;
                Setll *Loval IVLORRITM5;
             Endif;
          Else;
             *In84 = *Off;
             If *In80 = *On;
                Setll PrmUser IVLORRITM1;
             Endif;
          Endif;
          Dow 1 = 1;
             // Get Data to fill screen
             If WrkViewAll = 'Y';
                If *In80 = *On;
                   Read(N) IVLORRITM1;
                Endif;
                If *In81 = *On;
                   Read(N) IVLORRITM5;
                Endif;
             Else;
                Reade(N) PrmUser IVLORRITM1;
             Endif;
             If WrkClSf = 'Y';
                Clear Sfl1;
                Leave;
             EndIf;
             Select;
                When *In80 = *On;
                   If %Eof(IVLORRITM1);
                      Leave;
                   Endif;
                When *In81 = *On;
                   If %Eof(IVLORRITM5);
                      Leave;
                   Endif;
             Endsl;
             // Show on hold
             If Orr_Hold <> 'M';
                Iter;
             Endif;
             // Skip items where the job has been created, the item has been ord
             // or the item has been scheduled for rerun
             If Orr_RerunSts <> *Blanks
                and Orr_RerunSts <> 'A'
                and Orr_RerunSts <> 'E'
                and Orr_RerunSts <> 'Q'
                and Orr_RerunSts <> 'N'
             and Orr_RerunSts <> 'R';
                Iter;
             Endif;


             // Show Approved RR Qty on screen if it has been entered
             If Orr_AppRRQty = 0;
                If Orr_Flg6Mo = 'Y';
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'4');
                Else;
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'3');
                Endif;
             Else;
                Scn_EstRRQty = %Editc(Orr_AppRRQty:'4');
             Endif;
             // Higlight if Sts is A or D
             If Orr_RerunSts = 'A'
             Or Orr_RerunSts = 'N'
             Or Orr_RerunSts = 'R';
                *In50 = *On;
             Else;
                *In50 = *Off;
             Endif;
             // Special formatting if Yamaha item with no Xref item#
             *In60 = *Off;
             If Orr_MktCoord = 'YAMAHA';
                Chain Orr_Itmnum IVPYAMXRF;
                If Not %Found(IVPYAMXRF);
                   *In60 = *On;
                Endif;
             Endif;
             //...Display Items needing a quote as turquoise...
             *In62 = *Off;
             If Scn_PrtQuote = 'Y';
                Chain (Orr_Itmnum:Orr_MinQtyDt) IVPORRQDTL;
                If Not %Found(IVPORRQDTL);
                   *In62 = *On;
                Else;
                   Scn_PrtQuote = *Blanks;
                Endif;
             Endif;
             // Only show items with no approval date
             If Orr_ApprvDt = *Loval;
                Scn_Option  = *Blank;
                WrkRrn      = WrkRrn + 1;
                Scn_ExpCd   = *Blank;
                Scn_RerunSts = 'H';
                Scn_ItmNum = Orr_ItmNum;

                Chain(N) Scn_ItmNum IVPITEMS;
                If %Found(IVPITEMS);
                   Scn_SDesc = Itm_SDesc;
                Else;
                   Scn_SDesc = *Blanks;
                Endif;

                Chain(N) Scn_ItmNum IVPITEMS;
                If %Found(IVPITEMS)
                   And Itm_Cntrtp = 'A'
                      Or Itm_Cntrtp = 'C'
                Or Itm_Cntrtp = 'J';
                   Scn_Cntrtp = Itm_Cntrtp;
                Else;
                   Scn_Cntrtp = *Blanks;
                Endif;

                //...consignment quanity in pepper...
                // WrkLoc = '68';
                // Chain (Scn_ItmNum:WrkLoc) IVPCNSIV;
                // If %Found(IVPCNSIV);
                   // Scn_CnsQty = Cns_CnsQty - Cns_CnsBil
                   // + Cns_CnsShp + Cns_Cnssd;
                // Else;
                   // Scn_CnsQty = 0;
                // EndIf;

                // WrkLoc = '69';
                // Chain (Scn_ItmNum:WrkLoc) IVPCNSIV;
                // If %Found(IVPCNSIV);
                   // Scn_CnsQty += Cns_CnsQty - Cns_CnsBil
                      // + Cns_CnsShp + Cns_Cnssd;
                // Else;
                   // Scn_CnsQty += 0;
                // EndIf;

                // SOS-2366 Change ConQty to Total;
                // used sql to avoid conflict reading due to
                // one open cursor/odp with multiple active chain
                Exec Sql
                Select Coalesce(Sum(CnsQty - CnsBil + CnsShp + Cnssd), 0)
                Into :Scn_CnsQty
                From IVPCNSIV
                Where ItmNum = :Scn_ItmNum;

                If Scn_CnsQty > 0;
                   *In54 = *On;
                Else;
                   *In54 = *Off;
                EndIf;

                // not enough room on screen - if we make the screen 132-wide
                // we can use the whole field
                If Orr_QtyAvail > 99999;
                   Scn_QtyAvail = 99999;
                Else;
                   Scn_QtyAvail = Orr_QtyAvail;
                Endif;
                Scn_StartDt = Orr_StartDt;

                // If New Price entered show New Price
                //HI/else show IVPITEMS price
                If Orr_NewPrice <> *Zeros;
                   Scn_Price72 = Orr_NewPrice;
                   *In52 = *On;
                Else;
                   Scn_Price72 = Itm_Price72;
                   *In52 = *Off;
                Endif;
                // Check if Permot is B
                Select;
                   When Itm_Permot = 'B' or Itm_Permot = 'Y';
                      Scn_Permot = 'BO';
                   When Itm_Permot = 'H';
                      Scn_Permot = 'HD';
                   Other;
                      Scn_Permot = *Blanks;
                Endsl;
                If Itm_BOQty > 0;
                   Scn_BOQty = Itm_BOQty;
                EndIf;

                // Hidden field
                Scn_MinQtyDt = Orr_MinQtyDt;
                // RI/Red if past start date
                If Scn_StartDt < WrkTodayDt;
                   *In53 = *On;
                Else;
                   *In53 = *Off;
                Endif;
                Scn_NbrWait += 1;
                // Check if Correction Notes
                Chain Scn_ItmNum NOTEPADI;
                If %Found(NOTEPADI)
                And Not_Note1 <> *Blanks;
                   Scn_CNO = 'Y';
                Else;
                   Scn_CNO = ' ';
                Endif;

                // Check if Correction Notes
                Chain Scn_ItmNum B#KITFIL;
                If %Found(B#KITFIL);
                   Scn_Sf1Kit = 'Yes';
                Else;
                   Scn_Sf1Kit = *Blanks;
                Endif;

                // File for Pages and Binding Info
                Chain Scn_ItmNum IVPITSPC;
                If %Found(IVPITSPC);
                   // Binding info
                   Scn_Bindng = Spc_Bindng;

                   // Pages info
                   Scn_Pages = Spc_Pages;
                Endif;

                 WrkPprItm = Scn_ItmNum;
                 Exsr Sbr_Get_Price_Flags;
                 WrkSugItm = Scn_ItmNum;
                 Exsr Sbr_Get_Suggestion;
                Exsr Sbr_Get_Last_Price_Change_Date;

                Write SFL1;
                Scn_BOQty = *Zeros;
                // If Scan field was filled, position cursor to nearest match
                If Scn_Rrn = 0
                And Scn_ItmNum = WrkStartFld;
                   Scn_Rrn = WrkRrn;
                Endif;
             Endif;
          Enddo;

          If Scn_Rrn = 0;
             Scn_Rrn     = 1;
          Endif;

          If WrkSavLow > WrkRrn;
             WrkSavLow = WrkRrn;
             Scn_Pos2Rrn = WrkSavlow;
          Endif;

          // Subfile empty
          If WrkRrn      = *Zero;
             WrkRrn      = WrkRrn + 1;
             Scn_Rrn     = 1;
             Scn_StartDt = *Loval;
             Scn_SDesc   = '** No records found **';
             Write SFL1;
          Endif;
       Endsr;

       //***********************************************************************
       //* View Detail      **
       //*********************
       Begsr SbrDetail;
          Scn_NbrWait = 0;
          Scn_MktCoord = PrmUser;
          If WrkViewAll = 'Y';
             *In84 = *On;
             If *In80 = *On;
                Setll *Loval IVLORRITM1;
             Endif;
             If *In81 = *On;
                Setll *Loval IVLORRITM5;
             Endif;
          Else;
             *In84 = *Off;
             //***Show records not on hold first
             Setll PrmUser IVLORRITM1;
          Endif;
          Dow 1 = 1;
             // Get Data to fill screen
             If WrkViewAll = 'Y';
                If *In80 = *On;
                   Read(N) IVLORRITM1;
                Endif;
                If *In81 = *On;
                   Read(N) IVLORRITM5;
                Endif;
             Else;
                Reade(N) PrmUser IVLORRITM1;
             Endif;
             Select;
                When *In80 = *On;
                   If %Eof(IVLORRITM1);
                      Leave;
                   Endif;
                When *In81 = *On;
                   If %Eof(IVLORRITM5);
                      Leave;
                   Endif;
             Endsl;

             If Orr_Hold <> *Blanks;
                Iter;
             Endif;
             // Skip items where the job has been created, the item has been ord
             // or the item has been scheduled for rerun
             If Orr_RerunSts <> *Blanks
             and Orr_RerunSts <> 'A'
                and Orr_RerunSts <> 'E'
                and Orr_RerunSts <> 'Q'
                and Orr_RerunSts <> 'N'
                and Orr_RerunSts <> 'R';
                Iter;
             Endif;
             //...Load hidden fields from owner/publisher file...
             Chain Orr_RorefNum IVLOWNPU1;
             If %Found(IVLOWNPU1);
                Scn_Imported = Own_Imported;
                Scn_RoyAprv  = Own_RoyAprv;
                Scn_PrtQuote = Own_PrtQuote;
             Else;
                Scn_Imported = *Blanks;
                Scn_RoyAprv  = *Blanks;
                Scn_PrtQuote = *Blanks;
             Endif;
             // Show Approved RR Qty on screen if it has been entered
             If Orr_AppRRQty = 0;
                If Orr_Flg6Mo = 'Y';
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'4');
                Else;
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'3');
                Endif;
             Else;
                Scn_EstRRQty = %Editc(Orr_AppRRQty:'4');
             Endif;
             // Highlight if Sts is A or D
             If Orr_RerunSts = 'A'
                Or Orr_RerunSts = 'N'
                Or Orr_RerunSts = 'R';
                *In50 = *On;
             Else;
                *In50 = *Off;
             Endif;
             // Special formatting if Yamaha item with no Xref item#
             *In60 = *Off;
             If Orr_MktCoord = 'YAMAHA';
                Chain Orr_Itmnum IVPYAMXRF;
                If Not %Found(IVPYAMXRF);
                   *In60 = *On;
                Endif;
             Endif;
             //...Display Items needing a quote as turquoise...
             *In62 = *Off;
             If Scn_PrtQuote = 'Y';
                Chain (Orr_Itmnum:Orr_MinQtyDt) IVPORRQDTL;
                If Not %Found(IVPORRQDTL);
                   *In62 = *On;
                Else;
                   Scn_PrtQuote = *Blanks;
                Endif;
             Endif;
             // Only show items with no approval date
             If Orr_ApprvDt = *loval;
                Scn_Option2 = *Blank;
                WrkRrn2     = WrkRrn2 + 1;
                Scn_ExpCd2  = *Blank;
                Scn_RerunSts2 = Orr_RerunSts;
                Scn_ItmNum2 = Orr_ItmNum;

                Chain(N) Scn_ItmNum2 IVPITEMS;
                If %Found(IVPITEMS)
                   And Itm_Cntrtp = 'A'
                   Or Itm_Cntrtp = 'C'
                Or Itm_Cntrtp = 'J';
                   Scn_Cntrtp2 = Itm_Cntrtp;
                Else;
                   Scn_Cntrtp2 = *Blanks;
                Endif;
                //    Scn_ItmNum2   Chain     IVPITEMS
                If %Found(IVPITEMS);
                   Scn_SDesc2 = Itm_SDesc;
                Else;
                   Scn_SDesc2 = *Blanks;
                Endif;
                WrkCount = *Zeros;
                WrkCount2 = *Zeros;
                // Fill 24 month arrays
                For WrkIndex = 1 to 12;
                   WrkCount = WrkCount + 1;
                   Arr24nq(WrkCount) = ArrLynq(WrkCount);
                Endfor;

                For WrkIndex = 1 to 12;
                   WrkCount = WrkCount + 1;
                   WrkCount2 = WrkCount2 + 1;
                   Arr24nq(WrkCount) = ArrTynq(WrkCount2);
                Endfor;

                Scn_QtyAvail2 = Orr_QtyAvail;
                Scn_StartDt2 = StartMM + StartDD + StartYY;
                Scn_EstBODt2 = BOMM + BODD + BOYY;
                Scn_MinQtyDt2 = MinMM + MinDD + MinYY;
                Scn_QuotePrc2 = Orr_QuotePrc;
                Scn_EstRRQty2 = %Editc(Orr_EstRRQty:'4');
                Scn_ApprrQty2 = Orr_ApprrQty;
                Scn_NewPrice2 = Orr_NewPrice;
                Scn_Price2 = Itm_Price72;
                Scn_MSWPCD2 = Itm_MSWPCD;
                Scn_MSls2 = *Zeros;
                Scn_WpComt = *Blanks;
                // Get last 12 month sales
                WrkCount = 12 + WrkTodayMM - 12;
                For WrkIndex = 1 to 13;
                   Scn_MSls2 = Scn_MSls2 + Arr24nq(WrkCount);
                   WrkCount = WrkCount + 1;
                Endfor;

     C                   Xfoot     ArrLynq       Scn_LYSls2
                Chain Scn_ItmNum2 IVPSLS2Y;
                If %Found(IVPSLS2Y);
     C                   Xfoot     ArrPynq       Scn_PYSls2
                Else;
                   Scn_PYSls2 = 0;
                Endif;

                // Get last run date
                If Itm_WLstRunMM = *Zero;
                   EvalR Scn_LRDate2 = %Editc(Itm_LstRunMM:'3') +
                   '/' +
                   WrkLstRunYY;
                Else;
                   EvalR Scn_LRDate2 = %Editc(Itm_WLstRunMM:'3') +
                      '/' +
                         WrkWLstRunYY;
                Endif;
                // Get Last Run Qty
                If Itm_WLRQtyNew = *Zeros;
                   Scn_LRQty2 = Itm_LrQty;
                Else;
                   Scn_LRQty2 = Itm_WLRQtyNew;
                Endif;
                // Get First Run Date
                EvalR Scn_FRunDt2 = %Editc(Itm_FrstRunMM:'3') +
                '/' +
                   WrkFrstRunYY;
                // Check if Permot is B
                //    Orr_ItmNum    Chain     IVPITEMS
                Select;
                   When Itm_Permot = 'B' or Itm_Permot = 'Y';
                      Scn_Permot2 = 'BO';
                   When Itm_Permot = 'H';
                      Scn_Permot2 = 'HD';
                   Other;
                      Scn_Permot2 = *Blanks;
                Endsl;
                If Itm_BOQty > 0;
                   Scn_BOQty2 = Itm_BOQty;
                EndIf;
                // Get Wip Comments
                Chain Scn_ItmNum2 IVPWPCMT;
                If %Found(IVPWPCMT);
                   Scn_WpComt = Wcm_WpComt;
                Endif;
                // Hidden field
                Scn_MinQtyDt = Orr_MinQtyDt;
                Scn_NbrWait += 1;
                // Check if Correction Notes
                Chain Scn_ItmNum2 NOTEPADI;
                If %Found(NOTEPADI)
                   And Not_Note1 <> *Blanks;
                   Scn_CNO2 = 'Y';
                Else;
                   Scn_CNO2 = ' ';
                Endif;

                 WrkPprItm = Scn_ItmNum2;
                 Exsr Sbr_Get_Price_Flags;
                 WrkSugItm = Scn_ItmNum2;
                 Exsr Sbr_Get_Suggestion;
                Write SFL2;
                Scn_BOQty2 = *Zeros;
             Endif;
          Enddo;
          //***Show On hold records at bottom of subfile ***********************
          If WrkViewAll = 'Y';
             *In84 = *On;
             If *In80 = *On;
                Setll *Loval IVLORRITM1;
             Endif;
             If *In81 = *On;
                Setll *Loval IVLORRITM5;
             Endif;
          Else;
             *In84 = *Off;
             If *In80 = *On;
                Setll PrmUser IVLORRITM1;
             Endif;
          Endif;
          Dow 1 = 1;
             // Get Data to fill screen
             If WrkViewAll = 'Y';
                If *In80 = *On;
                   Read(N) IVLORRITM1;
                Endif;
                If *In81 = *On;
                   Read(N) IVLORRITM5;
                Endif;
             Else;
                Reade(N) PrmUser IVLORRITM1;
             Endif;
             Select;
                When *In80 = *On;
                   If %Eof(IVLORRITM1);
                      Leave;
                   Endif;
                When *In81 = *On;
                   If %Eof(IVLORRITM5);
                      Leave;
                   Endif;
             Endsl;

             If Orr_Hold <> 'M';
                Iter;
             Endif;
             // Skip items where the job has been created, the item has been ord
             // or the item has been scheduled for rerun
             If Orr_RerunSts <> *Blanks
             and Orr_RerunSts <> 'A'
                and Orr_RerunSts <> 'E'
                and Orr_RerunSts <> 'Q'
                and Orr_RerunSts <> 'N'
                and Orr_RerunSts <> 'R';
                Iter;
             Endif;


             // Show Approved RR Qty on screen if it has been entered
             If Orr_AppRRQty = 0;
                If Orr_Flg6Mo = 'Y';
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'4');
                Else;
                   Scn_EstRRQty = %Editc(Orr_EstRRQty:'3');
                Endif;
             Else;
                Scn_EstRRQty = %Editc(Orr_AppRRQty:'4');
             Endif;
             // Highlight if Sts is A or D
             If Orr_RerunSts = 'A'
                Or Orr_RerunSts = 'N'
             Or Orr_RerunSts = 'R';
                *In50 = *On;
             Else;
                *In50 = *Off;
             Endif;
             // Special formatting if Yamaha item with no Xref item#
             *In60 = *Off;
             If Orr_MktCoord = 'YAMAHA';
                Chain Orr_Itmnum IVPYAMXRF;
                If Not %Found(IVPYAMXRF);
                   *In60 = *On;
                Endif;
             Endif;
             //...Display Items needing a quote as turquoise...
             *In62 = *Off;
             If Scn_PrtQuote = 'Y';
                Chain (Orr_Itmnum:Orr_MinQtyDt) IVPORRQDTL;
                If Not %Found(IVPORRQDTL);
                   *In62 = *On;
                Else;
                   Scn_PrtQuote = *Blanks;
                Endif;
             Endif;
             // Only show items with not approval date
             If Orr_ApprvDt = *loval;
                Scn_Option2 = *Blank;
                WrkRrn2     = WrkRrn2 + 1;
                Scn_ExpCd2  = *Blank;
                Scn_RerunSts2 = 'H';
                Scn_ItmNum2 = Orr_ItmNum;

                Chain(N) Scn_ItmNum2 IVPITEMS;
                If %Found(IVPITEMS)
                   And Itm_Cntrtp = 'A'
                Or Itm_Cntrtp = 'C'
                Or Itm_Cntrtp = 'J';
                   Scn_Cntrtp2 = Itm_Cntrtp;
                Else;
                   Scn_Cntrtp2 = *Blanks;
                Endif;
                Chain(N) Scn_ItmNum2 IVPITEMS;
                If %Found(IVPITEMS);
                   Scn_SDesc2 = Itm_SDesc;
                Else;
                   Scn_SDesc2 = *Blanks;
                Endif;
                WrkCount = *Zeros;
                WrkCount2 = *Zeros;


                // Fill 24 month arrays
                For WrkIndex = 1 to 12;
                   WrkCount = WrkCount + 1;
                   Arr24nq(WrkCount) = ArrLynq(WrkCount);
                Endfor;

                For WrkIndex = 1 to 12;
                   WrkCount = WrkCount + 1;
                   WrkCount2 = WrkCount2 + 1;
                   Arr24nq(WrkCount) = ArrTynq(WrkCount2);
                Endfor;

                Scn_QtyAvail2 = Orr_QtyAvail;
                Scn_StartDt2 = StartMM + StartDD + StartYY;
                Scn_EstBODt2 = BOMM + BODD + BOYY;
                Scn_MinQtyDt2 = MinMM + MinDD + MinYY;
                Scn_QuotePrc2 = Orr_QuotePrc;
                Scn_EstRRQty2 = %Editc(Orr_EstRRQty:'4');
                Scn_ApprrQty2 = Orr_ApprrQty;
                Scn_NewPrice2 = Orr_NewPrice;
                Scn_Price2 = Itm_Price72;
                Scn_MSWPCD2 = Itm_MSWPCD;
                Scn_MSls2 = *Zeros;
                Scn_WpComt = *Blanks;
                // Get last 12 month sales
                WrkCount = 12 + WrkTodayMM - 12;
                For WrkIndex = 1 to 13;
                   Scn_MSls2 = Scn_MSls2 + Arr24nq(WrkCount);
                   WrkCount = WrkCount + 1;
                Endfor;

     C                   Xfoot     ArrLynq       Scn_LYSls2
                Chain Scn_ItmNum2 IVPSLS2Y;
     C                   Xfoot     ArrPynq       Scn_PYSls2

                // Get last run date
                If Itm_WLstRunMM = *Zero;
                   EvalR Scn_LRDate2 = %Editc(Itm_LstRunMM:'3') +
                   '/' +
                   WrkLstRunYY;
                Else;
                   EvalR Scn_LRDate2 = %Editc(Itm_WLstRunMM:'3') +
                   '/' +
                      WrkWLstRunYY;
                Endif;
                // Get Last Run Qty
                If Itm_WLRQtyNew = *Zeros;
                   Scn_LRQty2 = Itm_LrQty;
                Else;
                   Scn_LRQty2 = Itm_WLRQtyNew;
                Endif;
                // Get First Run Date
                EvalR Scn_FRunDt2 = %Editc(Itm_FrstRunMM:'3') +
                '/' +
                   WrkFrstRunYY;
                // Check if Permot is B
                Chain(N) Orr_ItmNum IVPITEMS;
                Select;
                   When Itm_Permot = 'B' or Itm_Permot = 'Y';
                      Scn_Permot2 = 'BO';
                   When Itm_Permot = 'H';
                      Scn_Permot2 = 'HD';
                   Other;
                      Scn_Permot2 = *Blanks;
                Endsl;
                If Itm_BOQty > 0;
                   Scn_BOQty2 = Itm_BOQty;
                EndIf;
                // Get Wip Comments
                Chain Scn_ItmNum2 IVPWPCMT;
                If %Found(IVPWPCMT);
                   Scn_WpComt = Wcm_WpComt;
                Endif;
                // Hidden field
                Scn_MinQtyDt = Orr_MinQtyDt;
                Scn_NbrWait += 1;
                // Check if Correction Notes
                Chain Scn_ItmNum2 NOTEPADI;
                If %Found(NOTEPADI)
                   And Not_Note1 <> *Blanks;
                   Scn_CNO2 = 'Y';
                Else;
                   Scn_CNO2 = ' ';
                Endif;

                 WrkPprItm = Scn_ItmNum2;
                 Exsr Sbr_Get_Price_Flags;
                 WrkSugItm = Scn_ItmNum2;
                 Exsr Sbr_Get_Suggestion;
                Write SFL2;
                Scn_BOQty2 = *Zeros;
             Endif;
          Enddo;

          If Scn_Rrn = 0;
             Scn_Rrn     = 1;
          Endif;

          If WrkSavLow > WrkRrn2;
             WrkSavLow = WrkRrn2;
             Scn_Pos2Rrn = WrkSavlow;
          Endif;

          // Subfile empty
          If WrkRrn2     = *Zero;
             WrkRrn2     = WrkRrn2 + 1;
             Scn_Rrn     = 1;
             Scn_CnsQty = *Zeros;
             Scn_StartDt = *Loval;
             Scn_SDesc   = '** No records found **';
             Write SFL2;
          Endif;
       Endsr;

       //***********************************************************************
       //* Process the Subfile *
       //***********************
       Begsr Sbr_Process;

          If Scn_Startfld > 0;
             Scn_Startfld = 0;
             If Scn_Rrn < WrkSavLow
                And Scn_Rrn <> 0;
                Scn_Pos2Rrn = WrkSavLow;
             Else;
                Scn_Pos2Rrn = Scn_Rrn;
             Endif;
          Endif;

          If Scn_Pos2Rrn = 0;
             Scn_Pos2Rrn = Scn_Rrn;
          Endif;
          If WrkSavOpt = 'A';
             Scn_Pos2Rrn += 1;
             If Scn_Pos2Rrn > WrkRrn;
                Scn_Pos2Rrn = 1;
             Endif;
          Endif;

          // Update screen date and time
          Exsr Sbr_Update_Date_and_Time;
          // Output and read the screen
          *In31       = *On;
          *In32       = *On;
          If WrkView = 'N';
             Write MESSAGE;
             Exfmt SFLCTL1;
          Else;
             Write MESSAGE2;
             Exfmt SFLCTL2;
          Endif;
          Scn_Pos2Rrn = Scn_Rrn;
          *In31       = *Off;
          *In32       = *Off;
          Scn_Msg     = *Blanks;
          Scn_Option  = *Blank;
          *In61 = *Off;
          WrkStartFld = 0;

          Select;
             // F3 = Exit
             When *IN03       = *On;
             // If there are any items in file for this person w/ rerun <> ' ',
                // or 'Q' and Approved date is *loval show Confirmation screen
                If WrkView = 'N';
                   WrkRrn = 1;
                   Dow 1 = 1;
                      Chain WrkRrn SFL1;
                      *IN90 = NOT %FOUND;
                      If *In90 = *On;
                         Leave;
                      Endif;

                      Chain(N) (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;
                      If SdsUser = Orr_MktCoord
                      Or SdsUser = Orr_OthUser;
                         If Scn_ReRunSts <> *Blanks
                         And Scn_ReRunSts <> 'E'
                         And Scn_ReRunSts <> 'Q'
                         And Scn_ReRunSts <> 'H'
                            And Orr_ApprvDt = *Loval;
                            PrmCmd = *Blanks;
                            Callp IVRORRMKT2 (PrmCmd);
                            If PrmCmd = '12';
                               WrkExit = 'Y';
                            Endif;
                            WrkLeave = 'N';
                            Leave;
                         Else;
                            WrkLeave = 'Y';
                         Endif;
                      Endif;

                      WrkRrn = WrkRrn + 1;
                   Enddo;

                Else;
                   // F3 from Detail screen (WrkView = 'Y')
                   WrkRrn2 = 1;
                   Dow 1 = 1;
                      Chain WrkRrn2 SFL2;
                      *IN90 = NOT %FOUND;
                      If *In90 = *On;
                         Leave;
                      Endif;

                      Chain(N) (Scn_ItmNum2:Scn_MinQtyDt) IVPORRITM;
                      If SdsUser = Orr_MktCoord
                      Or SdsUser = Orr_OthUser;
                         If Scn_ReRunSts2 <> *Blanks
                         And Scn_ReRunSts2 <> 'E'
                         And Scn_ReRunSts2 <> 'Q'
                            And Scn_ReRunSts2 <> 'H'
                         And Orr_ApprvDt  = *Loval;
                            Callp IVRORRMKT2 (PrmCmd);
                            WrkLeave = 'N';
                            Leave;
                         Else;
                            WrkLeave = 'Y';
                         Endif;
                      Endif;

                      WrkRrn2 = WrkRrn2 + 1;
                   Enddo;

                Endif;
                If WrkLeave = 'Y';
                   WrkExit     = 'Y';
                Else;
                   WrkLeave = 'N';
                Endif;

                WrkExit = 'Y';
             // F04 = View
             When *In04 = *On;
                If WrkView = 'Y';
                   WrkView = 'N';
                Else;
                   WrkView = 'Y';
                Endif;
             // F6 = Pos to
             When *In06 = *On;
                WrkStartFld = 0;
                Scn_Rrn = 0;
                Scn_Pos2Rrn = 1;
                *In61 = *On;
             // F09 = Toggle
             When *In09 = *On;
                If WrkToggle = '1';
                   WrkToggle = '5';
                   Scn_Ttl2Text = 'Sorted By Start Date';
                   //...Center the Text in the Title line 2
                   WrkLen       = (%Len(Scn_Ttl2Text)
                   - %Len(%Trim(Scn_Ttl2Text)))/2;
                   Scn_Ttl2Text = %Subst(WrkBlanks:1:WrkLen)
                   + Scn_Ttl2Text;
                   *In80 = *Off;
                   *In81 = *On;
                Else;
                   WrkToggle = '1';
                   Scn_Ttl2Text = 'Sorted By Marketing '
                   + 'Coordinator';
                   //...Center the Text in the Title line 2
                   WrkLen       = (%Len(Scn_Ttl2Text)
                      - %Len(%Trim(Scn_Ttl2Text)))/2;
                   Scn_Ttl2Text = %Subst(WrkBlanks:1:WrkLen)
                   + Scn_Ttl2Text;
                   *In80 = *On;
                   *In81 = *Off;
                Endif;

             // F21 = Print
             When *IN21 = *On;
                WrkRrn = 1;
                Open HPL198N8_1;
                Except PrtHeader;
                Dow 1 = 1;
                   If WrkView = 'N';
                      Chain WrkRrn SFL1;
                      *IN90 = NOT %FOUND;
                      WrkItmnum = Scn_ItmNum;
                   Else;
                      Chain WrkRrn SFL2;
                      *IN90 = NOT %FOUND;
                      WrkItmnum = Scn_ItmNum2;
                   Endif;
                   If *In90 = *On;
                      Leave;
                   Endif;

                   Chain WrkItmNum IVPSLS2Y;
                   WrkPYSls = %Xfoot(ArrPynq);

                   Chain(N) WrkItmNum IVPITEMS;
                   WrkLYSls = %Xfoot(ArrLynq);
                   WrkCount = 0;
                   Itm_Wmsls = Itm_WmSls
                      - Itm_Wmpro
                      - Itm_Wmdis
                      + Itm_Wmret;
                   // Fill 24 month arrays
                   For X = 1 to 12;
                      WrkCount = WrkCount + 1;
                      Arr24nq(WrkCount) = ArrLynq(WrkCount);
                   Endfor;

                   WrkCount2 = *Zeros;
                   For X = 1 to 12;
                      WrkCount = WrkCount + 1;
                      WrkCount2 = WrkCount2 + 1;
                      Arr24nq(WrkCount) = ArrTynq(WrkCount2);
                   Endfor;
                   // Get last 12 month sales
                   WrkCount = 12 + WrkTodayMM - 12;
                   For X = 1 to 12;
                      WrkMSls  = WrkMSls  + Arr24nq(WrkCount);
                      WrkCount = WrkCount + 1;
                   Endfor;
                   // Get last run date
                   If Itm_WLstRunMM = *Zero;
                      EvalR WrkLRDate = %Editc(Itm_LstRunMM:'3') +
                         '/' +
                         %Char(Itm_LstRunYY);
                   Else;
                      EvalR WrkLRDate = %Editc(Itm_WLstRunMM:'3') +
                      '/' +
                      %Char(Itm_WLstRunYY);
                   Endif;
                   // Get Last Run Qty
                   If Itm_WLRQtyNew = *Zeros;
                      WrkLRQty  = Itm_LrQty;
                   Else;
                      WrkLRQty  = Itm_WLRQtyNew;
                   Endif;
                   // Get First Run Date
                   EvalR WrkFRunDt  = %Editc(Itm_FrstRunMM:'3') +
                      '/' +
                      %Char(Itm_FrstRunYY);

                   Chain(N) (WrkItmNum:Scn_MinQtyDt) IVPORRITM;
                   WrkRrn = WrkRrn + 1;
                   Except PrtDetail;
                   If *INOF = *On;
                      Except PrtHeader;
                      *InOF = *Off;
                   Endif;
                   WrkMSls = *Zeros;
                Enddo;
                Close HPL198N8_1;
                Scn_Msg = 'The report has been emailed.';

             // All other command keys
             When *IN26       = *On;
                WrkExit     = 'N';

             // Position to field entered
             When Scn_StartFld <> 0;
                WrkStartFld = Scn_StartFld;
                WrkSavLow = 0;
             // Enter - selected record
             Other;
                Exsr SbrSelect;

          Endsl;

       Endsr;

       //***********************************************************************
       //* Record Selected **
       //********************
       Begsr SbrSelect;
          // Read the first changed subfile record
          Dow 1 = 1;
             If WrkView = 'N';
                Readc SFL1;
             Else;
                Readc SFL2;
             Endif;
             If %Eof(IVSORRMKT);
                Leave;
             Endif;

             WrkSavOpt = Scn_Option;
             // Move the cursor back to the last entry
             If Scn_Rrn > 1;
                Scn_Rrn = Scn_Rrn - 1;
             Endif;
             // Expert code entered on summary screen
             Select;
                When Scn_ExpCd <> *Blanks;
                   Callp IVCORRMKT2();
                   In *Lock IVDINQ;
                   $Dtai# = Scn_ItmNum;
                   $Royal = 'O';
                   $Dtacm = *Blanks;
                   $Dtaex = Scn_ExpCd;
                   $Dtatg = 'E';
                   Out IVDINQ;
                   Callp IVRDRIVR();
                   $Royal = 'O';
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;

                // Expert code entered on detail screen
                When Scn_ExpCd2 <> *Blanks;
                   Callp IVCORRMKT2();
                   In *Lock IVDINQ;
                   $Dtai# = Scn_ItmNum2;
                   $Royal = 'O';
                   $Dtacm = *Blanks;
                   $Dtaex = Scn_ExpCd2;
                   $Dtatg = 'E';
                   Out IVDINQ;
                   Callp IVRDRIVR();
                   $Royal = 'O';
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL2;

                // "A" Accept on summary screen
                When Scn_Option = 'A';
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;
                   Chain(N) (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;

                   // needs response to question on flipping to digital
                   Chain(N) Scn_Itmnum IVPITEMS;
                   Chain Itm_Medium IVPDGTPMT;
                   If %Found(IVPDGTPMT) and Orr_MediumDec = 0;
                      PrmRtnCd = '  ';
                      PrmItmnum = %Char(Scn_Itmnum);
                      CallP IVRORRMKTD (PrmItmnum : PrmRtnCd);
                      If PrmRtnCd = '12';
                         // if medium selection required and they pressed F12,
                         // don't update this item
                         Iter;
                      Endif;
                   Endif;

                   If Orr_EstRRQty = 0
                      and Orr_AppRRQty = 0;
                      Scn_Msg = 'You must specify a rerun '
                      + 'quantity.';
                      Leave;
                   Else;
                      Chain (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;
                      Orr_RerunSts = 'A';
                      //...Display warning window for quote .........
                      If Scn_PrtQuote = 'Y';
                         Scn_WdwItmnum = Orr_Itmnum;
                         Exfmt WRNWDW;
                      Endif;
                      //...Set status = 'F' (foreign) if flagged as imported...
                      If Scn_Imported = 'Y';
                         Orr_RerunSts = 'F';
                      Endif;
                      Orr_Hold = *Blanks;
                      Orr_OthUser = SdsUser;
                      Update IV$ORRITM %Fields(Orr_Rerunsts
                                             : Orr_Hold
                                             : Orr_OthUser);
                   Endif;
                   If Orr_MktCoord = 'AMADEUS'
                   or Orr_MktCoord = 'LIMELIGHT';
                      Exsr SbrRerun;
                   Endif;

                // "A" Accept on detail screen
                When Scn_Option2 = 'A';
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL2;
                   Chain(N) (Scn_ItmNum2:Scn_MinQtyDt) IVPORRITM;
                   // needs response to question on flipping to digital
                   Chain(N) Scn_Itmnum2 IVPITEMS;
                   Chain Itm_Medium IVPDGTPMT;
                   If %Found(IVPDGTPMT) and Orr_MediumDec = 0;
                      PrmRtnCd = '  ';
                      PrmItmnum = %Char(Scn_Itmnum2);
                      CallP IVRORRMKTD (PrmItmnum : PrmRtnCd);
                      If PrmRtnCd = '12';
                         // if medium selection required and they pressed F12,
                         // don't update this item
                         Iter;
                      Endif;
                   Endif;

                   If Orr_EstRRQty = 0
                   and Orr_AppRRQty = 0;
                      Scn_Msg = 'You must specify a rerun '
                      + 'quantity.';
                      Leave;
                   Else;
                      Chain (Scn_ItmNum2:Scn_MinQtyDt) IVPORRITM;
                      Orr_RerunSts = 'A';
                      //...Display warning window for quote .........
                      If Scn_PrtQuote = 'Y';
                         Scn_WdwItmnum = Orr_Itmnum;
                         Exfmt WRNWDW;
                      Endif;
                      //...Set status = 'F' (foreign) if flagged as imported...
                      If Scn_Imported = 'Y';
                         Orr_RerunSts = 'F';
                      Endif;
                      Orr_Hold = *Blanks;
                      Orr_OthUser = SdsUser;
                      Update IV$ORRITM %Fields(Orr_Rerunsts
                                             : Orr_Hold
                                             : Orr_OthUser);
                   Endif;
                   If Orr_MktCoord = 'AMADEUS'
                   or Orr_MktCoord = 'LIMELIGHT';
                      Exsr SbrRerun;
                   Endif;

                // "N" Not to be Rerun on summary screen
                When Scn_Option = 'N';
                   Chain (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;
                   Orr_RerunSts = 'N';
                   Orr_Hold = *Blanks;
                   Orr_OthUser = SdsUser;
                   Orr_Dept = *Blanks;
                   Orr_DeptK = *Blanks;
                   Update IV$ORRITM %Fields(Orr_Rerunsts
                                          : Orr_Hold
                                          : Orr_OthUser
                                          : Orr_Dept
                                          : Orr_DeptK);
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option2 = *Blanks;
                   Update SFL1;
                // "N" Not to be Rerun on detail screen
                When Scn_Option2 = 'N';
                   Chain (Scn_ItmNum2:Scn_MinQtyDt) IVPORRITM;
                   Orr_RerunSts = 'N';
                   Orr_Hold = *Blanks;
                   Orr_OthUser = SdsUser;
                   Orr_Dept = *Blanks;
                   Orr_DeptK = *Blanks;
                   Update IV$ORRITM %Fields(Orr_Rerunsts
                                          : Orr_Hold
                                          : Orr_OthUser
                                          : Orr_Dept
                                          : Orr_DeptK);
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option2 = *Blanks;
                   Update SFL2;
                // "H" Hold on summary screen
                When Scn_Option  = 'H';
                   Chain (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;
                   If Orr_Hold = 'M';
                      Orr_Hold = ' ';
                      Orm_Action ='Release';
                   Else;
                      Orr_Hold = 'M';
                      Orm_Action ='Hold';
                   Endif;
                   Update IV$ORRITM %Fields(Orr_Hold);
                   Orm_Itmnum = Scn_ItmNum;
                   Orm_Desc   = 'Marketing';
                   Orm_MaintTs = %Timestamp();
                   Orm_MaintWho = SdsUser;
                   Write IV$ORRMNT;
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;
                // "H" Hold on detail screen
                When Scn_Option2 = 'H';
                   Chain (Scn_ItmNum2:Scn_MinQtyDt) IVPORRITM;
                   If Orr_Hold = 'M';
                      Orr_Hold = ' ';
                      Orm_Action ='Release';
                   Else;
                      Orr_Hold = 'M';
                      Orm_Action ='Hold';
                   Endif;
                   Update IV$ORRITM %Fields(Orr_Hold);
                   Orm_Itmnum = Scn_ItmNum;
                   Orm_Desc   = 'Marketing';
                   Orm_MaintTs = %Timestamp();
                   Orm_MaintWho = SdsUser;
                   Write IV$ORRMNT;
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option2 = *Blanks;
                   Update SFL2;
                // "E" Email on summary screen
                When Scn_Option = 'E';
                   If Scn_RerunSts = 'Q';
                      Scn_Msg = 'You can not email and quote '
                      + 'on the same item.';
                      Leave;
                   Endif;
                   PrmItmnum = %Editc(Scn_ItmNum:'X');
                   Callp IVRORRMKTE (PrmItmNum:Scn_MinQtyDt:PrmOrrMilw);
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;
                // "E" Email on detail screen
                When Scn_Option2 = 'E';
                   If Scn_RerunSts = 'Q';
                      Scn_Msg = 'You can not email and quote '
                              + 'on the same item.';
                      Leave;
                   Endif;
                   PrmItmnum = %Editc(Scn_ItmNum2:'X');
                   Callp IVRORRMKTE (PrmItmNum:Scn_MinQtyDt:PrmOrrMilw);
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL2;
                // "Q" Quote on summary screen
                When Scn_Option = 'Q';
                   If Scn_RerunSts = 'E';
                      Scn_Msg = 'You can not email and quote '
                              + 'on the same item.';
                      Leave;
                   Endif;
                   PrmItmnum = %Editc(Scn_ItmNum:'X');
                   Callp IVRORRMKTQ (PrmItmNum:Scn_MinQtyDt);
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;
                // "Q" Quote on detail screen
                When Scn_Option2 = 'Q';
                   If Scn_RerunSts = 'E';
                      Scn_Msg = 'You can not email and quote '
                              + 'on the same item.';
                      Leave;
                   Endif;
                   PrmItmnum = %Editc(Scn_ItmNum2:'X');
                   Callp IVRORRMKTQ (PrmItmNum:Scn_MinQtyDt);
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option2 = *Blanks;
                   Update SFL2;
                // "C" Change on summary screen
                When Scn_Option = 'C';
                   PrmItmnum = %Editc(Scn_ItmNum:'X');
                   Callp IVRORRMKTC (PrmItmNum:Scn_MinQtyDt:PrmOrrMilw);
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;
                // "C" Change on detail screen
                When Scn_Option2 = 'C';
                   PrmItmnum = %Editc(Scn_ItmNum2:'X');
                   Callp IVRORRMKTC (PrmItmNum:Scn_MinQtyDt:PrmOrrMilw);
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option2 = *Blanks;
                   Update SFL2;
                // "R" Remove on Summary Screen
                When Scn_Option = 'R';
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Exsr SbrDlt;
                   Scn_Option = ' ';
                   Update SFL1;
                // "R" Remove on Detail Screen
                When Scn_Option2 = 'R';
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Exsr SbrDlt2;
                   Scn_Option2 = *Blanks;
                   Update SFL2;
                // "U" Undo/Reset on summary screen
                When Scn_Option  = 'U';
                   Chain (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;
                   If Orr_Hold = 'M';
                      Orr_Hold = ' ';
                      Orm_Itmnum = Scn_ItmNum;
                      Orm_Action ='Release';
                      Orm_Desc   = 'Marketing';
                      Orm_MaintTs = %Timestamp();
                      Orm_MaintWho = SdsUser;
                      Write IV$ORRMNT;
                   Endif;
                   If Orr_RerunSts = 'A'
                      or Orr_RerunSts = 'N';
                      Orr_RerunSts = ' ';
                      Orr_MedAprDt = *Loval;
                      Orr_MediumDec = 0;
                      Orr_Medium = *Blanks;
                      Orr_NoteRecd = ' ';
                   Endif;

                   If Orr_MktCoord = 'AMADEUS'
                      or Orr_MktCoord = 'LIMELIGHT';
                      Chain (Scn_ItmNum:WrkJobNum7) RERUN8;
                      If %Found(RERUN8);
                         Delete B$RERUN;
                      Endif;
                      Chain Scn_Itmnum IVPITEMS;
                      Itm_Delete = ' ';
                      Update IVPITEM$ %Fields(Itm_Delete);
                      Orr_RerunSts = ' ';
                   Endif;

                   Update IV$ORRITM %Fields(Orr_Rerunsts
                                          : Orr_Hold
                                          : Orr_MedAprDt
                                          : Orr_MediumDec
                                          : Orr_Medium
                                          : Orr_NoteRecd);
                   WrkSavLow = WrkRrn;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option  = *Blanks;
                   Update SFL1;
                // "U" Undo/Reset on detail screen
                When Scn_Option2 = 'U';
                   Chain (Scn_ItmNum2:Scn_MinQtyDt) IVPORRITM;
                   If Orr_Hold = 'M';
                      Orr_Hold = ' ';
                      Orm_Itmnum = Scn_ItmNum;
                      Orm_Action ='Release';
                      Orm_Desc   = 'Marketing';
                      Orm_MaintTs = %Timestamp();
                      Orm_MaintWho = SdsUser;
                      Write IV$ORRMNT;
                   Endif;
                   If Orr_RerunSts = 'A'
                   or Orr_RerunSts = 'N';
                      Orr_RerunSts = ' ';
                      Orr_MedAprDt = *Loval;
                      Orr_MediumDec = 0;
                      Orr_Medium = *Blanks;
                      Orr_NoteRecd = ' ';
                   Endif;

                   If Orr_MktCoord = 'AMADEUS'
                   or Orr_MktCoord = 'LIMELIGHT';
                      Chain (Scn_ItmNum:WrkJobNum7) RERUN8;
                      If %Found(RERUN8);
                         Delete B$RERUN;
                      Endif;
                      Chain Scn_Itmnum IVPITEMS;
                      Itm_Delete = ' ';
                      Update IVPITEM$ %Fields(Itm_Delete);
                      Orr_RerunSts = ' ';
                   Endif;

                   Update IV$ORRITM %Fields(Orr_Rerunsts
                                          : Orr_Hold
                                          : Orr_MedAprDt
                                          : Orr_MediumDec
                                          : Orr_Medium
                                          : Orr_NoteRecd);
                   WrkSavLow = WrkRrn2;
                   Scn_Pos2Rrn = WrkSavLow;
                   Scn_Option2 = *Blanks;
                   Update SFL2;

                When Scn_Option = 'O'
                and PrmUser = 'DEHASKE';
                   Chain (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;

                   If Orr_EstRRQty = 0
                   and Orr_AppRRQty = 0;
                      Scn_Msg = 'You must specify a rerun '
                              + 'quantity.';
                      Leave;
                   Endif;

                   If %Found(IVPORRITM);
                      Orr_Dept     = 'RO';
                      Orr_Deptk    = 'Y';
                      Orr_Rerunsts = 'A';
                      Orr_Hold = *Blanks;
                      Orr_OthUser = SdsUser;
                      Update IV$ORRITM %Fields(Orr_Mktcoord
                                              :Orr_RerunSts
                                              :Orr_Dept
                                              :Orr_Deptk
                                              :Orr_Hold
                                              :Orr_OthUser);
                   Endif;

                   Orm_Itmnum = Scn_ItmNum;
                   Orm_Action = 'Buyer to Order';
                   Orm_Desc   = 'Marked for Buyer to Order';
                   Orm_MaintTs = %Timestamp();
                   Orm_MaintWho = SdsUser;
                   Write IV$ORRMNT;

                   Scn_Msg = 'Item '
                           + %Editc(Scn_Itmnum:'Z')
                           + ' has been coded for ordering';
                   Leave;

             Endsl;
          Enddo;

       Endsr;
       //***********************************************************************
       //* Delete Descripion(Summary) **
       //*******************************
       Begsr SbrDlt;
          Scn_WdwItmNum = Scn_ItmNum;
          Scn_WdwSDesc = Scn_SDesc;
          Scn_WdwStatus = Scn_RerunSts;
          Scn_WdwQtyAvl = Scn_QtyAvail;
          Scn_WdwStartDt = Scn_StartDt;
          Scn_WdwPrice = Scn_Price72;
          If Scn_EstRRQty = *Blanks;
             Scn_WdwEstRRQt = 0;
          Else;
             Scn_WdwEstRRQt = %Int(Scn_EstRRQty);
          Endif;
          Scn_WdwMsg = 'Press F23 to confirm delete.';

          Dow 1 = 1;
             // Output and read the screen
             Exfmt DLTWDW;
             Select;
                When *In12 = *On;
                   Leave;

                When *In23 = *On;
                   Chain Scn_WdwItmNum IVPORRITM;
                   If %Found(IVPORRITM);
                      Delete IV$ORRITM;
                      Orm_Itmnum = Scn_ItmNum;
                      Orm_Action ='Deleted';
                      Orm_Desc   = *Blanks;
                      Orm_MaintTs = %Timestamp();
                      Orm_MaintWho = SdsUser;
                      Write IV$ORRMNT;
                      Scn_Msg = 'Item# '
                              + %Char(Scn_WdwItmNum)
                              + ' was deleted.';
                      If Scn_Rrn = WrkRrn;
                         Scn_Rrn = 1;
                         WrkRrn -= 1;
                      Endif;
                      Leave;
                   Else;
                      Scn_WdwMsg = 'Item# not found.';
                   Endif;
             Endsl;

          Enddo;
          Scn_WdwMsg = *Blanks;
       Endsr;
       //***********************************************************************
       //* Delete Descripion (Detail) **
       //*******************************
       Begsr SbrDlt2;
          Chain(N) Scn_ItmNum2 IVPORRITM;
          Scn_WdwItmNum = Scn_ItmNum2;
          Scn_WdwSDesc = Scn_SDesc2;
          Scn_WdwStatus = Scn_RerunSts2;
          Scn_WdwQtyAvl = Scn_QtyAvail2;
          If Orr_StartDt = *Loval;
             Scn_WdwStartDt = *Loval;
          Else;
             Scn_WdwStartDt = Orr_StartDt;
          Endif;
          Scn_WdwPrice = Scn_Price2;
          If Scn_EstRRQty2 = *Blanks;
             Scn_WdwEstRRQt = 0;
          Else;
             Scn_WdwEstRRQt = %Int(Scn_EstRRQty2);
          Endif;
          Scn_WdwMsg = 'Press F23 to confirm delete.';

          Dow 1 = 1;
             // Output and read the screen
             Exfmt DLTWDW;
             Select;
                When *In12 = *On;
                   Leave;

                When *In23 = *On;
                   Chain Scn_WdwItmNum IVPORRITM;
                   If %Found(IVPORRITM);
                      Delete IV$ORRITM;
                      Orm_Itmnum = Scn_ItmNum;
                      Orm_Action ='Deleted';
                      Orm_Desc   = *Blanks;
                      Orm_MaintTs = %Timestamp();
                      Orm_MaintWho = SdsUser;
                      Write IV$ORRMNT;
                      Scn_Msg = 'Item# '
                              + %Char(Scn_WdwItmNum)
                              + ' was deleted.';
                      If Scn_Rrn = WrkRrn;
                         Scn_Rrn = 1;
                         WrkRrn -= 1;
                      Endif;
                      Leave;
                   Else;
                      Scn_WdwMsg = 'Item# not found.';
                   Endif;
             Endsl;

          Enddo;
          Scn_WdwMsg = *Blanks;
       Endsr;
       //***********************************************************************
       //* Mark Item for Rerun        **
       //*******************************
       Begsr SbrRerun;
          Scn_WdwItmNum = Scn_ItmNum;
          Scn_WdwSDesc = Scn_SDesc;
          If Orr_AppRRQty = 0;
             Scn_WdwEstRRQt = Orr_EstRRQty;
          Else;
             Scn_WdwEstRRQt = Orr_AppRRQty;
          Endif;
          Scn_WdwFnshMM = *Zeros;
          Scn_WdwFnshDD = *Zeros;
          Scn_WdwFnshYY = *Zeros;

          Scn_WdwMsg = 'Press Enter to confirm.';

          Dow 1 = 1;
             // Output and read the screen
             Exfmt RRNWDW;
             Select;
                When *In12 = *On;
                   Leave;

                // Mandatory field
                When Scn_WdwFnshMM = 0
                or Scn_WdwFnshDD = 0
                or Scn_WdwFnshYY = 0;
                   Scn_WdwMsg = 'Please enter a date';
                   Iter;

                // Everything ok - write to Rerun file, update inventory
                Other;
                   Clear B$RERUN;
                   Rrn_Item#   = Scn_Itmnum;
                   If Scn_EstRRQty = *Blanks;
                      Rrn_RunQty = *Zeros;
                   Else;
                      Rrn_RunQty = %Int(Scn_EstRRQty);
                   Endif;
                   Rrn_JobNum7 = 0;
                   Rrn_Delete = ' ';
                   Rrn_FinishMM = Scn_WdwFnshMM;
                   Rrn_FinishDD = Scn_WdwFnshDD;
                   Rrn_FinishYYYY = Scn_WdwFnshYY;
                   Rrn_Coment   = *Blanks;
                   Rrn_CompDt = %Int(%Char(WrkTodayMM) + %Char(WrkTodayDD));
                   Write B$RERUN;
                   Chain Scn_Itmnum IVPITEMS;
                   Itm_Delete = 'R';
                   Update IVPITEM$ %Fields(Itm_Delete);
                   Chain (Scn_ItmNum:Scn_MinQtyDt) IVPORRITM;
                   Orr_RerunSts = 'R';
                   Orr_Hold = *Blanks;
                   Orr_OthUser = SdsUser;
                   Update IV$ORRITM %Fields(Orr_Rerunsts
                                          : Orr_Hold
                                          : Orr_OthUser);
                   Leave;
             Endsl;

          Enddo;
          Scn_WdwMsg = *Blanks;
       Endsr;
       //***********************************************************************
       //* Get last price change date
       //********************************
       Begsr Sbr_Get_Last_Price_Change_Date;

          // get last price change date - we need to look for PRICE
          // and PRICE72
          *In58 = *Off;
          WrkPriceDt = *Loval;
          Setll (Scn_Itmnum : 'PRICE     ') IVLMAINT2;
          Reade (Scn_Itmnum : 'PRICE     ') IVLMAINT2;
          If Not %Eof(IVLMAINT2);
             WrkMaintYYYY = Mnt_MaintYYYY;
             WrkMaintMM   = Mnt_MaintMM;
             WrkMaintDD   = Mnt_MaintDD;
             Monitor;
                WrkPriceDt = %Date(WrkMaintDate : *ISO);
             On-Error;
                WrkPriceDt = *Loval;
             Endmon;
          Endif;
          WrkPriceDt72 = *Loval;
          Setll (Scn_Itmnum : 'PRICE72   ') IVLMAINT2;
          Reade (Scn_Itmnum : 'PRICE72   ') IVLMAINT2;
          If Not %Eof(IVLMAINT2);
             WrkMaintYYYY = Mnt_MaintYYYY;
             WrkMaintMM   = Mnt_MaintMM;
             WrkMaintDD   = Mnt_MaintDD;
             Monitor;
                WrkPriceDt72 = %Date(WrkMaintDate : *ISO);
             On-Error;
                WrkPriceDt72 = *Loval;
             Endmon;
          Endif;
          If WrkPriceDt72 > WrkPriceDt;
             Scn_PriceChgD = WrkPriceDt72;
          Else;
             Scn_PriceChgD = WrkPriceDt;
          Endif;
          If Scn_PriceChgD = *Loval;
             WrkPriceDt = *Loval;
             Setll (Scn_Itmnum : 'ADDED     ') IVLMAINT2;
             Reade (Scn_Itmnum : 'ADDED     ') IVLMAINT2;
             If Not %Eof(IVLMAINT2);
                WrkMaintYYYY = Mnt_MaintYYYY;
                WrkMaintMM   = Mnt_MaintMM;
                WrkMaintDD   = Mnt_MaintDD;
                Monitor;
                   WrkPriceDt = %Date(WrkMaintDate : *ISO);
                On-Error;
                   WrkPriceDt = *Loval;
                Endmon;
                *In58 = *On;
                Scn_PriceChgD = WrkPriceDt;
             Endif;
          Endif;
       Endsr;

       //***********************************************************************
       //* Printed price and third-party approval (IVPPRTPRT) **
       //***********************************************************************
       Begsr Sbr_Get_Price_Flags;

          // No row means neither is known yet, shown as blank.
          Scn_PrtPrc = *Blanks;
          Scn_TpAprv = *Blanks;
          Chain WrkPprItm IVPPRTPRT;
          If %Found(IVPPRTPRT);
             Scn_PrtPrc = Ppr_PrtPrc;
             Scn_TpAprv = Ppr_TpAprv;
          Endif;
          Scn_PrtPrc2 = Scn_PrtPrc;
          Scn_TpAprv2 = Scn_TpAprv;

       Endsr;

       //***********************************************************************
       //* Open price suggestion for the item (IVPRPCSUG) **
       //***********************************************************************
       Begsr Sbr_Get_Suggestion;

          // Only one suggestion is open for an item at a time. An
          // override shows the price the editor chose.
          WrkSugStat = *Blanks;
          WrkSugPrc  = *Zeros;
          WrkSugNote = *Blanks;
          Exec Sql
             Select RpcStat,
                    Case When RpcStat = 'O' Then RpcApp72
                         Else RpcSug72 End,
                    RpcNote
               Into :WrkSugStat, :WrkSugPrc, :WrkSugNote
               From IVPRPCSUG
              Where ItmNum = :WrkSugItm
                And RpcStat In ('S', 'G', 'A', 'O')
              Order By RpcCycl Desc
              Fetch First 1 Row Only;
          If SqlCod <> 0;
             WrkSugStat = *Blanks;
             WrkSugPrc  = *Zeros;
             WrkSugNote = *Blanks;
          Endif;

          // Pink on the list: a price change is waiting for a decision
          *In64 = (WrkSugStat = 'S' Or WrkSugStat = 'G');

          Scn_SugPrice2 = WrkSugPrc;
          Scn_SugNote2  = WrkSugNote;

       Endsr;
       //***********************************************************************
       //* Update Date/Time/DayOfWeek  **
       //********************************
       Begsr Sbr_Update_Date_and_Time;

          //...Get time and date and day of week for screen
          WrkDateISO  = %Date();
          Scn_TtlDate = %Date();
          Callp DayofWeek (WrkDateISO:Scn_Ttl2Day);

          SCn_Ttl2Time  = %Time();
       Endsr;

       //***********************************************************************
       //* Set Up   **
       //*************
       Begsr Sbr_Setup;
          WrkView = 'N';
     C                   Move      *Date         WrkTodayDt
          *In80 = *On;

          // ...Reset the screen cursor position to 1
          Scn_Pos2Rrn = 1;

          Scn_Ttl2User  = SdsUser;
          Scn_TtlPgm  = SdsProgram;

          //...Center the title of the report
          WrkLen1 = (%Len(WrkTitle)
          -%Len(%Trim(WrkTitle)))/2;
          WrkTitle = %Subst(WrkBlanks1:1:WrkLen1) +
          WrkTitle;

          //...Get time and date and day of week for report
          WrkTimeofday = %Time();
          WrkDateIso  = %Date();
          Callp DayofWeek (WrkDateISO:PrmDay);

          Scn_TtlText132 = 'On-line Rerun System - Marketing';

          //...Center the title of the screen
          WrkLen = (%Len(Scn_TtlText132) - %Len(%Trim(Scn_TtlText132)))/2;
          Scn_TtlText132 = %Subst(WrkBlanks:1:WrkLen) + Scn_TtlText132;

          //...Center the Text in the Title line 2
          Scn_Ttl2Text = 'Sorted By Marketing Coordinator';
          WrkLen = (%Len(Scn_Ttl2Text) - %Len(%Trim(Scn_Ttl2Text)))/2;
          Scn_Ttl2Text = %Subst(WrkBlanks:1:WrkLen) + Scn_Ttl2Text;

          WrkViewAll  = 'N';
          Chain PrmUser MFLUSERS20;
          Chain PrmUser IVPORRUSRS;
          If (%Found(IVPORRUSRS) and Usr_Viewall = 'Y')
          Or %Found(MFLUSERS20);
             WrkViewAll  = 'Y';
          Endif;

          If PrmUser = 'DEHASKE';
             *In55 = *On;
          Else;
             *In55 = *Off;
          Endif;

          WrkExit = 'N';
          Scn_Rrn = 0;
       Endsr;

       // /****************************************************************\ *
       //<                             PRINTOUT                             >*
       // \****************************************************************/ *
       //...Header............................................................
     OHPL198N8_1E            PrtHeader      1  1
     O                       WrkAsterisk       +  0

     O          E            PrtHeader      1
     O                                         +  0 '**'
     O                       SdsUser           +  1
     O                       WrkDateIso        +  1D*USA
     O                       WrkTitle          +  1
     O                       SdsProgram        +  1
     O                                         +  1 'PAGE'
     O                       Page          Z   +  1
     O                                         +  1 '**'

     O          E            PrtHeader      1
     O                                         +  0 '**'
     O                       PrmDay            + 12
     O                       WrkSubTitle       +  2
     O                       WrkTimeofDay      +  1T*USA
     O                                         + 13 '**'

     O          E            PrtHeader      1
     O                       WrkAsterisk       +  0

     O          E            PrtHeader      1
     O                                         +116 'New'
     O                                         +  3 'Current'
     O                                         +  8 'MTD'
     O                                         + 32 'Last'
     O                                         +  6 'Last'
     O                                         +  5 'First'

     O          E            PrtHeader      1
     O                                         +  0 'Status'
     O                                         +  2 '   Item#'
     O                                         +  2 'Description'
     O                                         + 19 'Qty Avail'
     O                                         +  2 'Start Date'
     O                                         +  4 'BO Date'
     O                                         +  4 'Quote'
     O                                         +  1 'Est RR Qty'
     O                                         +  2 'App RR Qty'
     O                                         +  3 'Price'
     O                                         +  3 'Price'
     O                                         +  2 'DP'
     O                                         +  4 'Units'
     O                                         +  3 '12M Sls'
     O                                         +  3 'LY Sls'
     O                                         +  3 '2Y Sls'
     O                                         +  2 'Run Date'
     O                                         +  2 'Run Qty'
     O                                         +  1 'Run Date'

     O          E            PrtHeader      1
     O                                         +  0 '-------|'
     O                                         +  0 '---------|'
     O                                         +  0 '-------------------------'
     O                                         +  0 '----|'
     O                                         +  0 '---------|'
     O                                         +  0 '-----------|'
     O                                         +  0 '-----------|'
     O                                         +  0 '-------|'
     O                                         +  0 '----------|'
     O                                         +  0 '-----------|'
     O                                         +  0 '-------|'
     O                                         +  0 '--------|'
     O                                         +  0 '---|'
     O                                         +  0 '--------|'
     O                                         +  0 '--------|'
     O                                         +  0 '--------|'
     O                                         +  0 '--------|'
     O                                         +  0 '---------|'
     O                                         +  0 '--------|'
     O                                         +  0 '--------|'

     O          E            PrtDetail      2
     O                       Orr_RerunSts      +  3
     O                       Orr_ItmNum        +  4
     O                       Itm_SDesc         +  2
     O                       Orr_QtyAvail  Z   +  3
     O                       Orr_StartDt       +  2D*USA
     O                       Orr_EstBODt       +  2D*USA
     O                       Orr_QuotePrc  4   +  1
     O                       Orr_EstRRQty  Z   +  2
     O                       Orr_AppRRQty  Z   +  5
     O                       Orr_NewPrice  4   +  1
     O                       Itm_Price72   4   +  1
     O                       Itm_MSWPCD        +  2
     O                       Itm_Wmsls     M   +  3
     O                       WrkMSls       M   +  1
     O                       WrkLYSls      M   +  1
     O                       WrkPYSls      M   +  1
     O                       WrkLRDate         +  2
     O                       WrkLRQty      Z   +  2
     O                       WrkFRunDt         +  2
