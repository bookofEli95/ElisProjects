     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO)
     H ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
     H/DEFINE   PROFOUNDUI
       //***********************************************************************
       // P1VEXPGEN
       // PCR: General Information Expert Code
       //***********************************************************************


       //**********************************************************************
       //** IF CHANGE ARE MADE TO THIS PROGRAM YOU MIGHT ALSO NEED TO CHANGE **
       //**                            P1REXPGEN                             **
       //**********************************************************************


       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       //
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33975  09/30/26 EFI Show Closed/Cancelled and POP on PCR
       // FIX     09/30/26 EFI Quick Fix - Auomate Release
       // H33111  08/02/24 TAK PCR program repeatedly writing a SELLBL MNT recor
       //                      d.
       // H32520  01/06/24 CMN Re-invoicing for 2024
       // H32200  10/03/23 TAK CST screen error when opening a new rerun
       // H31304  07/14/23 TAK PERMOT field changing when it shouldn't.  Some it
       //                      ems that should be marked BO are marked NYP
       // H30491  01/07/23 CMN 2023 Re-invoicing
       // H29268  08/02/22 SRK Update PCPMAIN Date Fields
       // H29268  08/02/22 SRK Update PCPMAIN Date Fields
       // MISC    05/20/22 CJR Misc Project
       // FIX     05/05/22 SRK Fix Compile error
       // H29268  05/05/22 SRK Update PCPMAIN Date Fields
       // FIX     05/02/22 CJR Quick Fix
       // H29054  04/29/22 CJR PCR: Allow Cancelling out of BA approval screen
       // H29268  03/21/22 SRK Update PCPMAIN Date Fields
       // H27551  01/24/22 CMN Marketing reimagined
       // H28753  01/17/22 CJR Filter the list of marketing codes for PCR
       // H27551  12/20/21 CMN Marketing reimagined
       // H28126  11/12/21 CJR PCR: Marketing code ADVERT
       // H27712  09/21/21 CJR Add Marketing codes to PCR
       // H27712  09/21/21 CJR Add Marketing codes to PCR
       // H27334  07/29/21 KMS Remove rerun dept for imports - Add delete to PCP
       //                      RRNDEPT for record when updated
       // H26191  06/30/21 SRK PCR: agency products
       // H26578  04/20/21 SRK PCR  - Royalty Options - Change B.A. Approval to
       //                      ask for information and flag PCR to Royalty
       // FIX     02/03/21 SRK Source Error Dates
       // FIX     02/03/21 SRK Source Error Dates
       // FIX     02/02/21 SRK Allow selection of different reports for email
       // H26169  02/02/21 SRK PCR: Unreceiving PCRs
       // H26165  02/02/21 SRK PCR: Allow Selecting Email Options on BA Approval
       // H26166  01/16/21 SRK PCR: Allow for different email addresses and Note
       // H25799  01/15/21 CMN Re-invoicing
       // H20805  12/28/20 SRK PCR System Update
       // H20805  12/08/20 SRK Fix Clinic/Show not saving
       // H24702  11/23/20 SRK Price Changes - Scott
       // H20805  11/11/20 SRK PCR System Update
       // H20805  11/11/20 SRK Add Instumentation List
       // H26075  11/09/20 SRK Retailed Closed Job Summary AS400 report messed u
       //                      p
       // H26075  11/09/20 SRK Retailed Closed Job Summary AS400 report messed u
       //                      p
       // H20805  11/03/20 SRK Change so Advertising Jobs are New Issue = N
       // H20805  11/03/20 SRK PCR System Update
       // H20805  10/14/20 SRK Create Outq Selection for Printing
       // H20805  09/16/20 SRK PCR System Update - Fix Retail Price not needed f
       //                      or Advertising items
       // H20805  09/04/20 SRK PCR System Update - Fix update ivpitems when pric
       //                      e is changed
       // H20805  09/03/20 SRK PCR System Update
       // H20805  09/03/20 SRK PCR System Update
       // H20805  09/03/20 SRK PCR System Update
       // H25586  08/10/20 CMN PCR kits not adding
       // MISC2   08/07/20 SRK Fix Source Errors
       // H20805  09/03/20 SRK Only Update data if something changed on the
       //                      screen
       // H20805  09/03/20 SRK Create a way to show if someone is in a job
       // H7904   07/29/20 SRK Expand the "Pub Code" field.
       // H20805  07/13/20 SRK PCR System Update - Show B/A Received fix
       // H20805  06/30/20 SRK PCR System Update - Remove ALWNULL.
       //                      overrides in Inventory Inq Driver causes error
       //                      if alwnull is in this program
       // H7904   06/29/20 SRK Expand the "Pub Code" field.
       // H20805  06/24/20 SRK PCR System Update - Longer Pubcode
       // H22742  05/22/20 SRK PCR: Update
       // H22742  05/22/20 SRK PCR: Update
       //***********************************************************************

       // Screen
     FP1DEXPGEN CF   E             WORKSTN Prefix(Scn_)
     F                                     HANDLER('PROFOUNDUI(HANDLER)')

       // Input Files
     FACPSRSGL  IF   E           K DISK    Prefix(Sgl_)
     FCTPDIVCAT IF   E           K DISK    Prefix(Cln_)
     FCTPTSCAT  IF   E           K DISK    Prefix(Tsh_)
     FDIV01L    IF   E           K DISK    Prefix(Div_)
     FIVLITM05  IF   E           K DISK    Prefix(I05_)
     F                                     Rename(IVPITEM$:IV$ITEM05)
     FIVLOWNPU1 IF   E           K DISK    Prefix(Pu1_)
     F                                     Rename(IVPOWNP$:IV$OWNPU1)
     FIVPARTX   IF   E           K DISK    Prefix(Art_)
     FIVPCAT    IF   E           K DISK    Prefix(Cat_)
     FMFARRNGR  IF   E           K DISK    Prefix(Ang_)
     FMFAUTHOR  IF   E           K DISK    Prefix(Aut_)
     FMFPUSERS  IF   E           K DISK    Prefix(Usr_)
     FMFLCOUNTR2IF   E           K DISK    Prefix(Cty_)
     FMFCATLOG  IF   E           K DISK    Prefix(Clg_)
     FMFPPBLSCHTIF   E           K DISK    Prefix(Pbl_)
     FMFVOICNG  IF   E           K DISK    Prefix(Voc_)
     FMFMEDIUM  IF   E           K DISK    Prefix(Med_)
     FNIPCATS   IF   E           K DISK    Prefix(Nic_)
     FIVPSRSD   IF   E           K DISK    Prefix(Srs_)
     FPCPCOMTS  IF   E           K DISK    Prefix(Cmt_)
     FPCPREV    IF   E           K DISK    Prefix(Prv_)
     FPCPRMTUS  IF   E           K DISK    Prefix(Rmt_)
     FPCPASRS   IF   E           K Disk    Prefix(Asr_)
     FPCPSRSD   IF   E           K DISK    Prefix(Srs_)
     FPCPWTXT   IF   E           K DISK    Prefix(Txt_)
     FROLOWCTL1 IF   E           K DISK    Prefix(Ctl_)
     FP1PDIVCODEIF   E           K DISK    Prefix(Cod_)
     FACPGLMKTCDIF   E           K DISK    Prefix(Mkt_)
     FW#JOBFLE  IF   E           K DISK    Prefix(Job_)
     F                                     Rename(WW$JOBAC:W$JOBFLE)

       // Output Files
     FPCPCATLG  IF A E           K DISK    Prefix(Pct_)
     FP1PBAFRCVHIF A E           K DISK    Prefix(Rch_)
     FPCPROYAPV IF A E           K DISK    Prefix(Rap_)

       // Update/Add Files
     FPCLMAIN08 UF A E           K DISK    Prefix(Mn8_)
     FJOBFLE7   UF A E           K DISK    Prefix(Jf7_)
     FRERUN8    UF A E           K DISK    Prefix(Rr8_)
     FW#JOBSCR  UF A E           K DISK    Prefix(Scr_)
     FPCPADVSPLTUF A E           K DISK    Prefix(Adv_)
     FIVPORRITM UF A E           K DISK    Prefix(Orr_)
     FIVPORRMNT UF A E           K DISK    Prefix(Orm_)
     FIVPITMCODEUF A E           K DISK    Prefix(Cod_)

       // Update Files
     FPCPROYLT  UF   E           K DISK    Prefix(Roy_)
     FIVPITEMS  UF   E           K DISK    Prefix(Itm_)
     FIVLITM    UF   E           K DISK    Prefix(Isr_)
     F                                     Rename(IVPITEM$:IVLITM$)
     FPCPBKEVN  UF   E           K DISK    Prefix(Bke_)
     FPCLKITFL  UF   E           K DISK    Prefix(Lkf_)
     F                                     Rename(PCPKITF$:PCLKITFL$)
     FPCPRRNDEPTUF   E           K DISK    Prefix(Dpt_)

       // Output Files
     FPCPSTACK  O    E             DISK    Prefix(Stk_)
     FIVPMAINT  O    E           K DISK    Prefix(Mnt_)
     FPCPREVITM O    E             DISK    Prefix(Rev_)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,checksec
      /copy qcopysrc,gurgetout2

      /copy qcopysrc,ivraskwd
      /copy qcopysrc,ivrorrgetc
      /copy qcopysrc,ivvupdtprc
      /copy qcopysrc,ivrtieritm
      /copy qcopysrc,ivrref#c

      /copy qcopysrc,pcrautinst
      /copy qcopysrc,pcrisbn
      /copy qcopysrc,pcrrern
      /copy qcopysrc,pcrnotify

      /copy qcopysrc,scvmnt
      /copy qcopysrc,upc#2
      /copy qcopysrc,sendmsg

      /copy qcopysrc,p1rgetjob
      /copy qcopysrc,p1r999s
      /copy qcopysrc,p1rgetdts
      /copy qcopysrc,p1rlodgoto
      /copy qcopysrc,p1rnextp
      /copy qcopysrc,p1remltpc
      /copy qcopysrc,p1rbhismn
      /copy qcopysrc,p1rapprkit
      /copy qcopysrc,p1rcansts

      /copy qcopysrc,p1vprint
      /copy qcopysrc,p1vchppl
      /copy qcopysrc,p1vcurcode
      /copy qcopysrc,p1valtsrs
      /copy qcopysrc,p1vviewbar
      /copy qcopysrc,p1vpmtmedm
      /copy qcopysrc,p1vpmtpblc
      /copy qcopysrc,p1vpmtorig
      /copy qcopysrc,p1vpmtrorf
      /copy qcopysrc,p1vpmtctlg
      /copy qcopysrc,p1vpmtsrs
      /copy qcopysrc,p1vpmtcntt
      /copy qcopysrc,p1vpmtcnty
      /copy qcopysrc,p1vpmtvoic
      /copy qcopysrc,p1vpmtart
      /copy qcopysrc,p1vpmtargr
      /copy qcopysrc,p1vpmtauth
      /copy qcopysrc,p1vpmtnict
      /copy qcopysrc,p1vpmtcat
      /copy qcopysrc,p1vpmtdiv
      /copy qcopysrc,p1vpmtbcat
      /copy qcopysrc,p1vpmtpubn
      /copy qcopysrc,p1rgetinus
      /copy qcopysrc,p1vpmtmkt

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds
     D AryCat          S                   Dim(10)
     D                                     Like(Scn_Cat1)
     D                                     Based(WrkCatPtr)
     D WrkCatPtr       S               *   Inz(%Addr(WrkCatDS))
     DWrkCatDS         DS                  Inz
     D  Scn_Cat1
     D  Scn_Cat2
     D  Scn_Cat3
     D  Scn_Cat4
     D  Scn_Cat5
     D  Scn_Cat6
     D  Scn_Cat7
     D  Scn_Cat8
     D  Scn_Cat9
     D  Scn_Cat10

     D AryCatD         S                   Dim(10)
     D                                     Like(Scn_Cat1d)
     D                                     Based(WrkCatDPtr)
     D WrkCatDPtr      S               *   Inz(%Addr(WrkCatDDs))
     DWrkCatDDs        DS                  Inz
     D  Scn_Cat1d
     D  Scn_Cat2d
     D  Scn_Cat3d
     D  Scn_Cat4d
     D  Scn_Cat5d
     D  Scn_Cat6d
     D  Scn_Cat7d
     D  Scn_Cat8d
     D  Scn_Cat9d
     D  Scn_Cat10d

     D ArySplit        S                   Dim(10)
     D                                     Like(Scn_Split1)
     D                                     Based(WrkSplitPtr)
     D WrkSplitPtr     S               *   Inz(%Addr(WrkSplitDS))
     DWrkSplitDS       DS                  Inz
     D  Scn_Split1
     D  Scn_Split2
     D  Scn_Split3
     D  Scn_Split4
     D  Scn_Split5
     D  Scn_Split6
     D  Scn_Split7
     D  Scn_Split8
     D  Scn_Split9
     D  Scn_Split10

     D PrmMenuText     S           1000
     D PrmText         S            100

     D PrmRoRefNum     S              5
     D PrmPblshrNum    S              5
     D PrmCmdKey       S              2
     D PrmAuthTier     S              1A
     D PrmItmNumA      S              8A
     D PrmJobnum7      S              7A
     D PrmMessage      S           1500A
     D PrmNotifyItm    S              8A
     D PrmPublCode     S              2A
     D PrmSubject      S             80A
     D PrmTierMnt      S              1A
     D PrmNicat1       S              3A
     D PrmNicat2       S              3A
     D PrmNicat3       S              3A
     D PrmPubcod       S             10A
     D PrmDivcat2      S              7A
     D PrmEmailTo      S             10
     D PrmCopyTo       S             10
     D PrmNotes        S            960
     D PrmOutq         S             10
     D PrmCopies       S              1


     D WrkOvrPubCode   S              1
     D WrkAllowCln     S              1A
     D WrkSUmSplits    S              4  0
     D WrkInquiry      S              1A
     D WrkUpdate       S              1A
     D Wrk$Admf        S              5  2
     D Wrk$Admfd       S              5  4
     D WrkCldes        S             87A
     D WrkCpric72      S              7  2
     D Wrkdesc         S             22A
     D WrkDivcat       S              7A
     D WrkExpCode      S              3A
     D WrkFlgCall      S              1A
     D WrkJvs01        S                   Like(Roy_AcrRate)
     D WrkJvs02        S                   Like(Roy_AcrRate)
     D WrkJvs03        S                   Like(Roy_AcrRate)
     D WrkJvs04        S                   Like(Roy_AcrRate)
     D WrkJvs05        S                   Like(Roy_AcrRate)
     D WrkJv00         S             15  5
     D WrkJv01         S             15  5
     D WrkKit          S              1
     D WrkLen          S              2S 0
     D WrkIndex1       S              4  0
     D WrkMktCoord     S             10A
     D WrkNoJob        S              1A
     D WrkOrigba       S              1A
     D WrkPldesc       S             87A
     D WrkPos          S              3  0
     D WrkPpric72      S              7  2
     D WrkPubDup       S              1A   Inz('N')
     D WrkQOH          S              7  0
     D WrkCatLen7      S              7  0
     D WrkSavVoicng    S             12A
     D WrkSvbsaf       S              1A
     D WrkSvbsus       S             10A
     D WrkSvrcvw       S             10A
     D WrkSvrun        S              2A
     D WrkTmpacm       S                   Like(Roy_AcrRate)
     D WrkTmpPr2       S              7  4
     D WrkTyp          S             12A
     D WrkDfltCntrtp   S              1A
     D WrkOKToContinu  S               N
     D WrkErrFound     S               N
     D WrkSplitCnt     S              4  0
     D WrkStartLoop    S              4  0
     D WrkIndex2       S              4  0
     D WrkGL           S              8  0
     D WrkMktCode      S              7A
     D WrkPCR          S              1A
     D WrkCancel       S              1A
     D WrkInvUpd       S              1A

       // Parameters passed to IVRASKWD
     D IVRASKWDDS      DS
     D  Prm$Itmnu              1      8  0
     D  PrmDelete              9      9
     D  PrmReruna             10     10
     D  Prm$Ldesc             11     97
     D  PrmDivcat             98    104  0
     D  PrmRorefNum2         105    109  0

     D PCDINQRY      E DS           100    Prefix(Pcd_)
     D                                     ExtName(PCDINQUIRY)
     D                                     DtaAra(PCDINQRY)

       //***********************************************************************
       //* Main Line **
       //**************
       Exsr Sbr_Setup;

     C     Reload        Tag
       *In97 = *OFF;
       // Rcd Force Prelim
       If Pcd_ForcePrelm <> ' ';
          *In97 = *On;
       Endif;

       // Move to screen fields
       Exsr Sbr_Load_Screen;

       If Pcd_NewAdd = 'A' and *In99 = *Off;
          Scn_Mode = 'ADD';
       Endif;

       // Do not run Edits if in Inquiry Mode
       If *In99 = *Off;
          Exsr Sbr_Check_For_Errors;
       Else;
          Exsr Sbr_Load_Extended_Data;
       Endif;

       // Main Line
       WrkOrigBA  = Mn8_Busaff;
       WrkSvbsaf  = Mn8_Busaff;
       WrkSvbsus  = Mn8_Buswho;
       WrkSvrcvw  = Mn8_Rcvwho;

       Chain (Mn8_Divcat) IVPCAT;
       If Itm_Sdesc = *Blanks;
          WrkLen = %Checkr(' ':Itm_Sdesc);
          // Check to see if Voicng is included in Sdesc
          // If not move it into sdesc
          If Mn8_Voicng <> *Blanks;
             WrkPos = %Scan(%Trim(Mn8_Voicng):Itm_Sdesc);
             If WrkPos = 0;
                %Subst(Itm_Sdesc:23:6) = *Blanks;
                If WrkLen < 18;
                   Itm_Sdesc = %Trim(Scn_Desc22) + ' ' + %Trim(Mn8_Voicng);
                Else;
                   Itm_Sdesc = Scn_Desc22 + ' ' + %Trim(Mn8_Voicng);
                Endif;
             Endif;
          Endif;

          If Mn8_Medium <> *Blanks;
             // Check to see if Medium is included in Sdesc
             // If not move it into sdesc
             WrkPos = %Scan(%Trim(Mn8_Medium):Itm_Sdesc);
             If WrkPos = 0;
                %Subst(Itm_Sdesc:23:6) = *Blanks;
                IF WrkLen < 18;
                   Itm_Sdesc = %Trim(Scn_Desc22) + ' ' + %Trim(Mn8_Medium);
                Else;
                   Itm_Sdesc = Scn_Desc22 + ' ' + %Trim(Mn8_Medium);
                Endif;
             Endif;
          Endif;
       Endif;

       If Scn_Jobnum7 <> 0;
          If Scn_InqMode = *Off;
             Scn_DisScore = *Off;
             If Scn_@Scslt = 'Y';
                Scn_DisScore = *On;
             Endif;
          Endif;
       Endif;

       If WrkFlgCall = *On;
          WrkFlgCall = *Off;
          WrkUpdate = 'N';
     C                   Goto      Reedit
       Endif;

       // Main Loop
       Dow 1 = 1;
          WrkUpdate = 'Y';

          If Scn_Mode = 'ADD' and WrkOKToContinu = *Off;
             Scn_MnuChoices = 'Previous,Alternate Series';
          Else;
             Scn_MnuChoices = 'Next,'
                            + %Trim(PrmMenuText)
                            + ',Previous,Alternate Series';
          Endif;

          // Show B/A Approval only if
          // In Update Mode       (Scn_Mode = 'UPDATE')
          // User is a B/A Person (Pcd_BusAffair = '1')
          // PCR sent to B/A      (Mn8_@Send = 'Y')
          // B/A has not Approved (Mn8_Busaff <> 'Y')
          If  Scn_Mode      = 'UPDATE'
          and Pcd_BusAffair = '1'
          and Mn8_@Send     = 'Y'
          and Mn8_Busaff    <> 'Y';
             Scn_MnuChoices = %Trim(Scn_MnuChoices) + ',B/A Approval';
          Endif;

          //Show F14={Send to B/A for Approval or Final} only if
          // In Update Mode       (Scn_Mode = 'UPDATE')
          // B/A has not Approved (Mn8_Busaff <> 'Y')
          If  Scn_Mode = 'UPDATE'
          and Mn8_@Send <> 'Y';
             If *In97 = *On;
                Scn_MnuChoices = %Trim(Scn_MnuChoices) + ',Finalize';
             Else;
                Scn_MnuChoices = %Trim(Scn_MnuChoices)
                               + ',Send to B/A for Approval';
             Endif;
          Endif;

          // Show F16=B/A Receive only if
          // Not in Inquiry Mode  (*In99 = *Off)
          // User is a B/A Person (Pcd_BusAffair = '1')
          // PCR sent to B/A      (Mn8_@Send = 'Y')
          If  Scn_Mode = 'UPDATE'
          and Pcd_BusAffair = '1'
          and Mn8_@Send = 'Y';
             Scn_MnuChoices = %Trim(Scn_MnuChoices) + ',B/A Received';
          Endif;

          // B/A Received History has More than 2 Records
          Scn_ShwBtnHst = *Off;
          Chain (Scn_Jobnum7 : Scn_Itmnum : 3) P1PBAFRCVH;
          If %Found(P1PBAFRCVH);
             Scn_ShwBtnHst = *On;
          Endif;

          // Show Tier Price Maintenance
          If PrmAuthTier = 'Y';
             Scn_MnuChoices = %Trim(Scn_MnuChoices)
                            + ',Tier Maintenance';
          Endif;

          Exsr Sbr_Update_Date_And_Time;

          Exfmt SCREEN;
          Scn_Message = *Blanks;

          // Setoff Position To Indicators
          Scn_ErrLdesc   = *Off; // Title
          Scn_FocLdesc   = *Off; // Title
          Scn_ErrDesc22  = *Off; // Short Desc
          Scn_ErrPrice72 = *Off; // Retail
          Scn_ErrRunQty  = *Off; // Run Quantity
          Scn_ErrSeries  = *Off; // Series
          Scn_ErrCntrtp  = *Off; // Contract Type
          Scn_ErrCtryOrg = *Off; // Country of Origin
          Scn_ErrMedium  = *Off; // Medium
          Scn_ErrVoicng  = *Off; // Voicing
          Scn_ErrMaxDis  = *Off; // Max Discount
          Scn_ErrRoRef   = *Off; // Roref#
          Scn_ErrPblshrN = *Off; // Publisher
          Scn_ErrArtist  = *Off; // Artist
          Scn_ErrArrngr  = *Off; // Arranger
          Scn_ErrAuthor  = *Off; // Composer/Author
          Scn_ErrPublcod = *Off; // Publisher Code
          Scn_ErrCatlog  = *Off; // Catalog Code
          Scn_Err@Catl1  = *Off; // Catalog 1
          Scn_Err@Catl2  = *Off; // Catalog 2
          Scn_Err@NI     = *Off; // New Issue Y/N
          Scn_ErrNICat1  = *Off; // New Issue Cat 1
          Scn_ErrNICat2  = *Off; // New Issue Cat 2
          Scn_ErrNICat3  = *Off; // New Issue Cat 3
          Scn_ErrClinic# = *Off; // Clinic
          Scn_ErrDcf     = *Off; // DCF
          Scn_ErrMarket  = *Off; // Market Focus
          Scn_ErrMarket1 = *Off; // Market prompt
          Scn_ErrMkt     = *Off; // Marketing code
          Scn_ErrMkt2    = *Off; // Marketing code
          Scn_ErrCat1    = *Off; // Split Charge Cat
          Scn_ErrPubCode = *Off; // Pubcod - Pubcode
          WrkErrFound    = *Off; // Error Red Message

          // Display Security System Authorizations
          If Scn_BtnAuth = *On;
             Callp SCVMNT(SdsProgram);
             Iter;
          Endif;

          // Exit
          If Scn_BtnExit = *On;
             Dow 1 = 1;
                Exfmt WDWEXIT;

                If Scn_BtnAuth = *On;
                   Callp SCVMNT(SdsProgram);
                   Iter;
                Endif;
                Leave;
             Enddo;
             If Scn_BtnCancel = *On;
                Iter;
             Endif;
             In *Lock PCDINQRY;
             Pcd_CmdKey = '03';
             Out PCDINQRY;
             Leave;
          Endif;

          // Prompt Category (Change Division Prompt)
          If Scn_PmtDiv = *On;
             In *Lock PCDINQRY;
             Pcd_Itmnum  = Scn_Itmnum;
             Pcd_Jobnum7 = Scn_Jobnum7;
             Out PCDINQRY;
             Callp P1VPMTDIV();
             WrkFlgCall = *On;
     C                   Goto      Reload
          Endif;

          // Prompt Retail Price (Foreign Currency Maintenance)
          IF Scn_PmtPrice = *On;
             Callp P1VCURCODE (%Char(Scn_Itmnum) : %Char(Scn_Jobnum7));
             Iter;
          Endif;

          // Prompt Series
          If Scn_PmtSrs = *On;
             WrkDivcat = %Editc(Scn_Divcat:'X');
             CallP P1VPMTSRS (WrkDivcat : Scn_Series);
             Chain (Scn_Series) IVPSRSD;
             Scn_SrsDsc = Srs_SrsDsc;
          Endif;

          // Prompt Contract Type
          If Scn_PmtCntt = *On;
             Callp P1VPMTCNTT ('Y' : Scn_Cntrtp);
          Endif;

          // Prompt Country of Origin
          If Scn_PmtCtryOrg = *On;
             Callp P1VPMTCNTY(Scn_CtryOrigin);
          Endif;

          // Prompt Medium
          If Scn_PmtMedm = *On;
             CallP P1VPMTMEDM(Scn_Medium);
          Endif;

          // Prompt Voicing
          If Scn_PmtVoic = *On;
             CallP P1VPMTVOIC (Scn_Voicng);
          Endif;

          // Prompt RoRef#
          If Scn_PmtRorf = *On;
             PrmRoRefNum  = %Char(Scn_Rorefnum);
             PrmPblshrNum = %Char(Scn_Pblshrnum);
             PrmCmdKey    = *Blanks;
             Callp P1VPMTRORF ( PrmRoRefNum
                              : PrmPblshrNum
                              : Scn_Cntrtp
                              : PrmCmdKey);

             Select;
                When PrmCmdKey = *Blanks;
                   Scn_Rorefnum  = %Int(PrmRoRefNum);
                   Scn_Pblshrnum = %Int(PrmPblshrNum);
                When PrmCmdKey = '12';

                When PrmCmdKey = 'ER';
                   Scn_Message = 'No records to display-blank '
                               + 'out both ROREF & PBLSHR '
                               + 'and Press F4 Again';
             EndSl;
          Endif;

          // Prompt Publisher
          If Scn_PmtPblshr = *On;
             PrmPblshrNum = %Char(Scn_PblshrNum);
             PrmRoRefNum  = %Char(Scn_RoRefNum);
             Callp P1VPMTPUBN( PrmPblshrNum
                             : PrmRoRefNum
                             : %Char(Scn_Itmnum)
                             : Scn_Cntrtp);
             Scn_PblshrNum = %Int(PrmPblshrNum);
             Scn_RoRefNum  = %Int(PrmRoRefNum);
          Endif;

          // Prompt Artist
          If Scn_PmtArtist = *On;
             CallP P1VPMTART (Scn_Artist);
          Endif;

          // Prompt Arranger
          If Scn_PmtArgr = *On;
             CallP P1VPMTARGR (Scn_Arrngr);
          Endif;

          // Prompt Composer/Author
          If Scn_PmtAuth = *On;
             CallP P1VPMTAUTH (Scn_Author);
          Endif;

          // Prompt PublCode
          If Scn_PmtPubCode = *On;
             PrmPublCode = %Editc(Scn_Publcode:'X');
             Callp P1VPMTPBLC(PrmPublCode);
             Scn_Publcode = %Int(PrmPublCode);
          Endif;

          // Prompt Catalog Code
          If Scn_PmtCtlg = *On;
             Callp P1VPMTCTLG (Scn_Catlog);
          Endif;

          // Prompt Catalog 1
          If Scn_PmtCat1 = *On;
             Callp P1VPMTCAT (Scn_@Catl1);
          Endif;

          // Prompt Catalog 2
          If Scn_PmtCat2 = *On;
             Callp P1VPMTCAT (Scn_@Catl2);
          Endif;

          // Prompt New Issue
          If Scn_PmtNewIss = *On;
             PrmNicat1 = %Char(Scn_NiCat1);
             PrmNicat2 = %Char(Scn_NiCat2);
             PrmNicat3 = %Char(Scn_NiCat3);
             Callp P1VPMTNICT ( %Char(Scn_Divcat)
                              : PrmNicat1
                              : PrmNicat2
                              : PrmNicat3 );
             Scn_Nicat1 = %Int(PrmNiCat1);
             Scn_Nicat2 = %Int(PrmNiCat2);
             Scn_Nicat3 = %Int(PrmNiCat3);
          Endif;

          // Prompt Advertising Billing Category
          If Scn_PmtBCat = *On;
             Callp P1VPMTBCAT(PrmDivcat2);
             If PrmDivcat2 <> ' ';
                Select;
                   When Scn_Cat1 = 0;
                      Scn_Cat1 = %Int(PrmDivcat2);
                   When Scn_Cat2 = 0;
                      Scn_Cat2 = %Int(PrmDivcat2);
                   When Scn_Cat3 = 0;
                      Scn_Cat3 = %Int(PrmDivcat2);
                   When Scn_Cat4 = 0;
                      Scn_Cat4 = %Int(PrmDivcat2);
                   When Scn_Cat5 = 0;
                      Scn_Cat5 = %Int(PrmDivcat2);
                   When Scn_Cat6 = 0;
                      Scn_Cat6 = %Int(PrmDivcat2);
                   When Scn_Cat7 = 0;
                      Scn_Cat7 = %Int(PrmDivcat2);
                   When Scn_Cat8 = 0;
                      Scn_Cat8 = %Int(PrmDivcat2);
                   When Scn_Cat9 = 0;
                      Scn_Cat9 = %Int(PrmDivcat2);
                   When Scn_Cat10 = 0;
                      Scn_Cat10 = %Int(PrmDivcat2);
                EndSl;
             Endif;
          Endif;

          // Prompt Originator (Change Originator)
          If Scn_PmtOrig = *On;
             CallP P1VPMTORIG (Scn_Orign);
             Chain (Scn_Orign) MFPUSERS;
             If %Found(MFPUSERS);
                Scn_StartUser = Usr_UserName;
             Else;
                Scn_StartUser = Scn_Orign;
             Endif;
          Endif;

          // Prompt Market Code
          If Scn_PmtMktCd = *On;
             Scn_PmtMktCd = *Off;

             //Hdr 28126: allow Advertising to have all market codes
             If %Trim(Scn_Desc16) <> 'ADVERTISING';
                //Series and DCF need values before prompting market code
                If Scn_Series = *Blanks Or Scn_DCF = *Blanks;
                   Scn_ErrMarket1 = *On;
                   Iter;
                EndIf;
                WrkMktCode = *Blanks;
             Else;
                WrkMktCode = 'X';
             EndIf;

             CallP P1VPMTMKT (Scn_Series:WrkMktCode:Scn_DCF:WrkPCR);
             If WrkMktCode <> *Blanks And WrkMktCode <> 'X';
                Scn_MktCode = %Int(WrkMktCode);
                Iter;
             EndIf;
          EndIf;

          // View B/A Received History
          If Scn_BtnViewHst = *On;
             Callp P1VVIEWBAR (%Char(Scn_Itmnum) : %Char(Scn_Jobnum7));
             Iter;
          Endif;

          // Next
          If Scn_MnuOption = 'Next';
             Callp P1RNEXTP (WrkExpCode : Mn8_@Kit : '' : Pcd_NewAdd);
             WrkUpdate = 'N';
          Endif;

          // Goto Expert Codes
          If Scn_MnuOption = 'Beginning';
             WrkExpCode = '  ';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'General Information';
             WrkExpCode = 'GEN';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Comments';
             WrkExpCode = 'CMT';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Kits';
             WrkExpCode = 'KIT';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Production';
             WrkExpCode = 'PRD';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Instrumentation List';
             WrkExpCode = 'INS';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Cost Summary';
             WrkExpCode = 'CST';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Royalty Information';
             WrkExpCode = 'ROY';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Table of Contents';
             WrkExpCode = 'TOC';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Song Revisions';
             WrkExpCode = 'REV';
             WrkUpdate = 'N';
          Endif;
          If Scn_MnuOption = 'Breakeven';
             WrkExpCode = 'BKE';
             WrkUpdate = 'N';
          Endif;

          // Dup PubCode is OK
          If Scn_BtnPubCode = *On;
             WrkOvrPubCode = 'Y';
          Endif;

          // Return
          If Scn_MnuOption = 'Previous';
             In *Lock PCDINQRY;
             Pcd_CmdKey = '12';
             Out PCDINQRY;
             Leave;
          Endif;

          // Mark Business Affairs Approved
          If Scn_MnuOption = 'B/A Approval';
             Exsr Sbr_Mark_Business_Affairs_Approved;
          Endif;

          // Send to Business Affairs for Approval
          If Scn_MnuOption = 'Send to B/A for Approval'
          or Scn_MnuOption = 'Finalize';
             Exsr Sbr_Send_to_Business_Affairs_for_Approval;
          Endif;

          // Alternate Series
          If Scn_MnuOption = 'Alternate Series';
             Callp P1VALTSRS ( %Char(Scn_Itmnum)
                             : %Char(Scn_JobNum7)
                             : %Char(Scn_RorefNum)
                             : %Char(Scn_Divcat)
                             : Scn_Series
                             : Scn_Mode);
             // Check for Alternate Series and Display
             Chain (Scn_Itmnum : Scn_Jobnum7) PCPASRS;
             If %Found(PCPASRS);
                Scn_ShwAltSrs = *On;
             Else;
                Scn_ShwAltSrs = *Off;
             Endif;

             WrkUpdate = 'Y';
          Endif;

          // Mark Business Affairs Received
          If Scn_MnuOption = 'B/A Received';
             Exsr Sbr_Mark_Business_Affairs_Received;
          Endif;

          // Tier Price Maint
          If Scn_MnuOption = 'Tier Maintenance';
             PrmItmNumA = %Editc( Scn_Itmnum : 'X' );
             PrmCmdKey  = *Blanks;
             Callp IVVUPDTPRC ( PrmItmNumA : PrmCmdKey );
          Endif;

          // Not in Inquiry Mode
          // Check for erros then update files.
          If *In99 = *Off;
             // EDITS
     C     Reedit        Tag
             Exsr Sbr_Update_Screen_Values;
             Exsr Sbr_Check_For_Errors;

             // Errors found
             If WrkErrFound = *On;
                Iter;
             Endif;

             // Update Files
             If WrkUpdate = 'Y';

                // Update VOICNG field in IVPITEMS
                WrkSavVoicng  = Scn_VOICNG;
                Chain (Scn_Itmnum) IVPITEMS;
                If %Found(IVPITEMS) and Scn_VOICNG <> WrkSavVoicng;
                   Scn_VOICNG = WrkSavVoicng;
                   Update IVPITEM$;
                Else;
                   Unlock IVPITEMS;
                Endif;

                In *Lock PCDINQRY;
                Pcd_Jobnum7 = Scn_Jobnum7;
                Pcd_Itmnum = Scn_Itmnum;
                Out PCDINQRY;

                CallP PCRISBN ();
                CallP PCRAUTINST ();

                PrmPubcod = Mn8_Pubcode;
                Callp P1RBHISMN(%Char(Scn_Itmnum) : PrmPubcod);

                //************************************
                // Add Mode
                //************************************
                If Scn_Mode = 'ADD';

                   // Inventory should be updated if this is a new item
                   // or the QOH = 0
                   If WrkInvUpd = 'Y';
                      Exsr Sbr_Update_IVPITEMS;
                   Endif;

                   Exsr Sbr_Update_PCPMAIN;
                   If Cod_Splits = 'Y';
                      Exsr Sbr_Write_Advertising_Expense_Splits;
                   Endif;

                   If Scn_@Upc = 'Y';
                      Itm_Upc#   = 0;
                      Itm_Check# = 0;
                      Callp UPC#2 (Itm_Itmnum : Itm_Upc# : Itm_Check#);
                   Endif;

                   Exsr Sbr_Update_RERUN8;
                   Exsr Sbr_Update_JOBFLE7;
                   Exsr Sbr_Update_Score_Information;
                Else;
                   //*********************************************
                   // Update Mode
                   //*********************************************

                   // Inventory should be updated if this is a new item
                   // or the QOH = 0
                   If WrkInvUpd = 'Y';
                      Exsr Sbr_Update_IVPITEMS;
                   Endif;

                   Exsr Sbr_Update_PCPMAIN;
                   If Cod_Splits = 'Y';
                      Exsr Sbr_Write_Advertising_Expense_Splits;
                   Endif;

                   If Scn_@Upc = 'Y';
                      Unlock(E) Ivpitems;
                      Itm_Upc#   = 0;
                      Itm_Check# = 0;
                      Callp UPC#2 (Itm_Itmnum : Itm_Upc# : Itm_Check#);
                   Endif;

                   // KIT
                   Chain (Scn_Jobnum7) PCLKITFL;
                   If %Found(PCLKITFL);
                      Lkf_Compds = Mn8_Sdesc;
                      Update PCLKITFL$ %Fields(Lkf_Compds);
                   Endif;

                   WrkSvRun = *Blanks;
                   Exsr Sbr_Update_RERUN8;
                   Exsr Sbr_Update_JOBFLE7;

                   // If @Scprc changed,
                   // update price in IVPITEMS for that item
                   Chain(n) (Scn_Jobnum7) W#JOBSCR;
                   If %Found(W#JOBSCR);
                      Chain (Scr_Scrnum) IVLITM;
                      If %Found(IVLITM);
                         If Mn8_@ScPrc72 <> Scn_@ScPrc72;
                            // Log updates to IVPMAINT
                            // and update IVPITEMS
                            Mnt_Itmnum = Isr_Itmnum;
                            Mnt_After  = %Trim(%Editc(Mn8_@ScPrc72:'4'));
                            Mnt_Before = %Trim(%Editc(Scn_@ScPrc72:'4'));
                            Mnt_Fldnam = 'PRICE';
                            Write IVPMAIN$;

                            Isr_Price72  = Mn8_@ScPrc72;
                            Isr_Price112 = Mn8_@ScPrc72;
                            Update IVLITM$ %Fields(Isr_Price72 : Isr_Price112);
                         Endif;
                      Endif;
                   Endif;

                   Exsr Sbr_Update_Score_Information;
                Endif;

                If Pcd_ForcePrelm <> ' ' and *IN97 = *Off;
                   In *Lock PCDINQRY;
                   Pcd_ForcePrelm = ' ';
                   Out PCDINQRY;
                Endif;

                If Scn_InqMode = *Off;
                   Scn_DisScore = *Off;
                   If Scn_@Scslt = 'Y';
                      Scn_DisScore = *On;
                   Endif;
                Endif;

                In *Lock PCDINQRY;
                Pcd_Jobnum7 = Scn_Jobnum7;
                Pcd_Itmnum  = Scn_Itmnum;
                Out PCDINQRY;

                // If Approved by Business Affairs then return to
                // Driver
                If  Scn_Busaff = 'Y'
                and Scn_Itmnum = 0;
                   In *Lock PCDINQRY;
                   Pcd_ExpCd     = 'APV';
                   Pcd_PrevExpCd = '   ';
                   Pcd_CmdKey    = '  ';
                   Out PCDINQRY;
                   Leave;
                Endif;

                Scn_Message = 'Screen Fields Updated Click "NEXT" to continue';
                Scn_FocLdesc = *On;
                WrkOKToContinu = *On;
             Endif;

          Endif;

          // EXP CODE (NORMAL)
          IF WrkExpCode <> 'GEN';
             In *Lock PCDINQRY;
             Pcd_ExpCd     = WrkExpCode;
             Pcd_PrevExpCd = 'GEN';
             Pcd_CmdKey    = ' ';
             Out PCDINQRY;
             Leave;
          Endif;
       Enddo;

       // Sent to BA
       If Scn_@Send <> ' ' and Pcd_NewAdd <> 'A';
          WrkCldes   = Scn_Ldesc;
          WrkCpric72 = Scn_Price72;
          // Price/Title change
          If WrkCldes <> WrkPldesc OR WrkCpric72 <> WrkPpric72;
             Dow 1 = 1;
                Exfmt WDWPRCTTL;

                If Scn_BtnAuth = *On;
                   Callp SCVMNT(SdsProgram);
                   Iter;
                Endif;

                If Scn_BtnCancel = *On;
                   Leave;
                Endif;

                If Scn_BtnSubmit = *On;
                   Callp P1REMLTPC ( %Editc(Scn_JobNum7:'Z')
                                   : %Editc(Scn_Itmnum:'Z')
                                   : WrkPldesc
                                   : WrkCldes
                                   : %Editc(WrkCpric72:'1')
                                   : %Editc(WrkPpric72:'1'));
                   Leave;
                Endif;
             Enddo;
          Endif;
       Endif;
       *InLr = *On;
       //******************
       //* End Main Line **
       //*********************************************************************

       // /***************************************************************\  *
       //<*************** SUBROUTINES *************************************> *
       // \***************************************************************/  *

       //*********************************************************************
       //* Update Score Information *
       //****************************
       Begsr Sbr_Update_JOBFLE7;

          If Scn_Mode = 'ADD';
             Chain (Scn_Jobnum7) JOBFLE7;
             If Scn_Itmnum <> 0;
                Jf7_Fininv = %Editc(Scn_Itmnum:'X');
             Else;
                Jf7_Fininv = '00000000';
             Endif;

             Jf7_Jobdes = %Trim(Scn_Series) + ' ' + Scn_Desc22;
             If WrkNojob = *On or Not %Found(JOBFLE7);
                Jf7_JOBNUM7    = Scn_Jobnum7;
                Jf7_TRNQTY     = *Zeros;
                Jf7_INFORM     = *Blanks;
                Jf7_STARTMM    = %Subdt(%Date():*M);
                Jf7_STARTDD    = %Subdt(%Date():*D);
                Jf7_STARTYY    = %Subdt(%Date():*Y);
                Jf7_COMPLETEMM = *Zeros;
                Jf7_COMPLETEDD = *Zeros;
                Jf7_COMPLETEYY = *Zeros;
                Jf7_RUNQTY     = Scn_RUNQTY;
                Jf7_RUNID      = WrkSvrun;
                Jf7_FILL01     = *Zeros;
                Jf7_CLOSEMM    = *Zeros;
                Jf7_CLOSEDD    = *Zeros;
                Jf7_CLOSEYY    = *Zeros;
                Jf7_FINQTY     = *Zeros;
                Jf7_UFEO       = ' ';
                Jf7_CLOSE      = ' ';
                Jf7_TASK1120   = *Zeros;
                Jf7_TASK1130   = *Zeros;
                Jf7_ITMNUMNEW  = Scn_Itmnum;
                Write WW$JOBAC;

                // Add to RRR screen
                If Jf7_Itmnumnew <> 0;
                   Chain Jf7_ItmNumNew IVPORRITM;
                   Select;
                      When %Found(IVPORRITM)
                       and Orr_RerunSts <> 'O'
                       and Orr_RerunSts <> 'J';
                         Orr_RerunSts = 'J';
                         Orr_Hold     = *Blanks;
                         Orr_Jobnum7  = Scn_Jobnum7;
                         Orr_Jobdate  = %Date();
                         Orr_Jobuser  = SdsUser;
                         Update IV$ORRITM %Fields( Orr_RerunSts
                                                 : Orr_Hold
                                                 : Orr_Jobnum7
                                                 : Orr_Jobdate
                                                 : Orr_Jobuser );

                      Other;
                         Orr_Itmnum   = Jf7_ItmNumNew;
                         Orr_MinQtyDt = %Date();
                         Orr_Note1    = 'PCR created job '
                                      + '(not Online Rerun)';
                         Orr_RerunSts = 'J';
                         Orr_Hold     = *Blanks;
                         Orr_Jobnum7  = Scn_Jobnum7;
                         Orr_Jobdate  = %Date();
                         Orr_Jobuser  = SdsUser;
                         Write IV$ORRITM;
                   Endsl;
                   Orm_Itmnum = Jf7_ItmNumNew;
                   Orm_Action ='Job Created';
                   Orm_Desc   = 'Job# '
                              + %Trim(%Editc(Scn_Jobnum7:'X'));
                   Orm_MaintTs = %Timestamp();
                   Orm_MaintWho = SdsUser;
                   Write IV$ORRMNT;
                Endif;

                // Write record to revision file
                If Jf7_Runid = 'RA';
                   Rev_Itmnum  = Jf7_Itmnumnew;
                   Rev_Jobnum7 = Scn_Jobnum7;
                   Rev_Pshelf = 'N';
                   Write PC$PREVITM;
                Endif;
             Else;
                Jf7_RunQty    = Scn_RunQty;
                Jf7_ItmnumNew = Scn_Itmnum;
                Update WW$JOBAC %Fields( Jf7_Fininv
                                       : Jf7_Jobdes
                                       : Jf7_RunQty
                                       : Jf7_Itmnumnew );
             Endif;
          Else;
             Chain (Scn_Jobnum7) JOBFLE7;
             Jf7_Runqty    = Scn_Runqty;
             Jf7_Jobdes    = Itm_Sdesc;
             Jf7_Fininv    = %Editc(Scn_Itmnum : 'X');
             Jf7_ItmnumNew = Scn_Itmnum;
             If %Found(JOBFLE7);
                Update WW$JOBAC %Fields( Jf7_Fininv
                                       : Jf7_Jobdes
                                       : Jf7_Runqty
                                       : Jf7_Itmnumnew );
             Endif;
          Endif;

       Endsr;

       //*********************************************************************
       //* Update Score Information *
       //****************************
       Begsr Sbr_Update_RERUN8;

          Chain (Scn_Itmnum : Scn_Jobnum7) RERUN8;
          If %Found(RERUN8);
             Rr8_Runqty     = Scn_RUNQTY;
             Rr8_FinishMM   = %Subdt(Mn8_EstCmpDt:*M);
             Rr8_FinishDD   = %Subdt(Mn8_EstCmpDt:*D);
             Rr8_FinishYYYY = %Subdt(Mn8_EstCmpDt:*Y);
             Update B$RERUN %Fields( Rr8_Runqty
                                   : Rr8_FinishMM
                                   : Rr8_FinishDD
                                   : Rr8_FinishYYYY );
          Else;
             If WrkSvrun = 'RA';
                Rr8_ITEM#      = Scn_Itmnum;
                Rr8_RUNQTY     = Scn_RUNQTY;
                Rr8_JOBNUM7    = Scn_Jobnum7;
                Rr8_DELETE     = *Blanks;
                Rr8_FinishMM   = %Subdt(Mn8_EstCmpDt:*M);
                Rr8_FinishDD   = %Subdt(Mn8_EstCmpDt:*D);
                Rr8_FinishYYYY = %Subdt(Mn8_EstCmpDt:*Y);
                Rr8_COMENT     = *Blanks;
                Rr8_COMPDT     = (%Subdt(%Date():*M) * 100)+%Subdt(%Date():*D);
                Rr8_PHOTDT     = *Zeros;
                Rr8_PRESDT     = *Zeros;
                Rr8_BINDDT     = *Zeros;
                Rr8_XTRCMT     = *Blanks;
                Rr8_BOCHKD     = *Blanks;
                Rr8_PREPDT     = *Zeros;
                Rr8_SCANDT     = *Zeros;
                Rr8_PRNTDT     = *Zeros;
                Rr8_DGBINDDT   = *Zeros;
                Write B$RERUN;
                Callp PCRRERN (Rr8_ITEM#);
             Endif;
          Endif;

       Endsr;

       //*********************************************************************
       //* Update Score Information *
       //****************************
       Begsr Sbr_Update_Score_Information;

          If Scn_@Scqty <> 0 or Scn_@Scslt = 'Y';
             Chain (Scn_Jobnum7) W#JOBSCR;
             If %Found(W#JOBSCR);
                Scr_Scrqty = Scn_@Scqty;
                Update W$JOBSCR %Fields(Scr_Scrqty);
             Else;
                Scr_Scrnum  = 0;
                Scr_JobNum7 = Scn_Jobnum7;
                Scr_Scrqty  = Scn_@Scqty;
                Write W$JOBSCR;
             Endif;

             Chain (Scr_Scrnum) IVLITM;
             If %Found(IVLITM);
                Isr_Divcat     = Itm_DivCat;
                Isr_Series     = Itm_Series;
                Isr_Sdesc      = %Trim(%Subst(Itm_Sdesc:1:26)) + ' SC';
                Isr_Ldesc      = %Trim(%Subst(Itm_Ldesc:1:76)) + ' FULL SCORE';
                Isr_Arrngr     = Itm_Arrngr;
                Isr_Artist     = Itm_Artist;
                Isr_Author     = Itm_Author;
                Isr_Catlog     = Itm_Catlog;
                Isr_PblshrNum  = Itm_PblshrNum;
                Isr_RoRefNum   = Itm_RoRefNum;
                Isr_Niyn       = 'N';
                Isr_Nicat1     = Itm_NiCat1;
                Isr_Nicat2     = Itm_NiCat2;
                Isr_Nicat3     = Itm_NiCat3;
                Isr_CtryOrigin = Itm_CtryOrigin;

                Update IVLITM$ %Fields( Isr_Divcat
                                      : Isr_Series
                                      : Isr_Sdesc
                                      : Isr_Ldesc
                                      : Isr_Arrngr
                                      : Isr_Artist
                                      : Isr_Author
                                      : Isr_Catlog
                                      : Isr_PblshrNum
                                      : Isr_RoRefNum
                                      : Isr_Niyn
                                      : Isr_Nicat1
                                      : Isr_Nicat2
                                      : Isr_Nicat3
                                      : Isr_CtryOrigin );
             Endif;
          Endif;

       Endsr;


       //*********************************************************************
       //* Clears all screens **
       //***********************
       Begsr SbrClearAll;

          Clear Cat_Desc16;
          Scn_Cntrtp = 'L';
          Scn_Sellbl = 'Y';
          Scn_@Send  = 'N';
          Scn_Busaff = 'N';
          In *Lock PCDINQRY;
          Pcd_NewAdd = 'A';
          Out PCDINQRY;

       Endsr;

       //*********************************************************************
       //* Edits : Default Fields **
       //***************************
       Begsr Sbr_Update_Screen_Values;

          // Purchased Product
          If Scn_@Purch <> 'Y' and Scn_@Purch <> 'N';
             Scn_@Purch = 'N';
          Endif;

          // Rush
          If Scn_@Rush <> 'Y' and Scn_@Rush <> 'N';
             Scn_@Rush = 'N';
          Endif;

          // Outside Approval
          If Scn_@Outs <> 'Y' and Scn_@Outs <> 'N';
             Scn_@Outs = 'N';
          Endif;

          // Split
          If Scn_@Splt <> 'Y' and Scn_@Splt <> 'N';
             Scn_@Splt = 'N';
          Endif;

          // Sellable (Y/N/M/C/S)
          If  Scn_Sellbl <> 'Y'
          and Scn_Sellbl <> 'N'
          and Scn_Sellbl <> 'M'
          and Scn_Sellbl <> 'C'
          and Scn_Sellbl <> 'S';
             Scn_Sellbl = 'Y';
          Endif;

          // Kit
          If Scn_@Kit <> 'Y' AND Scn_@Kit <> 'N';
             Scn_@Kit = 'N';
          Endif;

          // Contract Type Load Default if Blank
          If Scn_Cntrtp = ' ';
             Scn_Cntrtp = WrkDfltCntrtp;
          Endif;

          // UPC
          If Scn_@Upc <> 'Y' and Scn_@Upc <> 'N';
             Scn_@Upc = 'Y';
          Endif;

          // ISBN
          If Scn_@Isbn <> 'Y' and Scn_@Isbn <> 'N';
             // PCR division#
             If Pcd_DivCat = 1130
             or Pcd_DivCat = 1135
             or Pcd_DivCat >= 4100 and Pcd_DivCat < 4599
             or Pcd_DivCat = 5912
             or Pcd_DivCat = 7999;
                Scn_@Isbn = 'N';
             Else;
                Scn_@Isbn = 'Y';
             Endif;
          Endif;

          If Scn_Series = 'EEAR1+'
          OR Scn_Series = 'EEMST2'
          OR Scn_Series = 'EEPRF1'
          OR Scn_Series = 'EEXPL1'
          OR Scn_Series = 'EEXP1+';
             Scn_@Isbn = 'N';
          Endif;

          // EAN
          If Scn_@Ean# <> 'Y' AND Scn_@Ean# <> 'N';
             Scn_@Ean# = 'N';
          Endif;

          // New Issue
          If Scn_@Ni <> 'Y' AND Scn_@Ni <> 'N';
             Scn_@Ni = 'Y';
          Endif;
          If Scn_@Ni = 'N';
             Scn_NiCat1 = 0;
             Scn_NiCat2 = 0;
             Scn_NiCat3 = 0;
          Endif;

          // Score
          If Scn_@Scslt <> 'Y' AND Scn_@Scslt <> 'N';
             Scn_@Scslt = 'N';
          Endif;

          // Notify user of duplicate PUBCODE
          If Scn_Pubcode <> *Blanks and WrkOvrPubCode = ' ';
             // Check PUBCODE
             Setll (Scn_PubCode) IVLITM05;
             Dow 1 = 1;
                Reade (Scn_PubCode) IVLITM05;
                If %Eof(IVLITM05);
                   Leave;
                Endif;

                If I05_Itmnum = Scn_Itmnum;
                   Leave;
                Endif;

                If WrkPubDup = 'N';
                   WrkPubDup = 'Y';
                   Scn_ErrPubCode = *On;
                   Scn_Message   = 'Fix Error(s) to continue';
                   WrkErrFound = *On;
                   Leavesr;
                Endif;
             Enddo;
          Endif;
          WrkPubDup = 'N';

          // Score Fields Blank if no score
          If Scn_@Scslt = 'N';
             Scn_@ScQty   = 0;
             Scn_@ScPrc72 = 0;
          Endif;

       Endsr;

       //*********************************************************************
       //* Load Extended Data - Inquiry Mode *
       //*************************************
       Begsr Sbr_Load_Extended_Data;

          // Series Description
          Scn_SrsDsc = *Blanks;
          Chain (Scn_Divcat : Scn_Series) PCPSRSD;
          If %Found(PCPSRSD);
             Chain (Scn_Series) IVPSRSD;
             Scn_SrsDsc = Srs_SrsDsc;
          Endif;

          // Contract Type Description
          Scn_CntrtpDsc = *Blanks;
          WrkTyp = Scn_Cntrtp;
          Chain ('CNTRTP    ':WrkTyp) PCPWTXT;
          If %Found(PCPWTXT);
             Scn_CntrtpDsc = Txt_Wfld2;
          Endif;

          // Country of Origin
          Scn_CtryNameMC = *Blanks;
          Chain (Scn_CtryOrigin) MFLCOUNTR2;
          If %Found(MFLCOUNTR2);
             Scn_CtryNameMC = Cty_CtryNameMC;
          Endif;

          // Medium
          Scn_MedDsc = *Blanks;
          Chain (Scn_Medium) MFMEDIUM;
          If %Found(MFMEDIUM);
             Scn_MedDsc = Med_MedDsc;
          Endif;

          // Voicing
          Scn_VoiDsc = *Blanks;
          Chain (Scn_Voicng) MFVOICNG;
          If %Found(MFVOICNG);
             Scn_VoiDsc = Voc_VoiDsc;
          Endif;

          // Roref
          Scn_RorefDsc = *Blanks;
          If Scn_RoRefNum <> 0;
             Chain (Scn_Rorefnum) IVLOWNPU1;
             Scn_RorefDsc = Pu1_Owner@;
          Endif;

          // Artist
          Scn_ArtistDsc = *Blanks;
          Chain (Scn_Artist) IVPARTX;
          If %Found(IVPARTX);
             Scn_ArtistDsc = Art_QArt;
          Endif;

          // Publisher Code
          Scn_PublcodeDs = *Blanks;
          If Scn_Publcode <> 0;
             Chain (Scn_Publcode) MFPPBLSCHT;
             If %Found(MFPPBLSCHT);
                Scn_PublCodeDs = Pbl_PblDsc;
             Endif;
          Endif;

          // Catalog Code
          Scn_CatlogDsc = *Blanks;
          If Scn_Catlog <> *Blanks;
             Chain (Scn_Catlog) MFCATLOG;
             If %Found(MFCATLOG);
                Scn_CatlogDsc = Clg_CatTxt;
             Endif;
          Endif;

          // Catalog 1
          Scn_@Catl1Dsc = *Blanks;
          If Scn_@Catl1 <> *Blanks;
             Chain (Scn_@Catl1) PCPCATLG;
             If %Found(PCPCATLG);
                Scn_@Catl1Dsc = Pct_PcDesc;
             Endif;
          Endif;

          // Catalog 2
          Scn_@Catl2Dsc = *Blanks;
          If Scn_@Catl2 <> *Blanks;
             Chain (Scn_@Catl2) PCPCATLG;
             If %Found(PCPCATLG);
                Scn_@Catl2Dsc = Pct_PcDesc;
             Endif;
          Endif;

          // New Issue
          Scn_NiCatD1 = *Blanks;
          If Scn_Nicat1 <> 0;
             Chain (Scn_Nicat1) NIPCATS;
             If %Found(NIPCATS);
                Scn_NiCatD1 = Nic_NICatD;
             Endif;
          Endif;

          Scn_NiCatD2 = *Blanks;
          If Scn_Nicat2 <> 0;
             Chain (Scn_Nicat2) NIPCATS;
             If %Found(NIPCATS);
                Scn_NiCatD2 = Nic_NICatD;
             Endif;
          Endif;

          Scn_NiCatD3 = *Blanks;
          If Scn_Nicat3 <> 0;
             Chain (Scn_Nicat3) NIPCATS;
             If %Found(NIPCATS);
                Scn_NiCatD3 = Nic_NICatD;
             Endif;
          Endif;

       Endsr;

       //*********************************************************************
       //* Error Checking *
       //******************
       Begsr Sbr_Check_For_Errors;

          WrkAllowCln = 'N';
          // Title Field
          If Scn_Ldesc = *Blanks;
             Scn_FocLdesc = *On;
             Scn_ErrLdesc = *On;
             Scn_Message  = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          // Short Desc
          If Scn_Desc22 = *Blanks;
             Scn_ErrDesc22 = *On;
             Scn_Message  = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          // Retrail Price
          If  Scn_Price72 = 0
          and Scn_Divcat  <> 8999
          and Scn_Sellbl  = 'Y'
          and *IN97 = *Off;
             Scn_ErrPrice72 = *On;
             Scn_ErmPrice72 = 'Retail Price must be filled in';
             Scn_Message    = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          If Scn_Price72 < 0;
             Scn_ErrPrice72 = *On;
             Scn_ErmPrice72 = 'Price can not be less than zero.';
             Scn_Message    = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          // Run Quantity
          If Scn_Runqty = 0
          and *IN97 = *Off;
             Scn_ErrRunQty = *On;
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          // Check Series for Error
          If (*IN97 = *On and Scn_Series = *Blanks);
          Else;
             Chain (Scn_Divcat : Scn_Series) PCPSRSD;
             If Not %Found(PCPSRSD);
                Scn_SrsDsc = *Blanks;
                Scn_ErrSeries = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Chain (Scn_Series) IVPSRSD;
                Scn_SrsDsc = Srs_SrsDsc;
             Endif;
          Endif;

          // If CNTRTP not in PCPWTXT, display errmsg.
          WrkTyp = Scn_Cntrtp;
          Chain ('CNTRTP    ':WrkTyp) PCPWTXT;
          If Not %Found(PCPWTXT);
             Scn_CntrtpDsc = *Blanks;
             Scn_ErrCntrtp = *On;
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Else;
             Scn_CntrtpDsc = Txt_Wfld2;
          Endif;

          // Country of Origin
          Scn_CtryNameMC = *Blanks;
          If Scn_CtryOrigin <> *Blanks;
             Chain (Scn_CtryOrigin) MFLCOUNTR2;
             If Not %Found(MFLCOUNTR2) or Cty_ROYCTRY = 'Y';
                Scn_ErrCtryOrg = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_CtryNameMC = Cty_CtryNameMC;
             Endif;
          Else;
             Scn_ErrCtryOrg = *On;
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
             Leavesr;
          Endif;

          // Medium
          If  Scn_Medium = *Blanks
          and Scn_Series <> 'UNF'
          and Scn_Divcat <> 7999;
             Scn_ErrMedium = *On;
             Scn_ErmMedium = 'Medium is required';
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          EndIf;

          If Scn_Medium <> *Blanks;
             If PrmCmdKey <> *Blanks;
                Scn_ErrMedium = *On;
                Scn_ErmMedium = 'Medium is invalid';
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             EndIf;
          Endif;

          If Scn_Medium = 'DLD' and Scn_Sellbl <> 'S';
             Scn_ErrMedium = *On;
             Scn_ErmMedium = 'Medium = DLD, Sellable must be S.';
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          Chain (Scn_Medium) MFMEDIUM;
          If %Found(MFMEDIUM);
             Scn_MedDsc = Med_MedDsc;
          Else;
             Scn_MedDsc = *Blanks;
          Endif;

          // Voicing
          If Scn_Voicng <> *Blanks;
             Chain (Scn_Voicng) MFVOICNG;
             If Not %Found(MFVOICNG);
                Scn_ErrVoicng = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_VoiDsc = Voc_VoiDsc;
             Endif;
          Endif;

          // Max Discount
          If Scn_Maxdis >= 1.000 AND Scn_Maxdis <> 9.999;
             Scn_ErrMaxDis = *On;
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          If (Scn_Divcat = 1200 or Scn_Divcat = 1230)
          and Scn_Maxdis <> .520 and Scn_Maxdis <> 9.999;
             Scn_Maxdis = .520;
          Endif;

          // Must Enter a Roref# if Cntrtp = J,C,A,R
          // Must Enter a Roref# if B&H
          If Scn_RorefNum = 0;
             If Scn_Cntrtp = 'J'
             or Scn_Cntrtp = 'A'
             or Scn_Cntrtp = 'C'
             or Scn_Cntrtp = 'R'
             or Scn_Divcat = 5912;
                Scn_ErrRoRef = *On;
                Scn_ErmRoRef = 'Roref# is required';
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;
          Endif;

          If Scn_RorefNum <> 0;
             If Scn_Itmnum <  55000000 and Scn_Rorefnum = 55
             or Scn_Itmnum >  55999999 and Scn_Rorefnum = 55
             or Scn_Itmnum >= 55000000 and Scn_Itmnum  <= 55999999
                                       and Scn_Rorefnum <> 55;
                Scn_ErrRoRef = *On;
                Scn_ErmRoRef = 'Only Ashley Corp items (55xxxxxx) can '
                             + 'have 55 for Pblshr/Roref# & they must';
                Scn_Message  = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;

                If Scn_Itmnum < 53314000  and Scn_Rorefnum = 53
                or Scn_Itmnum > 53314999  and Scn_Rorefnum = 53
                or Scn_Itmnum >= 53314000 and Scn_Itmnum <= 53314999
                and Scn_Rorefnum <> 53;
                   Scn_ErrRoRef = *On;
                   Scn_ErmRoRef = 'Only Applause items (53xxxxxx) can '
                                + 'have 53 for Pblshr/Roref# & they must';
                   Scn_Message  = 'Fix Error(s) to continue';
                   WrkErrFound = *On;
                Else;

                   Chain (Scn_Rorefnum) IVLOWNPU1;
                   If %Found(IVLOWNPU1);
                      If Scn_Cntrtp = Pu1_Cntty1
                      or Scn_Cntrtp = Pu1_Cntty2
                      or Scn_Cntrtp = Pu1_Cntty3
                      or Scn_Cntrtp = Pu1_Cntty4
                      or Scn_Cntrtp = Pu1_Cntty5;
                         Scn_PblshrNum = Pu1_PblshrNum;
                      Else;
                         Scn_ErrRoRef = *On;
                         Scn_ErmRoRef = 'Contract type not valid '
                                      + 'for this Roref#';
                         Scn_Message  = 'Fix Error(s) to continue';
                         WrkErrFound = *On;
                      Endif;
                   Else;
                      Scn_ErrRoRef = *On;
                      Scn_ErmRoRef = 'Roref# is invalid';
                      Scn_Message  = 'Fix Error(s) to continue';
                      WrkErrFound = *On;
                   Endif;
                Endif;
             Endif;
          Endif;

          Scn_RorefDsc = *Blanks;
          If Scn_RoRefNum <> 0;
             Chain (Scn_Rorefnum) IVLOWNPU1;
             Scn_RorefDsc = Pu1_Owner@;
          Endif;

          // Must Enter a PBLSHR if Cntrtp = C,A,R
          // Must Enter a PBLSHR if B&H
          If Scn_PblshrNum = 0;
             If Scn_Cntrtp = 'A'
             or Scn_Cntrtp = 'C'
             or Scn_Cntrtp = 'R'
             or Scn_Divcat = 5912;
                Scn_ErrPblshrN = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;
          Endif;

          // Artist
          Scn_ArtistDsc = *Blanks;
          If Scn_Artist <> *Blanks;
             Chain (Scn_Artist) IVPARTX;
             If Not %Found(IVPARTX);
                Scn_ErrArtist = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_ArtistDsc = Art_QArt;
             Endif;
          Endif;

          // Arranger
          If Scn_Arrngr <> *Blanks;
             Chain (Scn_Arrngr) MFARRNGR;
             If Not %Found(MFARRNGR);
                Scn_ErrArrngr = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;
          Endif;

          // Composer/Author
          If Scn_Author <> *Blanks;
             Chain (Scn_Author) MFAUTHOR;
             If Not %Found(MFAUTHOR);
                Scn_ErrAuthor = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;
          Endif;

          // Publisher Code
          Scn_PublcodeDs = *Blanks;
          If Scn_Publcode <> 0;
             Chain (Scn_Publcode) MFPPBLSCHT;
             If Not %Found(MFPPBLSCHT);
                Scn_ErrPublcod = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_PublCodeDs = Pbl_PblDsc;
             Endif;
          Endif;

          // Catalog Code
          Scn_CatlogDsc = *Blanks;
          If Scn_Catlog <> *Blanks;
             Chain (Scn_Catlog) MFCATLOG;
             If Not %Found(MFCATLOG);
                Scn_ErrCatlog = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_CatlogDsc = Clg_CatTxt;
             Endif;
          Endif;

          // Catalog 1
          Scn_@Catl1Dsc = *Blanks;
          If Scn_@Catl1 <> *Blanks;
             Chain (Scn_@Catl1) PCPCATLG;
             If Not %Found(PCPCATLG);
                Scn_Err@Catl1 = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_@Catl1Dsc = Pct_PcDesc;
             Endif;
          Endif;

          // Catalog 2
          Scn_@Catl2Dsc = *Blanks;
          If Scn_@Catl2 <> *Blanks;
             Chain (Scn_@Catl2) PCPCATLG;
             If Not %Found(PCPCATLG);
                Scn_Err@Catl2 = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_@Catl2Dsc = Pct_PcDesc;
             Endif;
          Endif;

          // New Issue
          If  Scn_@Ni = 'Y'
          and Scn_Nicat1 = 0
          and Scn_Nicat2 = 0
          and Scn_Nicat3 = 0;
             Scn_ErrNICat1 = *On;
             Scn_Message   = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          If Scn_@Ni = 'N'
             And (Scn_Nicat1 <> 0 Or Scn_Nicat2 <> 0 Or Scn_Nicat3 <> 0);
             Scn_Err@NI  = *On;
             Scn_Message = 'Fix Error(s) to continue';
             WrkErrFound = *On;
          Endif;

          Scn_NiCatD1 = *Blanks;
          If Scn_Nicat1 <> 0;
             Chain (Scn_Nicat1) NIPCATS;
             If Not %Found(NIPCATS);
                Scn_ErrNICat1 = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_NiCatD1 = Nic_NICatD;
             Endif;
          Endif;

          Scn_NiCatD2 = *Blanks;
          If Scn_Nicat2 <> 0;
             Chain (Scn_Nicat2) NIPCATS;
             If Not %Found(NIPCATS);
                Scn_ErrNICat2 = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_NiCatD2 = Nic_NICatD;
             Endif;
          Endif;

          Scn_NiCatD3 = *Blanks;
          If Scn_Nicat3 <> 0;
             Chain (Scn_Nicat3) NIPCATS;
             If Not %Found(NIPCATS);
                Scn_ErrNICat3 = *On;
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Else;
                Scn_NiCatD3 = Nic_NICatD;
             Endif;
          Endif;

          If (Scn_Series = 'CLCADS' or Scn_Series = 'CLCADT');
             WrkAllowCln = 'Y';
          Endif;

          // Advertising edits
          If Cod_Splits = 'Y';
             Exsr Sbr_Move_Cats_Up;

             // Check for Clinic# or Charge to Category
             If Scn_Cat1 = 0 and Scn_Clinic# = 0;
                Scn_ErrClinic# = *On;
                Scn_ErmClinic# = 'Must have Clinic# or Charge to Category';
                Scn_Message    = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;

             // Check for both a Clinic# and Charge to Category
             If Scn_Cat1 <> 0 and Scn_Clinic# <> 0;
                Scn_ErrClinic# = *On;
                Scn_ErmClinic# = 'Cannot have both a Clinic# '
                               + 'and Charge to Category';
                Scn_Message    = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;

             // Check for valid Clinic/Tradeshow number
             If Scn_Clinic# <> 0;
                If Scn_Series <> *Blanks;
                   Chain (Scn_Series) ACPSRSGL;
                   If %Found(ACPSRSGL);
                      If (Sgl_DomGl < 68000100 or Sgl_DomGl > 68000250)
                         And WrkAllowCln <> 'Y';
                         Scn_ErrClinic# = *On;
                         Scn_ErmClinic# = 'This is not a Clinic '
                                        + 'or Trade Show Series';
                         Scn_Message    = 'Fix Error(s) to continue';
                         WrkErrFound = *On;
                         Scn_Clinic# = 0;
                      Endif;
                   Else;
                      Scn_ErrClinic# = *On;
                      Scn_ErmClinic# = 'Invalid Clinic or Trade Show Series';
                      Scn_Message    = 'Fix Error(s) to continue';
                      WrkErrFound = *On;
                      Scn_Clinic# = 0;
                   Endif;
                Endif;

                Select;
                   When Sgl_DomGl = 68000100
                      or Sgl_DomGL = 68000125
                      or Sgl_DomGL = 68000150
                      or Sgl_DomGL = 68000250
                      or Scn_Series = 'CLCADT';
                      Setll (Scn_Clinic#) CTPTSCAT;
                      If Not %Equal(CTPTSCAT);
                         Scn_ErrClinic# = *On;
                         Scn_ErmClinic# = 'Invalid Trade Show#';
                         Scn_Message    = 'Fix Error(s) to continue';
                         WrkErrFound = *On;
                      Endif;

                   When Sgl_DomGl = 68000200
                      or Scn_Series = 'CLCADS';
                      Setll (Scn_Clinic#) CTPDIVCAT;
                      If Not %Equal(CTPDIVCAT);
                         Scn_ErrClinic# = *On;
                         Scn_ErmClinic# = 'Invalid Clinic#';
                         Scn_Message    = 'Fix Error(s) to continue';
                         WrkErrFound = *On;
                      Endif;
                Endsl;
             Endif;


             Scn_ErmAdvBill = *Blanks;
             Scn_ErrAdvBill = *Off;

             Scn_ErmCat1 = *Blanks;
             Scn_ErrCat1 = *Off;
             Scn_ErmCat2 = *Blanks;
             Scn_ErrCat2 = *Off;
             Scn_ErmCat3 = *Blanks;
             Scn_ErrCat3 = *Off;
             Scn_ErmCat4 = *Blanks;
             Scn_ErrCat4 = *Off;
             Scn_ErmCat5 = *Blanks;
             Scn_ErrCat5 = *Off;
             Scn_ErmCat6 = *Blanks;
             Scn_ErrCat6 = *Off;
             Scn_ErmCat7 = *Blanks;
             Scn_ErrCat7 = *Off;
             Scn_ErmCat8 = *Blanks;
             Scn_ErrCat8 = *Off;
             Scn_ErmCat9 = *Blanks;
             Scn_ErrCat9 = *Off;
             Scn_ErmCat10= *Blanks;
             Scn_ErrCat10= *Off;

             Scn_ErmSplit1 = *Blanks;
             Scn_ErrSplit1 = *Off;
             Scn_ErmSplit2 = *Blanks;
             Scn_ErrSplit2 = *Off;
             Scn_ErmSplit3 = *Blanks;
             Scn_ErrSplit3 = *Off;
             Scn_ErmSplit4 = *Blanks;
             Scn_ErrSplit4 = *Off;
             Scn_ErmSplit5 = *Blanks;
             Scn_ErrSplit5 = *Off;
             Scn_ErmSplit6 = *Blanks;
             Scn_ErrSplit6 = *Off;
             Scn_ErmSplit7 = *Blanks;
             Scn_ErrSplit7 = *Off;
             Scn_ErmSplit8 = *Blanks;
             Scn_ErrSplit8 = *Off;
             Scn_ErmSplit9 = *Blanks;
             Scn_ErrSplit9 = *Off;
             Scn_ErmSplit10= *Blanks;
             Scn_ErrSplit10= *Off;


             // validate that if category entered, a %split is entered
             For WrkIndex1 = 1 to 10;
                If AryCat(WrkIndex1) <> 0;
                   If ArySplit(WrkIndex1) = 0;
                      If Scn_Cat1 <> 0 and Scn_Split1 = 0;
                         Scn_ErmSplit1 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit1 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat2 <> 0 and Scn_Split2 = 0;
                         Scn_ErmSplit2 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit2 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat3 <> 0 and Scn_Split3 = 0;
                         Scn_ErmSplit3 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit3 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat4 <> 0 and Scn_Split4 = 0;
                         Scn_ErmSplit4 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit4 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat5 <> 0 and Scn_Split5 = 0;
                         Scn_ErmSplit5 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit5 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat6 <> 0 and Scn_Split6 = 0;
                         Scn_ErmSplit6 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit6 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat7 <> 0 and Scn_Split7 = 0;
                         Scn_ErmSplit7 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit7 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat8 <> 0 and Scn_Split8 = 0;
                         Scn_ErmSplit8 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit8 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat9 <> 0 and Scn_Split9 = 0;
                         Scn_ErmSplit9 = 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit9 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If Scn_Cat10<> 0 and Scn_Split10= 0;
                         Scn_ErmSplit10= 'Please enter percent for category';
                         Scn_Message   = 'Fix Error(s) to continue';
                         Scn_ErrSplit10= *On;
                         WrkErrFound = *On;
                      Endif;
                   Endif;
                Endif;
             Endfor;

             // validate that if split % entered, category is valid
             WrkSplitCnt = 0;
             For WrkIndex1 = 1 to 10;

                // clear description,
                //it will get refilled in each time in case of ch
                AryCatD(WrkIndex1) = *Blanks;
                If ArySplit(WrkIndex1) <> 0;
                   WrkSplitCnt += 1;
                   WrkCatLen7 = AryCat(WrkIndex1);
                   Setll (WrkCatLen7) IVPCAT;
                   Setll (WrkCatLen7) DIV01L;
                   If Not %Equal(IVPCAT) and Not %Equal(DIV01L);
                      If WrkIndex1 = 1;
                         Scn_ErmCat1 = 'Category not valid';
                         Scn_ErrCat1 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 2;
                         Scn_ErmCat2 = 'Category not valid';
                         Scn_ErrCat2 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 3;
                         Scn_ErmCat3 = 'Category not valid';
                         Scn_ErrCat3 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 4;
                         Scn_ErmCat4 = 'Category not valid';
                         Scn_ErrCat4 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 5;
                         Scn_ErmCat5 = 'Category not valid';
                         Scn_ErrCat5 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 6;
                         Scn_ErmCat6 = 'Category not valid';
                         Scn_ErrCat6 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 7;
                         Scn_ErmCat7 = 'Category not valid';
                         Scn_ErrCat7 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 8;
                         Scn_ErmCat8 = 'Category not valid';
                         Scn_ErrCat8 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 9;
                         Scn_ErmCat9 = 'Category not valid';
                         Scn_ErrCat9 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 10;
                         Scn_ErmCat10= 'Category not valid';
                         Scn_ErrCat1 = *On;
                         WrkErrFound = *On;
                      Endif;
                   Endif;

                   // must be valid, so fill in category description
                   // first look in IVPCAT,
                   // if not found, must be in DIV01L file
                   If AryCat(WrkIndex1) <> 0;
                      Chain (WrkCatLen7) IVPCAT;
                      If %Found(IVPCAT);
                         AryCatD(WrkIndex1) = Cat_Desc16;
                      Else;
                         Chain (WrkCatLen7) DIV01L;
                         If %Found(DIV01L);
                            AryCatD(WrkIndex1) = Div_Div;
                         Endif;
                      Endif;
                   Endif;
                Endif;
             Endfor;

             // if no splits, set Split for Cat1 to 100%
             If WrkSplitCnt <= 1;
                If WrkSplitCnt = 0;
                   Scn_Split1 = 0;
                   Scn_Message= 'Adjust the Split of the Category to continue.';
                //an error to fix could have been turned on for the split being 0
                //with Ermsplit1 = *Blanks the user wouldnt know - set this message
                Else;
                   Scn_Split1 = 100;
                Endif;
                Scn_ErmSplit1 = *Blanks;
                Scn_ErrSplit1 = *Off;
             Endif;

             // validate that if splits entered, they add up to 100%
             Eval(H) WrkSumSplits = %Xfoot(ArySplit);
             If WrkSplitCnt <> 0 and WrkSUmSplits <> 100;
                Scn_ErmAdvBill = 'Percentages must equal 100%';
                Scn_ErrAdvBill = *On;
                WrkErrFound = *On;
             Endif;

             // validate that same category not entered more than once
             For WrkIndex1 = 1 to 9;
                WrkStartLoop = WrkIndex1 + 1;
                For WrkIndex2 = WrkStartLoop to 10;
                   If AryCat(WrkIndex1) = 0;
                      Leave;
                   Endif;
                   If AryCat(WrkIndex1) = AryCat(WrkIndex2);
                      If WrkIndex1 = 1;
                         Scn_ErmCat1 = 'Category may only be entered once';
                         Scn_ErrCat1 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 2;
                         Scn_ErmCat2 = 'Category may only be entered once';
                         Scn_ErrCat2 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 3;
                         Scn_ErmCat3 = 'Category may only be entered once';
                         Scn_ErrCat3 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 4;
                         Scn_ErmCat4 = 'Category may only be entered once';
                         Scn_ErrCat4 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 5;
                         Scn_ErmCat5 = 'Category may only be entered once';
                         Scn_ErrCat5 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 6;
                         Scn_ErmCat6 = 'Category may only be entered once';
                         Scn_ErrCat6 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 7;
                         Scn_ErmCat7 = 'Category may only be entered once';
                         Scn_ErrCat7 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 8;
                         Scn_ErmCat8 = 'Category may only be entered once';
                         Scn_ErrCat8 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 9;
                         Scn_ErmCat9 = 'Category may only be entered once';
                         Scn_ErrCat9 = *On;
                         WrkErrFound = *On;
                      Endif;

                      If WrkIndex1 = 10;
                         Scn_ErmCat10= 'Category may only be entered once';
                         Scn_ErrCat1 = *On;
                         WrkErrFound = *On;
                      Endif;
                   Endif;
                Endfor;
             Endfor;
             // End

             If  Scn_Dcf <> 'D'
             and Scn_Dcf <> 'C'
             and Scn_Dcf <> 'F'
             and Scn_ShwDFC = *On;
                Scn_ErrDcf  = *On;
                Scn_Message = 'Fix Error(s) to continue';
                WrkErrFound = *On;
             Endif;

             If Scn_MktCode = *Zero And Scn_ShowMKT = *On;
                Scn_ErrMkt    = *On;
                Scn_ErrMarket = *On; //focus field
                Scn_Message   = 'Fix Error(s) to continue';
                WrkErrFound   = *On;
             EndIf;

             //Get the valid GL numbers for this series/DCF
             WrkGL = *Zero;
             If Scn_MktCode <> *Zero And Scn_ShowMKT = *On;
                Chain (Scn_Series) ACPSRSGL;
                If %Found(ACPSRSGL);
                   Select;
                      When Scn_DCF = 'D';
                         WrkGL = Sgl_DomGL;

                      When Scn_DCF = 'F';
                         WrkGL = Sgl_ForGL;

                      When Scn_DCF = 'C';
                         WrkGL = Sgl_CnsGL;
                   EndSl;
                EndIf;
             EndIf;

             //Use the GL from ACPSRSGL to validate if this mkt code works
             If WrkGL <> *Zero And Scn_ShowMKT = *On
              And %Trim(Scn_Desc16) <> 'ADVERTISING';
                Chain (Scn_MktCode : WrkGL) ACPGLMKTCD;
                If Not %Found(ACPGLMKTCD);
                   Scn_ErrMkt2   = *On;
                   Scn_Message   = 'Fix Error(s) to continue';
                   WrkErrFound   = *On;
                   Scn_ErrMarket = *On; //focus field
                EndIf;
             EndIf;

          Endif;
       // end of code for advertising only edits

       Endsr;

       //***********************************************************************
       //*            *
       //**************
       Begsr Sbr_Move_Cats_Up;

          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;
          Exsr Sbr_Move_Up;

       Endsr;

       //***********************************************************************
       //*            *
       //**************
       Begsr Sbr_Move_Up;

          If Scn_Cat1 = 0;
             Scn_Cat1 = Scn_Cat2;
             Scn_Cat2 = Scn_Cat3;
             Scn_Cat3 = Scn_Cat4;
             Scn_Cat4 = Scn_Cat5;
             Scn_Cat5 = Scn_Cat6;
             Scn_Cat6 = Scn_Cat7;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split1 = Scn_Split2;
             Scn_Split2 = Scn_Split3;
             Scn_Split3 = Scn_Split4;
             Scn_Split4 = Scn_Split5;
             Scn_Split5 = Scn_Split6;
             Scn_Split6 = Scn_Split7;
             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat2 = 0;
             Scn_Cat2 = Scn_Cat3;
             Scn_Cat3 = Scn_Cat4;
             Scn_Cat4 = Scn_Cat5;
             Scn_Cat5 = Scn_Cat6;
             Scn_Cat6 = Scn_Cat7;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split2 = Scn_Split3;
             Scn_Split3 = Scn_Split4;
             Scn_Split4 = Scn_Split5;
             Scn_Split5 = Scn_Split6;
             Scn_Split6 = Scn_Split7;
             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat3 = 0;
             Scn_Cat3 = Scn_Cat4;
             Scn_Cat4 = Scn_Cat5;
             Scn_Cat5 = Scn_Cat6;
             Scn_Cat6 = Scn_Cat7;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split3 = Scn_Split4;
             Scn_Split4 = Scn_Split5;
             Scn_Split5 = Scn_Split6;
             Scn_Split6 = Scn_Split7;
             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat4 = 0;
             Scn_Cat4 = Scn_Cat5;
             Scn_Cat5 = Scn_Cat6;
             Scn_Cat6 = Scn_Cat7;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split4 = Scn_Split5;
             Scn_Split5 = Scn_Split6;
             Scn_Split6 = Scn_Split7;
             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat5 = 0;
             Scn_Cat5 = Scn_Cat6;
             Scn_Cat6 = Scn_Cat7;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split5 = Scn_Split6;
             Scn_Split6 = Scn_Split7;
             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat6 = 0;
             Scn_Cat6 = Scn_Cat7;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split6 = Scn_Split7;
             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat7 = 0;
             Scn_Cat7 = Scn_Cat8;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split7 = Scn_Split8;
             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat8 = 0;
             Scn_Cat8 = Scn_Cat9;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split8 = Scn_Split9;
             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

          If Scn_Cat9 = 0;
             Scn_Cat9 = Scn_Cat10;
             Scn_Cat10= 0;

             Scn_Split9 = Scn_Split10;
             Scn_Split10= 0;
          Endif;

       Endsr;

       //*********************************************************************
       //* Gets Next job# - Data Area **
       //*******************************
       Begsr Sbr_Update_IVPITEMS;

          If Scn_Itmnum <> 0;
             Chain(n) (Scn_Itmnum) IVPITEMS;
             If %Found(IVPITEMS);

                Exsr Sbr_Write_Records_To_IVPMAINT;

                Chain (Scn_Itmnum) IVPITEMS;
                Itm_Divcat     = Scn_Divcat;
                Itm_LDesc      = Scn_Ldesc;
                Itm_SDesc      = %Trim(Scn_Series) + ' ' + Scn_Desc22;
                Itm_Series     = Scn_Series;
                Itm_Arrngr     = Scn_Arrngr;
                Itm_Artist     = Scn_Artist;
                Itm_Author     = Scn_Author;
                Itm_Catlog     = Scn_Catlog;
                Itm_Medium     = Scn_Medium;
                Itm_PblshrNum  = Scn_PblshrNum;
                Itm_RorefNum   = Scn_RorefNum;
                Itm_Voicng     = Scn_Voicng;
                Itm_Pubcode    = Scn_Pubcode;
                Itm_Maxdis     = Scn_Maxdis;

                If Scn_Maxdis = 9.999;
                   Itm_Net = 'Y';
                Else;
                   Itm_Net = 'N';
                Endif;

                Itm_Price72    = Scn_Price72;
                Itm_Price112   = Scn_Price72;
                If Scn_@KIT = 'Y';
                   Itm_Kit = 'K';
                Else;
                   Itm_Kit = ' ';
                Endif;

                WrkMktCoord = *Blanks;
                CallP IVRORRGETC (%Editc(Scn_Itmnum:'X') : WrkMktCoord);

                Select;
                   When Scn_Medium = 'SITLC';
                      Itm_Permot = *Blanks;
                   When Scn_Series = 'SI';
                      Itm_Permot = 'S';
                   When WrkMktCoord = 'IMPORT';
                      Itm_Permot = 'B';
                   other;
                      If Pcd_NewRevised = 'R'
                        and WrkQOH = *Zero;
                         Itm_Permot = 'B';
                      Else;
                         If Pcd_NewRevised = 'N';
                            Itm_Permot = 'Y';
                         Endif;
                      Endif;
                Endsl;

                // PERMOT changed above based on the job/item and QOH
                If Itm_Permot <> Scn_Permot;
                   Mnt_After  = Itm_Permot;
                   Mnt_Before = Scn_Permot;
                   Mnt_Fldnam = 'PERMOT';
                   Mnt_Comment = 'P1VEXPGEN';
                   Write IVPMAIN$;
                Endif;
                Mnt_Comment = *Blanks;

                Itm_WlrqtyNew  = Scn_Runqty;
                Itm_NIYN       = Scn_@NI;
                Itm_Nicat1     = Scn_Nicat1;
                Itm_Nicat2     = Scn_Nicat2;
                Itm_Nicat3     = Scn_Nicat3;
                Itm_Stdtyp     = 'N';
                Itm_Sellbl     = Scn_Sellbl;
                Itm_Cntrtp     = Scn_Cntrtp;
                Itm_Muskey     = Scn_Muskey;
                Itm_Publcode   = Scn_Publcode;
                Itm_CtryOrigin = Scn_CtryOrigin;

                // Check the PublCode Number
                // If 22 delete record from PCPRRNDEPT
                If Scn_Publcode = 22;
                   Chain Scn_Itmnum PCPRRNDEPT;
                   If %Found(PCPRRNDEPT);
                      Delete PC$RRNDEPT;
                   Endif;
                Endif;

                Update IVPITEM$ %Fields( Itm_Divcat
                                       : Itm_Series
                                       : Itm_Sdesc
                                       : Itm_Ldesc
                                       : Itm_Arrngr
                                       : Itm_Artist
                                       : Itm_Author
                                       : Itm_Catlog
                                       : Itm_Medium
                                       : Itm_PblshrNum
                                       : Itm_RorefNum
                                       : Itm_Voicng
                                       : Itm_Pubcode
                                       : Itm_Maxdis
                                       : Itm_Net
                                       : Itm_Price72
                                       : Itm_Price112
                                       : Itm_Kit
                                       : Itm_Permot
                                       : Itm_WlrqtyNew
                                       : Itm_NIYN
                                       : Itm_Nicat1
                                       : Itm_Nicat2
                                       : Itm_Nicat3
                                       : Itm_Stdtyp
                                       : Itm_Sellbl
                                       : Itm_Cntrtp
                                       : Itm_Muskey
                                       : Itm_Publcode
                                       : Itm_CtryOrigin);

                CallP P1R999S();
             Endif;
          Endif;

       Endsr;

       //*********************************************************************
       //* Writes records to IVPMAINT *
       //******************************
       Begsr Sbr_Write_Records_To_IVPMAINT;

          Mnt_Itmnum = Itm_Itmnum;

          // SERIES
          If Itm_Series <> Scn_Series;
             Mnt_After  = Scn_Series;
             Mnt_Before = Itm_Series;
             Mnt_Fldnam = 'SERIES';
             Write IVPMAIN$;
          Endif;

          //Long description
          If Itm_LDesc <> Scn_Ldesc;
             Mnt_Fldnam = 'LDESC';
             Mnt_After  = %Subst(Scn_Ldesc:1:29);
             Mnt_Before = %Subst(Itm_Ldesc:1:29);
             Write IVPMAIN$;

             Mnt_After  = %Subst(Scn_Ldesc:30:29);
             Mnt_Before = %Subst(Itm_Ldesc:30:29);
             Write IVPMAIN$;

             Mnt_After  = %Subst(Scn_Ldesc:59:29);
             Mnt_Before = %Subst(Itm_Ldesc:59:29);
             Write IVPMAIN$;

             // UPDATE ALPHA SEARCH
             Prm$Itmnu    = Itm_Itmnum;
             PrmDelete    = ' ';
             PrmReruna    = ' ';
             Prm$Ldesc    = Scn_Ldesc;
             PrmDivcat    = Scn_DivCat;
             PrmRorefNum2 = Scn_RoRefNum;
             Callp IVRASKWD ( IVRASKWDDS );
          Endif;

          //Short Description
          If Itm_SDesc <> (%Trim(Scn_Series) + ' ' + Scn_Desc22);
             Mnt_After  = %Trim(Scn_Series) + ' ' + Scn_Desc22;
             Mnt_Before = Itm_SDesc;
             Mnt_Fldnam = 'SDESC';
             Write IVPMAIN$;
          Endif;

          // Arranger
          If Itm_Arrngr <> Scn_Arrngr;
             Mnt_After  = Scn_Arrngr;
             Mnt_Before = Itm_Arrngr;
             Mnt_Fldnam = 'ARRNGR';
             Write IVPMAIN$;
          Endif;

          // Artist
          IF Itm_Artist <> Scn_Artist;
             Mnt_After  = Scn_Artist;
             Mnt_Before = Itm_Artist;
             Mnt_Fldnam = 'ARTIST';
             Write IVPMAIN$;
          Endif;

          // Author
          If Itm_Author <> Scn_Author;
             Mnt_After  = Scn_Author;
             Mnt_Before = Itm_Author;
             Mnt_Fldnam = 'AUTHOR';
             Write IVPMAIN$;
          Endif;

          // Catalog Code
          If Itm_Catlog <> Scn_Catlog;
             Mnt_After  = Scn_Catlog;
             Mnt_Before = Itm_Catlog;
             Mnt_Fldnam = 'CATLOG';
             Write IVPMAIN$;
          Endif;

          // Medium
          If Itm_Medium <> Scn_Medium;
             Mnt_After  = Scn_Medium;
             Mnt_Before = Itm_Medium;
             Mnt_Fldnam = 'MEDIUM';
             Write IVPMAIN$;
          Endif;

          // Publisher Number
          If Itm_PblshrNum <> Scn_PblshrNum;
             Mnt_After  = %Editc(Scn_PblshrNum:'X');
             Mnt_Before = %Editc(Itm_PblshrNum:'X');
             Mnt_Fldnam = 'PBLSHR';
             Write IVPMAIN$;
          Endif;

          // RoRef Number
          If Itm_RorefNum <> Scn_RorefNum;
             Mnt_After  = %Editc(Scn_RorefNum:'X');
             Mnt_Before = %Editc(Itm_RorefNum:'X');
             Mnt_Fldnam = 'ROREF#';
             Write IVPMAIN$;
             Callp IVRREF#C ( Itm_Itmnum );
          Endif;

          // Voicing
          If Itm_Voicng <> Scn_Voicng;
             Mnt_After  = Scn_Voicng;
             Mnt_Before = Itm_Voicng;
             Mnt_Fldnam = 'VOICNG';
             Write IVPMAIN$;
          Endif;

          // PUBCODE
          If Itm_Pubcode <> Scn_Pubcode;
             Mnt_After  = Scn_Pubcode;
             Mnt_Before = Itm_Pubcode;
             Mnt_Fldnam = 'PUBCODE';
             Write IVPMAIN$;
          Endif;

          // MAXDIS
          If Itm_Maxdis <> Scn_Maxdis;
             Mnt_After  = %Trim(%Editc(Scn_Maxdis:'3'));
             Mnt_Before = %Trim(%Editc(Itm_Maxdis:'3'));
             Mnt_Fldnam = 'MAXDIS';
             Write IVPMAIN$;
          Endif;

          // Price
          If Itm_Price72 <> Scn_Price72;
             Mnt_After  = %Trim(%Editw(Scn_Price72:'    0.  '));
             Mnt_Before = %Trim(%Editw(Itm_Price72:'    0.  '));
             Mnt_Fldnam = 'PRICE';
             Write IVPMAIN$;

             // Update price
             Chain (Scn_Itmnum : Scn_Jobnum7) PCPBKEVN;
             If %Found(PCPBKEVN);
                Bke_Bke00172 = Scn_Price72;
                Update PCPBKEV$ %Fields(Bke_Bke00172);
             Endif;

             Exsr Sbr_Update_Roy_Accrual_Rate;
          Endif;

          // KIT
          If Scn_@KIT = 'Y';
             WrkKit = 'K';
          Else;
             WrkKit = ' ';
          Endif;
          If Itm_Kit <> WrkKit;
             Mnt_After  = WrkKit;
             Mnt_Before = Itm_Kit;
             Mnt_Fldnam = 'KIT';
             Write IVPMAIN$;
          Endif;

          // NIYN
          If Itm_NIYN <> Scn_@NI;
             Mnt_After  = Scn_@Ni;
             Mnt_Before = Itm_NIYN;
             Mnt_Fldnam = 'NIYN';
             Write IVPMAIN$;
          Endif;

          // NICAT1
          If Itm_Nicat1 <> Scn_Nicat1;
             Mnt_After  = %Editc(Scn_Nicat1:'X');
             Mnt_Before = %Editc(Itm_Nicat1:'X');
             Mnt_Fldnam = 'NICAT1';
             Write IVPMAIN$;
          Endif;

          // NICAT2
          If Itm_Nicat2 <> Scn_Nicat2;
             Mnt_After  = %Editc(Scn_Nicat2:'X');
             Mnt_Before = %Editc(Itm_Nicat2:'X');
             Mnt_Fldnam = 'NICAT2';
             Write IVPMAIN$;
          Endif;

          // NICAT3
          If Itm_Nicat3 <> Scn_Nicat3;
             Mnt_After  = %Editc(Scn_Nicat3:'X');
             Mnt_Before = %Editc(Itm_Nicat3:'X');
             Mnt_Fldnam = 'NICAT3';
             Write IVPMAIN$;
          Endif;

          // SELLBL
          If Itm_Sellbl <> Scn_Sellbl;
             Mnt_After  = Scn_Sellbl;
             Mnt_Before = Itm_Sellbl;
             Mnt_Fldnam = 'SELLBL';
             Write IVPMAIN$;
          Endif;

          // Contract Type
          IF Itm_Cntrtp <> Scn_Cntrtp;
             Mnt_After  = Scn_Cntrtp;
             Mnt_Before = Itm_Cntrtp;
             Mnt_Fldnam = 'CNTRTP';
             Write IVPMAIN$;
             Exsr Sbr_Update_Roy_Accrual_Rate;
          Endif;

          // MUSKEY
          If Itm_Muskey <> Scn_Muskey;
             Mnt_After  = Scn_Muskey;
             Mnt_Before = Itm_Muskey;
             Mnt_Fldnam = 'MUSKEY';
             Write IVPMAIN$;
          Endif;

          // Country of Origin
          If Itm_CtryOrigin <> Scn_CtryOrigin;
             Mnt_After  = Scn_CtryOrigin;
             Mnt_Before = Itm_CtryOrigin;
             Mnt_Fldnam = 'CTRYORIGIN';
             Write IVPMAIN$;
          Endif;

       Endsr;

       //*********************************************************************
       //* Update Accrual Rate and Joint Ventur Rate in PCPROYLT *
       //* Update RoyAcrRat1 in IVPITEMS                         *
       //*********************************************************
       Begsr Sbr_Update_Roy_Accrual_Rate;

          Chain (Scn_RorefNum) ROLOWCTL1;
          If Not %Found(ROLOWCTL1);
             Ctl_Admfee = 0;
          Endif;

          Chain (Scn_Itmnum : Scn_Jobnum7) PCPROYLT;
          If %Found(PCPROYLT) and Roy_Codepr72 = 0;
             Eval(H) WrkTmppr2 = Scn_Price72 / 100;
             Eval(H) WrkTmpacm = Roy_Sngrte * WrkTmppr2;
             WrkJvs01          = WrkTmpacm;
             Roy_AcrRate       = WrkTmpacm;
             Eval(H) WrkTmpacm = Roy_Cmprte * WrkTmppr2;
             WrkJvs02          = WrkTmpacm;
             Roy_AcrRate      += WrkTmpacm;
             Eval(H) WrkTmpacm = Roy_Arrrte * WrkTmppr2;
             WrkJvs03          = WrkTmpacm;
             Roy_AcrRate      += WrkTmpacm;
             Eval(H) WrkTmpacm = Roy_Imgrte * WrkTmppr2;
             WrkJvs04          = WrkTmpacm;
             Roy_AcrRate      += WrkTmpacm;
             Eval(H) WrkTmpacm = Roy_Othrte * WrkTmppr2;
             WrkJvs05          = WrkTmpacm;
             Roy_AcrRate      += WrkTmpacm;

             Roy_Jvrte = 0;
             If Roy_Jvpc <> 0;
                Eval(H) WrkJv00   = Scn_Price72 * .50;
                Wrk$Admf          = 100.0 - Ctl_Admfee;
                Eval(H) Wrk$Admfd = Wrk$Admf / 100;
                Eval(H) WrkJv01   = (WrkJv00 * Wrk$Admfd)
                                  - WrkJvs02
                                  - WrkJvs03
                                  - WrkJvs04
                                  - WrkJvs05;

                // MCA Music
                If Scn_RorefNum <> 726;
                   WrkJv01 = WrkJv01 - WrkJvs01 - Roy_Mecfee;
                Endif;

                Eval(H) WrkJv00   = Roy_Jvpc * .01;
                Eval(H) WrkTmpacm = WrkJv00 * WrkJv01;
                If WrkTmppr2 <> 0;
                   Eval(H) Roy_Jvrte = WrkTmpacm / WrkTmppr2;
                Endif;
                Roy_AcrRate += WrkTmpacm;
             Endif;

             // Agency is 50%
             Eval(H) WrkTmpacm = Roy_Agcrte * WrkTmppr2 * .50;
             Roy_AcrRate      += WrkTmpacm + Roy_Mecfee + Roy_Othfee;
             Update PCPROYL$ %Fields(Roy_AcrRate : Roy_Jvrte);

             If Scn_Itmnum <> 0;
                Chain (Scn_Itmnum) IVPITEMS;
                If %Found(IVPITEMS);
                   Itm_RoyAcrRat1 = Roy_AcrRate;
                   Update IVPITEM$ %Fields(Itm_RoyAcrRat1);
                Endif;
             Endif;

          Endif;

       Endsr;

       //*********************************************************************
       //* Write splits to PCPADVSPLT *
       //******************************
       Begsr Sbr_Write_Advertising_Expense_Splits;

          // delete any existing splits for this item+job
          Setll (Scn_Jobnum7 : Scn_Itmnum) PCPADVSPLT;
          Dow 1 = 1;
             Reade (Scn_Jobnum7 : Scn_Itmnum) PCPADVSPLT;
             If %Eof(PCPADVSPLT);
                Leave;
             Endif;
             Delete PC$ADVSPLT;
          Enddo;

          // now write out any splits
          Adv_Jobnum7 = Scn_Jobnum7;
          Adv_Itmnum  = Scn_Itmnum;
          Adv_DCF     = Scn_Dcf;
          Adv_Cat1    = Scn_Cat1;
          Adv_Split1  = Scn_Split1;
          Adv_Cat2    = Scn_Cat2;
          Adv_Split2  = Scn_Split2;
          Adv_Cat3    = Scn_Cat3;
          Adv_Split3  = Scn_Split3;
          Adv_Cat4    = Scn_Cat4;
          Adv_Split4  = Scn_Split4;
          Adv_Cat5    = Scn_Cat5;
          Adv_Split5  = Scn_Split5;
          Adv_Cat6    = Scn_Cat6;
          Adv_Split6  = Scn_Split6;
          Adv_Cat7    = Scn_Cat7;
          Adv_Split7  = Scn_Split7;
          Adv_Cat8    = Scn_Cat8;
          Adv_Split8  = Scn_Split8;
          Adv_Cat9    = Scn_Cat9;
          Adv_Split9  = Scn_Split9;
          Adv_Cat10   = Scn_Cat10;
          Adv_Split10 = Scn_Split10;
          Adv_MktCode = Scn_MktCode;
          Write PC$ADVSPLT;

       Endsr;

       //*********************************************************************
       //* Send to Business Affairs for Approval *
       //*****************************************
       Begsr Sbr_Send_to_Business_Affairs_for_Approval;

          Scn_SendCopies = 0;

          Chain (Scn_Jobnum7) JOBFLE7;
          If %Found(JOBFLE7) and Jf7_RunId = 'RA';
             Chain (Scn_Itmnum : Scn_Jobnum7) PCPREV;
             If Not %Found(PCPREV);
                Dow 1 = 1;
                   Exfmt WDWREVPCR;

                   If Scn_BtnAuth = *On;
                      Callp SCVMNT(SdsProgram);
                      Iter;
                   Endif;

                   If Scn_BtnCancel = *On;
                      LeaveSr;
                   Endif;

                   If Scn_BtnNo = *On;
                      Leave;
                   Endif;

                   If Scn_BtnYes = *On;
                      Leave;
                   Endif;
                Enddo;
             Endif;
          Endif;

          If Scn_BtnYes = *On;
             WrkExpCode = 'TOC';
             WrkUpdate = 'N';
             Leavesr;
          Endif;

          If *In97 = *Off;
             Scn_SendCopies = 0;
             Scn_EmlPrint = 'E';

             // Get the Users Default Outq
             Callp GURGETOUT2 ( 'HP1' : Scn_PrtOutq);

             Dow 1 = 1;
                Exfmt WDWSENDBAF;

                If Scn_BtnAuth = *On;
                   Callp SCVMNT(SdsProgram);
                   Iter;
                Endif;

                If Scn_BtnCancel = *On;
                   Leave;
                Endif;

                Chain (Scn_Itmnum : Scn_Jobnum7) PCLMAIN08;
                If %Found(PCLMAIN08);
                   Mn8_@Send      = 'Y';
                   Mn8_Senwho     = SdsUser;
                   Mn8_SntBafMM   = %Subdt(%DATE():*M);
                   Mn8_SntBafDD   = %Subdt(%DATE():*D);
                   Mn8_SntBafYYYY = %Subdt(%DATE():*Y);
                   Mn8_SntBafDt   = %DATE();
                   Update PCPMAIN$ %Fields( Mn8_@Send
                                          : Mn8_Senwho
                                          : Mn8_SntBafMM
                                          : Mn8_SntBafDD
                                          : Mn8_SntBafYYYY
                                          : Mn8_SntBafDt);
                Endif;

                // Sent to Business Affairs
                Scn_SntBafDate = Mn8_SntBafDt;
                Chain (Mn8_SenWho) MFPUSERS;
                If %Found(MFPUSERS);
                   Scn_SntBafUser = Usr_UserName;
                Else;
                   Scn_SntBafUser = Mn8_SenWho;
                Endif;

                // Send Message if Remote User.
                Chain (SdsUser) PCPRMTUS;
                If %Found(PCPRMTUS);
                   PrmSubject = 'A PCR is on its way from '
                              + %Trim(SdsUser)
                              + '. Job# '
                              + %Editc(Scn_Jobnum7:'X')
                              + ' Item# '
                              + %Trim(%Char(Scn_Itmnum))
                              + '.';
                   PrmMessage = PrmSubject;
                   Callp SENDMSG( SdsProgram
                                : ' '
                                : PrmMessage
                                : PrmSubject
                                : ' ');
                Endif;

                // check PCPNOTIFY and send emails
                PrmNotifyItm = %Char(Scn_Itmnum);
                Callp PCRNOTIFY(PrmNotifyItm);

                // Print Approval Copy
                If Scn_EmlPrint = 'E';
                   PrmOutq   = 'EMAIL';
                   PrmCopies = *Blanks;
                Else;
                   PrmOutq   = Scn_PrtOutq;
                   PrmCopies = %Char(Scn_SendCopies);
                Endif;

                PrmEmailTo = *Blanks;
                PrmCopyTo  = *Blanks;
                PrmNotes   = *Blanks;
                Callp P1VPRINT( %Char(Scn_Itmnum)
                              : %Char(Scn_Jobnum7)
                              : 'APV'
                              : PrmOutq
                              : PrmCopies
                              : PrmEmailTo
                              : PrmCopyTo
                              : PrmNotes);
                Leave;
             Enddo;
          Else;
             *In97 = *Off;
             In *Lock PCDINQRY;
             Pcd_NewAdd = 'A';
             Out PCDINQRY;
     C                   Goto      Reedit
          Endif;

       Endsr;

       //*********************************************************************
       //* Mark Business Affairs Received *
       //**********************************
       Begsr Sbr_Mark_Business_Affairs_Received;

          Chain (Scn_Itmnum : Scn_Jobnum7) PCLMAIN08;
          If %Found(PCLMAIN08);
             Mn8_RcvWho     = SdsUser;
             Mn8_BafRcvMM   = %Subdt(%DATE():*M);
             Mn8_BafRcvDD   = %Subdt(%DATE():*D);
             Mn8_BafRcvYYYY = %Subdt(%DATE():*Y);
             Mn8_BafRcvDt   = %DATE();
             Update PCPMAIN$ %Fields( Mn8_RcvWho
                                    : Mn8_BafRcvMM
                                    : Mn8_BafRcvDD
                                    : Mn8_BafRcvYYYY
                                    : Mn8_BafRcvDt);

             // Write to Business Affairs Receive History File.
             SetGt (Scn_Jobnum7 : Scn_Itmnum) P1PBAFRCVH;
             Readpe (Scn_Jobnum7 : Scn_Itmnum) P1PBAFRCVH;
             If %Eof(P1PBAFRCVH);
                Rch_Seq = 1;
             Else;
                Rch_Seq += 1;
             Endif;

             Rch_Jobnum7    = Scn_Jobnum7;
             Rch_Itmnum     = Scn_Itmnum;
             Rch_BafRcvMM   = %Subdt(Mn8_BafRcvDt:*M);
             Rch_BafRcvDD   = %Subdt(Mn8_BafRcvDt:*D);
             Rch_BafRcvYYYY = %Subdt(Mn8_BafRcvDt:*Y);
             Rch_RcvWho     = Mn8_RcvWho;
             Write P1$BAFRCVH;
          Endif;

          // Business Affairs Received
          Scn_BafRcvDate = Mn8_BafRcvDt;

          Chain (Mn8_RcvWho) MFPUSERS;
          If %Found(MFPUSERS);
             Scn_BafRcvUser = Usr_UserName;
          Else;
             Scn_BafRcvUser = Mn8_RcvWho;
          Endif;

          // Load 2nd Business Affairs Received
          Scn_BafRcvDat2 = *Loval;
          Scn_BafRcvUsr2 = *Blanks;
          SetGt (Scn_Jobnum7 : Scn_Itmnum) P1PBAFRCVH;
          Readpe (Scn_Jobnum7 : Scn_Itmnum) P1PBAFRCVH;
          Readpe (Scn_Jobnum7 : Scn_Itmnum) P1PBAFRCVH;
          If Not %Eof(P1PBAFRCVH);
             Monitor;
                Scn_BafRcvDat2 = %Date(Rch_BafRcvYYYY * 10000
                               + Rch_BafRcvMM  * 100
                               + Rch_BafRcvDD);
             On-Error;
                Scn_BafRcvDat2 = *Loval;
             Endmon;
             Chain (Rch_RcvWho) MFPUSERS;
             If %Found(MFPUSERS);
                Scn_BafRcvUsr2 = Usr_UserName;
             Else;
                Scn_BafRcvUsr2 = Rch_RcvWho;
             Endif;
          Endif;

          WrkUpdate = 'Y';

       Endsr;

       //***********************************************************************
       //* Mark Business Affairs Approved *
       //**********************************
       Begsr Sbr_Mark_Business_Affairs_Approved;

          // IF LICENSED ITEM AND ROREF# NE 100 (CHAPPELL)
          // SEE IF IT SHOULD BE
          If Scn_Cntrtp = 'L' and Scn_RorefNum <> 100;
             PrmRoRefNum  = %Char(Mn8_RorefNum);
             PrmPblshrNum = %Char(Mn8_RorefNum);
             Callp P1VCHPPL( %Char(Scn_Itmnum)
                           : %Char(Scn_Jobnum7)
                           : PrmRoRefNum
                           : PrmPblshrNum);

             If PrmRoRefNum = '00100';
                Scn_RorefNum  = 100;
                Scn_PblshrNum = 100;
             Endif;
          Endif;

          Scn_ApvGen = ' ';
          Scn_ApvPrd = ' ';
          Scn_ApvRoy = ' ';
          Scn_ApvToc = ' ';
          Scn_ApvDup = ' ';
          Scn_ApvRoySup = 'N';
          Scn_ApVRoyCmt = *Blanks;
          WrkCancel     = *Blanks;
          Dow 1 = 1;
             Exfmt WDWBAFAPV;

             If Scn_BtnAuth = *On;
                Callp SCVMNT(SdsProgram);
                Iter;
             Endif;

             If Scn_BtnCancel = *On;
                WrkUpdate = 'N';
                Leave;
             Endif;

             If Scn_BtnSubmit = *On;

                //Hdr 29054: Add an additional Alert before approving PCR
                Dow 1 = 1;

                   Exfmt WDWALERT;

                   If Scn_BtnAuth = *On;
                      Callp SCVMNT(SdsProgram);
                      Iter;
                   Endif;

                   If Scn_BtnCancel = *On;
                      Scn_BtnCancel = *Off;
                      WrkCancel = 'Y';
                      WrkUpdate = 'N';
                      Leave;
                   Endif;

                   If Scn_BtnApprove = *On;
                      Scn_BtnApprove = *Off;
                      WrkCancel = *Blank;
                      Leave;
                   EndIf;
                EndDo;

                If WrkCancel = 'Y';
                   Scn_Message = 'PCR Approval Cancelled.';
                   Leave;
                EndIf;

                Chain (Scn_Itmnum : Scn_Jobnum7) PCLMAIN08;
                If %Found(PCLMAIN08);
                   Mn8_BusAff     = 'Y';
                   Mn8_Buswho     = SdsUser;
                   Mn8_BafApvMM   = %Subdt(%DATE():*M);
                   Mn8_BafApvDD   = %Subdt(%DATE():*D);
                   Mn8_Bafapvyyyy = %Subdt(%DATE():*Y);
                   Mn8_BafapvDt   = %DATE();
                   Update PCPMAIN$ %Fields( Mn8_BusAff
                                          : Mn8_Buswho
                                          : Mn8_BafApvMM
                                          : Mn8_BafApvDD
                                          : Mn8_Bafapvyyyy
                                          : Mn8_BafapvDt);

                   // Write to Royalty Approval List.
                   Chain (Scn_Itmnum : Scn_Jobnum7) PCPROYAPV;
                   If Not %Found(PCPROYAPV);
                      Clear PC$ROYAPV;
                      Rap_@Itm    = Scn_Itmnum;
                      Rap_Jobnum7 = Scn_JobNum7;
                      Rap_Comment = Scn_ApvRoyCmt;
                      Rap_Support = Scn_ApvRoySup;
                      Write PC$ROYAPV;
                   Endif;

                   If Scn_@Kit = 'Y';
                      // Have components of the kit approved as well
                      Callp P1RAPPRKIT (%Char(Scn_Itmnum) : %Char(Scn_Jobnum7));
                   Endif;
                Endif;

                // Business Affairs Approved
                Scn_BafApvDate = Mn8_BafApvDt;

                Chain (Mn8_BusWho) MFPUSERS;
                If %Found(MFPUSERS);
                   Scn_BafApvUser = Usr_UserName;
                Else;
                   Scn_BafApvUser = Mn8_BusWho;
                Endif;

                PrmEmailTo = *Blanks;
                PrmCopyTo  = *Blanks;
                PrmNotes   = *Blanks;
                If Scn_ApvGen <> ' ';
                   Callp P1VPRINT( %Char(Scn_Itmnum)
                                 : %Char(Scn_Jobnum7)
                                 : 'GEN'
                                 : 'EMAIL'
                                 : ' '
                                 : PrmEmailTo
                                 : PrmCopyTo
                                 : PrmNotes);
                Endif;

                If Scn_ApvPrd <> ' ';
                   Callp P1VPRINT( %Char(Scn_Itmnum)
                                 : %Char(Scn_Jobnum7)
                                 : 'PRD'
                                 : 'EMAIL'
                                 : ' '
                                 : PrmEmailTo
                                 : PrmCopyTo
                                 : PrmNotes);
                Endif;

                If Scn_ApvRoy <> ' ';
                   Callp P1VPRINT( %Char(Scn_Itmnum)
                                 : %Char(Scn_Jobnum7)
                                 : 'ROY'
                                 : 'EMAIL'
                                 : ' '
                                 : PrmEmailTo
                                 : PrmCopyTo
                                 : PrmNotes);
                Endif;

                If Scn_ApvToc <> ' ';
                   Callp P1VPRINT( %Char(Scn_Itmnum)
                                 : %Char(Scn_Jobnum7)
                                 : 'TOC'
                                 : 'EMAIL'
                                 : ' '
                                 : PrmEmailTo
                                 : PrmCopyTo
                                 : PrmNotes);
                Endif;

                If Scn_ApvDup <> ' ';
                   Callp P1VPRINT( %Char(Scn_Itmnum)
                                 : %Char(Scn_Jobnum7)
                                 : 'DUP'
                                 : 'EMAIL'
                                 : ' '
                                 : PrmEmailTo
                                 : PrmCopyTo
                                 : PrmNotes);
                Endif;
                Leave;
             Endif;
          Enddo;

       Endsr;

       //***********************************************************************
       //* Update the Screen Date and Time *
       //***********************************
       Begsr Sbr_Update_Date_And_Time;

          Scn_TtlPgm   = SdsProgram;

          // Get Users working on the PCR
          CallP P1RGETINUS (%Char(Scn_Jobnum7) : PrmText);
          If PrmText = *Blanks;
             Scn_TtlText = 'Product Clearance Request';
             Scn_TtlLine2 = 'General Information';
          Else;
             Scn_TtlText = 'Product Clearance Request - General Information';
             Scn_TtlLine2 = PrmText;
          Endif;

       Endsr;

       //*********************************************************************
       //* Initialize Subroutine **
       //**************************
       Begsr Sbr_Setup;

          In PCDINQRY;
          WrkExpCode  = Pcd_ExpCd;
          Scn_Itmnum  = Pcd_ItmNum;
          Scn_Jobnum7 = Pcd_JobNum7;
          WrkPCR      = 'Y';

          Stk_$Expcd = WrkExpCode;
          Write PCPSTAC$;

          *In99 = *Off;
          WrkInquiry  = 'N';
          Scn_Mode    = 'UPDATE';
          Scn_InqMode = *Off;
          Scn_ShowMktINQ = *Off;
          Scn_DisScore = *Off;

          If Pcd_NewAdd = 'A';
             Scn_Mode = 'ADD';
             Scn_StartDate = %Date();
             Scn_Orign     = SdsUser;
             Chain (Scn_Orign) MFPUSERS;
             If %Found(MFPUSERS);
                Scn_StartUser = Usr_UserName;
             Else;
                Scn_StartUser = Scn_Orign;
             Endif;
          Else;
             Callp P1RGETDTS ( %Char(Pcd_JobNum7)
                             : %Char(Pcd_Itmnum)
                             : Scn_EstCmpDate
                             : Scn_StartDate
                             : Scn_StartUser
                             : Scn_SntBafDate
                             : Scn_SntBafUser
                             : Scn_BafRcvDate
                             : Scn_BafRcvUser
                             : Scn_BafRcvDat2
                             : Scn_BafRcvUsr2
                             : Scn_BafApvDate
                             : Scn_BafApvUser
                             : Scn_SntWinDate
                             : Scn_SntWinUser
                             : Scn_CancelDate
                             : Scn_CancelUser);
          Endif;

          // Closed or Cancelled, and whether the item was POP'd
          Callp P1RCANSTS(Scn_Itmnum : Scn_Jobnum7 : Scn_CancelLbl);

          Chain(n) (Scn_Itmnum : Scn_Jobnum7) PCLMAIN08;
          If Pcd_Inquiry <> ' '
          or Mn8_@Wino   <> ' '
          or Mn8_Canwho  <> ' ';
             Scn_InqMode = *On;
             Scn_DisScore = *On;
             *In99 = *On;
             Scn_Mode = 'INQUIRY';
             WrkInquiry = 'Y';
          Endif;

          WrkDfltCntrtp = 'L';
          WrkFlgCall = *Off;

          // Fields for IVPMAINT
          Mnt_Maintwho  = SdsUser;
          Mnt_MaintYYYY = %Subdt(%Date():*Y);
          Mnt_Maintmm   = %Subdt(%Date():*M);
          Mnt_Maintdd   = %Subdt(%Date():*D);
          Mnt_Repcode   = 'N';

          Callp P1RLODGOTO ( WrkExpCode : PrmMenuText);

       Endsr;

       //*********************************************************************
       //* Load Screen Information *
       //***************************
       Begsr Sbr_Load_Screen;

          // Load Screen Information from Files.
          Chain(N) (Scn_Itmnum : Scn_Jobnum7) PCLMAIN08;
          If Not %Found(PCLMAIN08);
             Clear *Nokey PCPMAIN$;
             Exsr  SbrClearAll;
             Mn8_StartMM   = %Subdt(%Date():*M);
             Mn8_StartDD   = %Subdt(%Date():*D);
             Mn8_StartYYYY = %Subdt(%Date():*Y);
             Mn8_StartDt   = %Date();
             Mn8_Divcat    = Pcd_DivCat;
             Mn8_Orign     = Scn_Orign;
          Else;
             WrkPldesc = Scn_Ldesc;
             WrkPpric72 = Mn8_Price72;
             If Mn8_@Wino <> ' ';
                If Mn8_@Wino = '1';
                   *IN99 = *ON;
                Endif;
             Endif;

             If Mn8_Canwho <> *Blanks;
                *IN99 = *ON;
             Endif;

             If Mn8_Divcat = 0;
                Exsr SbrClearAll;
             Else;
                // move all fields to save
                WrkDfltCntrtp = Mn8_Cntrtp;
             Endif;
          Endif;

          // Get What items on the screen to show.
          Chain (Mn8_Divcat) P1PDIVCODE;

          Chain (Mn8_Divcat) IVPCAT;
          If %Found(IVPCAT);
             Scn_Desc16 = Cat_Desc16;
          Else;
             Scn_Desc16 = '*Not Found*';
          Endif;

          If Cod_DomFgnCnsr = 'Y';
             Scn_ShwDFC = *On;
          Else;
             Scn_ShwDFC = *Off;
          Endif;

          // Display New Issue Information
          If Cod_NewIssue = 'Y';
             Scn_ShwNewIss = *On;
          Else;
             Scn_ShwNewIss = *Off;
             Mn8_@NI = 'N';
          Endif;

          //Display Marketing Code
          If Cod_MktCode = 'Y';
             Scn_ShowMKT = *On;
             Scn_ShowMktLNK = *On;

             If WrkInquiry = 'Y';
                Scn_ShowMktLNK = *Off;
                Scn_ShowMktINQ = *On;
             Else;
                Scn_ShowMktLNK = *On;
                Scn_ShowMktINQ = *Off;
             Endif;
          Else;
             Scn_ShowMKT    = *Off;
             Scn_ShowMktLNK = *Off;
             Scn_ShowMktINQ = *Off;
          EndIf;

          // Show "** Alternate Series **" if found
          If Cod_Splits = 'Y';
             Scn_ShwSplits = *On;
             Chain(n) (Scn_Jobnum7 : Scn_Itmnum) PCPADVSPLT;
             If %Found(PCPADVSPLT);
                Scn_DCF  = Adv_Dcf;
                Scn_Cat1 = Adv_Cat1;
                Scn_MktCode = Adv_MktCode;
                Scn_Cat1    = Adv_Cat1;
                Scn_Split1  = Adv_Split1;
                Scn_Cat2    = Adv_Cat2;
                Scn_Split2  = Adv_Split2;
                Scn_Cat3    = Adv_Cat3;
                Scn_Split3  = Adv_Split3;
                Scn_Cat4    = Adv_Cat4;
                Scn_Split4  = Adv_Split4;
                Scn_Cat5    = Adv_Cat5;
                Scn_Split5  = Adv_Split5;
                Scn_Cat6    = Adv_Cat6;
                Scn_Split6  = Adv_Split6;
                Scn_Cat7    = Adv_Cat7;
                Scn_Split7  = Adv_Split7;
                Scn_Cat8    = Adv_Cat8;
                Scn_Split8  = Adv_Split8;
                Scn_Cat9    = Adv_Cat9;
                Scn_Split9  = Adv_Split9;
                Scn_Cat10   = Adv_Cat10;
                Scn_Split10 = Adv_Split10;
             Endif;
             If WrkInquiry = 'Y';
                Scn_ShwSpltPmt = *Off;
                Scn_ShwSpltTxt = *On;
             Else;
                Scn_ShwSpltPmt = *On;
                Scn_ShwSpltTxt = *Off;
             Endif;

          Else;
             Scn_ShwSplits = *Off;
             Scn_ShwSpltPmt = *Off;
             Scn_ShwSpltTxt = *Off;
          Endif;

          // Hiden Fields
          Scn_DivCat = Mn8_DivCat;
          Scn_Orign  = Mn8_Orign;

          Scn_LDesc = Mn8_LDesc1 + Mn8_LDesc2 + Mn8_LDesc3;

          // Load Sdesc on screen/Do not show series
          WrkPos = %Scan(' ':Mn8_Sdesc);
          If WrkPos > 0;
             WrkDesc = %Subst(Mn8_Sdesc:1:WrkPos);
             If WrkDesc = Mn8_Series;
                Scn_Desc22 = %SUBST(Mn8_Sdesc:WrkPos+1);
             Else;
                Scn_Desc22 = Mn8_Sdesc;
             Endif;
          Endif;

          Scn_Price72    = Mn8_Price72;
          Scn_Runqty     = Mn8_RunQty;
          Scn_Series     = Mn8_Series;
          Scn_Cntrtp     = Mn8_Cntrtp;
          Scn_CtryOrigin = Mn8_CtryOrigin;
          Scn_Medium     = Mn8_Medium;

          If Cod_Voicing = 'Y';
             If Scn_InqMode = *Off;
                Scn_ShwPmtVoic = *On;
                Scn_ShwTxtVoic = *Off;
             Else;
                Scn_ShwPmtVoic = *Off;
                Scn_ShwTxtVoic = *On;
             Endif;
             Scn_Voicng = Mn8_Voicng;
          Else;
             Scn_ShwPmtVoic = *Off;
             Scn_ShwTxtVoic = *Off;
             Scn_Voicng = *Blanks;
          Endif;

          Scn_Maxdis     = Mn8_MaxDis;
          Scn_Rorefnum   = Mn8_RorefNum;
          Scn_Pblshrnum  = Mn8_PblshrNum;
          Scn_Artist     = Mn8_Artist;
          Scn_Arrngr     = Mn8_Arrngr;
          Scn_Author     = Mn8_Author;
          Scn_Publcode   = Mn8_PublCode;
          Scn_Catlog     = Mn8_Catlog;
          Scn_@Catl1     = MN8_@Catl1;
          Scn_@Catl2     = Mn8_@Catl2;

          If Cod_MusicKey = 'Y';
             Scn_ShwMusKey = *On;
             Scn_Muskey    = Mn8_Muskey;
          Else;
             Scn_ShwMusKey = *Off;
             Scn_MusKey = *Blanks;
          Endif;

          Scn_Pubcode    = Mn8_Pubcode;

          Scn_@PURCH  = Mn8_@PURCH;
          Scn_@KIT    = Mn8_@KIT;
          Scn_@RUSH   = Mn8_@RUSH;
          Scn_@OUTS   = Mn8_@OUTS;
          Scn_@SPLT   = Mn8_@SPLT;
          Scn_SELLBL  = Mn8_SELLBL;
          Scn_Clinic# = Mn8_Clinic#;

          //   Scn_Dcf

          // New Issue
          Scn_@NI      = Mn8_@NI;
          Scn_NiCat1   = Mn8_Nicat1;
          Scn_NiCat2   = Mn8_Nicat2;
          Scn_NiCat3   = Mn8_Nicat3;
          Scn_NiCatD1  = *Blanks;
          Scn_NiCatD2  = *Blanks;
          Scn_NiCatD3  = *Blanks;

          // Barcodes
          Scn_@UPC  = Mn8_@Upc;
          Scn_@Ean# = MN8_@EAN#;
          Scn_@Isbn = MN8_@ISBN;

          // Score Information
          If Cod_Score = 'Y';
             Scn_ShwScore = *On;
             Scn_@SCSLT   = Mn8_@SCSLT;
             Scn_@SCQTY   = Mn8_@SCQTY;
             Scn_@SCPRC72 = Mn8_@SCPRC72;
          Else;
             Scn_ShwScore = *Off;
             Scn_@SCSLT   = 'N';
             Scn_@SCQTY   = *Zeros;
             Scn_@SCPRC72 = *Zeros;
          Endif;

          // If not in Break Even File chang to Add Mode.
          Chain (Scn_Itmnum : Scn_Jobnum7) PCPBKEVN;
          If Not %Found(PCPBKEVN);
             In *Lock PCDINQRY;
             Pcd_NewAdd = 'A';
             Out PCDINQRY;
          Else;
             Unlock PCPBKEVN;
          Endif;

          // Load information from IVPITEMS
          Chain(N) (Scn_Itmnum) IVPITEMS;
          In *Lock PCDINQRY;
          If %Found(IVPITEMS);
             WrkQOH = Itm_Prbbal
                    + Itm_Pradj
                    + Itm_Minput
                    + Itm_Rcvinp
                    + Itm_RaQty
                    + Itm_WmSls
                    + Itm_Sdsls;

             If WrkQOH = 0;

                // Use the RUNID to see if this is a rerun item, don't change
                // the PERMOT to NYP
                Chain Scn_Jobnum7 W#JOBFLE;
                If %Found(W#JOBFLE)
                  and Job_Runid in %List('RR':'RA');

                   Pcd_NewRevised = 'R';
                   WrkSvrun = 'RA';

                Else;
                   // New job, set fields
                   If %Found(W#JOBFLE)
                     and Job_Runid = 'NW';

                      Pcd_NewRevised = 'N';
                      WrkSvrun = 'RA';
                   Else;

                      // Default - BO item
                      Pcd_NewRevised = 'R';
                      WrkSvrun = 'RA';

                   Endif;

                Endif;

                WrkInvUpd = 'Y';

             Else;
                Pcd_NewRevised = 'R';
                WrkSvrun = 'RA';
                WrkInvUpd = 'N';
             Endif;

             // Hidden field
             Scn_Permot = Itm_Permot;

          Else;
             Pcd_NewRevised = 'N';
             WrkSvrun = 'NW';

             WrkInvUpd = 'Y';

             // Hidden field
             Scn_Permot = *Blanks;

          Endif;

          Out PCDINQRY;

          // Show "** Comments **" if found
          Chain (Scn_Itmnum : Scn_Jobnum7 : 'G') PCPCOMTS;
          If %Found(PCPCOMTS);
             Scn_ShwCmts = *On;
          Else;
             Scn_ShwCmts = *Off;
          Endif;

          // Is user authorized to Add/Change Teir Price
          PrmAuthTier = ' ';
          If *In99 = *Off;
             If Scn_Itmnum <> 0;
                PrmTierMnt = *Blanks;
                Callp CHECKSEC( SdsProgram
                              : 'REFPRICE'
                              : ' '
                              : SdsUser
                              : PrmTierMnt);
                If PrmTierMnt = 'Y';
                   PrmItmNumA = %Editc(Scn_Itmnum : 'X');

                   // Is Item elgible for Tier Pricing
                   Callp IVRTIERITM (PrmItmNumA : PrmAuthTier);
                Endif;
             Endif;
          Endif;

          // Check for Alternate Series and Display
          Chain (Scn_Itmnum : Scn_Jobnum7) PCPASRS;
          If %Found(PCPASRS);
             Scn_ShwAltSrs = *On;
          Else;
             Scn_ShwAltSrs = *Off;
          Endif;

          Scn_FocLdesc   = *On;



          // Load Split Information
          Chain(n) (Scn_Jobnum7 : Scn_Itmnum) PCPADVSPLT;
          If %Found(PCPADVSPLT);
             Scn_Cat1  = Adv_Cat1;
             Scn_Cat2  = Adv_Cat2;
             Scn_Cat3  = Adv_Cat3;
             Scn_Cat4  = Adv_Cat4;
             Scn_Cat5  = Adv_Cat5;
             Scn_Cat6  = Adv_Cat6;
             Scn_Cat7  = Adv_Cat7;
             Scn_Cat8  = Adv_Cat8;
             Scn_Cat9  = Adv_Cat9;
             Scn_Cat10 = Adv_Cat10;

             Scn_Split1  = Adv_Split1;
             Scn_Split2  = Adv_Split2;
             Scn_Split3  = Adv_Split3;
             Scn_Split4  = Adv_Split4;
             Scn_Split5  = Adv_Split5;
             Scn_Split6  = Adv_Split6;
             Scn_Split7  = Adv_Split7;
             Scn_Split8  = Adv_Split8;
             Scn_Split9  = Adv_Split9;
             Scn_Split10 = Adv_Split10;
          Else;
             Scn_Cat1  = 0;
             Scn_Cat2  = 0;
             Scn_Cat3  = 0;
             Scn_Cat4  = 0;
             Scn_Cat5  = 0;
             Scn_Cat6  = 0;
             Scn_Cat7  = 0;
             Scn_Cat8  = 0;
             Scn_Cat9  = 0;
             Scn_Cat10 = 0;

             Scn_Split1  = 0;
             Scn_Split2  = 0;
             Scn_Split3  = 0;
             Scn_Split4  = 0;
             Scn_Split5  = 0;
             Scn_Split6  = 0;
             Scn_Split7  = 0;
             Scn_Split8  = 0;
             Scn_Split9  = 0;
             Scn_Split10 = 0;
          Endif;

          // fill in description for any splits already entered
          // save divcat prior to chain and then reset at end of subroutine
          // scrDivCat = Divcat;
          // save curr value of indicators used for cursor positioning in this
          // subroutine so they can be restored when done.
          WrkIndex1 = 1;
          For WrkIndex1 = 1 to 10;
             If AryCat(WrkIndex1) <> 0;
                WrkCatLen7 = AryCat(WrkIndex1);
                Chain (WrkCatLen7) IVPCAT;
                If %Found(IVPCAT);
                   AryCatD(WrkIndex1) = Cat_Desc16;
                Else;
                   Chain (WrkCatLen7) DIV01L;
                   If %Found(DIV01L);
                      AryCatD(WrkIndex1) = Div_Div;
                   Endif;
                Endif;
             Endif;
          Endfor;

       Endsr;

       //*********************************************************************
       //* Load Screen Information *
       //***************************
       Begsr Sbr_Update_PCPMAIN;

          Chain (Scn_Itmnum : Scn_Jobnum7) PCLMAIN08;
          WrkNoJob = *Off;
          If Scn_Jobnum7 = 0;
             WrkNoJob = *On;
             PrmJobNum7 = *Blanks;
             Callp P1RGETJOB ( PrmJobnum7 );
             Monitor;
                Scn_Jobnum7 = %Int(PrmJobNum7);
             On-Error;
                Scn_Jobnum7 = *Zero;
             Endmon;
          Endif;

          Mn8_@Prelm = 'F';
          If *In97 = *On;
             Mn8_@Prelm = 'P';
          Endif;

          Mn8_Orign      = Scn_Orign;
          Mn8_DivCat     = Scn_DivCat;

          Mn8_LDesc1     = %Subst(Scn_Ldesc:1:29);
          Mn8_LDesc2     = %Subst(Scn_Ldesc:30:29);
          Mn8_LDesc3     = %Subst(Scn_Ldesc:59:29);

          Mn8_Voicng     = Scn_Voicng;
          Mn8_@Kit       = Scn_@Kit;
          Mn8_RunQty     = Scn_RunQty;
          Mn8_@Purch     = Scn_@Purch;
          Mn8_Series     = Scn_Series;
          Mn8_Price72    = Scn_Price72;
          Mn8_Price112   = Scn_Price72;

          If Scn_EstCmpDate = *Loval;
             Mn8_EstCmpMM   = *zero;
             Mn8_EstCmpDD   = *zero;
             Mn8_EstCmpYYYY = *zero;
             Mn8_EstCmpDt   = *Loval;
          Else;
             Mn8_EstCmpMM   = %Subdt(Scn_EstCmpDate:*M);
             Mn8_EstCmpDD   = %SubDt(Scn_EstCmpDate:*D);
             Mn8_EstCmpYYYY = %SubDt(Scn_EstCmpDate:*Y);
             Mn8_EstCmpDt   = Scn_EstCmpDate;
          Endif;

          Mn8_Cntrtp     = Scn_Cntrtp;
          Mn8_Sellbl     = Scn_Sellbl;
          Mn8_Medium     = Scn_Medium;
          Mn8_Artist     = Scn_Artist;
          Mn8_Arrngr     = Scn_Arrngr;
          Mn8_Author     = Scn_Author;
          Mn8_@UPC       = Scn_@UPC;
          Mn8_@ISBN      = Scn_@ISBN;
          Mn8_@NI        = Scn_@NI;
          Mn8_NICAT1     = Scn_NICat1;
          Mn8_NICAT2     = Scn_NICat2;
          Mn8_NICAT3     = Scn_NICat3;
          Mn8_@Catl1     = Scn_@Catl1;
          Mn8_@Catl2     = Scn_@Catl2;
          Mn8_@ScSlt     = Scn_@ScSlt;
          Mn8_@ScQty     = Scn_@ScQty;
          Mn8_@ScPrc72   = Scn_@ScPrc72;
          Mn8_@ScPrc112  = Scn_@ScPrc72;
          Mn8_PubCode    = Scn_PubCode;
          Mn8_Catlog     = Scn_Catlog;
          Mn8_RoRefNum   = Scn_RoRefNum;
          Mn8_PblshrNum  = Scn_PblshrNum;
          Mn8_MaxDis     = Scn_MaxDis;
          Mn8_@Splt      = Scn_@Splt;
          Mn8_@Rush      = Scn_@Rush;
          Mn8_@Ean#      = Scn_@Ean#;
          Mn8_@Outs      = Scn_@Outs;
          Mn8_@Bill      = 'N';
          Mn8_MusKey     = Scn_MusKey;
          Mn8_Clinic#    = Scn_Clinic#;
          Mn8_NIYN       = Scn_@NI;
          Mn8_CtryOrigin = Scn_CtryOrigin;
          Mn8_PublCode   = Scn_PublCode;
          If %Found(PCLMAIN08);
             // Check to see if series is included in Sdesc
             // If not move it into sdesc
             WrkPos = %Scan(%Trim(Scn_Series):Scn_Desc22);
             If WrkPos >=1;
                Mn8_Sdesc = Scn_Desc22;
             Else;
                Mn8_Sdesc = %Trim(Scn_Series) + ' ' + Scn_Desc22;
             Endif;

             Update PCPMAIN$ %FIELDS( Mn8_StartMM
                                    : Mn8_StartDD
                                    : Mn8_StartYYYY
                                    : Mn8_StartDt
                                    : Mn8_Orign
                                    : Mn8_@Prelm
                                    : Mn8_Priort
                                    : Mn8_DivCat
                                    : Mn8_LDesc1
                                    : Mn8_LDesc2
                                    : Mn8_LDesc3
                                    : Mn8_Sdesc
                                    : Mn8_Voicng
                                    : Mn8_@Kit
                                    : Mn8_RunQty
                                    : Mn8_@Purch
                                    : Mn8_Series
                                    : Mn8_Price72
                                    : Mn8_Price112
                                    : Mn8_EstCmpMM
                                    : Mn8_EstCmpDD
                                    : Mn8_EstCmpYYYY
                                    : Mn8_EstCmpDt
                                    : Mn8_EstWinMM
                                    : Mn8_EstWinDD
                                    : Mn8_EstWinYYYY
                                    : Mn8_EstWinDt
                                    : Mn8_Cntrtp
                                    : Mn8_Sellbl
                                    : Mn8_Medium
                                    : Mn8_Artist
                                    : Mn8_Arrngr
                                    : Mn8_Author
                                    : Mn8_@UPC
                                    : Mn8_@ISBN
                                    : Mn8_@NI
                                    : Mn8_NICAT1
                                    : Mn8_NICAT2
                                    : Mn8_NICAT3
                                    : Mn8_@Catl1
                                    : Mn8_@Catl2
                                    : Mn8_@ScSlt
                                    : Mn8_@ScQty
                                    : Mn8_@ScPrc72
                                    : Mn8_@ScPrc112
                                    : Mn8_PubCode
                                    : Mn8_Catlog
                                    : Mn8_RoRefNum
                                    : Mn8_PblshrNum
                                    : Mn8_MaxDis
                                    : Mn8_@Splt
                                    : Mn8_@Rush
                                    : Mn8_@Ean#
                                    : Mn8_@Outs
                                    : Mn8_@Bill
                                    : Mn8_MusKey
                                    : Mn8_Clinic#
                                    : Mn8_NIYN
                                    : Mn8_CtryOrigin
                                    : Mn8_PublCode);
          Else;
             Mn8_Jobnum7    = Scn_Jobnum7;

             Mn8_BusAff     = 'N';
             Mn8_BafApvMM   = *Zeros;
             Mn8_BafApvDD   = *Zeros;
             Mn8_BafApvYYYY = *Zeros;
             Mn8_BafApvDt   = *Loval;
             Mn8_BusWho     = *Blanks;

             Mn8_@Send      = *Blanks;
             Mn8_SntBafMM   = *Zeros;
             Mn8_SntBafDD   = *Zeros;
             Mn8_SntBafYYYY = *Zeros;
             Mn8_SntBafDt   = *Loval;
             Mn8_SenWho     = *Blanks;

             Mn8_@Wino      = *Blanks;
             Mn8_SntWinMM   = *Zeros;
             Mn8_SntWinDD   = *Zeros;
             Mn8_SntWinYYYY = *Zeros;
             Mn8_SntWinDt   = *Loval;
             Mn8_WinWho     = *Blanks;

             Mn8_Cancl      = *Blanks;
             Mn8_CancelMM   = *Zeros;
             Mn8_CancelDD   = *Zeros;
             Mn8_CancelYYYY = *Zeros;
             Mn8_CancelDt   = *Loval;

             Mn8_CanWho     = *Blanks;

             Mn8_BafRcvMM   = *Zeros;
             Mn8_BafRcvDD   = *Zeros;
             Mn8_BafRcvYYYY = *Zeros;
             Mn8_BafRcvDt   = *Loval;

             Mn8_RcvWho     = *Blanks;
             Mn8_Trackdone  = 'N';

             Mn8_Sdesc = %Trim(Scn_Series) + ' '  + Scn_Desc22;

             Write PCPMAIN$;
          Endif;

          // Update IVPITMCODE
          // If Purchased Item write to file
          // If not Purchased delete from File.
          Chain (Scn_Itmnum : 'PUR') IVPITMCODE;
          Select;
             When Scn_@Purch = 'Y';
                If Not %Found(IVPITMCODE);
                   Cod_Itmnum  = Scn_Itmnum;
                   Cod_ItmCode = 'PUR';
                   Write IV$ITMCODE;
                Endif;
             When Scn_@Purch = 'N';
                If %Found(IVPITMCODE);
                   Delete IV$ITMCODE;
                Endif;
          Endsl;

       Endsr; 