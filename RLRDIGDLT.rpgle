     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLRDIGDLT
       // RL: Update DLD in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Delete DLD from selected files. The items will be added back in RLRDIGUPD
       //
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // FIX     08/03/15 DRS Copy Source Not Needed for Progam
       // H2078   10/15/12 DRS fix delete
       // 2078   10/09/12 DRS  ew
       //***********************************************************************

       // Input Files
     FIVPRELITM IF   E           K DISK    Prefix(Dig_)

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

       //***********************************************************************
       //* Prototypes *
       //**************

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds

       // Work Variables
       //***********************************************************************
       //* Main Line *
       //*************

       Setll *Loval IVPRELITM;
       Dow 1 = 1;
          Read IVPRELITM;
          If %Eof(IVPRELITM);
             Leave;
          Endif;

          // Hal data
          Setll Dig_RelItmnum IVLPROD2;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2;
             If %Eof(IVLPROD2);
                Leave;
             Endif;

             Delete RLPPROD$;
          Enddo;

          // This logical points to IVLPROD2 in AM_ROY
          Setll Dig_RelItmnum IVLPROD2AM;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2AM;
             If %Eof(IVLPROD2AM);
                Leave;
             Endif;

             Delete RLPPRODAM;
          Enddo;

          // This logical points to IVLPROD2 in AP_ROY
          Setll Dig_RelItmnum IVLPROD2AP;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2AP;
             If %Eof(IVLPROD2AP);
                Leave;
             Endif;

             Delete RLPPRODAP;
          Enddo;

          // This logical points to IVLPROD2 in AT_ROY
          Setll Dig_RelItmnum IVLPROD2AT;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2AT;
             If %Eof(IVLPROD2AT);
                Leave;
             Endif;

             Delete RLPPRODAT;
          Enddo;

          // This logical points to IVLPROD2 in CL_ROY
          Setll Dig_RelItmnum IVLPROD2CL;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2CL;
             If %Eof(IVLPROD2CL);
                Leave;
             Endif;

             Delete RLPPRODCL;
          Enddo;

          // This logical points to IVLPROD2 in TM_ROY
          Setll Dig_RelItmnum IVLPROD2TM;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2TM;
             If %Eof(IVLPROD2TM);
                Leave;
             Endif;

             Delete RLPPRODTM;
          Enddo;

          // This logical points to IVLPROD2 in WL_ROY
          Setll Dig_RelItmnum IVLPROD2WL;
          Dow 1 = 1;
             Reade Dig_RelItmnum IVLPROD2WL;
             If %Eof(IVLPROD2WL);
                Leave;
             Endif;

             Delete RLPPRODWL;
          Enddo;

          // Gheck to see if in Master override
          Chain Dig_RelItmnum IVPMSTOV;
          If %Found(IVPMSTOV);
             Delete IVPMSTO$;
          Endif;

          // This logical points to IVPMSTOV in CL_ROY
          Chain Dig_RelItmnum IVLMSTOVCL;
          If %Found(IVLMSTOVCL);
             Delete IVPMSTOCL;
          Endif;

          // This logical points to IVPMSTOV in TM_ROY
          Chain Dig_RelItmnum IVLMSTOVTM;
          If %Found(IVLMSTOVTM);
             Delete IVPMSTOTM;
          Endif;

          // This logical points to IVPMSTOV in WL_ROY
          Chain Dig_RelItmnum IVLMSTOVWL;
          If %Found(IVLMSTOVWL);
             Delete IVPMSTOWL;
          Endif;

          // Gheck to see if G. Schirmer item
          Setll Dig_RelItmnum GSROY1;
          Dow 1 = 1;
             Reade Dig_RelItmnum GSROY1;
             If %Eof(GSROY1);
                Leave;
             Endif;

             Delete GSROY$;
          Enddo;


          // Amadeus/Limelight
          Setll Dig_RelItmnum RMLPROD2;
          Dow 1 = 1;
             Reade Dig_RelItmnum RMLPROD2;
             If %Eof(RMLPROD2);
                Leave;
             Endif;
             Delete RMPPROD$;

          Enddo;

          // This logical points to RMLPROD2 in AP_ROY
          Setll Dig_RelItmnum RMLPROD2AP;
          Dow 1 = 1;
             Reade Dig_RelItmnum RMLPROD2AP;
             If %Eof(RMLPROD2AP);
                Leave;
             Endif;

             Delete RMPPRODAP;
          Enddo;

          // Applause
          Setll Dig_RelItmnum RBLPROD2;
          Dow 1 = 1;
             Reade Dig_RelItmnum RBLPROD2;
             If %Eof(RBLPROD2);
                Leave;
             Endif;

             Delete RBPPROD$;

          Enddo;

          // High Discount update
          Setll Dig_RelItmnum ROPHIGHDIS;
          Dow 1 = 1;
             Reade Dig_RelItmnum ROPHIGHDIS;
             If %Eof(ROPHIGHDIS);
                Leave;
             Endif;

             Delete RO$HIGHDIS;

          Enddo;

          // Matrix overrides
          // Hal data
          Setll Dig_RelItmnum RLLMTXO4;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXO4;
             If %Eof(RLLMTXO4);
                Leave;
             Endif;
             Delete RLPMTXO$;
          Enddo;

          // This Logical points to RLPMTXOV in AM_Roy
          Setll Dig_RelItmnum RLLMTXOVAM;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXOVAM;
             If %Eof(RLLMTXOVAM);
                Leave;
             Endif;
             Delete RL$MTXOAM;
          Enddo;

          // This Logical points to RLPMTXOV in AP_Roy
          Setll Dig_RelItmnum RLLMTXOVAP;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXOVAP;
             If %Eof(RLLMTXOVAP);
                Leave;
             Endif;
             Delete RL$MTXOAP;
          Enddo;

          // This Logical points to RLPMTXOV in AT_Roy
          Setll Dig_RelItmnum RLLMTXOVAT;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXOVAT;
             If %Eof(RLLMTXOVAT);
                Leave;
             Endif;
             Delete RL$MTXOAT;
          Enddo;

          // This Logical points to RLPMTXOV in CL_Roy
          Setll Dig_RelItmnum RLLMTXOVCL;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXOVCL;
             If %Eof(RLLMTXOVCL);
                Leave;
             Endif;
             Delete RL$MTXOCL;
          Enddo;

          // This Logical points to RLPMTXOV in TM_Roy
          Setll Dig_RelItmnum RLLMTXOVTM;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXOVTM;
             If %Eof(RLLMTXOVTM);
                Leave;
             Endif;
             Delete RL$MTXOTM;
          Enddo;

          // This Logical points to RLPMTXOV in WL_Roy
          Setll Dig_RelItmnum RLLMTXOVWL;
          Dow 1 = 1;
             Reade Dig_RelItmnum RLLMTXOVWL;
             If %Eof(RLLMTXOVWL);
                Leave;
             Endif;
             Delete RL$MTXOWL;
          Enddo;

       Enddo;
       *Inlr = *On;
