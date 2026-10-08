     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLREBKADPR
       // RL: Update eBooks in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Add Ebooks to selected files.
       // A licence line whose payee (STMTID) has a digital rate in RLPDGTRAT
       // gets that rate instead of the print item's.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // HXXXXX  10/08/26 EFI Use the payee's digital rate from RLPDGTRAT on
       //                      copied licence lines when one is set up
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
     D WrkRoyLib       S              2A
     D WrkStmtid       S                   Like(Hal_Stmtid)
     D WrkCntrid       S                   Like(Hal_Cntrid)
     D WrkDgtFound     S               N

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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'HL';
          WrkStmtid = Hal_Stmtid;
          WrkCntrid = Hal_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'AM';
          WrkStmtid = Am2_Stmtid;
          WrkCntrid = Am2_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'AP';
          WrkStmtid = Ap2_Stmtid;
          WrkCntrid = Ap2_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'AT';
          WrkStmtid = At2_Stmtid;
          WrkCntrid = At2_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'CL';
          WrkStmtid = Cl2_Stmtid;
          WrkCntrid = Cl2_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'TM';
          WrkStmtid = Tm2_Stmtid;
          WrkCntrid = Tm2_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
          // Digital rate for this payee, if one is set up
          WrkRoyLib = 'WL';
          WrkStmtid = Wl2_Stmtid;
          WrkCntrid = Wl2_Cntrid;
          Exsr Sbr_Digital_Rate;
          If WrkDgtFound;
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
       //* Digital rate for a payee **
       //******************************
       // Looks up WrkRoyLib/WrkStmtid/WrkCntrid in RLPDGTRAT. A row for the
       // exact contract wins; otherwise a row with a blank contract applies
       // to every contract for that payee.
       Begsr Sbr_Digital_Rate;

          Chain (WrkRoyLib : WrkStmtid : WrkCntrid) RLLDGTRAT;
          If Not %Found(RLLDGTRAT);
             WrkCntrid = *Blanks;
             Chain (WrkRoyLib : WrkStmtid : WrkCntrid) RLLDGTRAT;
          Endif;
          WrkDgtFound = %Found(RLLDGTRAT);

       Endsr;

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
