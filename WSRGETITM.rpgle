     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO)ALWNULL(*USRCTL)
       //***********************************************************************
       //* WSRGETITM
       //* Wrap To Screen:Item Entry Screen
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Wrap To Screen Item Entry Program.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // FIX     10/09/26 EFI Do not allow Please Finish (F9) once every line
       //                      on the order has been wrapped.  Pressing it by
       //                      mistake kept the order from invoicing.
       // H7904   07/19/20 SRK Expand the "Pub Code" field.
       // H7904   07/19/20 SRK Expand the "Pub Code" field.
       // H21738  11/04/19 TAK Fix BOM screen for 2 Versions
       // FIX     06/12/19 TAK Source cleanup.
       // H19080  06/11/19 TAK SMP:  Setup inserts.
       // H20510  04/20/19 KMS Update Company Field in OEPSDHDR to removed the "
       //                      Corp"
       // H20522  01/08/19 TGM Create a new way for the value entered in the wra
       //                      pping systems to pull the correct Hal item#.
       // H20522  01/08/19 TGM Create a new way for the value entered in the wra
       //                      pping systems to pull the correct Hal item#.
       // H20984  12/11/18 JFH Prop65 - Wrapping Pop up for Labeling
       // H17354  10/23/17 SRK Change size of Employee number field
       // H17354  10/08/17 SRK Change size of Employee number field
       // H17354  09/24/17 SRK Change size of Employee number field-WSPCONTROL
       //                      WSPPCKERR
       // H17354  09/02/17 SRK Change size of Employee number field-WSPORDDTL
       // H17354  08/17/17 SRK Change the size of the Employee number field.
       // H17354  08/16/17 SRK Change the size of the Employee number field.
       // H14571  05/31/17 SAC Convert IMGMCOVR from Acom to TLAFORMS
       // H16585  05/10/17 KCP EDI: Set up EDI connections for GC Drums and MFI
       //                      Drums accounts
       // H16580  04/13/17 RAT Have the rental wrapping program auto print a new
       //                       BOM sheet for every RH rental order.  Have it pr
       //                      int with the packing list.
       // MISC3   02/22/17 SRK Fix Source Errors (DO)
       // MISC3   05/31/16 SRK Source Fix. Remove Program Defined Variables
       // MISC    05/26/16 TAK Work field clean up.
       // H14167  05/26/16 TAK review WSRGETITM and see if the file IVPMFITEMS i
       //                      s still needed.
       // MISC3   05/26/16 SRK Source Fix. Remove Files not used
       // MISC3   04/08/16 SRK Remove /Free - /End-Free
       // H13364  03/08/16 TGM We have a need to insert a unique card into all H
       //                      enle Urtext items atthe point of pack-out. We wou
       //                      ld like a pop-up window that will notifythe wrapp
       //                      er to insert the card.  This will need to happen
       //                      in all wrapping areas.
       // H8086   08/26/15 TGM Would it be possible when a blank box is needed t
       //                      o have the screen show somewhere during the entir
       //                      e order that a blank box is needed
       // H11104  07/31/15 RAT Change WTS, Single Line, Put to Light, Pick to Li
       //                      ght wrapping programsto look for the Brentwood Hy
       //                      mnal number using IVPXREFDTL.
       // H6157   03/02/15 JFH We would like to enter certain items in order ent
       //                      ry and then have thesystem auto add another item(
       //                      s) to the order.  This will allow Distribution to
       //                      ship single items that require multiple boxes.  W
       //                      ill offer more explanation when needed.
       // H6157   02/05/15 JFH We would like to enter certain items in order ent
       //                      ry and then have thesystem auto add another item(
       //                      s) to the order.  This will allow Distribution to
       //                      ship single items that require multiple boxes.  W
       //                      ill offer more explanation when needed.
       // H6157   01/06/15 JFH We would like to enter certain items in order ent
       //                      ry and then have thesystem auto add another item(
       //                      s) to the order.  This will allow Distribution to
       //                      ship single items that require multiple boxes.  W
       //                      ill offer more explanation when needed.
       // H27289  04/14/14 TAK Pass the item# scanned to WSRWRPINSS.
       // H6566   04/09/14 KCP When Items are backordered during wrapping, recor
       //                      d this in our historyfile.
       // I28732  11/05/12 SRK [DP] Source Management Phase III
       // I28732  11/05/12 SRK [DP] Source Management Phase III
       // I29393  03/21/12 JFH [DI] EAN Labels at the Wrap Stations
       // I29616  10/23/11 KKW [DI] Voice picking system
       // MISC    03/14/11 SRK Remove Rack & Roll Re-order Labels Per Email from
       //                      David J.
       // I28532  02/09/11 JFH [DI] Indigo Labeling
       // FIX     09/30/10 TAK Remove Tote data when an item from the tote is wr
       //                      apped.
       // I26589  05/12/10 TAK [DI] Wrapping Instructions
       // I26589  05/11/10 KKW [DI] Wrapping Instructions
       // I26526  04/29/10 JFH [DI] MFI Change
       // I26148  03/11/10 JFH [CS] Change routing code description
       // I25474  02/26/10 DRS [DP] Remove CTLTSHEAD1 not used
       // I25425  01/08/10 JFH [DI] Henle WTS Screen
       // I24708  01/06/10 JFH [DI] WIM ERRORS: Check if Item has a weight
       // I21927  02/05/09 DRS [DI] Item wrapper Comment
       // I21912  11/18/08 JFH [DI] Please Finish Label
       // I21266  09/30/08 JFH [DI] Henle reminder
       // I14948  08/20/08 TAK [DI] Clear tote data when an item from the toteis
       //                      wrapped, not just keyed/scanned in.
       // I16468  06/06/08 JFH [DP] Label Changes for New Manifest (Varsity)
       // I14948  05/06/08 TAK [DI] Only write please finish record if wrapperis
       //                      at a table.
       // I14948  05/06/08 TAK [DI] Batching system for new building
       // I14948  04/05/08 TAK [DI] Remove order from TSPTOTE if any item inthat
       //                      tote is scanned.
       // FIX     03/20/08 SRK Do not prompt for Supervisor ok on every item
       // I14948  03/15/08 TAK [DI] If wrapper is starting a manifestable orderw
       //                      ith a sub batch, display a message to as
       // MISC    02/26/08 SRK Add call to WSRGOLD for item 312392
       // I16592  11/08/07 JFH [DI] Setup daily processes for Freehand products
       // I12867  03/21/07 TAK [DI] Musician's Friend label and ASN
       // I7766   06/19/06 SRK [DI] Convert to ISBN-13
       // DP00841 10/31/05 JFH Create standard user security system
       // FIX     08/15/05 SRK Do not allow Neg number entered
       // DP00758 07/23/05 SRK Convert Order Number to 8 Long
       // DP00696 04/21/05 DRS Remove MFLROUTE
       // MISC3   04/03/05 TAK Remove reprint label function.
       // DI00485 02/24/05 KCS Change usage of route to route3 using MFPROUTE fi
       //                      le
       // DI00492 11/14/04 KCS Create new bin location field.
       // DI00445 01/13/04 KCS ADD FUNCTION KEY TO WTS
       // DI00438 01/10/04 SDC WTS: Add the table number to the detail file
       // FIX     01/10/04 TAK Add Disney xref file for scan of UPC#.
       // DI00431 09/17/03 TAK WTS: Add pubcod to item entry screen.
       // FIX     08/18/03 TAK Change reprint option to work like maintenance me
       //                      nu reprint.
       // DI00391 07/30/03 SRK Remove WSLORDBCH1 from Program  (Not needed)
       // DI00329 04/27/03 SRK Wrap To Screen
       // DI00329 04/16/03 SRK Wrap To Screen
       // DI00329 04/11/03 TAK Allow scanning of Fender UPC#
       // DI00329 04/08/03 SRK Wrap To Screen
       // DI00329 12/18/02 SRK Wrap To Screen (Parent Project)
       // DI00329 10/11/02 TAK NEW
       //***********************************************************************

       // Screen File
     FWSSGETITM CF   E             WORKSTN Prefix(Scn_)

       // Input Files
     FIVLITM19  IF   E           K DISK    Prefix(Upc_)
     F                                     Rename(IVPITEM$:IV$ITEMS19)
     FIVPITEMS  IF   E           K DISK    Prefix(Itm_)
     FIVPXREFDTLIF   E           K DISK    Prefix(Bbx_)
     FDIPCSTLBL IF   E           K DISK    Prefix(Lbl_)

     FWSLORDDTL1IF   E           K DISK    Prefix(Dt1_)
     F                                     Rename(WS$ORDDTL:WS$ORDDTL1)
     FWSLORDDTL2IF   E           K DISK    Prefix(Dt2_)
     F                                     Rename(WS$ORDDTL:WS$ORDDTL2)
     FWSLORDDTL4IF   E           K DISK    Prefix(Dt4_)
     F                                     Rename(WS$ORDDTL:WS$ORDDTL4)
     FWSLORDDTL8IF   E           K DISK    Prefix(DT8_)
     F                                     Rename(WS$ORDDTL:WS$ORDDTL8)
     FWSLORDDT15IF   E           K DISK    Prefix(D15_)
     F                                     Rename(WS$ORDDTL:WS$ORDDT15)
     FWSPORDHDR IF   E           K DISK    Prefix(Hdr_)
     FWSPMSPKD  IF   E           K DISK    Prefix(Pkd_)
     FMFPUSERS  IF   E           K DISK    Prefix(Usr_)
     FWSPMBOXLINIF   E           K DISK    Prefix(Mbl_)
     FWSLPCKERR3IF   E           K DISK    Prefix(Pe3_)
     F                                     Rename(WS$PCKERR:WS$PCKERR3)
     FIVLFREEHNDIF   E           K DISK    Prefix(Frl_)
     FPTLORDDTL9IF   E           K DISK    Prefix(Pd9_)
     FOEPSDHDR  IF   E           K DISK    Prefix(Hd2_)
     FWSLFENDER1IF   E           K DISK    Prefix(Fnd_)
     FWSLDISNEY1IF   E           K DISK    Prefix(Dsn_)
     FIVLITM15  IF   E           K DISK    Prefix(Ean_)
     F                                     Rename(IVPITEM$:IV$ITEMS15)
     FMFPROUTE  IF   E           K DISK    Prefix(Rte_)
     FIVPIMGMREVIF   E           K DISK    Prefix(Rev_)

       // Update Files
     FWSPCONTROLUF A E           K DISK    Prefix(Ctl_)
     FWSPPLSFNSHUF A E           K DISK    Prefix(Pls_)

       // Update Files
     FWSPORDDTL UF   E           K DISK    Prefix(Dtl_)
     FTSPTOTE   UF   E           K DISK    Prefix(Tot_)

       // Update Files
     FWSPPCKERR IF A E           K DISK    Prefix(Pke_)

       // Output Files
     FWSLORDDTL3O    E             DISK    Prefix(Dt3_)
     F                                     Rename(WS$ORDDTL:WS$ORDDTL3)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,dayofweek
      /copy qcopysrc,dirchkwght
      /copy qcopysrc,dirfrmtbin
      /copy qcopysrc,dirmfiucc
      /copy qcopysrc,lbrplsfnsh
      /copy qcopysrc,lbrmfiucc
      /copy qcopysrc,lbrmfiucc2
      /copy qcopysrc,gurmboxitm
      /copy qcopysrc,gurprop65

      /copy qcopysrc,wsrchkbox
      /copy qcopysrc,wsrclsbox
      /copy qcopysrc,wsrgold
      /copy qcopysrc,wsrmfierrs
      /copy qcopysrc,wsrmissitm
      /copy qcopysrc,wsrmltboxc
      /copy qcopysrc,wsrpckerrc
      /copy qcopysrc,wsrscnfh
      /copy qcopysrc,wsrwrpcmt
      /copy qcopysrc,wsrwrpinss
      /copy qcopysrc,wsrdspwrap
      /copy qcopysrc,wsrprtlbl
      /copy qcopysrc,wsrrplclbl
      /copy qcopysrc,wsrmboxcls
      /copy qcopysrc,wsrmboxwrp
      /copy qcopysrc,wsrmbox1st
      /copy qcopysrc,otrwrthst
      /copy qcopysrc,gurgetbwgh

      /copy qcopysrc,wsrremhght
      /copy qcopysrc,gurdspmsg
      /copy qcopysrc,dirwrpmsg

      /copy qcopysrc,ivrimgmprt
      /copy qcopysrc,gurgetitm8

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds
      /copy qcopysrc,scn80ttl2
      /copy qcopysrc,uplow

     D Index           S              2  0
     D x               S              1  0

     D WrkQtyAry       S              1    Dim(5)
     D WrkCseAry       S              1    Dim(3)
     D Y               S              2  0
     D WrkCharQty      S              5A
     D WrkCharCse      S              3A
     D WrkMfQty        S              3S 0
     D WrkCharItmnum   S              8A
     D WrkItmNum       S              8S 0
     D WrkItmNum2      S              8S 0
     D WrkLen          S              2S 0
     D WrkPickerCmt1   S             25A
     D WrkPickerCmt2   S             25A
     D WrkPickerCmt3   S             25A
     D Wrk20           S             20A
     D Wrk29           S             29A
     D Wrk39           S             39A
     D Wrk78           S             78A
     D WrkStartOver    S              1A
     D WrkErr05Qty     S                   Like(Scn_Qty)
     D WrkFirstPass    S              1A   Inz('Y')
     D WrkExit         S                   Like(Ctl_Exit)
     D WrkTs           S               Z   Inz(*Loval)
     D WrkScanField12  S             12A
     D WrkScanField    S             13S 0
     D WrkScanField18  S             18S 0
     D SavDspItm       S                   Like(Scn_DspItm)
     D SavItmnum       S                   Like(Scn_DspItm)
     D SavItmnum65     S                   Like(Scn_DspItm)
     D SavMBoxItm      S              8  0
     D WrkNextMBox     S              1A   Inz
     D WrkMBox         S              1A   Inz
     D SavBlankPos     S              2S 0
     D WrkBlankPos     S              2S 0
     D WrkBlanks       S            132A   Inz
     D WrkDateISO      S               D   Datfmt(*ISO)
     D SavEmp5         S              5S 0
     D WrkQtyChg       S              5  0 Inz
     D PrmOrdnum       S              8A
     D PrmSubAlph      S              4A
     D PrmItmnum       S              8A
     D WrkError4       S              1A
     D WrkColumn       S              2S 0
     D WrkDoNotWrap    S              1A
     D WrkOrdnum       S              8A
     D WrkDspItm       S                   Like(Scn_DspItm)
     D WrkLineRem      S              6S 0
     D WrkOpenLines    S              6S 0
     D WrkOrdWrapped   S              1A
     D WrkFenderUPC    S              1A
     D WrkDisneyUPC    S              1A
     D WrkUPC          S              1A
     D WrkEAN          S              1A
     D WrkEANPrcExt    S              1A
     D WrkBBHymn       S              1A
     D WrkVCode        S              3S 0 Inz(071)
     D WrkQtyRmn       S                   Like(Dtl_QtyOrd)
     D WrkFHFlag       S              1A   INZ('N')
     D WrkQtyOrd       S                   Like(Dtl_QtyOrd)
     D WrkOK           S              1A
     D WrkReplaceLbls  S              1A   Inz
     D WrkName         S             30A   Inz
     D WrkBoQty        S              5  0
     D WrkWeight       S             12A
     D WrkWeightDec    S             12  2
     D WrkHeight       S             12A
     D PrmRevision     S              2A

     D WrkColor        S              5A   Inz('Green')
     D C               S              1
     D W               S              1    Inz(X'23')
     D G               S              1    Inz(X'21')
     D N               S              1    Inz(X'20')
     D B               S              1    Inz(' ')

       // Number Setup Fields
     D Wrk_1_L1        S              4A
     D Wrk_1_L2        S              4A
     D Wrk_1_L3        S              4A
     D Wrk_1_L4        S              4A
     D Wrk_1_L5        S              4A

     D Wrk_2_L1        S              4A
     D Wrk_2_L2        S              4A
     D Wrk_2_L3        S              4A
     D Wrk_2_L4        S              4A
     D Wrk_2_L5        S              4A

     D Wrk_3_L1        S              4A
     D Wrk_3_L2        S              4A
     D Wrk_3_L3        S              4A
     D Wrk_3_L4        S              4A
     D Wrk_3_L5        S              4A

     D Wrk_4_L1        S              4A
     D Wrk_4_L2        S              4A
     D Wrk_4_L3        S              4A
     D Wrk_4_L4        S              4A
     D Wrk_4_L5        S              4A

     D Wrk_5_L1        S              4A
     D Wrk_5_L2        S              4A
     D Wrk_5_L3        S              4A
     D Wrk_5_L4        S              4A
     D Wrk_5_L5        S              4A

     D Wrk_6_L1        S              4A
     D Wrk_6_L2        S              4A
     D Wrk_6_L3        S              4A
     D Wrk_6_L4        S              4A
     D Wrk_6_L5        S              4A

     D Wrk_7_L1        S              4A
     D Wrk_7_L2        S              4A
     D Wrk_7_L3        S              4A
     D Wrk_7_L4        S              4A
     D Wrk_7_L5        S              4A

     D Wrk_8_L1        S              4A
     D Wrk_8_L2        S              4A
     D Wrk_8_L3        S              4A
     D Wrk_8_L4        S              4A
     D Wrk_8_L5        S              4A

     D Wrk_9_L1        S              4A
     D Wrk_9_L2        S              4A
     D Wrk_9_L3        S              4A
     D Wrk_9_L4        S              4A
     D Wrk_9_L5        S              4A

     D Wrk_0_L1        S              4A
     D Wrk_0_L2        S              4A
     D Wrk_0_L3        S              4A
     D Wrk_0_L4        S              4A
     D Wrk_0_L5        S              4A

     D Wrk___L1        S              4A
     D Wrk___L2        S              4A
     D Wrk___L3        S              4A
     D Wrk___L4        S              4A
     D Wrk___L5        S              4A

     D Error4Ary       S             78A   Dim(12) Based(Error4Ptr)
     D Error4Ptr       S               *   Inz(%Addr(Error4Ds))
     D Error4Ds        DS
     D Scn_Error4Ln01                78A
     D Scn_Error4Ln02                78A
     D Scn_Error4Ln03                78A
     D Scn_Error4Ln04                78A
     D Scn_Error4Ln05                78A
     D Scn_Error4Ln06                78A
     D Scn_Error4Ln07                78A
     D Scn_Error4Ln08                78A
     D Scn_Error4Ln09                78A
     D Scn_Error4Ln10                78A
     D Scn_Error4Ln11                78A
     D Scn_Error4Ln12                78A

       // Parameters
     D PrmMBoxFlg      S              1A
     D PrmMBoxItm      S              8A
     D PrmContinue     S              1A   Inz('2')
     D PrmQtyChg       S              5A
     D PrmCmdKey       S              2A
     D PrmBoxNum       S              5A
     D PrmQty          S              5A
     D PrmConvertType  S              1A   Inz('2')
     D PrmBinloc       S             10A
     D PrmBinZone      S              2A
     D PrmBinAisle     S              1A
     D PrmBinSection   S              3A
     D PrmBinLevel     S              1A
     D PrmBinSlot      S              3A
     D PrmError        S              1A
     D PrmZonePlus     S             11A
     D PrmNoZone       S              8A
     D PrmUCC#         S             10A
     D PrmReprintLbl   S              1A
     D PrmScanFld      S             18A
     D PrmText         S            124A
     D PrmMssg         S            120A
     D PrmMssgColor    S              3A
     D PrmMssgAtr1     S              3A
     D PrmWrapMthd     S              3A   Inz('WTS')
     D PrmBatch4       S              4A   Inz

     D PrmScanNum      S             50A
     D PrmBatchNum     S              4A
     D PrmItmNum2      S              8A
     D PrmWrapType     S             10A
     D PrmType         S             10A
     D PrmErrorMsg     S             80A

       //***********************************************************************
       //* MainLine *
       //************
       Exsr Sbr_Setup;

       // Main Loop
       Dow 1 = 1;

          // See if order should be wrapped
          // A large manifestable order with sub batches should be wrapped
          // and shipped together
          // Display window so the wrapper asks a supervisor if they should
          // start wrapping the order
          If WrkOK <> 'Y';
             Chain ( Ctl_Ordnum : Ctl_Subalph ) WSPORDHDR;
             If %Found(WSPORDHDR);

                Chain (Hdr_Route) MFPROUTE;
                If %Found(MFPROUTE);

                   If Rte_Who <> 'TRUCK'
                      and Rte_Who <> 'AIRFR'
                      and Rte_Who <> 'OCEAN'
                      and Rte_Who <> 'IMEX'
                      and Rte_Who <> 'BWW'
                      and Rte_Who <> 'PILOT'
                      and Rte_Route <> 641
                      and Rte_Route <> 642
                      and Rte_Route <> 643
                      and Ctl_Subalph <> *Blanks;

                      Dow 1 = 1;

                         Scn_Ordnum = Ctl_Ordnum;
                         Scn_Subalph = Ctl_Subalph;
                         Exfmt WRAPORD;

                         // Continue and wrapper will do a please finish if
                         // the order should wait
                         If *In07 = *On;
                            WrkOk = 'Y';
                            Leave;
                         Else;
                            Iter;
                         Endif;
                      Enddo;
                   Endif;
                Endif;
             Endif;
          Endif;

          //Check if they should use a blank box
          Chain Ctl_Ordnum OEPSDHDR;
          If %Found(OEPSDHDR) And Hd2_Company <> 'HAL LEONARD';
             If *In60 <> *On;
                *In65 = *On;
                Scn_BlnkBxTxt = 'Use Blank Box';

                WrkLen = (%Len(Scn_BlnkBxTxt) - %Len(%Trim(Scn_BlnkBxTxt)))/2;
                Scn_BlnkBxTxt = %Subst(WrkBlanks:1:WrkLen) +  Scn_BlnkBxTxt;

             Endif;
          Endif;

          // Load Current Box on Screen
          Scn_CurrBoxA = %Trim(%Editc(Ctl_BoxNum:'Z'));
          WrkLen = (%Len(Scn_CurrBoxA) - %Len(%Trim(Scn_CurrBoxA)))/2;
          Scn_CurrBoxA = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_CurrBoxA);
          *In81 = *On;

          // If 1 item is wrapped then always display the F1=Close Box
          Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;

          Dow 1 = 1;
             Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
             If %Eof(WSLORDDTL1);
                *In56 = *Off;
                Leave;
             Endif;
             If Dt1_WrapSeq <> 0 and Dt1_Status = 1;
                *In56 = *On;
                Leave;
             Endif;
          Enddo;

          // If the Qty needed is 1 then do not show the enter diff qty and
          // do not show F10 Multi close
          //   If Ctl_BoxNum > 1;
          //      *In55 = *On;
          //   Else;
          //      *In55 = *Off;
          //   Endif;

          // If the Wrapping Instructions Were Printed Then Display a
          // message
          Select;

             When Ctl_PickHdr = 'Y' and Ctl_WrapIns = 'Y';
                Chain SdsDevice WSPCONTROL;
                Ctl_PickHdr = ' ';
                Ctl_WrapIns = ' ';
                Update WS$CONTROL %Fields(Ctl_PickHdr:Ctl_WrapIns);

                Scn_Msg001 = 'P I C K E R';
                Scn_Msg003 = 'H E A D E R';
                Scn_Msg005 = 'S H E E T';
                Scn_Msg007 = 'A N D';
                Scn_Msg009 = 'W R A P P I N G';
                Scn_Msg011 = 'I N S T R U C T I O N S';
                Scn_Msg013 = 'H A V E   P R I N T E D';

                Exsr Sbr_MsgCntr;

                *In60 = *On;

             When Ctl_PickHdr = 'Y';
                Chain SdsDevice WSPCONTROL;
                Ctl_PickHdr = ' ';
                Update WS$CONTROL %Fields(Ctl_PickHdr);

                Scn_Msg001 = 'P I C K E R';
                Scn_Msg003 = 'H E A D E R';
                Scn_Msg005 = 'S H E E T';
                Scn_Msg007 = 'H A S';
                Scn_Msg009 = 'P R I N T E D';

                Exsr Sbr_MsgCntr;

                *In60 = *On;

             When Ctl_WrapIns = 'Y';
                Chain SdsDevice WSPCONTROL;
                Ctl_WrapIns = ' ';
                Update WS$CONTROL %Fields(Ctl_WrapIns);

                Scn_Msg001 = 'W R A P P I N G';
                Scn_Msg003 = 'I N S T R U C T I O N S';
                Scn_Msg005 = 'H A V E';
                Scn_Msg007 = 'P R I N T E D';

                Exsr Sbr_MsgCntr;

                *In60 = *On;

             When Ctl_NoItmBox = 'Y';
                Chain SdsDevice WSPCONTROL;
                Ctl_NoItmBox = ' ';
                Update WS$CONTROL %Fields(Ctl_NoItmBox);
                *In60 = *On;
                Exsr Sbr_MsgCntr;

             Other;

                *In60 = *Off;

          Endsl;

          // Load the Lines Remaining on the Screen
          WrkLineRem = 0;

          Setll (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL4;
          Dow 1 = 1;
             Reade (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL4;
             If %Eof(WSLORDDTL4);
                Leave;
             Endif;
             If Dt4_Status <> 9;
                WrkLineRem = WrkLineRem + 1;
             Endif;
          Enddo;

          Scn_LineRem  = %Trim(%Editc(WrkLineRem:'1'));
          WrkLen = (%Len(Scn_LineRem) - %Len(%Trim(Scn_LineRem)))/2;
          Scn_LineRem  = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_LineRem);


          // Update Time / Date and Day of week
          Scn_Ttl2Time     = %Time();
          Scn_TtlDate = %Date();
          WrkDateISO  = %Date();
          Callp DAYOFWEEK(WrkDateISO : Scn_Ttl2Day);

          Exfmt SCREEN;
          SavMBoxItm  = *Zeros;
          WrkNextMBox = *Blanks;
          WrkMBox     = *Blanks;
          WrkError4   = ' ';

          // Clear Non-Valid Characters from the Scan Field
          Scn_ScanField = %Xlate(WrkFrom3:WrkTo3:Scn_ScanField);

          // ERROR6-More Qty Entered in than ordered or Neg Qty Entered
          If (Dtl_QtyOrd < Scn_Qty and Scn_Qty <> 0) or (Scn_Qty < 0);
             Exsr Sbr_Error6;
             Scn_Qty = 0;
             Iter;
          Endif;

          // New Quantity Entered Display the Selection Screen
          If Scn_Qty <> Dtl_QtyOrd and Scn_Qty <> 0;
             WrkDoNotWrap = 'N';
             If Scn_Qty <> 0;

                If Scn_Qty    <> Itm_CasQty
                  and Dtl_QtyOrd >= Itm_CasQty
                  and Itm_CasQty <> 0;
                   WrkErr05Qty = Scn_Qty;
                   Exsr Sbr_Error5;
                Endif;
             Else;
                If Dtl_QtyOrd >  Itm_CasQty and Itm_CasQty <> 0;
                   WrkErr05Qty = Dtl_QtyOrd;
                   Exsr Sbr_Error5;
                Endif;
             Endif;

             If WrkDoNotWrap = 'Y';
                Scn_Qty = 0;
                Iter;
             Endif;

             Exsr Sbr_Error13;

             Exsr Sbr_ClrScreen;
             Iter;
          Endif;

          // Command Key Processing
          // F1 = Close Box on Multi Box
          If (*In01 = *On or *In07 = *On)
                and *In55 = *On;

             Chain SdsDevice WSPCONTROL;
             Ctl_Itmnum = Scn_DspItm;
             Update WS$CONTROL %Fields(Ctl_Itmnum);

             PrmOrdNum  = %EditC(Ctl_OrdNum:'X');
             PrmBoxNum  = %EditC(Ctl_BoxNum:'Z');
             PrmItmNum  = %EditC(Ctl_ItmNum:'X');

             // If MFI then Display Screen telling the wrapper to replace the previous label with the next one.
             If Ctl_Itmnum <> *Zero
                           And ( Hdr_Custno = 17679024    // MFI
                           Or    Hdr_Custno = 17021553 ); // MFI Drums

                // Get UCC for item in box
                Callp WSRMFIERRS ( PrmOrdNum
                                 : Ctl_SubAlph
                                 : PrmBoxNum
                                 : PrmItmNum   );
             Endif;

             Callp WSRMBOXCLS ( PrmOrdNum
                              : Ctl_SubAlph
                              : PrmItmNum   );


             Chain SdsDevice WSPCONTROL;
             WrkExit = Ctl_Exit;
             Ctl_Exit = 'N';

             Update WS$CONTROL %Fields(Ctl_Exit);


             // Get Next MBOX Itm
             SavMBoxItm = Ctl_ItmNum;
             WrkNextMBox = *Blanks;
             WrkMBox = 'Y';
             Setll ( Ctl_OrdNum : Ctl_SubAlph ) WSPMBOXLIN;
             Dow 1 = 1;
                Reade ( Ctl_OrdNum : Ctl_SubAlph ) WSPMBOXLIN;
                If %EOF(WSPMBOXLIN);
                   Leave;
                EndIf;
                Select;
                   When Mbl_Itmnum = Ctl_ItmNum;
                      SavMBoxItm = *Zeros;
                      Iter;
                   When SavMBoxItm = *Zeros;
                      SavMBoxItm = Mbl_ItmNum;
                      WrkNextMBox = 'Y';
                      Leave;
                EndSl;
             EndDo;



             If WrkExit = 'C';
                Exsr Sbr_ClrScreen;
             Else;
                WrkDspItm = Scn_DspItm;
                Exsr Sbr_ClrScreen;
             Endif;

             Chain (Ctl_Ordnum : Ctl_SubAlph : WrkDspItm) WSLORDDTL4;
             If %Found(WSLORDDTL4);
                Scn_ScanField = %Editc(WrkDspItm:'X');
             Else;
                If WrkNextMBox = 'Y' and SavMBoxItm <> *Zeros;
                   Scn_ScanField = %Char(SavMBoxItm);
                Endif;
             Endif;

             If *In07 = *On;
                Exsr Sbr_ClrScreen;
                Callp WSRMISSITM();

                If WrkReplaceLbls = 'Y';
                   Callp WSRRPLCLBL();
                Endif;

                Chain(N) SdsDevice WSPCONTROL;
                If Ctl_Exit = 'Y' or Ctl_Exit = 'F';
                   Callp WSRDSPWRAP();
                   Chain (Ctl_Ordnum:Ctl_SubAlph) WSPPLSFNSH;
                   If %Found(WSPPLSFNSH);
                      Delete WS$PLSFNSH;
                   Endif;
                   *InLr = *On;
                   Return;
                Endif;
                Iter;
             ENDIF;
          Endif;

          // F1 = Close Box
          If *In01 = *On
                and WrkMBox <>'Y'
                and (*In50 = *On or *In56 = *On);

             Chain SdsDevice WSPCONTROL;
             Ctl_Itmnum = Scn_DspItm;
             Update WS$CONTROL %Fields(Ctl_Itmnum);

             If Scn_DspItm <> 0 or Scn_DspDesc = '       Parts & Scores';
                WrkDoNotWrap = 'N';
                If Scn_Qty <> 0;

                   If Scn_Qty <> Itm_CasQty
                     and Dtl_QtyOrd >= Itm_CasQty
                     and Itm_CasQty <> 0;
                      WrkErr05Qty = Scn_Qty;
                      Exsr Sbr_Error5;
                   Endif;
                Else;
                   If Dtl_QtyOrd >  Itm_CasQty and Itm_CasQty <> 0;
                      WrkErr05Qty = Dtl_QtyOrd;
                      Exsr Sbr_Error5;
                   Endif;

                   If WrkDoNotWrap = 'Y';
                      Iter;
                   Endif;

                   Exsr Sbr_Wrap_Item;
                //                  Endif

                Endif;
             Endif;

             Callp WSRCHKBOX();

             Chain(N) SdsDevice WSPCONTROL;

             If WrkMBox <> 'Y';
                If Ctl_NoItmBox = 'Y';
                   Scn_Msg001 = 'No Items in the box';
                Else;
                   // Close  the box
                   Callp WSRCLSBOX();
                Endif;
             Endif;

             Exsr Sbr_ClrScreen;
             Iter;
          Endif;

          // F2 = Wrapper Comment
          If *In02 = *On;
             Callp WSRWRPCMT();
          Endif;

          // F7 = Finish Order
          If *In07 = *On and *In81 = *On and WrkMBox <>'Y';
             If Scn_DspItm  <> 0 or Scn_DspDesc = '       Parts & Scores';
                Chain SdsDevice WSPCONTROL;
                Ctl_Itmnum = Scn_DspItm;
                Update WS$CONTROL %Fields(Ctl_Itmnum);

                WrkDoNotWrap = 'N';

                If Scn_Qty <> 0;

                   If Scn_Qty    <> Itm_CasQty
                     and Dtl_QtyOrd >= Itm_CasQty
                     and Itm_CasQty <> 0;
                      WrkErr05Qty = Scn_Qty;
                      Exsr Sbr_Error5;
                   Endif;
                Else;
                   If Dtl_QtyOrd >  Itm_CasQty and Itm_CasQty <> 0;
                      WrkErr05Qty = Dtl_QtyOrd;
                      Exsr Sbr_Error5;
                   Endif;
                Endif;

                If WrkDoNotWrap = 'Y';
                   Iter;
                Endif;

                Exsr Sbr_Wrap_Item;

             Endif;

             Exsr Sbr_ClrScreen;
             Callp WSRMISSITM();

             If WrkReplaceLbls = 'Y';
                Callp WSRRPLCLBL();
             Endif;

             Chain(N) SdsDevice WSPCONTROL;
             If Ctl_Exit = 'Y' or Ctl_Exit = 'F';
                Callp WSRDSPWRAP();
                Chain (Ctl_Ordnum:Ctl_SubAlph) WSPPLSFNSH;
                If %Found(WSPPLSFNSH);
                   Delete WS$PLSFNSH;
                Endif;
                *InLr = *On;
                Return;
             Endif;
             Iter;
          Endif;

          // F8 = Height Remaining
          If *In08 = *On;
             Callp WSRREMHGHT(%Char(Ctl_OrdNum):Ctl_SubAlph:WrkHeight);

             *In08 = *Off;
             *In12 = *Off;
          Endif;

          // F9 = Please Finish
          If *In09 = *On;
             If Scn_DspItm  <> 0 or Scn_DspDesc = '       Parts & Scores';
                Exsr Sbr_Error9;
             Endif;

             // Do not allow Please Finish when the entire order has been
             // scanned and wrapped, the order would not invoice.  Checked
             // after Error 9 since that window can wrap the last item.
             Exsr Sbr_ChkOrdWrap;
             If WrkOrdWrapped = 'Y';
                PrmMssg = 'All items on this order are wrapped. Please '
                        + 'Finish is not allowed - finish the order instead.';
                PrmMssgColor = 'RED';
                PrmMssgAtr1 = 'RI';
                Callp GURDSPMSG (PrmMssg:PrmMssgColor:PrmMssgAtr1);
                Exsr Sbr_ClrScreen;
                Iter;
             Endif;

             // Put a '9' in the Exit flag to indicate that this is from Please Finish
             Chain SdsDevice WSPCONTROL;
             Ctl_Exit    = '9';
             Update WS$CONTROL %Fields(Ctl_Exit);

             // Print Please Finish Label
             PrmOrdNum  = %EditC(Ctl_OrdNum:'Z');
             PrmSubAlph = Ctl_SubAlph;
             PrmBoxNum  = %EditC(Ctl_BoxNum:'Z');
             Callp LBRPLSFNSH( PrmOrdNum : PrmSubAlph : PrmBoxNum );

             // If there were errors display the Picker error Comment screen
             Chain (Ctl_Ordnum : Ctl_SubAlph : Ctl_EmpNum6 : WrkTs) WSLPCKERR3;
             If %Found(WSLPCKERR3);
                Callp WSRPCKERRC();
             Endif;

             Chain SdsDevice WSPCONTROL;
             Ctl_Exit    = 'Y';
             Update WS$CONTROL %Fields(Ctl_Exit);

             // Only keep track of a please finish if wrapper is at a wrapping station
             If %Subst(SdsDevice:1:5) = 'TABLE'
                   or %Subst(SdsDevice:1:3) = 'PUT'
                   or %Subst(SdsDevice:1:3) = 'TBL';
                Chain (Ctl_Ordnum:Ctl_Subalph) WSPPLSFNSH;
                If Not %Found(WSPPLSFNSH);

                   Pls_Ordnum = Ctl_Ordnum;
                   Pls_Subalph = Ctl_Subalph;
                   Pls_TS      = %Timestamp();
                   Pls_Station = SdsDevice;
                   Write WS$PLSFNSH;
                Else;
                   Delete WS$PLSFNSH;
                   Pls_Ordnum = Ctl_Ordnum;
                   Pls_Subalph = Ctl_Subalph;
                   Pls_TS      = %Timestamp();
                   Pls_Station = SdsDevice;
                   Write WS$PLSFNSH;
                Endif;
             Endif;

             *InLr = *On;
             Leave;
          Endif;

          // F10 = Multi Box Close
          If *In10 = *On
                 and *In50 = *On
                 and *In54 = *On
                 and *In55 = *Off;
             Chain SdsDevice WSPCONTROL;
             Ctl_Itmnum = Scn_DspItm;

             Update WS$CONTROL %Fields(Ctl_Itmnum);

             // If MFI then Display Screen telling the wrapper to replace the previous label with the next one.
             If Ctl_Itmnum <> *Zero
                           And ( Hdr_Custno = 17679024    // MFI
                           Or    Hdr_Custno = 17021553 ); // MFI Drums

                PrmOrdNum  = %EditC(Ctl_OrdNum:'X');
                PrmBoxNum  = %EditC(Ctl_BoxNum:'Z');
                PrmItmNum  = %EditC(Ctl_ItmNum:'X');
                // Get UCC for item in box
                Callp WSRMFIERRS ( PrmOrdNum
                                 : Ctl_SubAlph
                                 : PrmBoxNum
                                 : PrmItmNum   );
             Endif;


             Callp WSRMLTBOXC();

             Chain SdsDevice WSPCONTROL;
             WrkExit = Ctl_Exit;
             Ctl_Exit = 'N';

             Update WS$CONTROL %Fields(Ctl_Exit);

             If WrkExit = 'C';
                Exsr Sbr_ClrScreen;
             Else;
                WrkDspItm = Scn_DspItm;
                Exsr Sbr_ClrScreen;
             Endif;

             Chain (Ctl_Ordnum : Ctl_SubAlph : WrkDspItm) WSLORDDTL4;
             If %Found(WSLORDDTL4);
                Scn_ScanField = %Editc(WrkDspItm:'X');
             Endif;
          Endif;

          // F12 = Cancel Item
          If *In12 = *On;
             Exsr Sbr_ClrScreen;
             If *In55 = *On;
             // Cancel all multi-boxed items that are part of this item.

             EndIf;
             Iter;
          Endif;

          // No Item Entered and No Change to Quantity then Redisplay the screen
          If Scn_Qty = 0 and Scn_ScanField = *Blanks;
             Iter;
          Endif;

          // No Change in Qty and change in itm number wrap item
          If Scn_DspItm <> 0  or Scn_DspDesc = '       Parts & Scores';
             WrkDoNotWrap = 'N';
             If Scn_Qty <> 0;

                If Scn_Qty <> Itm_CasQty
                  and Dtl_QtyOrd >= Itm_CasQty
                  and Itm_CasQty <> 0;
                   WrkErr05Qty = Scn_Qty;
                   Exsr Sbr_Error5;
                Endif;
             Else;
                If Dtl_QtyOrd >  Itm_CasQty and Itm_CasQty <> 0;
                   WrkErr05Qty = Dtl_QtyOrd;
                   Exsr Sbr_Error5;
                Endif;
             Endif;

             If WrkDoNotWrap = 'Y';
                Iter;
             Endif;

             Exsr Sbr_Wrap_Item;
          Endif;

          Scn_Qty        = 0;
          Scn_DspItm     = 0;
          Scn_DspDesc    = *Blanks;
          Scn_DspPubcode = *Blanks;
          *In50 = *Off;
          *In51 = *Off;
          *In52 = *Off;
          *In53 = *Off;
          *In54 = *Off;
          *In55 = *Off;
          *In81 = *Off;
          WrkFenderUPC   = ' ';
          WrkDisneyUPC   = ' ';
          WrkUPC         = ' ';
          WrkEan         = ' ';
          WrkEanPrcExt   = ' ';
          WrkBBHymn      = ' ';
          WrkScanfield   = 0;
          WrkScanfield18 = 0;
          WrkScanField12 = *Blanks;

          If Scn_ScanField = *Blanks;
             Iter;
          Endif;

          If Scn_ScanField = '890765002001'
             or Scn_ScanField = '884088217105'
             or Scn_ScanField = '639000'
             or Scn_ScanField = '639500'
             or Scn_ScanField = '00639000'
             or Scn_ScanField = '00639500'
             or Scn_ScanField = '0639000'
             or Scn_ScanField = '0639500'
             or Scn_ScanField = '000639000'
             or Scn_ScanField = '000639500'
             or Scn_ScanField = '0000639000'
             or Scn_ScanField = '0000639500';

             // Check to see that Freehand only gets 639500
             If Hdr_Custno = 9001888;
                If Scn_ScanField = '639000' or Scn_ScanField = '890765002001'
                 OR Scn_ScanField = '00639000' or Scn_ScanField = '0639000'
                 OR Scn_ScanField = '000639000' or Scn_ScanField = '0000639000';
                   Dow 1 = 1;
                      Exfmt Error16;
                      Scn_DspItm = 0;
                      Scn_ScanField = *Blanks;
                      If *In12 = *On;
                         Leave;
                      Endif;
                   Enddo;
                   Iter;
                Endif;
             Else;
                If Scn_ScanField = '639500' or Scn_ScanField = '884088217105'
                 or Scn_ScanField = '00639500' or Scn_ScanField = '0639500'
                 or Scn_ScanField = '000639500' or Scn_ScanField = '0000639500';
                   Dow 1 = 1;
                      Exfmt Error15;
                      Scn_DspItm = 0;
                      Scn_ScanField = *Blanks;
                      If *In12 = *On;
                         Leave;
                      Endif;
                   Enddo;
                   Iter;
                Endif;
             Endif;

             Exsr Sbr_Scan_FreeHand;
             If WrkFHFlag = 'Y';
                Scn_ScanField = *Blanks;
                Iter;
             Endif;
          Endif;

          // If a Parts & Scores Barcode was scanned
          If %Subst(Scn_ScanField:1:2) = 'PS';
             WrkScanField12 = Scn_Scanfield;
             Chain (Ctl_Ordnum : Ctl_SubAlph : WrkScanField12) WSLORDDT15;
             If Not %Found(WSLORDDT15);
                Scn_Err14Txt1 = Scn_ScanField;
                WrkLen = (%Len(Scn_Err14Txt1)
                    -%Len(%Trim(Scn_Err14Txt1)))/2;
                Scn_Err14Txt1= %Subst(WrkBlanks:1:WrkLen)+
                    %Trim(Scn_Err14Txt1);
                Dow 1 = 1;
                   Exfmt Error14;
                   Scn_DspItm = 0;
                   If *In12 = *On;
                      Leave;
                   Endif;
                Enddo;
                Iter;
             Endif;

             Scn_DspItm = 0;
             Scn_DspDesc = '       Parts & Scores';
             Scn_BinLoc10 = *BLANKS;
             Scn_PickerCmt1 = '     Parts & Scores';
             Scn_PickerCmt2 = '        Package';
             Scn_PickerCmt3 = *Blanks;
             *In53 = *On;

          Else;

          // See if item scanned is ok and fill info on screen
          PrmScanNum  = Scn_ScanField;
          PrmOrdNum   = %Char(Ctl_Ordnum);
          PrmBatchNum = *Blanks;
          PrmItmNum2  = *Blanks;
          PrmWrapType = *Blanks;
          PrmType     = *Blanks;
          PrmErrorMsg = *Blanks;
          Callp GURGETITM8 ( PrmScanNum
                           : PrmOrdNum
                           : PrmBatchNum
                           : PrmItmNum2
                           : PrmWrapType
                           : PrmType
                           : PrmErrorMsg);

          If PrmErrorMsg = *Blanks and PrmItmNum2 <> *Blanks;

             Monitor;
                Scn_DspItm = %Int(PrmItmNum2);
             On-Error;
                Scn_DspItm = *Zeros;
             Endmon;

             Chain Scn_DspItm IVPITEMS;
             If %Found (IVPITEMS);

                Scn_DspDesc = Itm_Sdesc;
                WrkLen = (%Len(Scn_DspDesc) - %Len(%Trim(Scn_DspDesc)))/2;
                Scn_DspDesc = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_DspDesc);

                Scn_DspPubcode = Itm_Pubcode;
                WrkLen = (%Len(Scn_DspPubcode)
                       - %Len(%Trim(Scn_DspPubcode)))/2;
                Scn_DspPubcode = %Subst(WrkBlanks:1:WrkLen)
                               + %Trim(Scn_DspPubcode);

                // Get Bin loc
                PrmBinLoc   = %Editc(Itm_Binzone:'4')
                            + Itm_BinAisle
                            + %Editc(Itm_Binsection:'4')
                            + Itm_BinLevel
                            + %Editc(Itm_Binslot:'4');

                If PrmBinLoc   <> *Blanks;
                   PrmBinZone    = %Editc(Itm_Binzone:'X');
                   PrmBinAisle   = Itm_BinAisle;
                   PrmBinSection = %Editc(Itm_BinSection:'X');
                   PrmBinLevel   = Itm_BinLevel;
                   PrmBinSlot    = %Editc(Itm_BinSlot:'X');

                   Exsr Sbr_FrmtBin;
                Endif;
                Scn_BinLoc10 = PrmBinLoc;

             Endif;

             Select;

                // If a UPC/EAN was Entered then Check for a valid code
                When PrmType = 'UPC' or PrmType = 'EAN';

                   // See if fender barcode scanned
                   WrkScanField12 = Scn_Scanfield;
                   Chain WrkScanField12 WSLFENDER1;
                   If %Found(WSLFENDER1);
                      WrkFenderUPC = 'Y';
                   Endif;

                   // See if disney barcode scanned
                   WrkScanField12 = Scn_Scanfield;
                   Chain WrkScanField12 WSLDISNEY1;
                   If %Found(WSLDISNEY1);
                      WrkDisneyUPC = 'Y';
                   Endif;

                   // See if UPC barcode scanned
                   WrkScanField12 = Scn_Scanfield;
                   Chain WrkScanField12 IVLITM19;
                   If %Found(IVLITM19);
                      WrkUPC = 'Y';
                   Endif;

                   // See if EAN barcode scanned
                   Monitor;
                      WrkScanfield = %Int(Scn_ScanField);
                   On-Error;
                      WrkScanfield = %Int(%SubSt(Scn_ScanField:1:13));
                      WrkEanPrcExt = 'Y';
                   EndMon;
                   Chain WrkScanField IVLITM15;
                   If %Found(IVLITM15);
                      WrkEAN = 'Y';
                   Endif;

                   // See if Brentwood Hymnal Code scanned


                   Bbx_VndItm = Scn_Scanfield;
                   Chain (WrkVCode : Bbx_VndItm) IVPXREFDTL;
                   If %Found(IVPXREFDTL);
                      WrkBBHymn = 'Y';
                   EndIf;

                   If WrkDisneyUPC = ' '
                          and WrkFenderUPC = ' '
                          and WrkUPC = ' '
                          and WrkEAN = ' '
                          and WrkBBHymn = ' ';
                      Scn_Error2Upc  = Scn_ScanField;
                      WrkLen = (%Len(Scn_Error2Upc)
                          -%Len(%Trim(Scn_Error2Upc)))/2;
                      Scn_Error2Upc= %Subst(WrkBlanks:1:WrkLen)+
                          %Trim(Scn_Error2Upc);
                      Dow 1 = 1;
                         Exfmt Error2;
                         Exsr Sbr_ClrScreen;
                         If *In12 = *On;
                            Leave;
                         Endif;
                      Enddo;
                      Iter;
                   Endif;

                   // Get Item Information
                   Select;
                      When WrkFenderUPC = 'Y';
                         Chain Fnd_Itmnum IVPITEMS;
                      When WrkDisneyUPC = 'Y';
                         Chain Dsn_Itmnum IVPITEMS;
                      When WrkUPC = 'Y';
                         Chain Upc_Itmnum IVPITEMS;
                      When WrkEAN = 'Y';
                         Chain Ean_Itmnum IVPITEMS;
                      When WrkBBHymn = 'Y';
                         Chain BBx_Itmnum IVPITEMS;
                   Endsl;

     C                   Move      Itm_Itmnum    WrkCharItmnum
             Endsl;

          Else;
     C                   MoveL     Scn_ScanField WrkCharItmNum
             Evalr WrkCharItmnum  = %Trim(WrkCharItmNum);
     C                   Move      WrkCharItmNum WrkItmnum
             Chain WrkItmnum IVPITEMS;
             If Not %Found(IVPITEMS);

                Scn_Error3Itm# = Scn_ScanField;
                WrkLen = (%Len(Scn_Error3Itm#)
                    -%Len(%Trim(Scn_Error3Itm#)))/2;
                Scn_Error3Itm#= %Subst(WrkBlanks:1:WrkLen)+
                    %Trim(Scn_Error3Itm#);

                Dow 1 = 1;
                   Exfmt Error3;
                   Exsr Sbr_ClrScreen;
                   If *In12 = *On;
                      Leave;
                   Endif;
                Enddo;
                Iter;
             Endif;
          Endif;

          Endif;


          // Get the Item From The Detail File
          Setll (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;
          Reade(N) (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;

          // If the Item is not on the order then send error message
          If %Eof(WSPORDDTL);
             Exsr Sbr_Error01;
             Iter;

          Else;

             // If Item has been Deleted then Display Error Screen
             If Dtl_Status = 9;
                Exsr Sbr_Error12;
                Iter;
             Endif;

             // If Item has been Backordered then Display Error Screen
             If Dtl_Status = 2;
                Exsr Sbr_Error11;
                Iter;
             Endif;

             // If is found find out if is has been completely wrapped
             Dow Dtl_WrapSeq <> 0;
                Reade(N) (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;
                If %Eof;

                   Exsr Sbr_Load_Error4;
                   WrkError4 = 'N';

                   // Check to see if an error was already given for this item
                   Chain (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPPCKERR;
                   If %Found(WSPPCKERR);
                      Scn_Err04Txt1 = 'A picker error was already '
                          + 'given for this item';
                      *In77 = *Off;
                   Else;
                      Scn_Err04Txt1 = 'PRESS <F6> to assign error';
                      *In77 = *On;
                   Endif;

                   // Center the Fields on the Screen
                   Wrk78  = Scn_Err04Txt1;
                   Exsr Sbr_Center78;
                   Scn_Err04Txt1 = Wrk78;

                   Dow 1 = 1;
                      Exfmt Error4;

                      If *In06 = *On and *In77 = *On;
                         Pke_Ordnum     = Ctl_Ordnum;
                         Pke_SubAlph    = Ctl_SubAlph;
                         Pke_Itmnum     = Scn_DspItm;
                         Pke_Type       = 'WQ';
                         Pke_PickEmp6   = 0;
                         Pke_WrapEmp6   = Ctl_EmpNum6;
                         Pke_ErrorTs    = %TimeStamp();
                         Pke_CommentTs  = *Loval;
                         Pke_Transfered = *Blanks;
                         Write WS$PCKERR;
                         Scn_Err04Txt1 = 'The picker Error was assigned';
                         Wrk78  = Scn_Err04Txt1;
                         Exsr Sbr_Center78;
                         Scn_Err04Txt1 = Wrk78;
                         *In77 = *Off;
                      Endif;

                      If *In12 = *On;
                         Exsr Sbr_ClrScreen;
                         Leave;
                      Endif;

                   Enddo;
                   WrkError4 = 'Y';
                   Leave;
                Endif;
             Enddo;

             If WrkError4 = 'Y';
                Iter;
             Endif;
          Endif;

          // Check if Item has a weight
          PrmItmNum = %EditC(Scn_DspItm:'X');
          Callp DIRCHKWGHT(PrmItmNum);

          // Check if Item needs a Prop65 label;
          If Scn_DspItm <>  SavItmNum65;
             Callp GURPROP65 (PrmItmNum);
             SavItmNum65 = Scn_DspItm;
          Endif;

          // Good Item Load Screen
          // If item has had the quantity changed then display screen
          If WrkFirstPass = 'Y';
             Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
             Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
             If Not %Eof(WSLORDDTL1) and Dt1_WrapSeq <> 0;
                SavItmnum = Dt1_Itmnum;
                WrkStartOver = 'N';
                Setll (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                Dow 1 = 1;
                   Reade (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                   If %Eof(WSLORDDTL1);
                      Leave;
                   Endif;
                   If SavItmnum = Dt1_Itmnum and Dt1_WrapSeq = 0;
                      If SavItmnum = Scn_DspItm;
                         Leave;
                      Else;
                         Exsr Sbr_Error8;
                         WrkStartOver = 'Y';
                      Endif;
                   Endif;
                Enddo;

                If WrkStartOver = 'Y';
                   Exsr Sbr_ClrScreen;
                   WrkFirstPass = 'N';
                   Iter;
                Endif;
             Endif;
          Endif;

          PrmOrdNum = *Blanks;
          PrmItmNum = *Blanks;

          // Call rack n roll reorder pgm and print labels if necessary
          Chain SdsDevice WSPCONTROL;
          If %Found(WSPCONTROL);
             PrmOrdNum = %EditC(Ctl_OrdNum:'X');
             PrmItmNum = %EditC(Scn_DspItm:'X');

             Ctl_Itmnum = Scn_Dspitm;
             Update WS$CONTROL %Fields(Ctl_Itmnum);
          Endif;
          PrmSubAlph = Ctl_SubAlph;

          // Is this an Multi Box Item?
          Callp GURMBOXITM ( PrmItmNum : PrmMBoxFlg : PrmMBoxItm);
          If PrmMBoxFlg = 'Y';
             Callp WSRMBOX1ST ( PrmOrdNum
                              : Ctl_SubAlph
                              : PrmItmNum
                              : PrmContinue );
             If PrmContinue = 'N';
                Exsr Sbr_ClrScreen;
                Iter;
             Endif;
             PrmQtyChg = %Char(Dtl_QtyOrd);
             Callp WSRMBOXWRP ( PrmOrdNum
                              : Ctl_SubAlph
                              : PrmMBoxItm
                              : PrmQtyChg
                              : PrmCmdKey    );
             Monitor;
                WrkQtyChg = %Int(PrmQtyChg);
             On-Error;
                WrkQtyChg = *Zeros;
             EndMon;
             If WrkQtyChg <> Dtl_QtyOrd;
                Dtl_QtyOrd = WrkQtyChg;
             ENDIF;
             *In55 = *On;
          Endif;

          // Print required labeling
          Chain Hdr_Custno DIPCSTLBL;
          If %Found(DIPCSTLBL);
             PrmOrdNum  = %EditC(Ctl_OrdNum:'Z');
             PrmSubAlph = Ctl_SubAlph;
             PrmItmNum  = %EditC(Ctl_ItmNum:'X');
             PrmScanFld = Scn_Scanfield;

             Callp WSRPRTLBL (PrmOrdNum : PrmSubAlph : PrmItmNum : PrmScanFld);
             If Lbl_CANPrc <> *Blanks;
                WrkReplaceLbls = 'Y';
             Endif;
          Endif;

          // Print Compliance label for item for Musicians Friend
          If Ctl_Itmnum <> *Zero
                        And ( Hdr_Custno = 17679024    // MFI
                        Or    Hdr_Custno = 17021553 ); // MFI Drums

             PrmBoxNum  = %EditC(Ctl_BoxNum:'Z');
             PrmUCC# = *Blanks;
             PrmReprintLbl = *Blanks;

             // Get UCC for item in box
             Callp DIRMFIUCC ( PrmOrdNum
                             : Ctl_SubAlph
                             : PrmBoxNum
                             : PrmItmNum
                             : PrmUCC# );

             // Print Label
             Callp LBRMFIUCC ( PrmOrdNum
                             : Ctl_SubAlph
                             : PrmBoxNum
                             : PrmItmNum
                             : PrmReprintLbl );

          Endif;

          // If item has had the quantity changed then display screen
          If Dtl_ModType = 'QTYCHG' and SavDspItm <> Scn_DspItm;
             Exsr Sbr_Error10;
          Endif;

          // If item is a do not break item then display the Green screen
          If Itm_MsPkCd = 'F';
             Dow 1 = 1;
                Exfmt Error7;
                If *In12 = *On;
                   Leave;
                Endif;
             Enddo;
          Endif;

          // If the Item is 312392 (Sound of Music) Call program that will
          // check for customers starting with 1797.... and display a screen
          // indicating that the book needs a special sticker.
          // This code can be removed after November 2008. (Scott Kinstler)
          If Itm_Itmnum = 312392;
             Callp WSRGOLD();
          Endif;

          // Check for Item Wrap Instructions
          Callp WSRWRPINSS(PrmItmnum);

          // Check for Wrap Message
          Callp DIRWRPMSG(PrmWrapMthd:PrmBatch4:PrmOrdNum:PrmItmNum:PrmSubalph);

          // Print BOM if Rental
          If Hdr_Custno = 9002939
                Or Hdr_Custno = 9002940
                Or Hdr_Custno = 9003082
                Or Hdr_Custno = 9003194;

             // See if the BOM revision is active
             // If it is, print
             Chain Scn_DspItm IVPIMGMREV;
             If %Found(IVPIMGMREV)
               and Rev_Active = 'Y';
                PrmRevision = %Editc(Rev_Revision:'Z');
             Else;
                PrmRevision = ' ';
             Endif;

             Callp IVRIMGMPRT (PrmItmnum:PrmRevision);
          Endif;

          // Load Picker Comment
          Exsr Sbr_LoadCmt;

          // Good Item Load Screen
          Scn_ScanField = *Blanks;

          WrkCharQty = %Editc(Dtl_QtyOrd:'Z');
          Exsr Sbr_Load_Number;

          // Turn on Indicator to display the Qty Needed
          If *In55 = *On;

          ENDIF;
          *In50 = *On;

          // If the Qty needed is 1 then do not show the enter diff qty and
          // do not show F10 Multi close
          If Dtl_QtyOrd = 1;
             *In54 = *Off;
          Else;
             *In54 = *On;
          Endif;

          // Check for Case Quantity in IVPITEMS
          //      (If there is a Case Qty and the Qty Order is less than the)
          //      (Case Qty do not display the Case Qty                     )
          If Hdr_Custno <> 17679024                 // MFI
                        And Hdr_Custno <> 17021553; // MFI Drums

             If Itm_CasQty <> 0;
                If Itm_CasQty <= Dtl_QtyOrd;

                   Scn_Cases = Dtl_QtyOrd / Itm_CasQty;
                   Scn_Extra = %Rem(Dtl_QtyOrd:Itm_CasQty);

                   If Scn_Extra <> 0;
                      *In52 = *On;
                   Else;
                      *In52 = *Off;
                   Endif;

                   *In51 = *On;
                   Exsr Sbr_Load_CseQty;
                Endif;
             Endif;
          Else;

          Endif;
       Enddo;

       // End Program
       *InLr = *On;

       //*******************
       //* End of MainLine *
       //***********************************************************************

       // /******************************************************************\ *
       //<                           SUBROUTINES                              >*
       // \******************************************************************/ *

       //***********************************************************************
       //* Center MSGxxx Fields *
       //************************
       Begsr Sbr_MsgCntr;

          WrkLen = (%Len(Scn_Msg001) - %Len(%Trim(Scn_Msg001)))/2;
          Scn_Msg001 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg001);

          WrkLen = (%Len(Scn_Msg002) - %Len(%Trim(Scn_Msg002)))/2;
          Scn_Msg002 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg002);

          WrkLen = (%Len(Scn_Msg003) - %Len(%Trim(Scn_Msg003)))/2;
          Scn_Msg003 = %Subst(WrkBlanks:1:WrkLen) +  %Trim(Scn_Msg003);

          WrkLen = (%Len(Scn_Msg004) - %Len(%Trim(Scn_Msg004)))/2;
          Scn_Msg004 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg004);

          WrkLen = (%Len(Scn_Msg005) - %Len(%Trim(Scn_Msg005)))/2;
          Scn_Msg005 = %Subst(WrkBlanks:1:WrkLen) +  %Trim(Scn_Msg005);

          WrkLen = (%Len(Scn_Msg006) - %Len(%Trim(Scn_Msg006)))/2;
          Scn_Msg006 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg006);

          WrkLen = (%Len(Scn_Msg007) - %Len(%Trim(Scn_Msg007)))/2;
          Scn_Msg007 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg007);

          WrkLen = (%Len(Scn_Msg008) - %Len(%Trim(Scn_Msg008)))/2;
          Scn_Msg008 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg008);


          WrkLen = (%Len(Scn_Msg009) - %Len(%Trim(Scn_Msg009)))/2;
          Scn_Msg009 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg009);


          WrkLen = (%Len(Scn_Msg010) - %Len(%Trim(Scn_Msg010)))/2;
          Scn_Msg010 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg010);


          WrkLen = (%Len(Scn_Msg011) - %Len(%Trim(Scn_Msg011)))/2;
          Scn_Msg011 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg011);


          WrkLen = (%Len(Scn_Msg012) - %Len(%Trim(Scn_Msg012)))/2;
          Scn_Msg012 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg012);

          WrkLen = (%Len(Scn_Msg013) - %Len(%Trim(Scn_Msg013)))/2;
          Scn_Msg013 = %Subst(WrkBlanks:1:WrkLen) +  %Trim(Scn_Msg013);

          WrkLen = (%Len(Scn_Msg014) - %Len(%Trim(Scn_Msg014)))/2;
          Scn_Msg014 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Msg014);

       Endsr;

       //***********************************************************************
       //* Load Error 4 Screen *
       //***********************
       Begsr Sbr_Load_Error4;

          Scn_Error4Item = %Editc(Scn_DspItm:'X');
          Scn_Error4Desc = Scn_DspDesc;
          Scn_Error4Bin = 'BinLoc: ' + Scn_Binloc10;
          WrkLen = (%Len(Scn_Error4Item) - %Len(%Trim(Scn_Error4Item)))/2;
          Scn_Error4Item = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Error4Item);

          WrkLen = (%Len(Scn_Error4Desc) - %Len(%Trim(Scn_Error4Desc)))/2;
          Scn_Error4Desc= %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Error4Desc);

          WrkLen = (%Len(Scn_Error4Bin) - %Len(%Trim(Scn_Error4Bin)))/2;
          Scn_Error4Bin= %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Error4Bin);

          Setll (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;
          For Index = 1 to 12            ;
             Error4Ary(Index) = '              |'+
                 '               |'+
                 '               |'+
                 '               |';
          Endfor;

          Index = 1;
          WrkColumn = 1;
          Dow 1 = 1;
             Reade (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;
             If %Eof;
                Leave;
             Else;

                Select;
                   When WrkColumn = 1;
                      Select;
                         When Dtl_Status = 1;
                            %Subst(Error4Ary(Index):1:13) =
                                %Editc(Dtl_QtyWrap:'1') +
                                ' '                   +
                                %Editc(Dtl_Box#:'1');

                         When Dtl_Status = 2;
                            %Subst(Error4Ary(Index):1:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                '  B.O.';

                         When Dtl_Status = 9;
                            %Subst(Error4Ary(Index):1:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                'DELETE';
                      Endsl;

                      Index = Index + 1;

                   When WrkColumn = 2;
                      Select;
                         When Dtl_Status = 1;
                            %Subst(Error4Ary(Index):17:13) =
                                %Editc(Dtl_QtyWrap:'1') +
                                ' '                   +
                                %Editc(Dtl_Box#:'1');

                         When Dtl_Status = 2;
                            %Subst(Error4Ary(Index):17:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                '  B.O.';

                         When Dtl_Status = 9;
                            %Subst(Error4Ary(Index):17:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                'DELETE';
                      Endsl;

                      Index = Index + 1;

                   When WrkColumn = 3;
                      Select;
                         When Dtl_Status = 1;
                            %Subst(Error4Ary(Index):33:13) =
                                %Editc(Dtl_QtyWrap:'1') +
                                ' '                   +
                                %Editc(Dtl_Box#:'1');

                         When Dtl_Status = 2;
                            %Subst(Error4Ary(Index):33:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                '  B.O.';

                         When Dtl_Status = 9;
                            %Subst(Error4Ary(Index):33:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                'DELETE';
                      Endsl;

                      Index = Index + 1;

                   When WrkColumn = 4;

                      Select;
                         When Dtl_Status = 1;
                            %Subst(Error4Ary(Index):49:13) =
                                %Editc(Dtl_QtyWrap:'1') +
                                ' '                   +
                                %Editc(Dtl_Box#:'1');

                         When Dtl_Status = 2;
                            %Subst(Error4Ary(Index):49:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                '  B.O.';

                         When Dtl_Status = 9;
                            %Subst(Error4Ary(Index):49:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                'DELETE';
                      Endsl;

                      Index = Index + 1;

                   When WrkColumn = 5;

                      Select;
                         When Dtl_Status = 1;
                            %Subst(Error4Ary(Index):66:13) =
                                %Editc(Dtl_QtyWrap:'1') +
                                ' '                   +
                                %Editc(Dtl_Box#:'1');

                         When Dtl_Status = 2;
                            %Subst(Error4Ary(Index):66:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                '  B.O.';

                         When Dtl_Status = 9;
                            %Subst(Error4Ary(Index):66:13) =
                                %Editc(Dtl_QtyOrd:'1') +
                                ' '                   +
                                'DELETE';
                      Endsl;

                      Index = Index + 1;

                Endsl;
             Endif;

             If Index = 13;
                WrkColumn = WrkColumn + 1;
                Index = 1;
             Endif;

             If WrkColumn = 6;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Load the Picker Comment *
       //***************************
       Begsr Sbr_LoadCmt;

          WrkPickerCmt1 = *Blanks;
          WrkPickerCmt2 = *Blanks;
          WrkPickerCmt3 = *Blanks;

          Chain Itm_Mspkcd WSPMSPKD;
          If %Found(WSPMSPKD);

             *In53 = *On;

             WrkBlankPos = 0;
             Dow 1 = 1;
                WrkBlankPos = %Scan(' ':Pkd_Pkdesc:WrkBlankPos+1);
                If WrkBlankPos > 23;
                   Leave;
                Endif;
                SavBlankPos = WrkBlankPos;
             Enddo;

             WrkPickerCmt1 = %Subst(Pkd_Pkdesc:1:SavBlankPos);
             WrkLen = (%Len(WrkPickerCmt1) - %Len(%Trim(WrkPickerCmt1)))/2;
             WrkPickerCmt1 = %Subst(WrkBlanks:1:WrkLen) + %Trim(WrkPickerCmt1);

             Pkd_Pkdesc =  %Subst(Pkd_Pkdesc:SavBlankPos+1);

             If Pkd_Pkdesc <> *Blanks;
                WrkBlankPos = 0;
                Dow 1 = 1;
                   WrkBlankPos = %Scan(' ':Pkd_Pkdesc:WrkBlankPos+1);

                   If WrkBlankPos > 23;
                      Leave;
                   Endif;
                   SavBlankPos = WrkBlankPos;
                Enddo;

                WrkPickerCmt2 =
                    %Subst(Pkd_Pkdesc:1:SavBlankPos);
                WrkLen = (%Len(WrkPickerCmt2)
                    -%Len(%Trim(WrkPickerCmt2)))/2;
                WrkPickerCmt2 = %Subst(WrkBlanks:1:WrkLen) +
                    %Trim(WrkPickerCmt2);

                Pkd_Pkdesc = %Subst(Pkd_Pkdesc:SavBlankPos+1);


                If Pkd_Pkdesc <> *Blanks;
                   WrkBlankPos = 0;
                   Dow 1 = 1;
                      WrkBlankPos = %Scan(' ':Pkd_Pkdesc:WrkBlankPos+1);

                      If WrkBlankPos > 23;
                         Leave;
                      Endif;
                      SavBlankPos = WrkBlankPos;
                   Enddo;

                   WrkPickerCmt3 = %Subst(Pkd_Pkdesc:1:SavBlankPos);
                   WrkLen = (%Len(WrkPickerCmt3)
                       -%Len(%Trim(WrkPickerCmt3)))/2;
                   WrkPickerCmt3 = %Subst(WrkBlanks:1:WrkLen) +
                       %Trim(WrkPickerCmt3);
                Endif;
             Endif;


             If WrkPickerCmt2 = *Blanks and WrkPickerCmt3 = *Blanks;
                Scn_PickerCmt1 = *Blanks;
                Scn_PickerCmt2 = WrkPickerCmt1;
                Scn_PickerCmt3 = *Blanks;
             Else;
                Scn_PickerCmt1 = WrkPickerCmt1;
                Scn_PickerCmt2 = WrkPickerCmt2;
                Scn_PickerCmt3 = WrkPickerCmt3;
             Endif;
          Endif;
       Endsr;

       //***********************************************************************
       //* Clear the Screen for New Input *
       //**********************************
       Begsr Sbr_ClrScreen;

          // Clear Fields
          Scn_Qty        = 0;
          Scn_ScanField  = *Blanks;
          Scn_DspItm     = 0;
          Scn_DspDesc    = *Blanks;
          Scn_DspPubcode = *Blanks;
          Scn_MFBoxType  = *Blanks;
          PrmContinue    = *Blanks;

          // Reset Indicator
          *In31 = *Off;
          *In50 = *Off;
          *In51 = *Off;
          *In52 = *Off;
          *In53 = *Off;
          *In54 = *Off;
          *In55 = *Off;
          *In81 = *Off;

          // Center the Current Box Number in Box Field
          Chain(N) SdsDevice WSPCONTROL;
          If %Found(WSPCONTROL);
             Scn_CurrBoxA = %Trim(%Editc(Ctl_BoxNum:'Z'));
             WrkLen = (%Len(Scn_CurrBoxA) - %Len(%Trim(Scn_CurrBoxA)))/2;
             Scn_CurrBoxA = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_CurrBoxA);
          Endif;

       Endsr;

       //***********************************************************************
       //* Wrap The Item *
       //*****************
       Begsr Sbr_Wrap_Item;

          Setll (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;

          Dow 1 = 1;
             Reade (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;
             If Not %Eof;
                If Dtl_WrapSeq = 0;

                   Select;
                      // If the full amount was wrapped
                      When Scn_Qty = 0 or Scn_Qty = Dtl_QtyOrd;

                         // Get the last WrapSeq Number
                         Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                         Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                         // Update the Detail Record
                         Dtl_WrapSeq = Dt1_WrapSeq + 10;
                         Dtl_QtyWrap = Dtl_QtyOrd;
                         Dtl_Status  = 1;
                         Dtl_Box#    = Ctl_BoxNum;
                         Dtl_Empnum6 = Ctl_EmpNum6;
                         Dtl_WrapTs  = %TimeStamp();
                         // Populate which station the item was wrapped
                         If Ctl_EmpNum6 <> 99999;
                            Dtl_Station = Ctl_Station;
                         Endif;
                         Update WS$ORDDTL %Fields(Dtl_WrapSeq
                                                 :Dtl_QtyWrap
                                                 :Dtl_Status
                                                 :Dtl_Box#
                                                 :Dtl_Empnum6
                                                 :Dtl_WrapTs
                                                 :Dtl_Station);
                         Leave;

                      // If the full amount was not wrapped
                      When Scn_Qty < Dtl_QtyOrd;
                         // Get the Last PtlLine Number
                         Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL2;
                         Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL2;
                         // Write a detail record with the remaining Qty
                         Dt3_Ordnum  = Dtl_Ordnum;
                         Dt3_SubAlph = Dtl_SubAlph;
                         Dt3_Line#   = Dtl_Line#;
                         Dt3_PtlLine = Dt2_PtlLine + 1;
                         Dt3_WrapSeq = 0;
                         Dt3_Itmnum  = Dtl_Itmnum;
                         Dt3_QtyOrd  = Dtl_QtyOrd - Scn_Qty;
                         Dt3_QtyWrap = 0;
                         Dt3_Status  = 0;
                         Dt3_Box#    = 0;
                         Dt3_Empnum6 = 0;
                         Dt3_WrapTs  = *Loval;
                         Write WS$ORDDTL3;
                         // Get the Last WrapSeq Number
                         Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                         Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                         // Update the detail record with the amount wrapped
                         Dtl_WrapSeq = Dt1_WrapSeq + 10;
                         Dtl_QtyOrd  = Scn_Qty;
                         Dtl_QtyWrap = Scn_Qty;
                         Dtl_Status  = 1;
                         Dtl_Box#    = Ctl_BoxNum;
                         Dtl_Empnum6 = Ctl_EmpNum6;
                         Dtl_WrapTs  = %TimeStamp();
                         // Populate which station the item was wrapped
                         If Ctl_EmpNum6 <> 99999;
                            Dtl_Station = Ctl_Station;
                         Endif;
                         Update WS$ORDDTL %Fields(Dtl_WrapSeq
                                                 :Dtl_QtyOrd
                                                 :Dtl_QtyWrap
                                                 :Dtl_Status
                                                 :Dtl_Box#
                                                 :Dtl_Empnum6
                                                 :Dtl_WrapTs
                                                 :Dtl_Station);
                         Leave;

                   Endsl;
                Else;
                   Iter;
                Endif;
             Endif;

          Enddo;

          // See if the item wrapped was in a tote from the 2nd floor or 960
          // If it is, clear the tote info so it is available to use again
          Chain (Ctl_Ordnum:Scn_DspItm) PTLORDDTL9;
          If %Found(PTLORDDTL9);
             Chain Pd9_Tote# TSPTOTE;
             If %Found(TSPTOTE) and Ctl_Ordnum = Tot_Ordnum;
                Tot_ODBatch# = *Zero;
                Tot_Ordnum = *Zero;
                Tot_Subalph = *Blanks;
                Tot_ActSumm# = *Zero;
                Tot_Toteloc = *Blanks;
                Tot_LocationTS = *Loval;
                Update TS$TOTE %Fields(Tot_ODBatch#
                                      :Tot_Ordnum
                                      :Tot_Subalph
                                      :Tot_ActSumm#
                                      :Tot_Toteloc
                                      :Tot_LocationTS);
             Endif;
          Endif;

          //Exsr Sbr_Check_Box_Weight;
          WrkFirstPass = 'Y';

       Endsr;


       //***********************************************************************
       //* Back Order Item *
       //*******************
       Begsr Sbr_BoItem;

          Setll (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;

          Dow 1 = 1;
             Reade (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPORDDTL;
             If Not %Eof and Dtl_WrapSeq = 0;

                // Get the last WrapSeq Number
                Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;

                // Update the Detail Record
                Dtl_WrapSeq = Dt1_WrapSeq + 10;
                Dtl_QtyWrap = 0;
                Dtl_Status  = 2;
                Dtl_Box#    = 0;
                Dtl_Empnum6 = Ctl_EmpNum6;
                Dtl_WrapTs  = %TimeStamp();
                // Populate which station the item was wrapped
                If Ctl_EmpNum6 <> 99999;
                   Dtl_Station = Ctl_Station;
                Endif;
                Update WS$ORDDTL %Fields(Dtl_WrapSeq
                                        :Dtl_QtyWrap
                                        :Dtl_Status
                                        :Dtl_Box#
                                        :Dtl_Empnum6
                                        :Dtl_WrapTs
                                        :Dtl_Station);
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Load Large Numbers Subrouting *
       //*********************************
       Begsr Sbr_Load_Number;

          If WrkColor = 'Green';
             C = W;
             *In88 = *On;
             WrkColor = 'White';
          Else;
             C = G;
             *In88 = *Off;
             WrkColor = 'Green';
          Endif;
          Exsr Sbr_SetupNum;

          // Center the title of the report
          WrkLen = (%Len(WrkCharQty) - %Len(%Trim(WrkCharQty)))/2;
          WrkCharQty = %Subst(WrkBlanks:1:WrkLen) + %Trim(WrkCharQty);

     C                   Movea     WrkCharQty    WrkQtyAry
          For x = 1 to 5             ;
             If x = 1;
                Y = 1;
             Else;
                Y =((X-1)*4)+1;
             Endif;

             Select;

                When WrkQtyAry(X) = '1';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_1_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_1_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_1_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_1_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_1_L5;

                When WrkQtyAry(X) = '2';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_2_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_2_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_2_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_2_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_2_L5;

                When WrkQtyAry(X) = '3';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_3_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_3_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_3_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_3_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_3_L5;

                When WrkQtyAry(X) = '4';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_4_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_4_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_4_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_4_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_4_L5;

                When WrkQtyAry(X) = '5';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_5_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_5_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_5_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_5_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_5_L5;

                When WrkQtyAry(X) = '6';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_6_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_6_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_6_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_6_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_6_L5;

                When WrkQtyAry(X) = '7';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_7_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_7_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_7_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_7_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_7_L5;

                When WrkQtyAry(X) = '8';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_8_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_8_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_8_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_8_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_8_L5;

                When WrkQtyAry(X) = '9';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_9_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_9_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_9_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_9_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_9_L5;

                When WrkQtyAry(X) = '0';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk_0_L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk_0_L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk_0_L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk_0_L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk_0_L5;

                When WrkQtyAry(X) = ' ';
                   %Subst(Scn_QtyLine1:Y:4) = Wrk___L1;
                   %Subst(Scn_QtyLine2:Y:4) = Wrk___L2;
                   %Subst(Scn_QtyLine3:Y:4) = Wrk___L3;
                   %Subst(Scn_QtyLine4:Y:4) = Wrk___L4;
                   %Subst(Scn_QtyLine5:Y:4) = Wrk___L5;

             Endsl;
          Endfor;
       Endsr;

       //***********************************************************************
       //* Load Large Numbers for Case Qty *
       //***********************************
       Begsr Sbr_Load_CseQty;

          C = W;
          Exsr Sbr_SetupNum;

          If Hdr_Custno = 17679024                // MFI
                        Or Hdr_Custno = 17021553; // MFI Drums

             WrkCharCse = %Editc(WrkMFQty:'Z');
          Else;
             WrkCharCse = %Editc(Itm_CasQty:'Z');
          Endif;

     C                   Movea     WrkCharCse    WrkCseAry
          For x = 1 to 3             ;
             If x = 1;
                Y = 1;
             Else;
                Y =((X-1)*4)+1;
             Endif;

             Select;

                When WrkCseAry(X) = '1';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_1_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_1_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_1_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_1_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_1_L5;

                When WrkCseAry(X) = '2';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_2_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_2_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_2_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_2_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_2_L5;

                When WrkCseAry(X) = '3';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_3_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_3_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_3_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_3_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_3_L5;

                When WrkCseAry(X) = '4';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_4_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_4_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_4_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_4_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_4_L5;

                When WrkCseAry(X) = '5';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_5_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_5_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_5_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_5_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_5_L5;

                When WrkCseAry(X) = '6';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_6_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_6_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_6_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_6_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_6_L5;

                When WrkCseAry(X) = '7';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_7_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_7_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_7_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_7_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_7_L5;

                When WrkCseAry(X) = '8';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_8_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_8_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_8_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_8_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_8_L5;

                When WrkCseAry(X) = '9';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_9_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_9_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_9_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_9_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_9_L5;

                When WrkCseAry(X) = '0';
                   %Subst(Scn_CseLine1:Y:4) = Wrk_0_L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk_0_L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk_0_L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk_0_L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk_0_L5;

                When WrkCseAry(X) = ' ';
                   %Subst(Scn_CseLine1:Y:4) = Wrk___L1;
                   %Subst(Scn_CseLine2:Y:4) = Wrk___L2;
                   %Subst(Scn_CseLine3:Y:4) = Wrk___L3;
                   %Subst(Scn_CseLine4:Y:4) = Wrk___L4;
                   %Subst(Scn_CseLine5:Y:4) = Wrk___L5;

             Endsl;
          Endfor;
       Endsr;

       //***********************************************************************
       //* Setup Numbers *
       //*****************
       Begsr Sbr_SetupNum;

          // Set up 1
          Wrk_1_L1 = N+C+B+N;
          Wrk_1_L2 = C+B+B+N;
          Wrk_1_L3 = N+C+B+N;
          Wrk_1_L4 = N+C+B+N;
          Wrk_1_L5 = C+B+B+B;

          // Set up 2
          Wrk_2_L1 = C+B+B+B;
          Wrk_2_L2 = N+B+C+B;
          Wrk_2_L3 = C+B+B+B;
          Wrk_2_L4 = C+B+N+B;
          Wrk_2_L5 = C+B+B+B;

          // Set up 3
          Wrk_3_L1 = C+B+B+B;
          Wrk_3_L2 = N+B+C+B;
          Wrk_3_L3 = C+B+B+B;
          Wrk_3_L4 = N+B+C+B;
          Wrk_3_L5 = C+B+B+B;

          // Set up 4
          Wrk_4_L1 = C+B+C+B;
          Wrk_4_L2 = C+B+C+B;
          Wrk_4_L3 = C+B+B+B;
          Wrk_4_L4 = N+B+C+B;
          Wrk_4_L5 = N+B+C+B;

          // Set up 5
          Wrk_5_L1 = C+B+B+B;
          Wrk_5_L2 = C+B+N+B;
          Wrk_5_L3 = C+B+B+B;
          Wrk_5_L4 = N+B+C+B;
          Wrk_5_L5 = C+B+B+B;

          // Set up 6
          Wrk_6_L1 = C+B+N+B;
          Wrk_6_L2 = C+B+N+B;
          Wrk_6_L3 = C+B+B+B;
          Wrk_6_L4 = C+B+C+B;
          Wrk_6_L5 = C+B+B+B;

          // Set up 7
          Wrk_7_L1 = C+B+B+B;
          Wrk_7_L2 = N+B+C+B;
          Wrk_7_L3 = N+B+C+B;
          Wrk_7_L4 = N+B+C+B;
          Wrk_7_L5 = N+B+C+B;

          // Set up 8
          Wrk_8_L1 = C+B+B+B;
          Wrk_8_L2 = C+B+C+B;
          Wrk_8_L3 = C+B+B+B;
          Wrk_8_L4 = C+B+C+B;
          Wrk_8_L5 = C+B+B+B;

          // Set up 9
          Wrk_9_L1 = C+B+B+B;
          Wrk_9_L2 = C+B+C+B;
          Wrk_9_L3 = C+B+B+B;
          Wrk_9_L4 = N+B+C+B;
          Wrk_9_L5 = N+B+C+B;

          // Set up 0
          Wrk_0_L1 = C+B+B+B;
          Wrk_0_L2 = C+B+C+B;
          Wrk_0_L3 = C+B+C+B;
          Wrk_0_L4 = C+B+C+B;
          Wrk_0_L5 = C+B+B+B;

          // Set up " "
          Wrk___L1 = N+B+B+B;
          Wrk___L2 = N+B+B+B;
          Wrk___L3 = N+B+B+B;
          Wrk___L4 = N+B+B+B;
          Wrk___L5 = N+B+B+B;

       Endsr;

       //***********************************************************************
       //* Error 1 - Item Not On Order Screen *
       //**************************************
       Begsr Sbr_Error01;

          // Get Item Number, Description and Binloc from IVPITEMS
          Chain Scn_DspItm IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Err01Itm# = %Editc(Itm_Itmnum:'X');
             Scn_Err01Desc = Itm_Sdesc;
             // Get Bin loc
             PrmBinLoc   = %Editc(Itm_Binzone:'4')
                         + Itm_BinAisle
                         + %Editc(Itm_Binsection:'4')
                         + Itm_BinLevel
                         + %Editc(Itm_Binslot:'4');
             If PrmBinLoc   <> *Blanks;
                PrmBinZone    = %Editc(Itm_Binzone:'X');
                PrmBinAisle   = Itm_BinAisle;
                PrmBinSection = %Editc(Itm_BinSection:'X');
                PrmBinLevel   = Itm_BinLevel;
                PrmBinSlot    = %Editc(Itm_BinSlot:'X');

                Exsr Sbr_FrmtBin;
             Endif;
             Scn_Err01Bin  = PrmBinLoc;
          Else;
             Scn_Err01Itm# = *Blanks;
             Scn_Err01Desc = *Blanks;
             Scn_Err01Bin  = *Blanks;
          Endif;

          // Check to see if an error was already given for this item
          Chain (Ctl_Ordnum : Ctl_SubAlph : Scn_DspItm) WSPPCKERR;
          If %Found(WSPPCKERR);
             Scn_Err01Txt1 = 'A picker error was already given for this item';
             *In77 = *Off;
          Else;
             Scn_Err01Txt1 = 'PRESS <F6> to assign error';
             *In77 = *On;
          Endif;

          // Center the Fields on the Screen
          Wrk78  = Scn_Err01Itm#;
          Exsr Sbr_Center78;
          Scn_Err01Itm# = Wrk78;

          Wrk78  = Scn_Err01Desc;
          Exsr Sbr_Center78;
          Scn_Err01Desc = Wrk78;

          Wrk78  = Scn_Err01Bin;
          Exsr Sbr_Center78;
          Scn_Err01Bin  = Wrk78;

          Wrk78  = Scn_Err01Txt1;
          Exsr Sbr_Center78;
          Scn_Err01Txt1 = Wrk78;

          // Display the Screen Until F12 is pressed
          Dow 1 = 1;
             Exfmt Error1;

             If *In06 = *On and *In77 = *On;
                Pke_Ordnum     = Ctl_Ordnum;
                Pke_SubAlph    = Ctl_SubAlph;
                Pke_Itmnum     = Scn_DspItm;
                Pke_Type       = 'WI';
                Pke_PickEmp6   = 0;
                Pke_WrapEmp6   = Ctl_EmpNum6;
                Pke_ErrorTs    = %TimeStamp();
                Pke_CommentTs  = *Loval;
                Pke_Transfered = *Blanks;
                Write WS$PCKERR;
                Scn_Err01Txt1 = 'The picker Error was assigned';
                Wrk78  = Scn_Err01Txt1;
                Exsr Sbr_Center78;
                Scn_Err01Txt1 = Wrk78;
                *In77 = *Off;
             Endif;

             If *In12 = *On;
                Exsr Sbr_ClrScreen;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 5 - Case Quantity Difference Error Window *
       //***********************************************************************
       Begsr Sbr_Error5;

          Dow 1 = 1;
             Scn_Error5Txt1 = 'You are wrapping a Quantity of ' +
                 %Trim(%Editc(WrkErr05Qty:'1'));
             WrkLen = (%Len(Scn_Error5Txt1) - %Len(%Trim(Scn_Error5Txt1)))/2;

             Scn_Error5Txt1 = %Subst(WrkBlanks:1:WrkLen)+
                 %Trim(Scn_Error5Txt1);
             Scn_Error5Txt2 = 'The Case Quantity is ' +
                 %Trim(%Editc(Itm_CasQty:'1'));
             WrkLen = (%Len(Scn_Error5Txt2)
                 -%Len(%Trim(Scn_Error5Txt2)))/2;
             Scn_Error5Txt2 = %Subst(WrkBlanks:1:WrkLen)+
                 %Trim(Scn_Error5Txt2);
             Exfmt Error5Wdw;
             If *In07 = *On;
                WrkDoNotWrap = 'N';
                Leave;
             Endif;
             If *In12 = *On;
                Scn_ScanField = *Blanks;
                WrkDoNotWrap = 'Y';
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 6 - More Quantity Entered than Ordered Error Window *
       //***********************************************************************
       Begsr Sbr_Scan_FreeHand;
          WrkItmNum2 = *Zeros;
          Select;
             When Scn_ScanField = '890765002001' or Scn_ScanField = '639000'
              OR Scn_ScanField = '00639000' or Scn_ScanField = '0639000'
              OR Scn_ScanField = '000639000' or Scn_ScanField = '0000639000';
                WrkItmNum2 = 639000;
             When Scn_ScanField = '884088217105' or Scn_ScanField = '639500'
              OR Scn_ScanField = '00639500' or Scn_ScanField = '0639500'
              OR Scn_ScanField = '000639500' or Scn_ScanField = '0000639500';
                WrkItmNum2 = 639500;
          EndSl;
          Chain (Ctl_OrdNum : Ctl_SubAlph : WrkItmNum2) WSLORDDTL8;
          IF %Found(WSLORDDTL8);
             WrkQtyOrd = Dt8_QtyOrd;
          Endif;

          WrkQtyRmn = *Zeros;

          Setll (Ctl_OrdNum : Ctl_SubAlph) IVLFREEHND;
          Dow 1 = 1;
             Reade (Ctl_OrdNum : Ctl_SubAlph) IVLFREEHND;
             If %Eof(IVLFREEHND);
                Leave;
             Endif;
             WrkQtyRmn += 1;
          Enddo;

          WrkQtyRmn = WrkQtyOrd - WrkQtyRmn;

          If WrkQtyRmn > 0;
             PrmOrdNum  = %EditC(Ctl_OrdNum:'X');
             PrmSubAlph = Ctl_SubAlph;
             PrmItmNum  = %EditC(WrkItmNum2:'X');
             Callp WSRSCNFH (PrmOrdNum : PrmSubAlph : PrmItmNum);

             // Check for any unscanned
             WrkQtyRmn = *Zeros;
             Setll (Ctl_OrdNum : Ctl_SubAlph) IVLFREEHND;
             Dow 1 = 1;
                Reade (Ctl_OrdNum : Ctl_SubAlph) IVLFREEHND;
                If %Eof(IVLFREEHND);
                   Leave;
                Endif;
                WrkQtyRmn += 1;
             Enddo;

             WrkQtyRmn = WrkQtyOrd - WrkQtyRmn;

             If WrkQtyRmn > 0 ;
                WrkFHFlag = 'Y';
             Else;
                WrkFHFlag = 'N';
             Endif;
          Endif;

       EndSr;

       //***********************************************************************
       //* Error 6 - More Quantity Entered than Ordered Error Window *
       //***********************************************************************
       Begsr Sbr_Error6;

          Scn_Error6Txt1 = 'You Entered a Quantity of ' +
              %Trim(%Editc(Scn_Qty:'N'));
          WrkLen = (%Len(Scn_Error6Txt1) - %Len(%Trim(Scn_Error6Txt1)))/2;
          Scn_Error6Txt1 = %Subst(WrkBlanks:1:WrkLen)+
              %Trim(Scn_Error6Txt1);

          Scn_Error6Txt2 = 'The Quantity Ordered is ' +
              %Trim(%Editc(Dtl_QtyOrd:'N'));
          WrkLen = (%Len(Scn_Error6Txt2)
              -%Len(%Trim(Scn_Error6Txt2)))/2;
          Scn_Error6Txt2 = %Subst(WrkBlanks:1:WrkLen)+
              %Trim(Scn_Error6Txt2);

          Dow 1 = 1;

             Exfmt Error6Wdw;

             If *In12 = *On;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 8 -                           *
       //***************************************
       Begsr Sbr_Error8;

          // Get Item Number, Description and BinLoc from IVPITEMS
          Chain SavItmnum IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Err08Itm# = %Editc(Itm_Itmnum:'X');
             Scn_Err08Desc = Itm_Sdesc;
          Else;
             Scn_Err08Itm# = *Blanks;
             Scn_Err08Desc = *Blanks;
          Endif;

          // Load Qty Remaining
          Scn_Err08Txt1 = %Trim(%Editc(Dt1_QtyOrd:'1'));

          // Center the Fields on the Screen
          Wrk78  = Scn_Err08Itm#;
          Exsr Sbr_Center78;
          Scn_Err08Itm# = Wrk78;

          Wrk78  = Scn_Err08Desc;
          Exsr Sbr_Center78;
          Scn_Err08Desc = Wrk78;

          Wrk78  = Scn_Err08Txt1;
          Exsr Sbr_Center78;
          Scn_Err08Txt1 = Wrk78;

          // Display the Screen Until F12 is presses
          Dow 1 = 1;
             Exfmt Error8;
             Exsr Sbr_ClrScreen;
             If *In12 = *On;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 9 - Did Item Get Wrapped on Please Finish *
       //***********************************************************************
       Begsr Sbr_Error9;

          Scn_Error9Txt1 = %Trim(%Editc(Scn_DspItm:'X'));
          WrkLen = (%Len(Scn_Error9Txt1) - %Len(%Trim(Scn_Error9Txt1)))/2;
          Scn_Error9Txt1 = %Subst(WrkBlanks:1:WrkLen)+
              %Trim(Scn_Error9Txt1);

          Scn_Error9Txt2 = %Trim(Scn_DspDesc);
          WrkLen = (%Len(Scn_Error9Txt2) - %Len(%Trim(Scn_Error9Txt2)))/2;
          Scn_Error9Txt2 = %Subst(WrkBlanks:1:WrkLen) + %Trim(Scn_Error9Txt2);

          Dow 1 = 1;
             Exfmt Error9Wdw;
             If *In07 = *On;
                Exsr Sbr_Wrap_Item;
                Leave;
             Endif;
             If *In12 = *On;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Check If The Entire Order Is Wrapped *
       //****************************************
       Begsr Sbr_ChkOrdWrap;

          WrkOrdWrapped = 'N';

          // Count the lines still to be wrapped, same test as the Lines
          // Remaining shown on the screen
          WrkOpenLines = 0;
          Setll (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL4;
          Dow 1 = 1;
             Reade (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL4;
             If %Eof(WSLORDDTL4);
                Leave;
             Endif;
             If Dt4_Status <> 9;
                WrkOpenLines = WrkOpenLines + 1;
             Endif;
          Enddo;

          // Nothing left to wrap and at least one line was wrapped, so the
          // order is complete (an order with nothing wrapped is not)
          If WrkOpenLines = 0;
             Setgt (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
             Dow 1 = 1;
                Readpe (Ctl_Ordnum : Ctl_SubAlph) WSLORDDTL1;
                If %Eof(WSLORDDTL1);
                   Leave;
                Endif;
                If Dt1_WrapSeq <> 0 and Dt1_Status = 1;
                   WrkOrdWrapped = 'Y';
                   Leave;
                Endif;
             Enddo;
          Endif;
       Endsr;

       //***********************************************************************
       //* Error 10 - Item Quantity Changed Info Screen *
       //***********************************************************************
       Begsr Sbr_Error10;

          // Save the Item Number so this screen will not be displayed if
          // comming back from multi box close
          SavDspItm = Scn_DspItm;

          // Get Item Number and Description from IVPITEMS
          Chain Scn_DspItm IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Err10Itm# = %Editc(Itm_Itmnum:'X');
             Scn_Err10Desc = Itm_Sdesc;
          Else;
             Scn_Err10Itm# = *Blanks;
             Scn_Err10Desc = *Blanks;
          Endif;

          // Get Name of Person who Changed the Quantity
          Chain Dtl_UserId MFPUSERS;
          If %Found(MFPUSERS);
             Scn_Err10Txt1 = Usr_UserName;
          Else;
             Scn_Err10Txt1 = 'Supervisor';
          Endif;

          // Load the Date and Time the Item was Backordered
          Scn_Err10Txt2 = %Char(%Date(Dtl_ModTs):*USA) + '   ' +
              %Char(%Time(Dtl_ModTs):*USA);

          // Center the Fields on the Screen
          Wrk78  = Scn_Err10Itm#;
          Exsr Sbr_Center78;
          Scn_Err10Itm# = Wrk78;

          Wrk78  = Scn_Err10Desc;
          Exsr Sbr_Center78;
          Scn_Err10Desc = Wrk78;

          Wrk78  = Scn_Err10Txt1;
          Exsr Sbr_Center78;
          Scn_Err10Txt1 = Wrk78;

          Wrk78  = Scn_Err10Txt2;
          Exsr Sbr_Center78;
          Scn_Err10Txt2 = Wrk78;

          // Display the Screen Until F12 is presses
          Dow 1 = 1;
             Exfmt Error10;
             If *In12 = *On;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 11 - Item Backordered Error Screen *
       //********************************************
       Begsr Sbr_Error11;

          // Get Item Number and Description from IVPITEMS
          Chain Scn_DspItm IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Err11Itm# = %Editc(Itm_Itmnum:'X');
             Scn_Err11Desc = Itm_Sdesc;
          Else;
             Scn_Err11Itm# = *Blanks;
             Scn_Err11Desc = *Blanks;
          Endif;

          // Get Name of Person who backordered the Item
          Chain Dtl_UserId MFPUSERS;
          If %Found(MFPUSERS);
             Scn_Err11Txt1 = Usr_UserName;
          Else;
             Scn_Err11Txt1 = 'Supervisor';
          Endif;

          // Load the Date and Time the Item was Backordered
          Scn_Err11Txt2 = %Char(%Date(Dtl_ModTS):*USA) + '   ' +
                          %Char(%Time(Dtl_ModTS):*USA);

          // Center the Fields on the Screen
          Wrk78  = Scn_Err11Itm#;
          Exsr Sbr_Center78;
          Scn_Err11Itm# = Wrk78;

          Wrk78  = Scn_Err11Desc;
          Exsr Sbr_Center78;
          Scn_Err11Desc = Wrk78;

          Wrk78  = Scn_Err11Txt1;
          Exsr Sbr_Center78;
          Scn_Err11Txt1 = Wrk78;

          Wrk78  = Scn_Err11Txt2;
          Exsr Sbr_Center78;
          Scn_Err11Txt2 = Wrk78;

          // Display the Screen Until F12 is presses
          Dow 1 = 1;
             Exfmt Error11;
             Exsr Sbr_ClrScreen;
             If *In12 = *On;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 12 - Item Deleted Error Screen *
       //****************************************
       Begsr Sbr_Error12;

          // Get Item Number, Description and BinLoc from IVPITEMS
          Chain Scn_DspItm IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Err12Itm# = %Editc(Itm_Itmnum:'X');
             Scn_Err12Desc = Itm_Sdesc;
             // Get Bin loc
             PrmBinLoc   = %Editc(Upc_Binzone:'4')
                         + Upc_BinAisle
                         + %Editc(Upc_Binsection:'4')
                         + Upc_BinLevel
                         + %Editc(Upc_Binslot:'4');
             If PrmBinLoc   <> *Blanks;
                PrmBinZone    = %Editc(Upc_Binzone:'X');
                PrmBinAisle   = Upc_BinAisle;
                PrmBinSection = %Editc(Upc_BinSection:'X');
                PrmBinLevel   = Upc_BinLevel;
                PrmBinSlot    = %Editc(Upc_BinSlot:'X');

                Exsr Sbr_FrmtBin;
             Endif;
             Scn_Err12Bin  = PrmBinLoc;
          Else;
             Scn_Err12Itm# = *Blanks;
             Scn_Err12Desc = *Blanks;
             Scn_Err12Bin  = *Blanks;
          Endif;

          // Get Name of Person who Deleted the Item
          Chain Dtl_UserId MFPUSERS;
          If %Found(MFPUSERS);
             Scn_Err12Txt1 = Usr_UserName;
          Else;
             Scn_Err12Txt1 = 'Supervisor';
          Endif;

          // Load the Date and Time the Item was Deleted
          Scn_Err12Txt2 =  %Char(%Date(Dtl_ModTs):*USA) + '   ' +
                           %Char(%Time(Dtl_ModTs):*USA);

          // Center the Fields on the Screen
          Wrk78  = Scn_Err12Itm#;
          Exsr Sbr_Center78;
          Scn_Err12Itm# = Wrk78;

          Wrk78  = Scn_Err12Desc;
          Exsr Sbr_Center78;
          Scn_Err12Desc = Wrk78;

          Wrk78  = Scn_Err12Bin;
          Exsr Sbr_Center78;
          Scn_Err12Bin  = Wrk78;

          Wrk78  = Scn_Err12Txt1;
          Exsr Sbr_Center78;
          Scn_Err12Txt1 = Wrk78;

          Wrk78  = Scn_Err12Txt2;
          Exsr Sbr_Center78;
          Scn_Err12Txt2 = Wrk78;

          // Display the Screen Until F12 is presses
          Dow 1 = 1;
             Exfmt Error12;
             Exsr Sbr_ClrScreen;
             If *In12 = *On;
                Leave;
             Endif;
          Enddo;
       Endsr;

       //***********************************************************************
       //* Error 13 - Change In Qty Selection Screen *
       //*********************************************
       Begsr Sbr_Error13;

          Scn_TtlText = 'Wrap Items - Split Quantity';
          WrkLen = (%Len(Scn_TtlText) - %Len(%Trim(Scn_TtlText)))/2;
          Scn_TtlText = %Subst(WrkBlanks:1:WrkLen) + Scn_TtlText;

          // Get Item Number, Description and BinLoc from IVPITEMS
          Chain Scn_DspItm IVPITEMS;
          If %Found(IVPITEMS);
             Scn_Err13Itm# = Itm_Itmnum;
             Scn_Err13Desc = Itm_Sdesc;
          Else;
             Scn_Err13Itm# = 0;
             Scn_Err13Desc = *Blanks;
          Endif;

          // Load Screen Fields
          Scn_Err13Qty1 = %Trim(%Editc(Scn_Qty:'1'));
          Scn_Err13Qty2 = %Trim(%Editc(Scn_Qty:'1'));
          Scn_Err13Qty3 = %Trim(%Editc(Scn_Qty:'1'));
          Scn_Err13Bo1  = %Trim(%Editc((Dtl_QtyOrd - Scn_Qty):'1'));
          Scn_Err13Bo2  = %Trim(%Editc((Dtl_QtyOrd - Scn_Qty):'1'));
          WrkBoQty      = Dtl_QtyOrd - Scn_Qty;

          // Center the Fields on the Screen
          Wrk29  = Scn_Err13Desc;
          Exsr Sbr_Center29;
          Scn_Err13Desc = Wrk29;

          Wrk20  = Scn_Err13Qty1;
          Exsr Sbr_Center20;
          Scn_Err13Qty1 = Wrk20;

          Wrk20  = Scn_Err13Qty2;
          Exsr Sbr_Center20;
          Scn_Err13Qty2 = Wrk20;

          Wrk20  = Scn_Err13Qty3;
          Exsr Sbr_Center20;
          Scn_Err13Qty3 = Wrk20;

          Wrk20  = Scn_Err13Bo1;
          Exsr Sbr_Center20;
          Scn_Err13Bo1  = Wrk20;

          Wrk20  = Scn_Err13Bo2;
          Exsr Sbr_Center20;
          Scn_Err13Bo2  = Wrk20;

          // Display the Screen Until F12 is presses
          Dow 1 = 1;
             Exfmt Error13;

             // F1=Close Box
             If *In01 = *On;

                Chain SdsDevice WSPCONTROL;
                Ctl_Itmnum = Scn_DspItm;
                Update WS$CONTROL %Fields(Ctl_Itmnum);

                Exsr Sbr_Wrap_Item;
                Callp WSRCHKBOX();

                Chain(N) SdsDevice WSPCONTROL;

                If Ctl_NoItmBox = 'Y';
                   Scn_Msg001 = 'No Items in the box';
                Else;

                   If Ctl_Itmnum <> *Zero
                                 And ( Hdr_Custno = 17679024    // MFI
                                 Or    Hdr_Custno = 17021553 ); // MFI Drums

                      Exsr Sbr_Print_MFI_UCC;
                   Endif;

                   // Close  the box
                   Callp WSRCLSBOX();
                Endif;

                Leave;
             Endif;

             // F4=Wrap Item and Backorder Remaining
             If *In04 = *On;

                Chain SdsDevice WSPCONTROL;
                Ctl_Itmnum = Scn_DspItm;
                Update WS$CONTROL %Fields(Ctl_Itmnum);

                If Ctl_Itmnum <> *Zero
                              And ( Hdr_Custno = 17679024    // MFI
                              Or    Hdr_Custno = 17021553 ); // MFI Drums

                   Exsr Sbr_Print_MFI_UCC;
                Endif;

                Exsr Sbr_Wrap_Item;

                Exsr Sbr_BoItem;

                // Write to order history
                PrmText = 'Qty: ' + %Editc(WrkBoQty : 'Z')
                   + ' of Item: ' + %Editc(Scn_DspItm : 'Z')
                   + ' was backordered by ';

                Exsr Sbr_Write_History;

                Leave;
             Endif;

             // F8=Wrap Item and Backorder Remaining and Close Box
             If *In08 = *On;

                Chain SdsDevice WSPCONTROL;
                Ctl_Itmnum = Scn_DspItm;
                Update WS$CONTROL %Fields(Ctl_Itmnum);

                Exsr Sbr_Wrap_Item;
                Callp WSRCHKBOX();

                Chain(N) SdsDevice WSPCONTROL;

                If Ctl_NoItmBox = 'Y';
                   Scn_Msg001 = 'No Items in the box';
                Else;

                   If Ctl_Itmnum <> *Zero
                                 And ( Hdr_Custno = 17679024    // MFI
                                 Or    Hdr_Custno = 17021553 ); // MFI Drums

                      Exsr Sbr_Print_MFI_UCC;
                   Endif;

                   // Close  the box
                   Callp WSRCLSBOX();
                Endif;

                Exsr Sbr_BoItem;

                // Write to order history
                PrmText = 'Qty: ' + %Editc(WrkBoQty : 'Z')
                   + ' of Item: ' + %Editc(Scn_DspItm : 'Z')
                   + ' was backordered by ';

                Exsr Sbr_Write_History;

                Leave;
             Endif;

             // F12=Cancel Item
             If *In12 = *On;
                Leave;
             Endif;

          Enddo;

          Scn_TtlText = 'Wrap Items';

          WrkLen = (%Len(Scn_TtlText) - %Len(%Trim(Scn_TtlText)))/2;
          Scn_TtlText = %Subst(WrkBlanks:1:WrkLen) +  Scn_TtlText;
       Endsr;

       //***********************************************************************
       //* Center Error Window Fields That are 20 Wide *
       //***********************************************
       Begsr Sbr_Center20;

          WrkLen = (20 - %Len( %Trim(Wrk20) ) ) / 2;
          Wrk20  = %Subst(WrkBlanks:1:WrkLen) + %Trim(Wrk20);
       Endsr;

       //***********************************************************************
       //* Center Error Window Fields That are 29 Wide *
       //***********************************************
       Begsr Sbr_Center29;

          WrkLen = (29 - %Len( %Trim(Wrk29) ) ) / 2;
          Wrk29  = %Subst(WrkBlanks:1:WrkLen) + %Trim(Wrk29);
       Endsr;

       //***********************************************************************
       //* Center Error Window Fields That are 39 Wide *
       //***********************************************
       Begsr Sbr_Center39;

          WrkLen = (39 - %Len( %Trim(Wrk39) ) ) / 2;
          Wrk39  = %Subst(WrkBlanks:1:WrkLen) + %Trim(Wrk39);
       Endsr;

       //***********************************************************************
       //* Center Error Screen Fields That are 78 Wide *
       //***********************************************
       Begsr Sbr_Center78;

          WrkLen = (78 - %Len( %Trim(Wrk78) ) ) / 2;
          Wrk78  = %Subst(WrkBlanks:1:WrkLen) + %Trim(Wrk78);
       Endsr;

       //***********************************************************************
       //* Print MFI UCC Label with Specific Qty *
       //*****************************************
       Begsr Sbr_Print_MFI_UCC;

          PrmOrdNum  = %EditC(Ctl_OrdNum:'Z');
          PrmBoxNum  = %EditC(Ctl_BoxNum:'Z');
          PrmItmNum  = %EditC(Ctl_ItmNum:'Z');
          PrmQty     = %EditC(Scn_Qty:'Z');
          PrmUCC#    = *Blanks;
          PrmReprintLbl = *Blanks;

          // Display Screen
          Callp WSRMFIERRS ( PrmOrdNum
                           : Ctl_SubAlph
                           : PrmBoxNum
                           : PrmItmNum   );

          // Get UCC for item in box
          Callp DIRMFIUCC ( PrmOrdNum
                          : Ctl_SubAlph
                          : PrmBoxNum
                          : PrmItmNum
                          : PrmUCC# );

          // Print Label
          Callp LBRMFIUCC2 ( PrmOrdNum
                           : Ctl_SubAlph
                           : PrmBoxNum
                           : PrmItmNum
                           : PrmQty
                           : PrmReprintLbl );
       Endsr;

       //***********************************************************************
       //* Call Bin location Format program  *
       //*************************************
       Begsr Sbr_FrmtBin;
          CallP DIRFRMTBIN(PrmConvertType
                          :PrmBinloc
                          :PrmBinzone
                          :PrmBinaisle
                          :PrmBinsection
                          :PrmBinlevel
                          :PrmBinslot
                          :PrmError
                          :PrmZonePlus
                          :PrmNoZone);
       Endsr;
       //***********************************************************************
       //* Write History *
       //*****************
       Begsr Sbr_Write_History;

          Chain (SdsUser) MFPUSERS;
          If %Found(MFPUSERS);
             WrkName = %Trim(Usr_UserName);
          Else;
             WrkName = SdsUser;
          Endif;

          PrmOrdNum = %Editc(Ctl_Ordnum:'X');
          PrmText = %Trim(PrmText) + ' ' + %Trim(WrkName) + ' at '
             + %Trim(SdsDevice);

          Callp OTRWRTHST( PrmOrdNum : Ctl_SubAlph : '0' : PrmText );

          PrmText = *Blanks;

       Endsr;

       Begsr Sbr_Check_Box_Weight;

          // Display box weight if order route = 750 Bound Printed Matter, and weight is > 13lbs
          If Hdr_Route = 750;
             PrmBoxNum = %Char(Ctl_BoxNum);
             callp GURGETBWGH (%Char(Ctl_Ordnum)
                               :Ctl_Subalph
                               :PrmBoxNum
                               :WrkWeight);
             If WrkWeight <> *Blanks;
                Monitor;
                   WrkWeightDec = %DECH(WrkWeight:10:2);
                On-Error;
                   WrkWeightDec = *Zeros;
                EndMon;

                If WrkWeightDec >= 13;
                   *In66 = *On;

                   PrmMssg = 'Box Weight is: ' +  %TRIM(WrkWeight) + ' Lbs';
                   PrmMssgColor = 'RED';
                   PrmMssgAtr1 = 'RI';

                   callp GURDSPMSG (PrmMssg:PrmMssgColor:PrmMssgAtr1);

                EndIf;
             Endif;
          Endif;

       Endsr;

       //***********************************************************************
       //* Setup Subroutine *
       //********************
       Begsr Sbr_Setup;

          C = G;
          Exsr Sbr_SetupNum;

          Chain SdsDevice WSPCONTROL;
          If Not %Found(WSPCONTROL);
             *InLr = *On;
             Return;
          Endif;

          Chain (Ctl_Ordnum : Ctl_SubAlph) WSPORDHDR;
          If %Found(WSPORDHDR);
             If Hdr_CurrBox = 0;
                Ctl_BoxNum = 1;
             Else;
                Ctl_BoxNum = Hdr_CurrBox;
             Endif;
             Update WS$CONTROL %Fields(Ctl_Boxnum);
          Endif;

          SavEmp5     = Ctl_EmpNum6;
          Scn_Ttl2Time     = %Time();
          Scn_TtlDate = %Date();
          WrkDateISO  = %Date();

          Callp DAYOFWEEK(WrkDateISO : Scn_Ttl2Day);

          Scn_Ttl2User     = SdsUser;
          Scn_TtlPgm  = SdsProgram;

          // Center the title of the report
          WrkOrdNum = %Editc(Ctl_OrdNum:'X');
          Scn_TtlText = 'Wrap Items';

          WrkLen = (%Len(Scn_TtlText) - %Len(%Trim(Scn_TtlText)))/2;
          Scn_TtlText = %Subst(WrkBlanks:1:WrkLen) +  Scn_TtlText;

          // Center the Screen Subtitle
          Scn_Ttl2Text = '(' + %Trim(Ctl_EmpNam) + ') Order:'
                             + %Trim(WrkOrdnum);

          If Ctl_SubAlph <> *Blanks;
             Scn_Ttl2Text = %Trim(Scn_Ttl2Text) + '-' + %Trim(Ctl_SubAlph);
          Endif;

          WrkLen = (%Len(Scn_Ttl2Text) - %Len(%Trim(Scn_Ttl2Text)))/2;
          Scn_Ttl2Text = %Subst(WrkBlanks:1:WrkLen) + Scn_Ttl2Text;

          *In50 = *Off;
          *In54 = *Off;
          *In55 = *Off;

          *In65 = *Off;
          *In66 = *Off;

          Scn_CurrBoxTxt = '   Current Box   ';
          Scn_LineRemTxt = ' Lines Remaining ';

       Endsr;
