     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLREBKUPD
       // RL: Update eBooks in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // All Ebook items are updated in the royalty files in this program.
       // RLREBKDLT deltes all items
       // This program and RLREBKADMS and RLREBKADPR add the files back based on the select statement
       // The accrual rate is not updated here. That is done vie RLRPDRVR
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H30612  12/07/22 TAK Fix Program That Automatically Creates MP3 Digita
       //                      l Items
       // H30629  11/16/22 TAK Data not being copied over for Ebooks: Copy field
       //                      s if a kit is setup.
       // H26577  03/02/21 TGM Option To Run New / Revised Product Listing On De
       //                      mand
       // FIX     02/12/21 SRK Source Error Dates
       // MISC    05/16/19 SRK Fix Source Error
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // MISC2   08/14/15 SRK Copy Source Not Needed for program
       // H8098   08/22/14 DRS Add CPRTUN field to the Royalty eBook update prog
       //                      ram
       // H3696   08/04/14 KCS Check the calculation of the accrual rates for Eb
       //                      ooks.  Looks like theprogram is changing the rate
       //                      s to 0; which, is incorrect.  Need tofix the  pro
       //                      gram and fix the accrual rates
       // H3696   08/04/14 KCS Check the calculation of the accrual rates for Eb
       //                      ooks.  Looks like theprogram is changing the rate
       //                      s to 0; which, is incorrect.  Need tofix the  pro
       //                      gram and fix the accrual rates
       // H6980   04/24/14 DRS Fix Royalty codes for eBook items.
       // H4199   11/06/13 DRS Remove ROREF# and PBLSHR from update programs.
       // MISC    04/10/13 DRS Add exempt items
       // I31187  03/01/13 DRS [DP] Increase Roref#/Pblshr# - Inventory
       // H2766   11/20/12 DRS Add record to IVPMAINT when Roref# is changed.
       // H2766   11/20/12 DRS Add call for RLRCHGTYPE
       // H2495   11/05/12 SMM Fix the Standards error "Prototype for Program Ne
       //                      eded"
       // MISC    09/18/12 DRS Add item to exclude
       // H2081   08/10/12 DRS Retain Roref# 876 for eBook items 314900 and 3183
       //                      85. Do not copy from hardgood.
       // H1787   07/24/12 DRS Write to work file instead of report.
       // 1787   07/17/12 DRS  ew
       //***********************************************************************

       // Input Files
     FRLPDSNHG  IF   E           K DISK    Prefix(Dsn_)

       // Update Files
     FIVLEPUBIT1UF   E           K DISK    Prefix(Epb_)
     FIVPITEMS  UF   E           K DISK    Prefix(Itm_)
     FGSROY1    IF A E           K DISK    Prefix(Gsr_)
     FRBLPROD2  IF A E           K DISK    Prefix(Apl_)
     FRMLPROD2  IF A E           K DISK    Prefix(Amd_)
     FRMLPROD2APIF A E           K DISK    Prefix(Ad2_)
     F                                     Rename(RMPPROD$:RMPPRODAP)
     FROPHIGHDISIF A E           K DISK    Prefix(Dis_)
     FR#DOMKIT  IF A E           K DISK    Prefix(Kit_)
     FDOMKIT1   IF A E           K DISK    Prefix(Kit_)
     F                                     Rename(B$KITFIL:B$KITFIL1)
     FAGCYITM   IF A E           K DISK    Prefix(Agc_)
     FIVPMAINT  O    E           K DISK    Prefix(Mnt_)
     FRLPAUTOSTPUF A E           K DISK    Prefix(Stp_)

       // Work Print File
     FRLWEBKRPRTO    E           K DISK    Prefix(Brt_)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,RLREBKUPD
      /copy qcopysrc,rlrchgtype

       //***********************************************************************
       //* Entry Parameters *
       //********************
     D RLREBKUPD       PI
     D PrmCalled                      1A   const

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds
      /copy qcopysrc,rlrebkdlt
      /copy qcopysrc,rlrebkadms
      /copy qcopysrc,rlrebkadpr
      /copy qcopysrc,rlrdgtmtxo

     D SavCprtun       S                   Like(Itm_Cprtun)
     D SavCntrtp       S                   Like(Itm_Cntrtp)
     D SavCexcpt       S                   Like(Itm_Cexcpt)
     D SavPrtrtp       S                   Like(Itm_Prtrtp)
     D SavRorefNum     S                   Like(Itm_RorefNum)
     D SavPblshrNum    S                   Like(Itm_PblshrNum)
     D PrmOrgItmnum    S              8A
     D PrmEbkItmnum    S              8A

     D $Chgpm          DS            22
     D PrmItmnum                      8  0
     D PrmNewcnt                      1
     D PrmOldcnt                      1
     D PrmNewprt                      1
     D PrmOldprt                      1
     D PrmNewcpr                      5  0
     D PrmOldcpr                      5  0

       //***********************************************************************
       //* Main Line *
       //*************

       // Call program to Delete Ebook Items
       Callp RlREBKDLT();

       Setll *Loval IVLEPUBIT1;
       Dow 1 = 1;
          Read IVLEPUBIT1;
          If %Eof(IVLEPUBIT1);
             Leave;
          Endif;

          // Do not change these items per Karla
          If Epb_Itmnum = 314900
             or Epb_Itmnum = 318122
             or Epb_Itmnum = 108014
             or Epb_Itmnum = 318362
             or Epb_Itmnum = 319036
             or Epb_Itmnum = 333284
             or Epb_Itmnum = 318385;
             Iter;
          Endif;

          Chain(n) Epb_OrgItmnum IVPITEMS;
          If %Found(IVPITEMS);
             SavCntrtp = Itm_Cntrtp;
             SavCexcpt = Itm_Cexcpt;
             SavPrtrtp = Itm_Prtrtp;
             SavCprtun = Itm_Cprtun;
             SavRorefnum = Itm_RorefNum;
             SavPblshrnum = Itm_Pblshrnum;
          Endif;

          PrmOrgItmnum = %Editc(Epb_OrgItmnum:'X');
          PrmEbkItmnum = %Editc(Epb_Itmnum:'X');

          // Check Disney File
          Chain Epb_OrgItmnum RLPDSNHG;

          Select;
             When Itm_RorefNum = 522
                or Itm_RorefNum = 523;
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Exsr Sbr_Write_PrintFile;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When Itm_RorefNum = 190
                or Itm_RorefNum = 729;
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );
                Exsr Sbr_Write_PrintFile;

             When %Found(RLPDSNHG);
                Exsr Sbr_Write_R#DOMKIT;
                SavCntrtp = 'S';
                SavCexcpt = 'O';
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );


             When Itm_PrtRtp   = 'O'
                and (Itm_Cntrtp = 'L'
                or   Itm_Cntrtp = 'R');
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When Itm_PrtRtp = 'X'
                and (Itm_Cntrtp = 'S'
                or   Itm_Cntrtp = 'R');
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When (Itm_PrtRtp <> 'O'
                and Itm_PrtRtp <> 'X')
                and (Itm_Cntrtp = 'L'
                or  Itm_Cntrtp = 'R');
                Exsr Sbr_Write_R#DOMKIT;
                SavCntrtp = 'S';
                SavCexcpt = 'O';
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When Itm_Cntrtp = 'F'
                or Itm_Cntrtp = 'G';
                SavCexcpt = 'O';
                Exsr Sbr_Write_R#DOMKIT;
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When (Itm_Cntrtp = 'A'
                or Itm_Cntrtp = 'C'
                or Itm_Cntrtp = 'J'
                or Itm_Cntrtp = 'N')
                and (Itm_Prtrtp = *Blanks
                or   Itm_Prtrtp = 'X');
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When (Itm_Cntrtp = 'A'
                or Itm_Cntrtp = 'C'
                or Itm_Cntrtp = 'J'
                or Itm_Cntrtp = 'N')
                and Itm_Prtrtp = 'O';
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When (Itm_Cntrtp = 'A'
               or Itm_Cntrtp = 'C'
               or Itm_Cntrtp = 'J'
               or Itm_Cntrtp = 'N');
                Exsr Sbr_Write_R#DOMKIT;
                SavCexcpt = 'O';
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;

             When Itm_Cntrtp = 'M';
                Exsr Sbr_Write_R#DOMKIT;
                SavCexcpt = 'O';
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;

             When Itm_Cntrtp =  'S'
                or Itm_Cexcpt = 'O';
                Exsr Sbr_Write_R#DOMKIT;
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Exsr Sbr_Write_PrintFile;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             When Epb_OrgItmnum = 100576;
                SavCexcpt = *Blanks;
                SavPrtrtp = *Blanks;
                Exsr Sbr_Update_IVPITEMS;
                Exsr Sbr_Write_Records;
                Exsr Sbr_Write_R#DOMKIT;
                Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
                Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

             Other;
                Exsr Sbr_Write_PrintFile;

          Endsl;

          Chain Epb_Itmnum AGCYITM;
          If Not %Found(AGCYITM);
             Agc_Itmnum = Epb_Itmnum;
             Agc_Agent  = Agc_Agent;
             Agc_Jvpc   = Agc_Jvpc;
             Agc_Series = *Blanks;
             Agc_Width  = *Zero;
             Agc_Length = *Zero;
             Agc_CvrFin = *Blanks;
             Agc_ClrCov = *Zero;
             Agc_ClrGut = *Zero;
             Agc_Clrbu  = *Zero;
             Agc_Numpag = *Zero;
             Agc_Bindng = *Blanks;
             Agc_Arrcst = *Zero;
             Agc_Arrpag = *Zero;
             Agc_Enpcst = *Zero;
             Agc_Enppag = *Zero;
             Agc_Enscst = *Zero;
             Agc_Enspag = *Zero;
             Agc_Titcst = *Zero;
             Agc_Titpag = *Zero;
             Agc_Negcst = *Zero;
             Agc_Negpag = *Zero;
             Agc_Covart = *Zero;
             Agc_Covsep = *Zero;
             Write AGCYITM$;
          Endif;

       Enddo;

       *Inlr = *On;

       //*****************
       //* End Main Line *
       //***********************************************************************

       // /******************************************************************\ *
       //<                           SUBROUTINES                              >*
       // \******************************************************************/ *
       //***********************************************************************
       //* Rebuild records **
       //********************
       Begsr Sbr_Write_Records;

          // Gheck to see if G. Schirmer item
          Setll Epb_Orgitmnum GSROY1;
          Dow 1 = 1;
             Reade Epb_OrgItmnum GSROY1;
             If %Eof(GSROY1);
                Leave;
             Endif;

             Gsr_Ritem = Epb_Itmnum;
             Write GSROY$;
          Enddo;

          // Amadeus/Limelight
          Setll Epb_OrgItmnum RMLPROD2;
          Dow 1 = 1;
             Reade Epb_OrgItmnum RMLPROD2;
             If %Eof(RMLPROD2);
                Leave;
             Endif;

             Amd_Itmnum = Epb_Itmnum;
             Write RMPPROD$;

          Enddo;

          // This logical points to RBLPROD2 in AP_Roy
          Setll Epb_OrgItmnum RMLPROD2AP;
          Dow 1 = 1;
             Reade Epb_OrgItmnum RMLPROD2AP;
             If %Eof(RMLPROD2AP);
                Leave;
             Endif;

             Ad2_Itmnum = Epb_Itmnum;
             Write RMPPRODAP;

          Enddo;

          // Applause
          Setll Epb_OrgItmnum RBLPROD2;
          Dow 1 = 1;
             Reade Epb_OrgItmnum RBLPROD2;
             If %Eof(RBLPROD2);
                Leave;
             Endif;

             Apl_Itmnum = Epb_Itmnum;
             Write RBPPROD$;

          Enddo;

          // High Discount update
          Setll Epb_OrgItmnum ROPHIGHDIS;
          Dow 1 = 1;
             Reade Epb_OrgItmnum ROPHIGHDIS;
             If %Eof(ROPHIGHDIS);
                Leave;
             Endif;

             Dis_Itmnum = Epb_Itmnum;
             Write RO$HIGHDIS;

          Enddo;

       Endsr;
       //***********************************************************************
       //* Add R#DOMKIT **
       //***************************
       Begsr Sbr_Write_R#DOMKIT;

          // Old Kit System

          If Itm_Cexcpt = 'O';
             Setll Epb_OrgItmnum R#DOMKIT;
             Dow 1 = 1;
                Reade Epb_OrgItmnum R#DOMKIT;
                If %Eof(R#DOMKIT);
                   Leave;
                Endif;

                Kit_Kit#   = Epb_Itmnum;
                Kit_Comp#  = Kit_Comp#;
                Kit_Compqt = 1;
                Write B$KITFIL1;
             Enddo;
          Else;
             Chain ( Epb_OrgItmnum : Epb_Itmnum) DOMKIT1;
             If Not %Found(DOMKIT1);
                Kit_Kit#   = Epb_Itmnum;
                Kit_Comp#  = Epb_OrgItmnum;
                Kit_Compqt = 1;
                Write B$KITFIL;
             Endif;
          Endif;

       Endsr;

       //***********************************************************************
       //* Update IVPITEMS **
       //********************
       Begsr Sbr_Update_IVPITEMS;

          Chain Epb_Itmnum IVPITEMS;
          If %Found(IVPITEMS);

             PrmItmnum  = Epb_Itmnum;

             PrmOldCnt  = Itm_Cntrtp;
             PrmNewCnt  = SavCntrtp;
             Itm_Cntrtp = SavCntrtp;

             PrmOldCpr  = *Zero;
             PrmNewCpr  = *Zero;

             If Itm_Cntrtp <> 'M';
                PrmOldPrt  = Itm_Prtrtp;
                PrmNewPrt  = SavPrtrtp;
                Itm_Cexcpt = SavCexcpt;
                Itm_Prtrtp = SavPrtrtp;
             Else;
                PrmOldPrt  = *Blanks;
                PrmNewPrt  = *Blanks;
             Endif;
             If Epb_Orgitmnum <> 100576;
                If SavRorefNum <> Itm_RorefNum;
                   // Write to Maint history
                   Mnt_Maintwho  = SdsUser;
                   Mnt_MaintYYYY = %Subdt(%Date():*Y);
                   Mnt_Maintmm   = %Subdt(%Date():*M);
                   Mnt_Maintdd   = %Subdt(%Date():*D);
                   Mnt_Repcode   = 'N';
                   Mnt_Itmnum    = Epb_Itmnum;
                   Mnt_Before    = %Editc(Itm_RorefNum:'X');
                   Mnt_After     = %Editc(SavRorefNum:'X');
                   Mnt_Fldnam    = 'ROREF#';
                   Mnt_Comment   = *Blanks;
                   Write IVPMAIN$;
                Endif;

                Itm_RorefNum  = SavRorefNum;
                Itm_PblshrNum = SavPblshrNum;
                Itm_Cprtun    = SavCprtun;
             Endif;
             Update IVPITEM$ %Fields( Itm_Cntrtp
                                    : Itm_Cexcpt
                                    : Itm_Prtrtp
                                    : Itm_Cprtun
                                    : Itm_Rorefnum
                                    : Itm_Pblshrnum );

             Stp_ItmNum   = Epb_Itmnum;
             Stp_DTEADDED = %Date();
             Write RL$AUTOSTP;

             Callp RLRCHGTYPE ( $Chgpm );

          Endif;

       Endsr;

       //***********************************************************************
       //* Write to Print File **
       //******************
       Begsr Sbr_Write_PrintFile;

          If (PrmCalled = 'M'
             and Epb_Mprinted = *Loval)
             or (PrmCalled = 'C'
             and Epb_Cprinted = *Loval);

             Brt_OrgItmnum = Epb_OrgItmnum;
             Brt_Itmnum    = Epb_Itmnum;
             Brt_Sdesc     = Itm_Sdesc;
             Brt_Permot    = Itm_Permot;
             Brt_Cntrtp    = Itm_Cntrtp;
             Brt_Cexcpt    = Itm_Cexcpt;
             Brt_Prtrtp    = Itm_Prtrtp;
             Brt_Cprtun    = Itm_Cprtun;
             Brt_Rorefnum  = Itm_Rorefnum;

             Write RL$EBKRPRT;

             Select;
                When PrmCalled = 'M';
                   Epb_Mprinted = %Date();
                   Update IV$EPUBITM %Fields( Epb_Mprinted );
                When PrmCalled = 'C';
                   Epb_Cprinted = %Date();
                   Update IV$EPUBITM %Fields( Epb_Cprinted );
             Endsl;

          Endif;

       Endsr;
