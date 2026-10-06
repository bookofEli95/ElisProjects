     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLREBKADPR
       // RL: Update eBooks in royalty files
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Add Ebooks to selected files.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // MISC3   04/12/16 SRK Remove /Free - /End-Free
       // MISC3   08/04/15 SMM Code review errors
       // H2495   10/12/12 SMM Fix the Standards error "Prototype for Program Ne
       //                      eded"
       // 1787   007/19/12DRS  ew
       //***********************************************************************

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
