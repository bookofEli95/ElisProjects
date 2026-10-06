     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLREBKADPR
       // RL: Update eBooks in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Add Ebooks to selected files.
       // A licence line whose contract has a digital rate in RLPDGTRAT gets
       // that rate instead of the print item's.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // HXXXXX  10/06/26 EFI Use the contract's digital rate from RLPDGTRAT
       //                      on copied licence lines when one is set up
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // MISC3   08/04/15 SMM Code review errors
       // H2495   10/12/12 SMM Fix the Standards error "Prototype for Program Ne
       //                      eded"
       // 1787   007/19/12DRS  ew
       //***********************************************************************

       // Input Files
     FRLLDGTRAT IF   E           K DISK    Prefix(Dgr_)

       // Update Files
     FIVLPROD2  IF A E           K DISK    Prefix(Hal_)
     FIVLPROD2AMIF A E           K DISK    Prefix(Am2_)
     F                                     Rename(RLPPROD$:RLPPRODAM)
     FIVLPROD2APIF A E           K DISK    Prefix(Ap2_)
     F                                     Rename(RLPPROD$:RLPPRODAP)
     FIVLPROD2ATIF A E           K DISK    Prefix(At2_)
     F                                     Rename(RLPPROD$:RLPPRODAT)
     FIVLPROD2CLIF A E           K DISK    Prefix(Cl2_)
     F                                     Rename(RLPPROD$:RLPPRODCL)
     FIVLPROD2TMIF A E           K DISK    Prefix(Tm2_)
     F                                     Rename(RLPPROD$:RLPPRODTM)
     FIVLPROD2WLIF A E           K DISK    Prefix(Wl2_)
     F                                     Rename(RLPPROD$:RLPPRODWL)

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,rlrebkadpr

       //***********************************************************************
       //* Entry Parameters *
       //********************
     D RLREBKADPR      PI
     D PrmOrgItmnum                   8A   const
     D PrmEbkItmnum                   8A   const

       //***********************************************************************
       //* Variables *
       //*************
      /copy qcopysrc,statusds

       // Work Variables
     D WrkOrgItmnum    S                   Like(Hal_Itmnum)
     D WrkEbkItmnum    S                   Like(Hal_Itmnum)

       //***********************************************************************
       //* Main Line *
       //*************

       Exsr Sbr_Setup;

       // Hal data
       Setll WrkOrgItmnum IVLPROD2;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2;
          If %Eof(IVLPROD2);
             Leave;
          Endif;
          Hal_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('HL' : Hal_Cntrid : Hal_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             Hal_Payrat = Dgr_Payrat;
             Hal_Payrtf = Dgr_Payrtf;
             Hal_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPROD$;
       Enddo;

       // This Logical points to IVLPROD2 in AM_Roy
       Setll WrkOrgItmnum IVLPROD2AM;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2AM;
          If %Eof(IVLPROD2AM);
             Leave;
          Endif;
          Am2_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('AM' : Am2_Cntrid : Am2_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             Am2_Payrat = Dgr_Payrat;
             Am2_Payrtf = Dgr_Payrtf;
             Am2_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPRODAM;
       Enddo;

       // This Logical points to IVLPROD2 in AP_Roy
       Setll WrkOrgItmnum IVLPROD2AP;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2AP;
          If %Eof(IVLPROD2AP);
             Leave;
          Endif;
          Ap2_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('AP' : Ap2_Cntrid : Ap2_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             Ap2_Payrat = Dgr_Payrat;
             Ap2_Payrtf = Dgr_Payrtf;
             Ap2_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPRODAP;
       Enddo;

       // This Logical points to IVLPROD2 in AT_Roy
       Setll WrkOrgItmnum IVLPROD2AT;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2AT;
          If %Eof(IVLPROD2AT);
             Leave;
          Endif;
          At2_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('AT' : At2_Cntrid : At2_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             At2_Payrat = Dgr_Payrat;
             At2_Payrtf = Dgr_Payrtf;
             At2_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPRODAT;
       Enddo;

       // This Logical points to IVLPROD2 in CL_Roy
       Setll WrkOrgItmnum IVLPROD2CL;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2CL;
          If %Eof(IVLPROD2CL);
             Leave;
          Endif;
          Cl2_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('CL' : Cl2_Cntrid : Cl2_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             Cl2_Payrat = Dgr_Payrat;
             Cl2_Payrtf = Dgr_Payrtf;
             Cl2_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPRODCL;
       Enddo;

       // This Logical points to IVLPROD2 in TM_Roy
       Setll WrkOrgItmnum IVLPROD2TM;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2TM;
          If %Eof(IVLPROD2TM);
             Leave;
          Endif;
          Tm2_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('TM' : Tm2_Cntrid : Tm2_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             Tm2_Payrat = Dgr_Payrat;
             Tm2_Payrtf = Dgr_Payrtf;
             Tm2_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPRODTM;
       Enddo;

       // This Logical points to IVLPROD2 in WL_Roy
       Setll WrkOrgItmnum IVLPROD2WL;
       Dow 1 = 1;
          Reade WrkOrgItmnum IVLPROD2WL;
          If %Eof(IVLPROD2WL);
             Leave;
          Endif;
          Wl2_Itmnum = WrkEbkItmnum;
          // Digital rate for this contract, if one is set up
          Chain ('WL' : Wl2_Cntrid : Wl2_Plcode) RLLDGTRAT;
          If %Found(RLLDGTRAT);
             Wl2_Payrat = Dgr_Payrat;
             Wl2_Payrtf = Dgr_Payrtf;
             Wl2_Dspcrt = Dgr_Dspcrt;
          Endif;
          Write RLPPRODWL;
       Enddo;

       *Inlr = *On;

       //*****************
       //* End Main Line *
       //***********************************************************************

       //***********************************************************************
       //* Setup **
       //**********
       Begsr Sbr_Setup;

       Monitor;
          WrkOrgItmnum = %Int(PrmOrgItmnum);
          On-error;
             WrkOrgItmnum = *Zero;
             *Inlr = *On;
       Endmon;

       Monitor;
          WrkEbkItmnum = %Int(PrmEbkItmnum);
          On-error;
             WrkEbkItmnum = *Zero;
             *Inlr = *On;
       Endmon;

       Endsr;
