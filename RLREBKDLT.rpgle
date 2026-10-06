     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLREBKDLT
       // RL: Update eBooks in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Delete Ebooks from selected files. The items will be added back in RLREBKUPD
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H30629  12/02/22 TAK Data not being copied over for Ebooks - Add TOC r
       //                      ecords for the digital item.
       // H30629  11/16/22 TAK Data not being copied over for Ebooks - Add matri
       //                      x override copy to all programs that create digit
       //                      al items from a hardgood.
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // MISC3   08/04/15 SRK Copy Source Not Needed for program
       // H3696   07/22/14 KCS Check the calculation of the accrual rates for Eb
       //                      ooks.  Looks like theprogram is changing the rate
       //                      s to 0; which, is incorrect.  Need tofix the  pro
       //                      gram and fix the accrual rates
       // I28732  09/05/12 SRK [DP] Source Management Phase III - Program Name i
       //                      s not Correct
       // H2081   08/10/12 DRS Retain Roref# 876 for eBook items 314900 and 3183
       //                      85. Do not copy from hardgood.
       // 1787   007/19/12DRS  ew
       //***********************************************************************

       // Input Files
     FIVPEPUBITMIF A E           K DISK    Prefix(Epb_)

       // Update Files
     FIVLPROD2  UF   E           K DISK    Prefix(Hal_)
     FIVLPROD2AMUF   E           K DISK    Prefix(Am2_)
     F                                     Rename(RLPPROD$:RLPPRODAM)
     FIVLPROD2APUF   E           K DISK    Prefix(Ap2_)
     F                                     Rename(RLPPROD$:RLPPRODAP)
     FIVLPROD2ATUF   E           K DISK    Prefix(At2_)
     F                                     Rename(RLPPROD$:RLPPRODAT)
     FIVLPROD2CLUF   E           K DISK    Prefix(Cl2_)
     F                                     Rename(RLPPROD$:RLPPRODCL)
     FIVLPROD2TMUF   E           K DISK    Prefix(Tm2_)
     F                                     Rename(RLPPROD$:RLPPRODTM)
     FIVLPROD2WLUF   E           K DISK    Prefix(Wl2_)
     F                                     Rename(RLPPROD$:RLPPRODWL)
     FIVPMSTOV  UF   E           K DISK    Prefix(Mst_)
     FIVLMSTOVCLUF   E           K DISK    Prefix(Mcl_)
     F                                     Rename(IVPMSTO$:IVPMSTOCL)
     FIVLMSTOVTMUF   E           K DISK    Prefix(Mtm_)
     F                                     Rename(IVPMSTO$:IVPMSTOTM)
     FIVLMSTOVWLUF   E           K DISK    Prefix(Mwl_)
     F                                     Rename(IVPMSTO$:IVPMSTOWL)
     FGSROY1    UF   E           K DISK    Prefix(Gsr_)
     FRBLPROD2  UF   E           K DISK    Prefix(Apl_)
     FRMLPROD2  UF   E           K DISK    Prefix(Apd_)
     FRMLPROD2APUF   E           K DISK    Prefix(Ad2_)
     F                                     Rename(RMPPROD$:RMPPRODAP)
     FROPHIGHDISUF   E           K DISK    Prefix(Dis_)
     FR#DOMKIT  UF   E           K DISK    Prefix(Kit_)

     FRLLMTXO4  UF   E           K DISK    Prefix(Hal_)
     FRLLMTXOVAMUF   E           K DISK    Prefix(Am2_)
     F                                     Rename(RLPMTXO$:RL$MTXOAM)
     FRLLMTXOVAPUF   E           K DISK    Prefix(Ap2_)
     F                                     Rename(RLPMTXO$:RL$MTXOAP)
     FRLLMTXOVATUF   E           K DISK    Prefix(At2_)
     F                                     Rename(RLPMTXO$:RL$MTXOAT)
     FRLLMTXOVCLUF   E           K DISK    Prefix(Cl2_)
     F                                     Rename(RLPMTXO$:RL$MTXOCL)
     FRLLMTXOVTMUF   E           K DISK    Prefix(Tm2_)
     F                                     Rename(RLPMTXO$:RL$MTXOTM)
     FRLLMTXOVWLUF   E           K DISK    Prefix(Wl2_)
     F                                     Rename(RLPMTXO$:RL$MTXOWL)
     FIVPCNTNT  UF   E           K DISK    Prefix(Toc_)

       //***********************************************************************
       //* Prototypes *
       //**************

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************

       //***********************************************************************
       //* Main Line *
       //*************

       Setll *Loval IVPEPUBITM;
       Dow 1 = 1;
          Read IVPEPUBITM;
          If %Eof(IVPEPUBITM);
             Leave;
          Endif;

          // Do not change these 2 items per Karla
          If Epb_Itmnum = 314900
             or Epb_Itmnum = 318122
             or Epb_Itmnum = 108014
             or Epb_Itmnum = 318362
             or Epb_Itmnum = 319036
             or Epb_Itmnum = 333284
             or Epb_Itmnum = 318385;
                Iter;
          Endif;

          // Hal data
          Setll Epb_Itmnum IVLPROD2;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2;
             If %Eof(IVLPROD2);
                Leave;
             Endif;

             Delete RLPPROD$;
          Enddo;

          // This logical points to IVLPROD2 in AM_ROY
          Setll Epb_Itmnum IVLPROD2AM;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2AM;
             If %Eof(IVLPROD2AM);
                Leave;
             Endif;

             Delete RLPPRODAM;
          Enddo;

          // This logical points to IVLPROD2 in AP_ROY
          Setll Epb_Itmnum IVLPROD2AP;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2AP;
             If %Eof(IVLPROD2AP);
                Leave;
             Endif;

             Delete RLPPRODAP;
          Enddo;

          // This logical points to IVLPROD2 in AT_ROY
          Setll Epb_Itmnum IVLPROD2AT;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2AT;
             If %Eof(IVLPROD2AT);
                Leave;
             Endif;

             Delete RLPPRODAT;
          Enddo;

          // This logical points to IVLPROD2 in CL_ROY
          Setll Epb_Itmnum IVLPROD2CL;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2CL;
             If %Eof(IVLPROD2CL);
                Leave;
             Endif;

             Delete RLPPRODCL;
          Enddo;

          // This logical points to IVLPROD2 in TM_ROY
          Setll Epb_Itmnum IVLPROD2TM;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2TM;
             If %Eof(IVLPROD2TM);
                Leave;
             Endif;

             Delete RLPPRODTM;
          Enddo;

          // This logical points to IVLPROD2 in WL_ROY
          Setll Epb_Itmnum IVLPROD2WL;
          Dow 1 = 1;
             Reade Epb_Itmnum IVLPROD2WL;
             If %Eof(IVLPROD2WL);
                Leave;
             Endif;

             Delete RLPPRODWL;
          Enddo;

          // Gheck to see if in Master override
          Chain Epb_Itmnum IVPMSTOV;
          If %Found(IVPMSTOV);
             Delete IVPMSTO$;
          Endif;

          // This logical points to IVPMSTOV in CL_ROY
          Chain Epb_Itmnum IVLMSTOVCL;
          If %Found(IVLMSTOVCL);
             Delete IVPMSTOCL;
          Endif;

          // This logical points to IVPMSTOV in TM_ROY
          Chain Epb_Itmnum IVLMSTOVTM;
          If %Found(IVLMSTOVTM);
             Delete IVPMSTOTM;
          Endif;

          // This logical points to IVPMSTOV in WL_ROY
          Chain Epb_Itmnum IVLMSTOVWL;
          If %Found(IVLMSTOVWL);
             Delete IVPMSTOWL;
          Endif;

          // Gheck to see if G. Schirmer item
          Setll Epb_Itmnum GSROY1;
          Dow 1 = 1;
             Reade Epb_Itmnum GSROY1;
             If %Eof(GSROY1);
                Leave;
             Endif;

             Delete GSROY$;
          Enddo;

          // Amadeus/Limelight
          Setll Epb_Itmnum RMLPROD2;
          Dow 1 = 1;
             Reade Epb_Itmnum RMLPROD2;
             If %Eof(RMLPROD2);
                Leave;
             Endif;
             Delete RMPPROD$;

          Enddo;

          // This logical points to RMLPROD2 in AP_ROY
          Setll Epb_Itmnum RMLPROD2AP;
          Dow 1 = 1;
             Reade Epb_Itmnum RMLPROD2AP;
             If %Eof(RMLPROD2AP);
                Leave;
             Endif;

             Delete RMPPRODAP;
          Enddo;

          // Applause
          Setll Epb_Itmnum RBLPROD2;
          Dow 1 = 1;
             Reade Epb_Itmnum RBLPROD2;
             If %Eof(RBLPROD2);
                Leave;
             Endif;
             Delete RBPPROD$;
          Enddo;

          // High Discount update
          Setll Epb_Itmnum ROPHIGHDIS;
          Dow 1 = 1;
             Reade Epb_Itmnum ROPHIGHDIS;
             If %Eof(ROPHIGHDIS);
                Leave;
             Endif;
             Delete RO$HIGHDIS;
          Enddo;

          // Old Kit System
          Setll Epb_Itmnum R#DOMKIT;
          Dow 1 = 1;
             Reade Epb_Itmnum R#DOMKIT;
             If %Eof(R#DOMKIT);
                Leave;
             Endif;

             Delete B$KITFIL;

          Enddo;

          // Matrix overrides
          // Hal data
          Setll Epb_Itmnum RLLMTXO4;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXO4;
             If %Eof(RLLMTXO4);
                Leave;
             Endif;
             Delete RLPMTXO$;
          Enddo;

          // This Logical points to RLPMTXOV in AM_Roy
          Setll Epb_Itmnum RLLMTXOVAM;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXOVAM;
             If %Eof(RLLMTXOVAM);
                Leave;
             Endif;
             Delete RL$MTXOAM;
          Enddo;

          // This Logical points to RLPMTXOV in AP_Roy
          Setll Epb_Itmnum RLLMTXOVAP;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXOVAP;
             If %Eof(RLLMTXOVAP);
                Leave;
             Endif;
             Delete RL$MTXOAP;
          Enddo;

          // This Logical points to RLPMTXOV in AT_Roy
          Setll Epb_Itmnum RLLMTXOVAT;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXOVAT;
             If %Eof(RLLMTXOVAT);
                Leave;
             Endif;
             Delete RL$MTXOAT;
          Enddo;

          // This Logical points to RLPMTXOV in CL_Roy
          Setll Epb_Itmnum RLLMTXOVCL;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXOVCL;
             If %Eof(RLLMTXOVCL);
                Leave;
             Endif;
             Delete RL$MTXOCL;
          Enddo;

          // This Logical points to RLPMTXOV in TM_Roy
          Setll Epb_Itmnum RLLMTXOVTM;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXOVTM;
             If %Eof(RLLMTXOVTM);
                Leave;
             Endif;
             Delete RL$MTXOTM;
          Enddo;

          // This Logical points to RLPMTXOV in WL_Roy
          Setll Epb_Itmnum RLLMTXOVWL;
          Dow 1 = 1;
             Reade Epb_Itmnum RLLMTXOVWL;
             If %Eof(RLLMTXOVWL);
                Leave;
             Endif;
             Delete RL$MTXOWL;
          Enddo;

          // Delete the table of contents
          Setll Epb_Itmnum IVPCNTNT;
          Dow 1 = 1;
             Reade Epb_Itmnum IVPCNTNT;
             If %Eof(IVPCNTNT);
                Leave;
             Endif;
             Delete IVPCNTN$;
          Enddo;

       Enddo;
       *Inlr = *On;
