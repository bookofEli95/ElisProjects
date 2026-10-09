     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO)
       //***********************************************************************
       //* IVRIFLT
       //* Inv Inq: Items On Float
       //***********************************************************************


       // **********************************************************************
       // ** IF CHANGE ARE MADE TO THIS PROGRAM YOU MIGHT ALSO NEED TO CHANGE **
       // **                             IVVIFLT                              **
       // **********************************************************************


       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Program for FLT expert code - Items on Float.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // SOS2324 09/28/26 PHB Fix SD, Wrapped, Order qty.
       // SRCERR  05/19/22 SRK Fix Source Error
       // H27444  04/16/22 SRK Convert Inventory Inquiry to Portal
       // FIX     07/13/21 TAK If the item is in BOPLINES, don't add the POD qua
       //                      ntity ordered to the estimated ship total.
       // H27444  06/17/21 SRK Convert Inventory Inquiry to Portal
       // H26339  01/07/21 JFH SMP Receiving Problem
       // MISC    11/20/20 SRK Fix Source Errors
       // FIX     08/16/19 CJR Quick Fix
       // FIX     08/16/19 CJR Quick Fix
       // H22303  08/15/19 CJR Inventory Inquiry: Display SD date from original
       //                      order number on FLT screen
       // H22028  02/25/19 TAK Remove orders from the POD system if they're ship
       //                      ped out using a BO pull.
       // H13469  10/30/18 TAK If item is POD Archive or has a ROREFNUM in DGPRO
       //                      REF, don't display twice on screen.
       // H13469  10/09/18 TAK Streamline POD process
       // H13469  09/04/18 TAK Display POD orders until they are sent to shippin
       //                      g docs.  These don't get written to the BO system
       //                       anymore, so sales needs a way to view them.
       // H19269  05/09/18 SAC Inventory Float screen changes
       // FIX     09/08/16 TAK The order tracking option doesn't work. It displa
       //                      ys the wrong order number.
       // H13954  08/15/16 TGM On the IVRIFLT display detail lines associated wi
       //                      th the units shippedin green
       // H13857  04/21/16 NAH Would it be possible to add a line on the 'IVRIFL
       //                      T' screen to click onan SD# and have it bring you
       //                      to order tracking/option #26?
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // H10802  06/05/15 NAH Remove usage of multiple date fields from file OE
       //                      PTRACK. (IVRIFLT)
       // H7016   04/06/15 SRK Convert all Inventory Inquiry Screens to 132
       // FIX     12/09/08 TRO Change screen to our standards
       // I20709  11/03/08 TRO [BB] Convert to Free Format
       // I12066  04/23/07 DRS [SA] Use IVPPERMO Code
       // I13026  02/16/07 TAK [DI] Correct FLT screen
       // DP00758 07/23/05 RML Convert Order Number to 8 Long
       // SA00644 09/01/04 KCS Online Rerun System: Marketing approvals
       // DP00554 11/22/02 SDC Convert help to all use the same program
       // DP00295 05/05/00 SRK Source management phase II
       //   7/02/99 JB  4 digi years
       //   4/03/98 SRK Remove Item with no Shipping Doc Dates
       //   1/30/98 SRK NEW PR GRAM
       //***********************************************************************

       // Screen File
     FIVSIFLT   CF   E             WORKSTN Prefix(Scn_)
     F                                     INFDS(DisplayIO)
     F                                     SFILE(SUBFILE1:WrkRrn1)

       // Input Files
     FIVPITEMS  IF   E           K DISK    Prefix(Itm_)
     FOELLINE2  IF   E           K DISK    Prefix(Li2_)
     FOELLINE7  IF   E           K DISK    Prefix(Li7_)
     F                                     RENAME(OEPLINE$:OE$LINES7)
     FOEPTRACK  IF   E           K DISK    Prefix(Trk_)
     FAR        IF   E           K DISK    Prefix(Ar__)
     FWSLORDDTL9IF   E           K DISK    Prefix(Dt9_)
     FEDLSMPDTL9IF   E           K DISK    Prefix(Smp_)
     FBOJLINE8  IF   E           K DISK    Prefix(BOJ_)
     FDGLPODITM1IF   E           K DISK    Prefix(Pod_)
     FDGLPODOR13IF   E           K DISK    Prefix(Por_)
     FOEPLINES  IF   E           K DISK    Prefix(Lin_)
     F                                     RENAME(OEPLINE$:OE$LINES)
     FOEPLINESHSIF   E           K DISK    Prefix(Lin_)
     FOELLINEH12IF   E           K DISK    Prefix(Oel_)
     F                                     RENAME(OE$LINESHS:OE$LINES12)
     FBOLLINE2  IF   E           K DISK    Prefix(Bo2_)
     F                                     RENAME(OEPLINE$:BO$LINES)
     FDGPROREF  IF   E           K DISK    Prefix(Rrf_)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,dayofweek
      /copy qcopysrc,ivrgetcodg
      /copy qcopysrc,gprduppubc
      /copy qcopysrc,gurgetitm1
      /copy qcopysrc,scrselect
      /copy qcopysrc,ivrfavlst
      /copy qcopysrc,otcdrivr5

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds
      /copy qcopysrc,scn132ttl2
      /copy qcopysrc,displayio

     D PrmType         S             10A
     D PrmCmdKey       S              2A
     D PrmIgPOP        S              1A
     D PrmError        S             80A
     D PrmPubCode      S             50A
     D PrmItmNum       S              8A
     D PrmItmNumA      S              8A
     D PrmOrdNum       S              8A

     D SavStatus       S              2  0 Inz

     D WrkLen          S              2S 0
     D WrkBlanks       S            132A   Inz
     D WrkRrn1         S              6S 0
     D WrkItmnum       S                   Like(Itm_Itmnum)
     D WrkPODate       S              8  0
     D WrkPOYYYY       S              4  0
     D WrkPOMM         S              2  0
     D WrkPODD         S              2  0
     D WrkOrdNum       S              8  0

     D IVDINQRY      E DS                  ExtName(IVDINQRYDS)
     D                                     Dtaara(IVDINQRY)
     D                                     Prefix(Ivd_)

       //***********************************************************************
       //* Main Line *
       //*************
       Scn_Sf1PosRrn = 1;
       Scn_Sf1CsrRrn = 0;
       Scn_Ttl2User = SdsUser;
       Scn_TtlPgm   = SdsProgram;
       Scn_TtlDate  = %Date();
       Scn_Ttl2Time = %Time();
       Callp DAYOFWEEK ( Scn_TtlDate : Scn_Ttl2Day );

       Scn_TtlText = 'Inventory Inquiry';
       WrkLen  = (%Len(Scn_TtlText) - %Len(%Trim(Scn_TtlText)))/2;
       Scn_TtlText = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_TtlText);

       Scn_Ttl2Text = 'Items on Float, lines keyed in Milwaukee, '
                    + 'and back orders';
       WrkLen   = (%Len(Scn_Ttl2Text) - %Len(%Trim(Scn_Ttl2Text)))/2;
       Scn_Ttl2Text = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Ttl2Text);

       In IVDINQRY;
       Scn_Expcd  = Ivd_ExpertCode;
       WrkItmnum  = Ivd_ItmNum;
       Scn_Lookup = %Trim(%Editc(Ivd_ItmNum:'Z'));

       If Ivd_CallFrmRoy = *Blanks;
          *In90 = *Off; // Show Correct Function Keys
          If Ivd_ToggleIE = 'E';
             *In91 = *Off; // Position to Scan Field
             *In92 = *On; // Position to Expert Code
          Else;
             *In91 = *On; // Position to Scan Field
             *In92 = *Off; // Position to Expert Code
          Endif;
       Else;
          *In90 = *On; // Show Correct Function Keys
          *In92 = *On; // Position to Expert Code
          *IN95 = *On; // Protect Item/Pubcode Entry
       Endif;

       Chain (WrkItmnum) IVPITEMS;
       If %Found(IVPITEMS);
          Dow 1 = 1;
             Exsr Sbr_Load_Screen;

             WrkLen   = (%Len(Scn_Message) - %Len(%Trim(Scn_Message)))/2;
             Scn_Message = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Message);

             Write CMDKEYS1;
             Exfmt CONTROL1;
             Scn_Message = *Blanks;
             *In91 = *Off; // Position to Scan Field
             *In92 = *Off; // Position to Expert Code
             *In93 = *Off; // Position to Pubcode
             *In99 = *Off; // RI/Red Message Line

             If Scn_Sf1CsrRRN > *zeros;
                Scn_Sf1PosRrn = Scn_Sf1CsrRRN;
             Else;
                Scn_Sf1PosRrn = DioRrnLow;
             Endif;

             If Ivd_ToggleIE = 'E';
                *In91 = *Off; // Position to Scan Field
                *In92 = *On; // Position to Expert Code
             Else;
                *In91 = *On; // Position to Scan Field
                *In92 = *Off; // Position to Expert Code
             Endif;

             // Call Security System
             If *In25 = *On;
                Callp SCRSELECT ( SdsProgram );
             Endif;

             // Search
             If *In01 = *On;
                In *Lock IVDINQRY;
                Ivd_ExpertCode = Scn_Expcd;
                Ivd_CmdKey = '01';
                Out IVDINQRY;
                Leave;
             Endif;

             // Select
             If *In02 = *On;
                In *Lock IVDINQRY;
                Ivd_ExpertCode = Scn_Expcd;
                Ivd_CmdKey = '02';
                Out IVDINQRY;
                Leave;
             Endif;

             // Exit
             If *In03 = *On;
                In *Lock IVDINQRY;
                Ivd_ExpertCode = Scn_Expcd;
                Ivd_CmdKey = '03';
                Out IVDINQRY;
                Leave;
             Endif;

             // Resume Search
             If *In06 = *On;
                In *Lock IVDINQRY;
                Ivd_ExpertCode = Scn_Expcd;
                Ivd_CmdKey = '06';
                Out IVDINQRY;
                Leave;
             Endif;

             // Goto Favorite Expert Code
             If *In07 = *On;
                Callp IVRFAVLST(Scn_Expcd);
             Endif;

             // Previous Item
             If *In08 = *On;
                In *Lock IVDINQRY;
                Ivd_ItmNum     = Ivd_PrevItmNum;
                Ivd_PrevItmNum = WrkItmnum;
                Out IVDINQRY;
                WrkItmnum = Ivd_ItmNum;
                Scn_Lookup = %Trim(%Editc(Ivd_ItmNum:'Z'));
                Scn_Sf1PosRrn = 1;
             Endif;

             // Toggle Cursor
             If *In09 = *On;
                In *Lock IVDINQRY;
                IF Ivd_ToggleIE = 'I';
                   Ivd_ToggleIE = 'E';
                Else;
                   Ivd_ToggleIE = 'I';
                Endif;
                Out IVDINQRY;
                If Ivd_ToggleIE = 'E';
                   *In91 = *Off; // Position to Scan Field
                   *In92 = *On; // Position to Expert Code
                Else;
                   *In91 = *On; // Position to Scan Field
                   *In92 = *Off; // Position to Expert Code
                Endif;
             Endif;

             // Return
             If *In12 = *On;
                In *Lock IVDINQRY;
                Ivd_ExpertCode = Scn_Expcd;
                Ivd_CmdKey = '12';
                Out IVDINQRY;
                Leave;
             Endif;

             // Process Subfile
             Dow 1 = 1;
                Readc SUBFILE1;
                If %Eof(IVSIFLT);
                   Leave;
                Endif;

                // If order is selected, go to order tracking
                If Scn_Sf1Select = *Blank;
                   Iter;
                Else;
                   If Scn_Sf1OrdNum <> *Zeros;
                      PrmOrdNum = %Char(Scn_Sf1OrdNum);
                      Callp OTCDRIVR5 (PrmOrdNum);
                      Scn_Sf1Select = *Blanks;
                   Endif;
                Endif;
             Enddo;

             // Previous Item (Control Page Up)
             If *In23 = *On;
                Setll (WrkItmnum) IVPITEMS;
                Readp IVPITEMS;
                If %Eof(IVPITEMS);
                   //* WRAP AROUND WHEN BOF IS REACHED.
                   Setgt 99999999 IVPITEMS;
                   Readp IVPITEMS;
                Endif;
                WrkItmnum = Itm_Itmnum;
                Scn_Lookup = %Trim(%Editc(Itm_Itmnum:'Z'));
                Scn_SDesc  = Itm_SDesc;

                In *Lock IVDINQRY;
                Ivd_PrevItmNum = Ivd_ItmNum;
                Ivd_ItmNum = WrkItmnum;
                Out IVDINQRY;
                Scn_Sf1PosRrn = 1;
                Iter;
             Endif;

             // Next Item (Control Page Down)
             If *In24 = *On;
                Setgt (WrkItmnum) IVPITEMS;
                Read IVPITEMS;
                If %Eof(IVPITEMS);
                   //* WRAP AROUND WHEN EOF IS REACHED.
                   Setll 00000000 IVPITEMS;
                   Read IVPITEMS;
                Endif;
                WrkItmnum = Itm_Itmnum;
                Scn_Lookup = %Trim(%Editc(Itm_Itmnum:'Z'));
                Scn_SDesc  = Itm_SDesc;

                In *Lock IVDINQRY;
                Ivd_PrevItmNum = Ivd_ItmNum;
                Ivd_ItmNum = WrkItmnum;
                Out IVDINQRY;
                Scn_Sf1PosRrn = 1;
                Iter;
             Endif;

             // Get Item Number from PubCode
             If *In98 = *On; // Change Indicator on PubCode
                *In98 = *Off; // Change Indicator on PubCode
                PrmPubCode = Scn_PubCode;
                CallP GPRDUPPUBC (PrmPubCode : PrmItmNum);
                If PrmItmNum = *Blanks or PrmItmnum = '0       ';
                   *In91 = *Off; // Position to Scan Field
                   *In92 = *Off; // Position to Expert Code
                   *In93 = *On; // Position to PubCode
                   *In99 = *On; // RI/Red Message Line
                   Scn_Message = 'Invalid Pub Code';
                   Scn_Sf1PosRrn = 1;
                   Iter;
                Else;
                   WrkItmnum = %Int(PrmItmNum);
                   Scn_Lookup = %Trim(%Editc(WrkItmnum:'Z'));

                   In *Lock IVDINQRY;
                   Ivd_PrevItmNum = Ivd_ItmNum;
                   Ivd_ItmNum = WrkItmnum;
                   Out IVDINQRY;
                   Scn_Sf1PosRrn = 1;
                EndIf;
             EndIf;

             // Get Item Number from "Lookup"
             If *In97 = *On; // Change Indicator on Lookup
                *In97 = *Off; // Change Indicator on Lookup
                PrmError      = *Blanks;
                Callp GURGETITM1 ( Scn_Lookup
                                 : PrmItmNumA
                                 : PrmType
                                 : PrmError
                                 : PrmIgPoP
                                 : PrmCmdKey);
                If PrmError <> *Blanks;
                   *In91 = *On; // Position to Scan Field
                   *In92 = *Off; // Position to Expert Code
                   *In93 = *Off; // Position to PubCode
                   *In99 = *On; // RI/Red Message Line
                   Scn_Message = %Trim(PrmError)
                               + ' - '
                               + %Trim(Scn_Lookup);
                   WrkItmnum = Itm_Itmnum;
                   Scn_Lookup = %Trim(%Editc(Itm_Itmnum:'Z'));
                   Scn_Sf1PosRrn = 1;
                   Iter;
                EndIf;
                WrkItmNum = %Int(PrmItmNumA);
                Scn_Lookup = %Trim(%Editc(WrkItmNum:'Z'));

                In *Lock IVDINQRY;
                Ivd_PrevItmNum = Ivd_ItmNum;
                Ivd_ItmNum = WrkItmnum;
                Out IVDINQRY;
                Scn_Sf1PosRrn = 1;
                Iter;
             Endif;

             // Check for Blank Expert Code
             If Scn_Expcd = *Blanks;
                *In91 = *Off; // Position to Scan Field
                *In92 = *On; // Position to Expert Code
                *In93 = *Off; // Position to PubCode
                *In99 = *On; // RI/Red Message Line
                Scn_Message = 'Please enter a Valid Expert Code.';
                Iter;
             Endif;

             // Branch to Another Program
             In *Lock IVDINQRY;
             Ivd_ExpertCode = Scn_Expcd;
             Ivd_CmdKey = '00';
             Out IVDINQRY;

             If Scn_Expcd <> 'FLT';
                Leave;
             Endif;
          Enddo;
       Endif;

       *InLr = *On;
       //*****************
       //* End Main Line *
       //***********************************************************************

       // /******************************************************************\ *
       //<                           SUBROUTINES                              >*
       // \******************************************************************/ *

       //***********************************************************************
       //* Load Screen Information *
       //***************************
       Begsr Sbr_Load_Screen;

          Chain (WrkItmnum) IVPITEMS;
          Scn_SDesc = Itm_SDesc;
          Scn_PubCode = Itm_PubCode;

          // Get Codes
          Callp IVRGETCODG ( %Char(WrkItmnum)
                           : Scn_Permot
                           : Scn_PermotAtr
                           : Scn_Delete
                           : Scn_DeleteAtr
                           : Scn_HldCmt
                           : Scn_HldCmtAtr
                           : Scn_CorNot
                           : Scn_CorNotAtr
                           : Scn_ReRun
                           : Scn_ReRunAtr
                           : Scn_CntTyp
                           : Scn_CntTypAtr
                           : Scn_SubItm
                           : Scn_SubItmAtr
                           : Scn_ClnFut
                           : Scn_ClnFutAtr);

          Scn_TotalOrd   = 0;
          Scn_TotalWrap  = 0;
          Scn_TotalSD    = 0;
          Scn_EstShpTot  = 0;

          *In31 = *On; // Clear Subfile
          Write CONTROL1;
          *In31 = *Off; // Clear Subfile
          WrkRrn1 = *Zeros;
          *In34 = *Off; // Do not show select subfile fields

          // Winona
          Setll (WrkItmnum) OELLINE2;
          Dow 1 = 1;
             Reade (WrkItmnum) OELLINE2;
             If %Eof(OELLINE2);
                Leave;
             Endif;

             // Don't display POD items in this group
             Chain (WrkItmnum:Li2_Ordnum) DGLPODITM1;
             If %Found(DGLPODITM1);
                Iter;
             Endif;

             // Don't display lines that have been fully shipped
             If Li2_QtyOrd - Li2_QtyShp = 0;
                Iter;
             Endif;

             Clear SUBFILE1;

             *In44 = (Li2_Status = 'BO');
             Scn_Sf1EstShp = Li2_QtyOrd - Li2_QtyShp;
             Scn_TotalSD += Scn_Sf1EstShp;
             Scn_Sf1LinTyp   = Li2_LinTyp;
             Scn_Sf1OrdNum   = Li2_OrdNum;
             Scn_Sf1CustNo   = Li2_CustNo;

             If Li2_LinTyp <> 'D';
                Chain (Li2_OrdNum) OEPTRACK;
                If %Found(OEPTRACK);
                   Scn_Sf1SDDATE = Trk_EstShipDt;
                   If Trk_KeyB# = 7;
                      *In40 = *On;
                      Scn_Sf1Loc = 'Milw';
                   Else;
                      Scn_Sf1Loc = 'Win';
                   Endif;

                   //Find earliest order date for Keyed Date field
                   WrkOrdNum = Li2_BOFrom;

                   //first, check if there's any backorders previously
                   Chain (WrkOrdNum : WrkItmnum) BOLLINE2;
                   If %Found(BOLLINE2);
                      //if no other backorders, take this Date
                      If Bo2_BoFrom = Bo2_OrdNum;
                         WrkPoYYYY = Bo2_PoDateYYYY;
                         WrkPoMM   = Bo2_PoDateMM;
                         WrkPoDD   = Bo2_PoDateDD;
                         WrkPoDate = %Int((%EDITC(WrkPoMM:'X')
                                   + %EDITC(WrkPoDD:'X')
                                   + %EDITC(WrkPoYYYY:'X')));
                         Monitor;
                            Scn_Sf1SDDATE = %Date(WrkPoDate:*usa);
                         On-Error;
                            Scn_Sf1SDDATE = *Loval;
                         EndMon;
                      Else;
                         Dow 1 = 1;
                         //If other backorders, check if theres more backorders (recursive)
                            Chain (WrkOrdNum : WrkItmnum) OELLINEH12;
                            If %Found(OELLINEH12);
                            //if this is the oldest backorder on file, take this Date

                               WrkPoYYYY = Oel_PoDateYYYY;
                               WrkPoMM   = Oel_PoDateMM;
                               WrkPoDD   = Oel_PoDateDD;
                               WrkPoDate = %Int((%EDITC(WrkPoMM:'X')
                                         + %EDITC(WrkPoDD:'X')
                                         + %EDITC(WrkPoYYYY:'X')));
                               Monitor;
                                  Scn_Sf1SDDATE = %Date(WrkPoDate:*usa);
                               On-Error;
                                  Scn_Sf1SDDATE = *Loval;
                               EndMon;

                               If Oel_BoFrom = 0;
                                  Leave;
                               Else;
                               //Make this Order number the current OrdNum to Check BOLLINE2 again
                                  WrkOrdNum = Oel_BoFrom;
                                  Iter;
                               EndIf;
                            // this is if the  BoFrom <> OrdNum, but wasnt in OELLINEH12
                            // (prevents a potential infinite loop)
                            // ... grab the previous ordnum's date..
                            Else;
                               WrkPoYYYY = Bo2_PoDateYYYY;
                               WrkPoMM   = Bo2_PoDateMM;
                               WrkPoDD   = Bo2_PoDateDD;
                               WrkPoDate = %Int((%EDITC(WrkPoMM:'X')
                                         + %EDITC(WrkPoDD:'X')
                                         + %EDITC(WrkPoYYYY:'X')));
                               Monitor;
                                  Scn_Sf1SDDATE = %Date(WrkPoDate:*usa);
                               On-Error;
                                  Scn_Sf1SDDATE = *Loval;
                               EndMon;
                               Leave;

                            EndIf;

                         EndDo;
                      EndIf;
                   Else;
                      // this is if the order wasnt in BOPLINES (should never hit this)
                      // this is if a user removes from Line at same time as a user pulls
                      If Scn_Sf1SDDATE = *Loval;
                         Scn_Sf1SDDATE = Trk_EstShipDt;
                      EndIf;

                   EndIf;

                //If Line type = 'D'...
                Else;
                   Iter;
                Endif;

                Chain (Li2_CustNo) AR;
                If %Found(AR);
                   Scn_Sf1Name  = Ar__Name;
                   Scn_Sf1City  = Ar__City;
                   Scn_Sf1State = Ar__State;
                Else;
                   Scn_Sf1Name  = *Blanks;
                   Scn_Sf1City  = *Blanks;
                   Scn_Sf1State = *Blanks;
                Endif;

                Scn_TotalOrd += 1;
                Scn_Sf1QtyOrd    = Li2_QtyOrd;
                Scn_EstShpTot += Scn_Sf1QtyOrd;

                SavStatus = 99; //reset savstatus
                Setll (Li2_OrdNum:WrkItmnum) WSLORDDTL9;
                Dow 1 = 1;
                   Reade (Li2_OrdNum:WrkItmnum) WSLORDDTL9;
                   If %Eof (WSLORDDTL9);
                      Leave;
                   Endif;

                   Scn_Sf1Wrapped   += Dt9_QtyWrap;
                   Scn_TotalWrap += DT9_QtyWrap;

                   If (SavStatus = 99 Or SavStatus = Dt9_Status)
                      And SavStatus <> 0;  //if status = 0 for one line, mark

                      SavStatus = Dt9_Status;

                      //Status descriptions from OneNote "Status Codes in WSP
                      Select;
                         When Dt9_Status = 0;
                            Scn_Sf1Status = 'Not Wrapped';
                         When Dt9_Status = 1;
                            Scn_Sf1Status = 'Wrapped';
                         When Dt9_Status = 2;
                            Scn_Sf1Status = 'Backordered';
                         When Dt9_Status = 4;
                            Scn_Sf1Status = 'Return';
                         When Dt9_Status = 9;
                            Scn_Sf1Status = 'Deleted Line';
                      Endsl;
                   Endif;

                Enddo;

                // Keep Wrapped aligned with what's actually left to ship
                Scn_Sf1Wrapped -= Li2_QtyShp;
                Scn_TotalWrap -= Li2_QtyShp;

                WrkRrn1 += 1;
                Write SUBFILE1;
                *In40 = *Off;
             Endif;
          Enddo;

          // Back Orders
          Setll (WrkItmnum) BOJLINE8;
          Dow 1 = 1;
             Reade (WrkItmnum) BOJLINE8;
             If %Eof(BOJLINE8);
                Leave;
             Endif;

             Clear SUBFILE1;

             Scn_Sf1OrdNum = Boj_OrdNum;
             Scn_Sf1CustNo = Boj_CustNo;
             Scn_Sf1QtyOrd = Boj_QtyOrd;
             Scn_TotalOrd += 1;
             Scn_EstShpTot += Scn_Sf1QtyOrd;

             Chain Scn_Sf1CustNo AR;
             If %Found(AR);
                Scn_Sf1Name  = Ar__Name;
                Scn_Sf1City  = Ar__City;
                Scn_Sf1State = Ar__State;
             Else;
                Scn_Sf1Name  = *Blanks;
                Scn_Sf1City  = *Blanks;
                Scn_Sf1State = *Blanks;
             Endif;

             Chain (Boj_OrdNum) OEPTRACK;
             If %Found(OEPTRACK);
                Scn_Sf1SDDATE = Trk_EstShipDt;
                Scn_Sf1Status = 'BO ' + %Char(Trk_KeyedDt:*MDY);
             Endif;

             //Find earliest order date for Keyed Date field
             WrkOrdNum = Boj_OrdNum;

             //first, check if there's any backorders previously
             Chain (WrkOrdNum : WrkItmnum) BOLLINE2;
             If %Found(BOLLINE2);
                //if no other backorders, take this Date
                If Bo2_BoFrom = Bo2_OrdNum;
                   WrkPoYYYY = Bo2_PoDateYYYY;
                   WrkPoMM   = Bo2_PoDateMM;
                   WrkPoDD   = Bo2_PoDateDD;
                   WrkPoDate = %Int((%EDITC(WrkPoMM:'X')
                             + %EDITC(WrkPoDD:'X')
                             + %EDITC(WrkPoYYYY:'X')));
                   Monitor;
                      Scn_Sf1SDDATE = %Date(WrkPoDate:*usa);
                   On-Error;
                      Scn_Sf1SDDATE = *Loval;
                   EndMon;
                Else;
                   Dow 1 = 1;
                      //If other backorders, check if theres more backorders (recursive)
                      Chain (WrkOrdNum : WrkItmnum) OELLINEH12;
                      If %Found(OELLINEH12);
                         //if this is the oldest backorder on file, take this Date

                         WrkPoYYYY = Oel_PoDateYYYY;
                         WrkPoMM   = Oel_PoDateMM;
                         WrkPoDD   = Oel_PoDateDD;
                         WrkPoDate = %Int((%EDITC(WrkPoMM:'X')
                                   + %EDITC(WrkPoDD:'X')
                                   + %EDITC(WrkPoYYYY:'X')));
                         Monitor;
                            Scn_Sf1SDDATE = %Date(WrkPoDate:*usa);
                         On-Error;
                            Scn_Sf1SDDATE = *Loval;
                         EndMon;

                         If Oel_BoFrom = 0;
                            Leave;
                         Else;
                            //Make this Order number the current OrdNum to Check BOLLINE2 again
                            WrkOrdNum = Oel_BoFrom;
                            Iter;
                         EndIf;
                      // this is if the  BoFrom <> OrdNum, but wasnt in OELLINEH12
                      // (prevents a potential infinite loop)
                      // ... grab the previous ordnum's date..
                      Else;
                         WrkPoYYYY = Bo2_PoDateYYYY;
                         WrkPoMM   = Bo2_PoDateMM;
                         WrkPoDD   = Bo2_PoDateDD;
                         WrkPoDate = %Int((%EDITC(WrkPoMM:'X')
                                   + %EDITC(WrkPoDD:'X')
                                   + %EDITC(WrkPoYYYY:'X')));
                         Monitor;
                            Scn_Sf1SDDATE = %Date(WrkPoDate:*usa);
                         On-Error;
                            Scn_Sf1SDDATE = *Loval;
                         EndMon;
                         Leave;

                      EndIf;

                   EndDo;
                EndIf;
             Else;
                // this is if the order wasnt in BOPLINES (should never hit this)
                // this is if a user removes from Line at same time as a user pulls
                Leave;
             EndIf;


             Chain (Boj_ItmNum) OELLINE2;
             If %Found(OELLINE2);
                Scn_Sf1EstShp += Li2_QtyShp;
             Endif;

             // Do not include a wrapping total for these back orders
             Scn_Sf1Wrapped = 0;

             // Find where this is located
             Scn_Sf1Loc = *Blanks;
             *In43 = *ON;

             WrkRrn1 += 1;
             Write SUBFILE1;
             *In40 = *Off;

          Enddo;

          // SMP Unprocessed
          Setll (WrkItmnum) EDLSMPDTL9;
          Dow 1 = 1;
             Reade (WrkItmnum) EDLSMPDTL9;
             If %Eof(EDLSMPDTL9);
                Leave;
             Endif;

             Clear SUBFILE1;
             Scn_Sf1LinTyp = *Blanks;
             Scn_Sf1OrdNum = Smp_OrdNum;
             Scn_Sf1CustNo = 17009121;

             Scn_Sf1SDDATE = *Loval;
             *IN42   = *On;
             Scn_Sf1Loc = 'SMP';

             Chain Scn_Sf1CustNo AR;
             If %Found(AR);
                Scn_Sf1Name  = Ar__Name;
                Scn_Sf1City  = Ar__City;
                Scn_Sf1State = Ar__State;
             Else;
                Scn_Sf1Name  = *Blanks;
                Scn_Sf1City  = *Blanks;
                Scn_Sf1State = *Blanks;
             Endif;

             Scn_TotalOrd += 1;
             Scn_Sf1QtyOrd    = Smp_QtyOrd - Smp_Qtyshp;
             Scn_EstShpTot += Scn_Sf1QtyOrd;
             Scn_Sf1Status = 'Unfulfilled';

             WrkRrn1 += 1;
             Write SUBFILE1;
             *In42 = *Off;
          Enddo;

          // POD Unprocessed (Not selected for print yet)
          Setll (WrkItmnum) DGLPODITM1;
          Dow 1 = 1;
             Reade (WrkItmnum) DGLPODITM1;
             If %Eof(DGLPODITM1);
                Leave;
             Endif;

             // The item isn't a POD anymore
             // The RERUNA value was changed
             If Itm_Reruna = *Blanks;
             //or Itm_Reruna = 'S';
                Iter;
             Endif;

             // Items with a ROREFNUM in this file are in the BO system
             Chain Itm_Rorefnum DGPROREF;
             If %Found(DGPROREF);
                Iter;
             Endif;

             Clear SUBFILE1;
             Scn_Sf1LinTyp = *Blanks;
             Scn_Sf1OrdNum = Pod_OrdNum;
             Scn_Sf1CustNo = Pod_Custno;

             Scn_Sf1SDDATE = *Loval;
             *IN42   = *On;
             Scn_Sf1Loc = 'POD';

             Chain Scn_Sf1CustNo AR;
             If %Found(AR);
                Scn_Sf1Name  = Ar__Name;
                Scn_Sf1City  = Ar__City;
                Scn_Sf1State = Ar__State;
             Else;
                Scn_Sf1Name  = *Blanks;
                Scn_Sf1City  = *Blanks;
                Scn_Sf1State = *Blanks;
             Endif;

             Scn_TotalOrd = *Zero;

             Chain (Pod_Ordnum:Pod_Line#) OEPLINES;
             If Not %Found(OEPLINES);
                Chain (Pod_Ordnum:Pod_Line#) OEPLINESHS;
                If Not %Found(OEPLINESHS);
                   Scn_Sf1Qtyord = *Zero;
                Endif;
             Endif;

             // If the entire QTY shipped, don't display
             If Itm_Reruna = 'A'
               and Lin_Qtyord = Lin_Qtyshp;
                Iter;
             Endif;

             // Don't display if active order from the BO system
             // OELLINE7 - Keyed by BOFROM
             Chain (Pod_Ordnum:WrkItmnum) OELLINE7;
             If %Found(OELLINE7);
                Iter;
             Endif;

             //Scn_QtyOrd    = Lin_QtyOrd - Lin_Qtyshp;
             Scn_Sf1QtyOrd    = Pod_QtyOrd;
             Scn_Sf1Status = 'Unfulfilled';

             // If item is in BO system, don't display a 2nd time
             Chain (Pod_Ordnum:Pod_Itmnum) BOLLINE2;
             If Not %Found(BOLLINE2);

                // Order/Item not in the BO system, so add the POD QTYORD to the
                // estimated ship total
                Scn_EstShpTot += Scn_Sf1QtyOrd - Lin_Qtyshp;

                WrkRrn1 += 1;
                Write SUBFILE1;
                *In42 = *Off;

             Endif;

          Enddo;

          // POD items in process
          // Use DGPPODORD (Display FINISHED = ' ')
          Setll (WrkItmnum) DGLPODOR13;
          Dow 1 = 1;
             Reade (WrkItmnum) DGLPODOR13;
             If %Eof(DGLPODOR13);
                Leave;
             Endif;

             Clear SUBFILE1;
             Scn_Sf1LinTyp = *Blanks;
             Scn_Sf1OrdNum = Por_PodOrdnum;
             Scn_Sf1CustNo = Por_Custno;

             Scn_Sf1SDDATE = *Loval;
             *IN42   = *On;
             Scn_Sf1Loc = 'POD';

             Chain Scn_Sf1CustNo AR;
             If %Found(AR);
                Scn_Sf1Name  = Ar__Name;
                Scn_Sf1City  = Ar__City;
                Scn_Sf1State = Ar__State;
             Else;
                Scn_Sf1Name  = *Blanks;
                Scn_Sf1City  = *Blanks;
                Scn_Sf1State = *Blanks;
             Endif;

             Scn_TotalOrd = *Zero;

             Chain (Por_PodOrdnum:Por_Line#) OEPLINES;
             If Not %Found(OEPLINES);
                Chain (Por_PodOrdnum:Por_Line#) OEPLINESHS;
                If Not%Found(OEPLINESHS);
                   Scn_Sf1Qtyord = *Zero;
                Endif;

             Endif;

             Scn_Sf1QtyOrd    = Lin_QtyOrd - Lin_Qtyshp;
             Scn_EstShpTot += Scn_Sf1QtyOrd - Lin_Qtyshp;
             Scn_Sf1Status = 'In-Process';

             // If item is in BO system, don't display a 2nd time
             Chain (Por_PodOrdnum:Por_Itmnum) BOLLINE2;
             If Not %Found(BOLLINE2);
                WrkRrn1 += 1;
                Write SUBFILE1;
                *In42 = *Off;
             Endif;

          Enddo;

          If WrkRrn1 = 0;
             Scn_Sf1Name = 'No Records Found ';
             *In34 = *On;
             *In41 = *Off;
             *In42 = *Off;
             *In43 = *Off;
             *In44 = *Off;
             Scn_Sf1CsrRRN = 1;
             Scn_Sf1PosRRN = 1;
             WrkRrn1 += 2;
             Write Subfile1;
          Endif;

          If Scn_Sf1PosRrn < DioRrnLow or Scn_Sf1PosRrn > DioRrnHi;
             Scn_Sf1PosRrn = DioRrnLow;
          Endif;

          If Scn_Sf1PosRrn = 0;
             If Scn_Sf1CsrRRN = 0;
                Scn_Sf1PosRrn = 1;
             Else;
                Scn_Sf1PosRrn = Scn_Sf1CsrRRN;
             Endif;
          Endif;
       Endsr;

