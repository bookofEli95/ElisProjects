     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
      //**********************************************************************
      // P1RBTCHUP
      // P1 - PCR Batch Upload Backend Processing
      //**********************************************************************

      // ******************************************************************
      // Program Information
      // ------------------------------------------------------------------
      // PCR Batch Upload Backend RPGLE Program
      // ******************************************************************

      // ******************************************************************
      // Program History
      // ------------------------------------------------------------------
      // Project   Date     Int Description
      // ------- -------- --- ---------------------------------------------
      // EFIFIX  08/18/26 EFI Create initial upload RPGLE program
      // EFIFIX  09/15/26 EFI Fix STG_ prefix trim and ROY_ field-name
      //                      collision; calculations in /free block
      // ******************************************************************

      //Input Files
     FPCRSTAGE  IF   E             DISK    EXTFILE('OBJECT/PCRSTAGE')
     F                                     EXTDESC('OBJECT/PCRSTAGE')
     F                                     PREFIX('STG_':3)
     FROLOWCTL1 IF   E           K DISK    EXTFILE('OBJECT/ROLOWCTL1')
     F                                     EXTDESC('OBJECT/ROLOWCTL1')
     F                                     PREFIX(CTL_)

      // Update / Add Files
     FPCPMAIN   UF A E           K DISK    EXTFILE('OBJECT/PCPMAIN')
     F                                     EXTDESC('OBJECT/PCPMAIN')
     FPCPROYLT  UF A E           K DISK    EXTFILE('OBJECT/PCPROYLT')
     F                                     EXTDESC('OBJECT/PCPROYLT')
     F                                     PREFIX(ROY_)
     FJOBFLE7   UF A E           K DISK    EXTFILE('OBJECT/JOBFLE7')
     F                                     EXTDESC('OBJECT/JOBFLE7')
     F                                     PREFIX(JF7_)
     FRERUN8    UF A E           K DISK    EXTFILE('OBJECT/RERUN8')
     F                                     EXTDESC('OBJECT/RERUN8')
     F                                     PREFIX(RR8_)
     FIVPORRITM UF A E           K DISK    EXTFILE('OBJECT/IVPORRITM')
     F                                     EXTDESC('OBJECT/IVPORRITM')
     F                                     PREFIX(ORR_)
     FIVPORRMNT UF A E           K DISK    EXTFILE('OBJECT/IVPORRMNT')
     F                                     EXTDESC('OBJECT/IVPORRMNT')
     F                                     PREFIX(ORM_)
     FIVPITEMS  UF A E           K DISK    EXTFILE('OBJECT/IVPITEMS')
     F                                     EXTDESC('OBJECT/IVPITEMS')
     F                                     PREFIX(ITM_)
     FPCPBKEVN  UF A E           K DISK    EXTFILE('OBJECT/PCPBKEVN')
     F                                     EXTDESC('OBJECT/PCPBKEVN')
     F                                     PREFIX(BKE_)
     FIVPITMCODEUF A E           K DISK    EXTFILE('OBJECT/IVPITMCODE')
     F                                     EXTDESC('OBJECT/IVPITMCODE')
     F                                     PREFIX(COD_)
     FW#JOBSCR  UF A E           K DISK    EXTFILE('OBJECT/W#JOBSCR')
     F                                     EXTDESC('OBJECT/W#JOBSCR')
     F                                     PREFIX(SCR_)

      // Output Files
     FROPSALES  O    E           K DISK    EXTFILE('OBJECT/ROPSALES')
     F                                     EXTDESC('OBJECT/ROPSALES')
     F                                     PREFIX(RSL_)
     FIVPMAINT  O    E           K DISK    EXTFILE('OBJECT/IVPMAINT')
     F                                     EXTDESC('OBJECT/IVPMAINT')
     F                                     PREFIX(MNT_)

      //***********************************************************************
      // Prototypes
      //***********************************************************************
     D P1RGETJOB       PR                  EXTPGM('OBJECT/P1RGETJOB')
     D  PrmJobnum7                    7A

     D IVRGETITMN      PR                  EXTPGM('OBJECT/IVRGETITMN')
     D  PrmNextItm                    8A
     D  PrmScorItm                    8A
     D  PrmError                      1A
     D  PrmScore                      1A
     D  PrmKit                        1A
     D  PrmBill                       1A
     D  PrmDivcat                     7A
     D  PrmBillItm                    8A

      /copy qcopysrc,upc#2
      /copy qcopysrc,pcrisbn
      /copy qcopysrc,ivraskwd
      /copy qcopysrc,ivrorrgetc
      /copy qcopysrc,p1r999s
      /copy qcopysrc,pcrrern

      //***********************************************************************
      // Data Structures & Variables
      //***********************************************************************
     D PCDINQRY      E DS           100    ExtName('OBJECT/PCDINQUIRY')
     D                                     DtaAra('OBJECT/PCDINQRY')
     D                                     Prefix(Pcd_)

     D SdsUser        SDS
     D                       254    263A

     D IVRASKWDDS      DS
     D  Prm$Itmnu              1      8  0
     D  PrmDelete              9      9A
     D  PrmReruna             10     10A
     D  Prm$Ldesc             11     97A
     D  PrmDivcat             98    104  0
     D  PrmRorefNum2         105    109  0

     D PrmJobNum7      S              7A
     D PrmNextItm      S              8A
     D PrmScorItm      S              8A
     D PrmError        S              1A
     D PrmScore        S              1A
     D PrmKit          S              1A
     D PrmBill         S              1A
     D WrkPrmDivCat    S              7A
     D PrmBillItm      S              8A

     D WrkDivCat       S              7S 0 Inz(0)
     D WrkDivCatChar   S             10A
     D WrkNewJob       S              7S 0 Inz(0)
     D WrkNewItm       S              8S 0 Inz(0)
     D WrkScoreItm     S              8S 0 Inz(0)
     D WrkPos          S              3S 0 Inz(0)
     D WrkDate         S               D
     D WrkMktCoord     S             10A    Inz(*Blanks)

     D WrkTmppr2       S              7S 4 Inz(0)
     D WrkTmpacm       S              9S 4 Inz(0)
     D WrkJvs01        S              9S 4 Inz(0)
     D WrkJvs02        S              9S 4 Inz(0)
     D WrkJvs03        S              9S 4 Inz(0)
     D WrkJvs04        S              9S 4 Inz(0)
     D WrkJvs05        S              9S 4 Inz(0)
     D WrkJv00         S             11S 4 Inz(0)
     D WrkJv01         S             11S 4 Inz(0)
     D Wrk$Admf        S              5S 2 Inz(0)
     D Wrk$Admfd       S              5S 4 Inz(0)
     D WrkAcrRate      S              9S 4 Inz(0)
     D WrkJvRate       S              7S 4 Inz(0)
     D WrkDupCount     S             10I 0 Inz(0)

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
      /free

         Read PCRSTAGE;
         Dow Not %Eof(PCRSTAGE);

            // 0. Skip blank/incomplete rows (e.g. trailing blank lines
            //    left over from a CSV import) before any job/item number
            //    gets generated for them.
            If STG_SDESC = *Blanks;
               Read PCRSTAGE;
               Iter;
            Endif;

            // 0b. Skip rows already uploaded previously - matched on
            //     PUBCODE, which is unique per title in PCPMAIN. This
            //     stops the same CSV (or an accidental re-run) from
            //     minting a second set of job/item numbers for titles
            //     that already exist.
            WrkDupCount = 0;
            If STG_PUBCODE <> *Blanks;
               Exec SQL
                  SELECT COUNT(*) INTO :WrkDupCount
                    FROM PCPMAIN
                   WHERE PUBCODE = :STG_PUBCODE;
               If WrkDupCount > 0;
                  Read PCRSTAGE;
                  Iter;
               Endif;
            Endif;

            // 1. Extract Numeric Divcat from Staging Column
            WrkPos = %Scan(' ' : STG_CAT);
            If WrkPos > 0;
               WrkDivCatChar = %Trim(%Subst(STG_CAT : 1 : WrkPos - 1));
               Monitor;
                  WrkDivCat = %Int(WrkDivCatChar);
               On-Error;
                  WrkDivCat = 0;
               Endmon;
            Else;
               Monitor;
                  WrkDivCat = %Int(STG_CAT);
               On-Error;
                  WrkDivCat = 0;
               Endmon;
            Endif;

            // 2. Generate New Job Number
            PrmJobnum7 = *Blanks;
            Callp P1RGETJOB(PrmJobnum7);
            WrkNewJob = %Int(PrmJobnum7);

            // 3. Generate New Item Number
            PrmNextItm = *Blanks;
            PrmScorItm = *Blanks;
            PrmError   = *Blanks;
            PrmScore   = STG_SCSLT;
            PrmKit     = STG_KIT;
            PrmBill    = 'N';
            WrkPrmDivCat = %Editc(WrkDivCat : 'X');
            PrmBillItm = *Blanks;
            Callp IVRGETITMN( PrmNextItm
                            : PrmScorItm
                            : PrmError
                            : PrmScore
                            : PrmKit
                            : PrmBill
                            : WrkPrmDivCat
                            : PrmBillItm );
            WrkNewItm = %Int(PrmNextItm);

            // 4. Data Area Tracking
            In *Lock PCDINQRY;
            Pcd_Itmnum  = WrkNewItm;
            Pcd_Jobnum7 = WrkNewJob;
            Pcd_DivCat  = WrkDivCat;
            Pcd_ExpCd   = 'GEN';
            Pcd_NewAdd  = 'A';
            Out PCDINQRY;

            // 5. Map and Write to PCR Master (PCPMAIN)
            Clear PCPMAIN$;
            @Itm        = WrkNewItm;
            Jobnum7     = WrkNewJob;
            Divcat      = WrkDivcat;
            LDesc1      = %Subst(STG_TITLE : 1 : 29);
            LDesc2      = %Subst(STG_TITLE : 30 : 29);
            LDesc3      = %Subst(STG_TITLE : 59 : 29);
            Sdesc       = STG_SDESC;
            Price72     = STG_PRICE;
            Price112    = STG_PRICE;
            RunQty      = STG_RUNQTY;
            Series      = STG_SERIES;
            Cntrtp      = STG_CNTRTP;
            Medium      = STG_MEDIUM;
            CtryOrigin  = STG_CTRY;
            Voicng      = STG_VOICNG;
            MaxDis      = STG_MAXDIS;
            Rorefnum    = STG_ROREF;
            Pblshrnum   = STG_PUBLSHR;
            Artist      = STG_ARTIST;
            Arrngr      = STG_ARRNGR;
            Author      = STG_AUTHOR;
            PublCode    = STG_PUBLCOD;
            PubCode     = STG_PUBCODE;
            Catlog      = STG_CATLOG;
            @Catl1      = STG_CATL1;
            @Catl2      = STG_CATL2;
            MusKey      = STG_MUSKEY;
            @Purch      = STG_PURCH;
            @Kit        = STG_KIT;
            @Rush       = STG_RUSH;
            @Outs       = STG_OUTS;
            @Splt       = STG_SPLT;
            Sellbl      = STG_SELLBL;
            @UPC        = STG_UPC;
            @EAN#       = STG_EAN;
            @ISBN       = STG_ISBN;
            @NI         = STG_NI;
            NICat1      = STG_NICAT1;
            NICat2      = STG_NICAT2;
            NICat3      = STG_NICAT3;
            @SCSLT      = STG_SCSLT;
            @SCQty      = STG_SCQTY;
            @SCPRC72    = STG_SCPRC;
            @SCPRC112   = STG_SCPRC;
            Clinic#     = STG_CLINIC;

            If STG_ESTCMP <> *Blanks;
               Monitor;
                  WrkDate = %Date(STG_ESTCMP : *ISO);
                  EstCmpMM   = %Subdt(WrkDate : *M);
                  EstCmpDD   = %Subdt(WrkDate : *D);
                  EstCmpYYYY = %Subdt(WrkDate : *Y);
                  EstCmpDt   = WrkDate;
               On-Error;
                  EstCmpMM   = 0;
                  EstCmpDD   = 0;
                  EstCmpYYYY = 0;
                  EstCmpDt   = *Loval;
               Endmon;
            Else;
               EstCmpMM   = 0;
               EstCmpDD   = 0;
               EstCmpYYYY = 0;
               EstCmpDt   = *Loval;
            Endif;

            StartMM     = %Subdt(%Date() : *M);
            StartDD     = %Subdt(%Date() : *D);
            StartYYYY   = %Subdt(%Date() : *Y);
            StartDt     = %Date();
            Orign       = SdsUser;
            @Send       = 'N';
            BusAff      = 'N';
            @Wino       = ' ';
            Write PCPMAIN$;

            // 6. Calculate Accrual Rate & Write to PCPROYLT
            Exsr Sbr_Update_Roy_Accrual_Rate;
            Clear PCPROYL$;
            ROY_@Itm     = WrkNewItm;
            ROY_Jobnum7  = WrkNewJob;
            ROY_CODEPR72 = STG_PRICE;
            ROY_AcrRate  = WrkAcrRate;
            ROY_Jvrte    = WrkJvRate;
            ROY_SNGRTE   = STG_SNGRTE;
            ROY_SNGADV   = STG_SNGADV;
            ROY_SNFPAY   = STG_SNFPAY;
            ROY_CMPRTE   = STG_CMPRTE;
            ROY_CMPADV   = STG_CMPADV;
            ROY_CMPPAY   = STG_CMPPAY;
            ROY_ARRRTE   = STG_ARRRTE;
            ROY_ARRADV   = STG_ARRADV;
            ROY_ARRPAY   = STG_ARRPAY;
            ROY_IMGRTE   = STG_IMGRTE;
            ROY_IMGADV   = STG_IMGADV;
            ROY_IMGPAY   = STG_IMGPAY;
            ROY_OTHRTE   = STG_OTHRTE;
            ROY_OTHADV   = STG_OTHADV;
            ROY_OTHPAY   = STG_OTHPAY;
            ROY_AGCRTE   = STG_AGCRTE;
            ROY_AGCADV   = STG_AGCADV;
            ROY_AGCPAY   = STG_AGCPAY;
            ROY_MECFEE   = STG_MECFEE;
            ROY_MECADV   = STG_MECADV;
            ROY_MECPAY   = STG_MECPAY;
            ROY_OTHFEE   = STG_OTHFEE;
            ROY_OTHFAD   = STG_OTHFAD;
            ROY_OTHFPY   = STG_OTHFPY;
            ROY_ARRFEE   = STG_ARRFEE;
            ROY_ARRFPY   = STG_ARRFPY;
            ROY_JVPC     = STG_JVPC;
            ROY_JVADV    = STG_JVADV;
            ROY_JVPAY    = STG_JVPAY;
            Write PCPROYL$;

            // 7. Write Production Job Master (JOBFLE7)
            Clear WW$JOBAC;
            Jf7_Jobnum7    = WrkNewJob;
            Jf7_Fininv     = %Editc(WrkNewItm : 'X');
            Jf7_Itmnumnew  = WrkNewItm;
            Jf7_Jobdes     = %Trim(STG_SERIES) + ' ' + STG_SDESC;
            Jf7_RunQty     = STG_RUNQTY;
            Jf7_RunId      = 'NW';
            Jf7_StartMM    = %Subdt(%Date() : *M);
            Jf7_StartDD    = %Subdt(%Date() : *D);
            Jf7_StartYY    = %Subdt(%Date() : *Y);
            Jf7_CompleteMM = 0;
            Jf7_CompleteDD = 0;
            Jf7_CompleteYY = 0;
            Jf7_TrnQty     = 0;
            Jf7_InForm     = *Blanks;
            Jf7_CloseMM    = 0;
            Jf7_CloseDD    = 0;
            Jf7_CloseYY    = 0;
            Jf7_FinQty     = 0;
            Jf7_UFEO       = ' ';
            Jf7_Close      = ' ';
            Write WW$JOBAC;

            // 8. Write Production Rerun Master (RERUN8)
            Clear B$RERUN;
            Rr8_ITEM#      = WrkNewItm;
            Rr8_Jobnum7    = WrkNewJob;
            Rr8_RunQty     = STG_RUNQTY;
            Rr8_Delete     = *Blanks;
            Rr8_FinishMM   = EstCmpMM;
            Rr8_FinishDD   = EstCmpDD;
            Rr8_FinishYYYY = EstCmpYYYY;
            Rr8_Coment     = *Blanks;
            Rr8_Compdt     = (%Subdt(%Date():*M) * 100) + %Subdt(%Date():*D);
            Rr8_Photdt     = 0;
            Rr8_Presdt     = 0;
            Rr8_Binddt     = 0;
            Rr8_Xtrcmt     = *Blanks;
            Rr8_Bochkd     = *Blanks;
            Rr8_Prepdt     = 0;
            Rr8_Scandt     = 0;
            Rr8_Prntdt     = 0;
            Rr8_DgBinddt   = 0;
            Write B$RERUN;
            Callp PCRRERN(Rr8_ITEM#);

            // 9. Write Online Rerun Queue (IVPORRITM & IVPORRMNT)
            Clear IV$ORRITM;
            Orr_Itmnum   = WrkNewItm;
            Orr_MinQtyDt = %Date();
            Orr_Note1    = 'PCR created job (not Online Rerun)';
            Orr_RerunSts = 'J';
            Orr_Hold     = *Blanks;
            Orr_Jobnum7  = WrkNewJob;
            Orr_Jobdate  = %Date();
            Orr_Jobuser  = SdsUser;
            Write IV$ORRITM;

            Clear IV$ORRMNT;
            Orm_Itmnum   = WrkNewItm;
            Orm_Action   = 'Job created';
            Orm_Desc     = 'Job# ' + %Trim(%Editc(WrkNewJob : 'X'));
            Orm_MaintTs  = %Timestamp();
            Orm_MaintWho = SdsUser;
            Write IV$ORRMNT;

            // 10. Write Inventory Item Master (IVPITEMS)
            Clear IVPITEM$;
            Itm_Itmnum     = WrkNewItm;
            Itm_Divcat     = WrkDivCat;
            Itm_Series     = STG_SERIES;
            Itm_Sdesc      = %Trim(STG_SERIES) + ' ' + STG_SDESC;
            Itm_Ldesc      = STG_TITLE;
            Itm_Arrngr     = STG_ARRNGR;
            Itm_Artist     = STG_ARTIST;
            Itm_Author     = STG_AUTHOR;
            Itm_Catlog     = STG_CATLOG;
            Itm_Medium     = STG_MEDIUM;
            Itm_PblshrNum  = STG_PUBLSHR;
            Itm_RorefNum   = STG_ROREF;
            Itm_Voicng     = STG_VOICNG;
            Itm_Pubcode    = STG_PUBCODE;
            Itm_Maxdis     = STG_MAXDIS;
            If STG_MAXDIS = 9.999;
               Itm_Net = 'Y';
            Else;
               Itm_Net = 'N';
            Endif;
            Itm_Price72    = STG_PRICE;
            Itm_Price112   = STG_PRICE;
            If STG_KIT = 'Y';
               Itm_Kit = 'K';
            Else;
               Itm_Kit = ' ';
            Endif;

            WrkMktCoord = *Blanks;
            Callp IVRORRGETC(%Editc(WrkNewItm : 'X') : WrkMktCoord);
            Select;
            When STG_MEDIUM = 'SITLC';
               Itm_Permot = *Blanks;
            When STG_SERIES = 'SI';
               Itm_Permot = 'S';
            When WrkMktCoord = 'IMPORT';
               Itm_Permot = 'B';
            Other;
               Itm_Permot = 'Y';
            Endsl;

            Eval(H) Itm_Minqty = STG_RUNQTY / 3;
            If Itm_Minqty = 0;
               Itm_Minqty = 1;
            Endif;

            If STG_SELLBL = 'S' or STG_MEDIUM = 'DLD' or STG_MEDIUM = 'VIDDL';
               Itm_MinQtyUsg = 'I';
            Endif;

            Itm_Stdtyp     = 'N';
            Itm_Sellbl     = STG_SELLBL;
            Itm_Cntrtp     = STG_CNTRTP;
            Itm_Muskey     = STG_MUSKEY;
            Itm_Publcode   = STG_PUBLCOD;
            Itm_CtryOrigin = STG_CTRY;
            Itm_NIYN       = STG_NI;
            Itm_Nicat1     = STG_NICAT1;
            Itm_Nicat2     = STG_NICAT2;
            Itm_Nicat3     = STG_NICAT3;
            Itm_Cprtun     = 1;
            Itm_Reruna     = ' ';
            Itm_Cexcpt     = ' ';
            Itm_RoyAcrRat1 = WrkAcrRate;
            Write IVPITEM$;

            // 11. Barcodes, Alpha Search, Audit & Sales
            If STG_UPC = 'Y';
               Itm_Upc#   = 0;
               Itm_Check# = 0;
               Callp UPC#2(Itm_Itmnum : Itm_Upc# : Itm_Check#);
            Endif;

            If STG_ISBN = 'Y';
               Callp PCRISBN();
            Endif;

            Callp P1R999S();

            Clear ROPSALE$;
            Rsl_Itmnum = WrkNewItm;
            Write ROPSALE$;

            Clear IVPMAIN$;
            Mnt_Itmnum    = WrkNewItm;
            Mnt_Fldnam    = 'ADDED';
            Mnt_MaintYYYY = %Subdt(%Date() : *Y);
            Mnt_Maintmm   = %Subdt(%Date() : *M);
            Mnt_Maintdd   = %Subdt(%Date() : *D);
            Mnt_Maintwho  = SdsUser;
            Mnt_Before    = '***** ITEM ADDED ************';
            Mnt_After     = '***** ITEM ADDED ************';
            Mnt_Repcode   = 'N';
            Mnt_Comment   = *Blanks;
            Write IVPMAIN$;

            Prm$Itmnu     = WrkNewItm;
            PrmDelete     = ' ';
            PrmReruna     = ' ';
            Prm$Ldesc     = STG_TITLE;
            PrmDivcat     = WrkDivCat;
            PrmRorefNum2  = STG_ROREF;
            Callp IVRASKWD(IVRASKWDDS);

            // 12. Write PCR Breakeven Master (PCPBKEVN)
            Clear PCPBKEV$;
            Bke_@Itm     = WrkNewItm;
            Bke_Jobnum7  = WrkNewJob;
            Bke_BKE00172 = STG_PRICE;
            Select;
            When STG_MAXDIS = 0;
               Bke_BKE002 = 0.47;
            When STG_MAXDIS = 9.999;
               Bke_BKE002 = 1.0;
            Other;
               Bke_BKE002 = 1 - STG_MAXDIS;
            Endsl;
            Bke_BKE00572 = 0;
            Bke_BKE006   = WrkAcrRate;
            Bke_BKE008   = 0;
            Bke_BKE014   = 0;
            Write PCPBKEV$;

            // 13. Conditional: Purchased Product Flag (IVPITMCODE)
            If STG_PURCH = 'Y';
               Cod_Itmnum  = WrkNewItm;
               Cod_ItmCode = 'PUR';
               Write IV$ITMCODE;
            Endif;

            // 14. Conditional: Score Item & Slot (W#JOBSCR & IVPITEMS)
            If STG_SCSLT = 'Y' and PrmScorItm <> *Blanks and %Int(PrmScorItm)
             <> 0;
               WrkScoreItm = %Int(PrmScorItm);
               Scr_Jobnum7 = WrkNewJob;
               Scr_Scrnum  = WrkScoreItm;
               Scr_Scrqty  = STG_SCQTY;
               Write W$JOBSCR;

               Clear IVPITEM$;
               Itm_Itmnum     = WrkScoreItm;
               Itm_Divcat     = WrkDivCat;
               Itm_Series     = STG_SERIES;
               Itm_Voicng     = 'SCORE';
               Itm_Price72    = STG_SCPRC;
               Itm_Price112   = STG_SCPRC;
               Itm_Ldesc      = %TrimR(STG_TITLE) + ' FULL SCORE';
               Itm_Sdesc      = %TrimR(STG_SDESC) + ' SC';
               Itm_Arrngr     = STG_ARRNGR;
               Itm_Artist     = STG_ARTIST;
               Itm_Author     = STG_AUTHOR;
               Itm_Catlog     = STG_CATLOG;
               Itm_Medium     = STG_MEDIUM;
               Itm_PblshrNum  = STG_PUBLSHR;
               Itm_RorefNum   = STG_ROREF;
               Itm_Pubcode    = STG_PUBCODE;
               Itm_Maxdis     = STG_MAXDIS;
               If STG_MAXDIS = 9.999;
                  Itm_Net = 'Y';
               Else;
                  Itm_Net = 'N';
               Endif;
               Itm_Kit        = ' ';
               Eval(H) Itm_Minqty = STG_SCQTY / 3;
               If Itm_Minqty = 0;
                  Itm_Minqty = 1;
               Endif;
               Itm_Stdtyp     = 'N';
               Itm_Cntrtp     = 'S';
               Itm_Cexcpt     = 'Z';
               Itm_NIYN       = 'N';
               Itm_Reruna     = ' ';
               Itm_Cprtun     = 1;
               Itm_Sellbl     = STG_SELLBL;
               Itm_Muskey     = STG_MUSKEY;
               Itm_Publcode   = STG_PUBLCOD;
               Itm_CtryOrigin = STG_CTRY;
               Write IVPITEM$;

               If STG_UPC = 'Y';
                  Itm_Upc#   = 0;
                  Itm_Check# = 0;
                  Callp UPC#2(Itm_Itmnum : Itm_Upc# : Itm_Check#);
               Endif;

               Clear ROPSALE$;
               Rsl_Itmnum = WrkScoreItm;
               Write ROPSALE$;

               Clear IVPMAIN$;
               Mnt_Itmnum    = WrkScoreItm;
               Mnt_Fldnam    = 'ADDED';
               Mnt_MaintYYYY = %Subdt(%Date() : *Y);
               Mnt_Maintmm   = %Subdt(%Date() : *M);
               Mnt_Maintdd   = %Subdt(%Date() : *D);
               Mnt_Maintwho  = SdsUser;
               Mnt_Before    = '***** ITEM ADDED ************';
               Mnt_After     = '***** ITEM ADDED ************';
               Mnt_Repcode   = 'N';
               Mnt_Comment   = *Blanks;
               Write IVPMAIN$;

               Prm$Itmnu     = WrkScoreItm;
               PrmDelete     = ' ';
               PrmReruna     = ' ';
               Prm$Ldesc     = Itm_Ldesc;
               PrmDivcat     = WrkDivCat;
               PrmRorefNum2  = STG_ROREF;
               Callp IVRASKWD(IVRASKWDDS);
            Endif;

            // Advance loop to next row
            Read PCRSTAGE;
         Enddo;

         DSPLY 'Batch upload processed successfully.';
         *InLr = *On;

      /end-free

      //***********************************************************************
      //* Subroutine: Calculate Total Royalty Accrual Rate
      //***********************************************************************
      /free
         Begsr Sbr_Update_Roy_Accrual_Rate;

            Chain (STG_ROREF) ROLOWCTL1;
            If Not %Found(ROLOWCTL1);
               Ctl_AdmFee = 0;
            Endif;

            If STG_PRICE <> 0;
               WrkTmppr2 = STG_PRICE / 100;
            Else;
               WrkTmppr2 = 0;
            Endif;

            WrkTmpacm   = STG_SNGRTE * WrkTmppr2;
            WrkJvs01    = WrkTmpacm;
            WrkAcrRate  = WrkTmpacm;

            WrkTmpacm   = STG_CMPRTE * WrkTmppr2;
            WrkJvs02    = WrkTmpacm;
            WrkAcrRate += WrkTmpacm;

            WrkTmpacm   = STG_ARRRTE * WrkTmppr2;
            WrkJvs03    = WrkTmpacm;
            WrkAcrRate += WrkTmpacm;

            WrkTmpacm   = STG_IMGRTE * WrkTmppr2;
            WrkJvs04    = WrkTmpacm;
            WrkAcrRate += WrkTmpacm;

            WrkTmpacm   = STG_OTHRTE * WrkTmppr2;
            WrkJvs05    = WrkTmpacm;
            WrkAcrRate += WrkTmpacm;

            WrkJvRate = 0;
            If STG_JVPC <> 0;
               WrkJv00   = STG_PRICE * 0.50;
               Wrk$Admf  = 100.0 - Ctl_AdmFee;
               Wrk$Admfd = Wrk$Admf / 100;
               WrkJv01   = (WrkJv00 * Wrk$Admfd)
                         - WrkJvs02 - WrkJvs03 - WrkJvs04 - WrkJvs05;
               If STG_ROREF <> 726;
                  WrkJv01 = WrkJv01 - WrkJvs01 - STG_MECFEE;
               Endif;
               WrkJv00   = STG_JVPC * 0.01;
               WrkTmpacm = WrkJv00 * WrkJv01;
               If WrkTmppr2 <> 0;
                  Eval(H) WrkJvRate = WrkTmpacm / WrkTmppr2;
               Endif;
               WrkAcrRate += WrkTmpacm;
            Endif;

            // Agency is 50%
            If STG_AGCRTE <> 0;
               Eval(H) WrkTmpacm = STG_AGCRTE * WrkTmppr2 * 0.50;
               WrkAcrRate += WrkTmpacm;
            Endif;

            WrkAcrRate += STG_MECFEE + STG_OTHFEE;

         Endsr;
      /end-free
