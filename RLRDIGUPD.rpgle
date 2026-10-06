     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLRDIGUPD
       // IV: Update Digital down Load in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // All DLD items are updated in the royalty files in this program.
       // RLRDIGDLT deltes all items
       // This program and RLRDIGADMS and RLRDIGADPR add the files back based on the select statement
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33962  05/22/26 EI  Roref # For Bock & Pavane items
       // H30612  02/01/23 TAK Set CEXCPT = 'O' and CNTRTP = 'S' if the digital
       //                      item is added to the kit file.
       // H30629  12/01/22 TAK Data not being copied over for Ebooks - Add matri
       //                      x override copy to all programs that create digit
       //                      al items from a hardgood.
       // H26577  03/02/21 TGM Option To Run New / Revised Product Listing On De
       //                      mand
       // MISC    05/16/19 SRK Fix Source Error
       // H17306  07/05/17 CMN Review RLRDIGUPD. There was an error. I Dumped th
       //                      e error however could not figure out what should
       //                      be done. Looks like this could be rerun by Royalt
       //                      ies. Check with Karla. This code in  Begsr Sbr_Wr
       //                      ite_R#DOMKIT;   looks incorrect as is chains to a
       //                       file with the wrong information.
       // MISC3   05/26/16 SRK Source Fix. Remove Files not used
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // H12541  01/04/16 TRO Digital Print Roy Types and Contract Types are be
       //                      ing changed.
       // H12541  12/14/15 TRO Digital Print Roy Types and Contract Types are be
       //                      ing changed.
       // MISC2   08/14/15 SRK Copy Source Not Needed for program
       // H7237   06/04/14 DRS Modify program RLRDIGUPD to copy royalty info to
       //                      IVPITEMS regardless of rules now in place. Leave
       //                      all other process in place and add updatethe old
       //                      kit system. Create separate program to verify all
       //                      items in therelated item file are in IVPCNTNT.
       // H4199   11/06/13 DRS Remove ROREF# and PBLSHR from update programs.
       // I31187  03/01/13 DRS [DP] Increase Roref#/Pblshr# - Inventory
       // H2766   11/20/12 DRS Add call for RLRCHGTYPE
       // 2078   10/03/12 DRS  ew
       //***********************************************************************

       // Update Files
     FIVPRELITM UF   E           K DISK    Prefix(Rel_)
     FIVPITEMS  UF   E           K DISK    Prefix(Itm_)
     FGSROY1    IF A E           K DISK    Prefix(Gsr_)
     FRBLPROD2  IF A E           K DISK    Prefix(Apl_)
     FRMLPROD2  IF A E           K DISK    Prefix(Amd_)
     FRMLPROD2APIF A E           K DISK    Prefix(Ad2_)
     F                                     Rename(RMPPROD$:RMPPRODAP)
     FROPHIGHDISIF A E           K DISK    Prefix(Dis_)
     FAGCYITM   IF A E           K DISK    Prefix(Agc_)
     FIVPMAINT  O    E           K DISK    Prefix(Mnt_)
     FR#DOMKIT  IF A E           K DISK    Prefix(Kit_)
     FDOMKIT1   IF A E           K DISK    Prefix(Kit_)
     F                                     Rename(B$KITFIL:B$KITFIL1)
     FRLPAUTOSTPUF A E           K DISK    Prefix(Stp_)

       // Work Print File
     FRLWDIGRPRTO    E           K DISK    Prefix(Brt_)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,rlrdigupd
      /copy qcopysrc,rlrchgtype
      /copy qcopysrc,rlrdgtmtxo

       //***********************************************************************
       //* Entry Parameters *
       //********************
     D RLRDIGUPD       PI
     D PrmCalled                      1A   const

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds
      /copy qcopysrc,rlrdigdlt
      /copy qcopysrc,rlrebkadms
      /copy qcopysrc,rlrebkadpr

     D WrkDgtKit       S              1A
     D SavCntrtp       S                   Like(Itm_Cntrtp)
     D SavCexcpt       S                   Like(Itm_Cexcpt)
     D SavPrtrtp       S                   Like(Itm_Prtrtp)
     D SavCprtun       S                   Like(Itm_Cprtun)
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
       Exsr Sbr_Setup;

       // Call Delete program to Delete Ebook Items
       Callp RLRDIGDLT();

       Setll *Loval IVPRELITM;
       Dow 1 = 1;
          Read IVPRELITM;
          If %Eof(IVPRELITM);
             Leave;
          Endif;

          If Rel_RelTypeid <> 1;
             Iter;
          Endif;

          Chain(n) ReL_Itmnum IVPITEMS;
          SavCntrtp = Itm_Cntrtp;
          SavCexcpt = Itm_Cexcpt;
          SavPrtrtp = Itm_Prtrtp;
          SavCprtun = Itm_Cprtun;
          SavRorefnum = Itm_RorefNum;
          SavPblshrnum = Itm_Pblshrnum;
          PrmOrgItmnum = %Editc(Rel_Itmnum:'X');
          PrmEbkItmnum = %Editc(Rel_RelItmnum:'X');

          WrkDgtKit = 'N';
          If SavCexcpt = 'O';
             Exsr Sbr_Write_R#DOMKIT;
          Endif;

          Exsr Sbr_Update_IVPITEMS;
          Exsr Sbr_Write_Records;
          Callp RLREBKADPR ( PrmOrgItmnum : PrmEbkItmnum );
          Callp RLREBKADMS ( PrmOrgItmnum : PrmEbkItmnum );
          Callp RLRDGTMTXO ( PrmOrgItmnum : PrmEbkItmnum );

          Chain Rel_RelItmnum AGCYITM;
          If Not %Found(AGCYITM);
             Agc_Itmnum = Rel_RelItmnum;
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
          Setll Rel_Itmnum GSROY1;
          Dow 1 = 1;
             Reade Rel_Itmnum GSROY1;
             If %Eof(GSROY1);
                Leave;
             Endif;

             Gsr_Ritem = Rel_RelItmnum;
             Write GSROY$;
          Enddo;

          // Amadeus/Limelight
          Setll Rel_Itmnum RMLPROD2;
          Dow 1 = 1;
             Reade Rel_Itmnum RMLPROD2;
             If %Eof(RMLPROD2);
                Leave;
             Endif;

             Amd_Itmnum = Rel_RelItmnum;
             Write RMPPROD$;

          Enddo;

          // This logical points to RBLPROD2 in AP_Roy
          Setll Rel_Itmnum RMLPROD2AP;
          Dow 1 = 1;
             Reade Rel_Itmnum RMLPROD2AP;
             If %Eof(RMLPROD2AP);
                Leave;
             Endif;

             Ad2_Itmnum = Rel_RelItmnum;
             Write RMPPRODAP;

          Enddo;

          // Applause
          Setll Rel_Itmnum RBLPROD2;
          Dow 1 = 1;
             Reade Rel_Itmnum RBLPROD2;
             If %Eof(RBLPROD2);
                Leave;
             Endif;

             Apl_Itmnum = Rel_RelItmnum;
             Write RBPPROD$;

          Enddo;

          // High Discount update
          Setll Rel_Itmnum ROPHIGHDIS;
          Dow 1 = 1;
             Reade Rel_Itmnum ROPHIGHDIS;
             If %Eof(ROPHIGHDIS);
                Leave;
             Endif;

             Dis_Itmnum = Rel_RelItmnum;
             Write RO$HIGHDIS;


          Enddo;

       Endsr;

       //***********************************************************************
       //* Update IVPITEMS **
       //********************
       Begsr Sbr_Update_IVPITEMS;

          Chain Rel_RelItmnum IVPITEMS;
          If %Found(IVPITEMS);
             PrmItmnum  = Rel_RelItmnum;
             Mnt_Itmnum = Itm_Itmnum;

             // Do not update items for Bock & Pavane publishers
             If SavPblshrNum <> 308
               and SavPblshrNum <> 604
               and SavPblshrNum <> 800;

                If Itm_Series <> 'DGTSHT';

                   If SavCntrtp <> Itm_Cntrtp;

                      // Digital item wasn't added to the kit file,
                      // update digital with HG values.
                      If WrkDgtKit = 'N';
                         Mnt_Before  = Itm_Cntrtp;
                         Mnt_After   = SavCntrtp;
                         Mnt_Fldnam  = 'CNTRTP';
                         Mnt_Comment = 'Change made by RLRDIGUPD';
                         Write IVPMAIN$;

                         PrmOldCnt  = Itm_Cntrtp;
                         PrmNewCnt  = SavCntrtp;
                         Itm_Cntrtp = SavCntrtp;
                      Else;

                         // Digital item is in the kit file,
                         // CNTRTP = 'S'
                         If WrkDgtKit = 'Y'
                           and Itm_Cntrtp <> 'S';
                            Mnt_Before  = Itm_Cntrtp;
                            Mnt_After   = 'S';
                            Mnt_Fldnam  = 'CNTRTP';
                            Mnt_Comment = 'Change made by RLRDIGUPD';
                            Write IVPMAIN$;

                            PrmOldCnt  = Itm_Cntrtp;
                            PrmNewCnt  = 'S';
                            Itm_Cntrtp = 'S';

                         Endif;
                      Endif;
                   Endif;
                Endif;

                PrmOldCpr  = *Zero;
                PrmNewCpr  = *Zero;
                PrmOldPrt  = *Blanks;
                PrmNewPrt  = *Blanks;

                If Itm_Cntrtp <> 'M' and Itm_Series <> 'DGTSHT';

                   If SavCexcpt <> Itm_Cexcpt;

                      // Digital item wasn't added to the kit file,
                      // update digital with HG values.
                      If WrkDgtKit = 'N';
                         Mnt_Before  = Itm_Cexcpt;
                         Mnt_After   = SavCexcpt;
                         Mnt_Fldnam  = 'CEXCPT';
                         Mnt_Comment = 'Change made by RLRDIGUPD';
                         Write IVPMAIN$;
                      Else;

                         // Digital item is in the kit file,
                         // CEXCPT = 'O'
                         If WrkDgtKit = 'Y'
                           and Itm_Cexcpt <> 'O';
                            Mnt_Before  = Itm_Cexcpt;
                            Mnt_After   = 'O';
                            Mnt_Fldnam  = 'CEXCPT';
                            Mnt_Comment = 'Change made by RLRDIGUPD';
                            Write IVPMAIN$;

                            PrmOldCnt  = Itm_Cexcpt;
                            PrmNewCnt  = 'O';
                            Itm_Cntrtp = 'O';

                         Endif;
                      Endif;
                   Endif;

                   If SavPrtrtp <> Itm_Prtrtp;
                      Mnt_Before  = Itm_Prtrtp;
                      Mnt_After   = SavPrtrtp;
                      Mnt_Fldnam  = 'PRTRTP';
                      Mnt_Comment = 'Change made by RLRDIGUPD';
                      Write IVPMAIN$;
                   Endif;

                   PrmOldPrt  = Itm_Prtrtp;
                   PrmNewPrt  = SavPrtrtp;
                   Itm_Cexcpt = SavCexcpt;
                   Itm_Prtrtp = SavPrtrtp;
                Endif;

                // Write to Maint history
                If SavRorefNum <> Itm_RorefNum;
                   Mnt_Before  = %Editc(Itm_RorefNum:'X');
                   Mnt_After   = %Editc(SavRorefNum:'X');
                   Mnt_Fldnam  = 'ROREFNUM';
                   Mnt_Comment = 'Change made by RLRDIGUPD';
                   Write IVPMAIN$;
                Endif;

                If SavPblshrNum <> Itm_PblshrNum;
                   Mnt_Before  = %Editc(Itm_PblshrNum:'X');
                   Mnt_After   = %Editc(SavPblshrNum:'X');
                   Mnt_Fldnam  = 'PBLSHRNUM';
                   Mnt_Comment = 'Change made by RLRDIGUPD';
                   Write IVPMAIN$;
                Endif;

                If SavCprtun <> Itm_Cprtun;
                   Mnt_Before  = %Editc(Itm_Cprtun:'X');
                   Mnt_After   = %Editc(SavCprtun:'X');
                   Mnt_Fldnam  = 'CPRTUN';
                   Mnt_Comment = 'Change made by RLRDIGUPD';
                   Write IVPMAIN$;
                Endif;

                Itm_Cprtun    = SavCprtun;
                Itm_RorefNum  = SavRorefNum;
                Itm_PblshrNum = SavPblshrNum;
                If Itm_Series = 'DGTSHT';
                   Update IVPITEM$ %Fields( Itm_Cprtun
                                          : Itm_Rorefnum
                                          : Itm_Pblshrnum );
                Else;
                   Update IVPITEM$ %Fields( Itm_Cntrtp
                                          : Itm_Cexcpt
                                          : Itm_Prtrtp
                                          : Itm_Cprtun
                                          : Itm_Rorefnum
                                          : Itm_Pblshrnum );

                   Callp RLRCHGTYPE ( $Chgpm );
                Endif;

             Endif; // End of Publisher Exclusion Block

             Stp_ItmNum   = Rel_RelItmnum;
             Stp_DTEADDED = %Date();
             Write RL$AUTOSTP;

          Endif;

       Endsr;

       //***********************************************************************
       //* Write to Print File **
       //******************
       Begsr Sbr_Write_PrintFile;

          If (PrmCalled = 'M'
             and Rel_Mprinted = *Loval)
             or (PrmCalled = 'C'
             and Rel_Cprinted = *Loval);

             Brt_Itmnum = Rel_Itmnum;
             Brt_RelItmnum = Rel_RelItmnum;
             Brt_Sdesc     = Itm_Sdesc;
             Brt_Permot    = Itm_Permot;
             Brt_Cntrtp    = Itm_Cntrtp;
             Brt_Cexcpt    = Itm_Cexcpt;
             Brt_Prtrtp    = Itm_Prtrtp;
             Brt_Cprtun    = Itm_Cprtun;
             Brt_Rorefnum  = Itm_Rorefnum;

             Write RL$DIGRPRT;

             Select;
                When PrmCalled = 'M';
                   Rel_Mprinted = %Date();
                   Update IV$RELITM %Fields( Rel_Mprinted );
                When PrmCalled = 'C';
                   Rel_Cprinted = %Date();
                   Update IV$RELITM %Fields( Rel_Cprinted );
             Endsl;
          Endif;

       Endsr;

       //***********************************************************************
       //* Add R#DOMKIT **
       //***************************
       Begsr Sbr_Write_R#DOMKIT;

          // Old Kit System
          If Itm_Cexcpt = 'O';
             Setll Rel_Itmnum R#DOMKIT;
             Dow 1 = 1;
                Reade Rel_Itmnum R#DOMKIT;
                If %Eof(R#DOMKIT);
                   Leave;
                Endif;

                Kit_Kit#   = Rel_RelItmnum;
                Kit_Comp#  = Kit_Comp#;
                Kit_Compqt = 1;
                Write(E) B$KITFIL;
                WrkDgtKit = 'Y';
             Enddo;
          Else;
             Chain ( Rel_Itmnum : Rel_RelItmnum) DOMKIT1;
             If Not %Found(DOMKIT1);
                Kit_Kit#   = Rel_RelItmnum;
                Kit_Comp#  = Rel_Itmnum;
                Kit_Compqt = 1;
                Write B$KITFIL1;
                WrkDgtKit = 'Y';
             Endif;
          Endif;

       Endsr;

       //***********************************************************************
       //* Initialize *
       //**************
       Begsr Sbr_Setup;
          // Initialize maintenance fields
          Mnt_Maintwho  = SdsUser;
          Mnt_MaintYYYY = *Year;
          Mnt_Maintmm   = *Month;
          Mnt_Maintdd   = *Day;
          Mnt_Repcode   = 'N';

       Endsr;

