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
      // EFIFIX  09/14/26 EFI Fix STG_ prefix trim, ROY_ field-name collision,
      //                      and convert calculations to fixed-form C-specs
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
     D PCDINQRY      E DS                  ExtName(PCDINQUIRY)
     D                                     DtaAra('OBJECT/PCDINQRY')
     D                                     Prefix(Pcd_)

     D SdsUser        SDS
     D                       254    263A

     D IVRASKWDDS      DS
     D  Prm$Itmnu              1      8  0
     D  PrmDelete              9      9A
     D  PrmReruna             10     10A
     D  Prm$Ldesc             11     97A
     D  PrmDivcat             98    104A
     D  PrmRorefNum2         105    109A

     D PrmJobNum7      S              7A
     D PrmNextItm      S              8A
     D PrmScorItm      S              8A
     D PrmError        S              1A
     D PrmScore        S              1A
     D PrmKit          S              1A
     D PrmBill         S              1A
     D PrmDivCat       S              7A
     D PrmBillItm      S              8A

     D WrkDivCat       S              7S 0 Inz(0)
     D WrkDivCatChar   S             10A
     D WrkNewJob       S              7S 0 Inz(0)
     D WrkNewItm       S              8S 0 Inz(0)
     D WrkScoreItm     S              8S 0 Inz(0)
     D WrkPos          S              3S 0 Inz(0)
     D WrkDate         S               D
     D WrkMktCoord     S             10A    Inz(*Blanks)
     D WrkMsg          S             40A

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

      //***********************************************************************
      //* MAIN LINE
      //***********************************************************************
     C                   READ      PCRSTAGE
     C                   DOW       NOT %Eof(PCRSTAGE)

      * 1. Extract Numeric Divcat from Staging Column
     C                   EVAL      WrkPos = %Scan(' ':STG_CAT)
     C                   IF        WrkPos > 0
     C                   EVAL      WrkDivCatChar = %Trim(%Subst(STG_CAT:1:WrkPos
     C                             - 1))
     C                   MONITOR
     C                   EVAL      WrkDivCat = %Int(WrkDivCatChar)
     C                   ON-ERROR
     C                   EVAL      WrkDivCat = 0
     C                   ENDMON
     C                   ELSE
     C                   MONITOR
     C                   EVAL      WrkDivCat = %Int(STG_CAT)
     C                   ON-ERROR
     C                   EVAL      WrkDivCat = 0
     C                   ENDMON
     C                   ENDIF

      * 2. Generate New Job Number
     C                   EVAL      PrmJobnum7 = *Blanks
     C                   CALLP     P1RGETJOB(PrmJobnum7)
     C                   EVAL      WrkNewJob = %Int(PrmJobnum7)

      * 3. Generate New Item Number
     C                   EVAL      PrmNextItm = *Blanks
     C                   EVAL      PrmScorItm = *Blanks
     C                   EVAL      PrmError = *Blanks
     C                   EVAL      PrmScore = STG_SCSLT
     C                   EVAL      PrmKit = STG_KIT
     C                   EVAL      PrmBill = 'N'
     C                   EVAL      PrmDivCat = %Editc(WrkDivCat:'X')
     C                   EVAL      PrmBillItm = *Blanks
     C                   CALLP     IVRGETITMN(PrmNextItm:PrmScorItm:PrmError:
     C                             PrmScore:PrmKit:PrmBill:PrmDivCat:PrmBillItm)
     C                   EVAL      WrkNewItm = %Int(PrmNextItm)

      * 4. Data Area Tracking
     C     *LOCK         IN        PCDINQRY
     C                   EVAL      Pcd_Itmnum = WrkNewItm
     C                   EVAL      Pcd_Jobnum7 = WrkNewJob
     C                   EVAL      Pcd_DivCat = WrkDivCat
     C                   EVAL      Pcd_ExpCd = 'GEN'
     C                   EVAL      Pcd_NewAdd = 'A'
     C                   OUT       PCDINQRY

      * 5. Map and Write to PCR Master (PCPMAIN)
     C                   CLEAR     PCPMAINS
     C                   EVAL      @Itm = WrkNewItm
     C                   EVAL      Jobnum7 = WrkNewJob
     C                   EVAL      Divcat = WrkDivcat
     C                   EVAL      LDesc1 = %Subst(STG_TITLE:1:29)
     C                   EVAL      LDesc2 = %Subst(STG_TITLE:30:29)
     C                   EVAL      LDesc3 = %Subst(STG_TITLE:59:29)
     C                   EVAL      Sdesc = STG_SDESC
     C                   EVAL      Price72 = STG_PRICE
     C                   EVAL      Price112 = STG_PRICE
     C                   EVAL      RunQty = STG_RUNQTY
     C                   EVAL      Series = STG_SERIES
     C                   EVAL      Cntrtp = STG_CNTRTP
     C                   EVAL      Medium = STG_MEDIUM
     C                   EVAL      CtryOrigin = STG_CTRY
     C                   EVAL      Voicng = STG_VOICNG
     C                   EVAL      MaxDis = STG_MAXDIS
     C                   EVAL      Rorefnum = STG_ROREF
     C                   EVAL      Pblshrnum = STG_PUBLSHR
     C                   EVAL      Artist = STG_ARTIST
     C                   EVAL      Arrngr = STG_ARRNGR
     C                   EVAL      Author = STG_AUTHOR
     C                   EVAL      PublCode = STG_PUBLCOD
     C                   EVAL      PubCode = STG_PUBCODE
     C                   EVAL      Catlog = STG_CATLOG
     C                   EVAL      @Catl1 = STG_CATL1
     C                   EVAL      @Catl2 = STG_CATL2
     C                   EVAL      MusKey = STG_MUSKEY
     C                   EVAL      @Purch = STG_PURCH
     C                   EVAL      @Kit = STG_KIT
     C                   EVAL      @Rush = STG_RUSH
     C                   EVAL      @Outs = STG_OUTS
     C                   EVAL      @Splt = STG_SPLT
     C                   EVAL      Sellbl = STG_SELLBL
     C                   EVAL      @UPC = STG_UPC
     C                   EVAL      @EAN# = STG_EAN
     C                   EVAL      @ISBN = STG_ISBN
     C                   EVAL      @NI = STG_NI
     C                   EVAL      NICat1 = STG_NICAT1
     C                   EVAL      NICat2 = STG_NICAT2
     C                   EVAL      NICat3 = STG_NICAT3
     C                   EVAL      @SCSLT = STG_SCSLT
     C                   EVAL      @SCQty = STG_SCQTY
     C                   EVAL      @SCPRC72 = STG_SCPRC
     C                   EVAL      @SCPRC112 = STG_SCPRC
     C                   EVAL      Clinic# = STG_CLINIC

     C                   IF        STG_ESTCMP <> *Blanks
     C                   MONITOR
     C                   EVAL      WrkDate = %Date(STG_ESTCMP:*ISO)
     C                   EVAL      EstCmpMM = %Subdt(WrkDate:*M)
     C                   EVAL      EstCmpDD = %Subdt(WrkDate:*D)
     C                   EVAL      EstCmpYYYY = %Subdt(WrkDate:*Y)
     C                   EVAL      EstCmpDt = WrkDate
     C                   ON-ERROR
     C                   EVAL      EstCmpMM = 0
     C                   EVAL      EstCmpDD = 0
     C                   EVAL      EstCmpYYYY = 0
     C                   EVAL      EstCmpDt = *Loval
     C                   ENDMON
     C                   ELSE
     C                   EVAL      EstCmpMM = 0
     C                   EVAL      EstCmpDD = 0
     C                   EVAL      EstCmpYYYY = 0
     C                   EVAL      EstCmpDt = *Loval
     C                   ENDIF

     C                   EVAL      StartMM = %Subdt(%Date():*M)
     C                   EVAL      StartDD = %Subdt(%Date():*D)
     C                   EVAL      StartYYYY = %Subdt(%Date():*Y)
     C                   EVAL      StartDt = %Date()
     C                   EVAL      Orign = SdsUser
     C                   EVAL      @Send = 'N'
     C                   EVAL      BusAff = 'N'
     C                   EVAL      @Wino = ' '
     C                   WRITE     PCPMAINS

      * 6. Calculate Accrual Rate & Write to PCPROYLT
     C                   EXSR      SbrRoyAcr
     C                   CLEAR     PCPROYL$
     C                   EVAL      ROY_@Itm = WrkNewItm
     C                   EVAL      ROY_Jobnum7 = WrkNewJob
     C                   EVAL      ROY_CODEPR72 = STG_PRICE
     C                   EVAL      ROY_AcrRate = WrkAcrRate
     C                   EVAL      ROY_Jvrte = WrkJvRate
     C                   EVAL      ROY_SNGRTE = STG_SNGRTE
     C                   EVAL      ROY_SNGADV = STG_SNGADV
     C                   EVAL      ROY_SNFPAY = STG_SNFPAY
     C                   EVAL      ROY_CMPRTE = STG_CMPRTE
     C                   EVAL      ROY_CMPADV = STG_CMPADV
     C                   EVAL      ROY_CMPPAY = STG_CMPPAY
     C                   EVAL      ROY_ARRRTE = STG_ARRRTE
     C                   EVAL      ROY_ARRADV = STG_ARRADV
     C                   EVAL      ROY_ARRPAY = STG_ARRPAY
     C                   EVAL      ROY_IMGRTE = STG_IMGRTE
     C                   EVAL      ROY_IMGADV = STG_IMGADV
     C                   EVAL      ROY_IMGPAY = STG_IMGPAY
     C                   EVAL      ROY_OTHRTE = STG_OTHRTE
     C                   EVAL      ROY_OTHADV = STG_OTHADV
     C                   EVAL      ROY_OTHPAY = STG_OTHPAY
     C                   EVAL      ROY_AGCRTE = STG_AGCRTE
     C                   EVAL      ROY_AGCADV = STG_AGCADV
     C                   EVAL      ROY_AGCPAY = STG_AGCPAY
     C                   EVAL      ROY_MECFEE = STG_MECFEE
     C                   EVAL      ROY_MECADV = STG_MECADV
     C                   EVAL      ROY_MECPAY = STG_MECPAY
     C                   EVAL      ROY_OTHFEE = STG_OTHFEE
     C                   EVAL      ROY_OTHFAD = STG_OTHFAD
     C                   EVAL      ROY_OTHFPY = STG_OTHFPY
     C                   EVAL      ROY_ARRFEE = STG_ARRFEE
     C                   EVAL      ROY_ARRFPY = STG_ARRFPY
     C                   EVAL      ROY_JVPC = STG_JVPC
     C                   EVAL      ROY_JVADV = STG_JVADV
     C                   EVAL      ROY_JVPAY = STG_JVPAY
     C                   WRITE     PCPROYL$

      * 7. Write Production Job Master (JOBFLE7)
     C                   CLEAR     WW$JOBAC
     C                   EVAL      Jf7_Jobnum7 = WrkNewJob
     C                   EVAL      Jf7_Fininv = %Editc(WrkNewItm:'X')
     C                   EVAL      Jf7_Itmnumnew = WrkNewItm
     C                   EVAL      Jf7_Jobdes = %Trim(STG_SERIES) + ' ' +
     C                             STG_SDESC
     C                   EVAL      Jf7_RunQty = STG_RUNQTY
     C                   EVAL      Jf7_RunId = 'NW'
     C                   EVAL      Jf7_StartMM = %Subdt(%Date():*M)
     C                   EVAL      Jf7_StartDD = %Subdt(%Date():*D)
     C                   EVAL      Jf7_StartYY = %Subdt(%Date():*Y)
     C                   EVAL      Jf7_CompleteMM = 0
     C                   EVAL      Jf7_CompleteDD = 0
     C                   EVAL      Jf7_CompleteYY = 0
     C                   EVAL      Jf7_TrnQty = 0
     C                   EVAL      Jf7_InForm = *Blanks
     C                   EVAL      Jf7_Fill01 = 0
     C                   EVAL      Jf7_CloseMM = 0
     C                   EVAL      Jf7_CloseDD = 0
     C                   EVAL      Jf7_CloseYY = 0
     C                   EVAL      Jf7_FinQty = 0
     C                   EVAL      Jf7_UFEO = ' '
     C                   EVAL      Jf7_Close = ' '
     C                   EVAL      Jf7_Task1120 = 0
     C                   EVAL      Jf7_Task1130 = 0
     C                   WRITE     WW$JOBAC

      * 8. Write Production Rerun Master (RERUN8)
     C                   CLEAR     B$RERUN
     C                   EVAL      Rr8_ITEM# = WrkNewItm
     C                   EVAL      Rr8_Jobnum7 = WrkNewJob
     C                   EVAL      Rr8_RunQty = STG_RUNQTY
     C                   EVAL      Rr8_Delete = *Blanks
     C                   EVAL      Rr8_FinishMM = EstCmpMM
     C                   EVAL      Rr8_FinishDD = EstCmpDD
     C                   EVAL      Rr8_FinishYYYY = EstCmpYYYY
     C                   EVAL      Rr8_Coment = *Blanks
     C                   EVAL      Rr8_Compdt = (%Subdt(%Date():*M) * 100) +
     C                             %Subdt(%Date():*D)
     C                   EVAL      Rr8_Photdt = 0
     C                   EVAL      Rr8_Presdt = 0
     C                   EVAL      Rr8_Binddt = 0
     C                   EVAL      Rr8_Xtrcmt = *Blanks
     C                   EVAL      Rr8_Bochkd = *Blanks
     C                   EVAL      Rr8_Prepdt = 0
     C                   EVAL      Rr8_Scandt = 0
     C                   EVAL      Rr8_Prntdt = 0
     C                   EVAL      Rr8_DgBinddt = 0
     C                   WRITE     B$RERUN
     C                   CALLP     PCRRERN(Rr8_ITEM#)

      * 9. Write Online Rerun Queue (IVPORRITM & IVPORRMNT)
     C                   CLEAR     IV$ORRITM
     C                   EVAL      Orr_Itmnum = WrkNewItm
     C                   EVAL      Orr_MinQtyDt = %Date()
     C                   EVAL      Orr_Note1 =
     C                             'PCR created job (not Online Rerun)'
     C                   EVAL      Orr_RerunSts = 'J'
     C                   EVAL      Orr_Hold = *Blanks
     C                   EVAL      Orr_Jobnum7 = WrkNewJob
     C                   EVAL      Orr_Jobdate = %Date()
     C                   EVAL      Orr_Jobuser = SdsUser
     C                   WRITE     IV$ORRITM

     C                   CLEAR     IV$ORRMNT
     C                   EVAL      Orm_Itmnum = WrkNewItm
     C                   EVAL      Orm_Action = 'Job created'
     C                   EVAL      Orm_Desc = 'Job# ' + %Trim(%Editc(WrkNewJob:
     C                             'X'))
     C                   EVAL      Orm_MaintTs = %Timestamp()
     C                   EVAL      Orm_MaintWho = SdsUser
     C                   WRITE     IV$ORRMNT

      * 10. Write Inventory Item Master (IVPITEMS)
     C                   CLEAR     IVPITEM$
     C                   EVAL      Itm_Itmnum = WrkNewItm
     C                   EVAL      Itm_Divcat = WrkDivCat
     C                   EVAL      Itm_Series = STG_SERIES
     C                   EVAL      Itm_Sdesc = %Trim(STG_SERIES) + ' ' +
     C                             STG_SDESC
     C                   EVAL      Itm_Ldesc = STG_TITLE
     C                   EVAL      Itm_Arrngr = STG_ARRNGR
     C                   EVAL      Itm_Artist = STG_ARTIST
     C                   EVAL      Itm_Author = STG_AUTHOR
     C                   EVAL      Itm_Catlog = STG_CATLOG
     C                   EVAL      Itm_Medium = STG_MEDIUM
     C                   EVAL      Itm_PblshrNum = STG_PUBLSHR
     C                   EVAL      Itm_RorefNum = STG_ROREF
     C                   EVAL      Itm_Voicng = STG_VOICNG
     C                   EVAL      Itm_Pubcode = STG_PUBCODE
     C                   EVAL      Itm_Maxdis = STG_MAXDIS
     C                   IF        STG_MAXDIS = 9.999
     C                   EVAL      Itm_Net = 'Y'
     C                   ELSE
     C                   EVAL      Itm_Net = 'N'
     C                   ENDIF
     C                   EVAL      Itm_Price72 = STG_PRICE
     C                   EVAL      Itm_Price112 = STG_PRICE
     C                   IF        STG_KIT = 'Y'
     C                   EVAL      Itm_Kit = 'K'
     C                   ELSE
     C                   EVAL      Itm_Kit = ' '
     C                   ENDIF

     C                   EVAL      WrkMktCoord = *Blanks
     C                   CALLP     IVRORRGETC(%Editc(WrkNewItm:'X'):WrkMktCoord)
     C                   SELECT
     C                   WHEN      STG_MEDIUM = 'SITLC'
     C                   EVAL      Itm_Permot = *Blanks
     C                   WHEN      STG_SERIES = 'SI'
     C                   EVAL      Itm_Permot = 'S'
     C                   WHEN      WrkMktCoord = 'IMPORT'
     C                   EVAL      Itm_Permot = 'B'
     C                   OTHER
     C                   EVAL      Itm_Permot = 'Y'
     C                   ENDSL

     C                   EVAL(H)   Itm_Minqty = STG_RUNQTY / 3
     C                   IF        Itm_Minqty = 0
     C                   EVAL      Itm_Minqty = 1
     C                   ENDIF

     C                   IF        STG_SELLBL = 'S' OR STG_MEDIUM = 'DLD' OR
     C                             STG_MEDIUM = 'VIDDL'
     C                   EVAL      Itm_MinQtyUsg = 'I'
     C                   ENDIF

     C                   EVAL      Itm_Stdtyp = 'N'
     C                   EVAL      Itm_Sellbl = STG_SELLBL
     C                   EVAL      Itm_Cntrtp = STG_CNTRTP
     C                   EVAL      Itm_Muskey = STG_MUSKEY
     C                   EVAL      Itm_Publcode = STG_PUBLCOD
     C                   EVAL      Itm_CtryOrigin = STG_CTRY
     C                   EVAL      Itm_NIYN = STG_NI
     C                   EVAL      Itm_Nicat1 = STG_NICAT1
     C                   EVAL      Itm_Nicat2 = STG_NICAT2
     C                   EVAL      Itm_Nicat3 = STG_NICAT3
     C                   EVAL      Itm_Cprtun = 1
     C                   EVAL      Itm_Reruna = ' '
     C                   EVAL      Itm_Cexcpt = ' '
     C                   EVAL      Itm_RoyAcrRat1 = WrkAcrRate
     C                   WRITE     IVPITEM$

      * 11. Barcodes, Alpha Search, Audit & Sales
     C                   IF        STG_UPC = 'Y'
     C                   EVAL      Itm_Upc# = 0
     C                   EVAL      Itm_Check# = 0
     C                   CALLP     UPC#2(Itm_Itmnum:Itm_Upc#:Itm_Check#)
     C                   ENDIF

     C                   IF        STG_ISBN = 'Y'
     C                   CALLP     PCRISBN()
     C                   ENDIF

     C                   CALLP     P1R999S()

     C                   CLEAR     ROPSALE$
     C                   EVAL      Rsl_Itmnum = WrkNewItm
     C                   WRITE     ROPSALE$

     C                   CLEAR     IVPMAIN$
     C                   EVAL      Mnt_Itmnum = WrkNewItm
     C                   EVAL      Mnt_Fldnam = 'ADDED'
     C                   EVAL      Mnt_MaintYYYY = %Subdt(%Date():*Y)
     C                   EVAL      Mnt_Maintmm = %Subdt(%Date():*M)
     C                   EVAL      Mnt_Maintdd = %Subdt(%Date():*D)
     C                   EVAL      Mnt_Maintwho = SdsUser
     C                   EVAL      Mnt_Before = '***** ITEM ADDED ************'
     C                   EVAL      Mnt_After = '***** ITEM ADDED ************'
     C                   EVAL      Mnt_Repcode = 'N'
     C                   EVAL      Mnt_Comment = *Blanks
     C                   WRITE     IVPMAIN$

     C                   EVAL      Prm$Itmnu = WrkNewItm
     C                   EVAL      PrmDelete = ' '
     C                   EVAL      PrmReruna = ' '
     C                   EVAL      Prm$Ldesc = STG_TITLE
     C                   EVAL      PrmDivcat = %Char(WrkDivCat)
     C                   EVAL      PrmRorefNum2 = STG_ROREF
     C                   CALLP     IVRASKWD(IVRASKWDDS)

      * 12. Write PCR Breakeven Master (PCPBKEVN)
     C                   CLEAR     PCPBKEV$
     C                   EVAL      Bke_@Itm = WrkNewItm
     C                   EVAL      Bke_Jobnum7 = WrkNewJob
     C                   EVAL      Bke_BKE00172 = STG_PRICE
     C                   SELECT
     C                   WHEN      STG_MAXDIS = 0
     C                   EVAL      Bke_BKE002 = 0.47
     C                   WHEN      STG_MAXDIS = 9.999
     C                   EVAL      Bke_BKE002 = 1.0
     C                   OTHER
     C                   EVAL      Bke_BKE002 = 1 - STG_MAXDIS
     C                   ENDSL
     C                   EVAL      Bke_BKE00572 = 0
     C                   EVAL      Bke_BKE006 = WrkAcrRate
     C                   EVAL      Bke_BKE008 = 0
     C                   EVAL      Bke_BKE014 = 0
     C                   WRITE     PCPBKEV$

      * 13. Conditional: Purchased Product Flag (IVPITMCODE)
     C                   IF        STG_PURCH = 'Y'
     C                   EVAL      Cod_Itmnum = WrkNewItm
     C                   EVAL      Cod_ItmCode = 'PUR'
     C                   WRITE     IVSITMCODE
     C                   ENDIF

      * 14. Conditional: Score Item & Slot (W#JOBSCR & IVPITEMS)
     C                   IF        STG_SCSLT = 'Y' AND PrmScorItm <> *Blanks AND
     C                             %Int(PrmScorItm) <> 0
     C                   EVAL      WrkScoreItm = %Int(PrmScorItm)
     C                   EVAL      Scr_Jobnum7 = WrkNewJob
     C                   EVAL      Scr_Scrnum = WrkScoreItm
     C                   EVAL      Scr_Scrqty = STG_SCQTY
     C                   WRITE     WSJOBSCR

     C                   CLEAR     IVPITEM$
     C                   EVAL      Itm_Itmnum = WrkScoreItm
     C                   EVAL      Itm_Divcat = WrkDivCat
     C                   EVAL      Itm_Series = STG_SERIES
     C                   EVAL      Itm_Voicng = 'SCORE'
     C                   EVAL      Itm_Price72 = STG_SCPRC
     C                   EVAL      Itm_Price112 = STG_SCPRC
     C                   EVAL      Itm_Ldesc = %TrimR(STG_TITLE) + ' FULL SCORE'
     C                   EVAL      Itm_Sdesc = %TrimR(STG_SDESC) + ' SC'
     C                   EVAL      Itm_Arrngr = STG_ARRNGR
     C                   EVAL      Itm_Artist = STG_ARTIST
     C                   EVAL      Itm_Author = STG_AUTHOR
     C                   EVAL      Itm_Catlog = STG_CATLOG
     C                   EVAL      Itm_Medium = STG_MEDIUM
     C                   EVAL      Itm_PblshrNum = STG_PUBLSHR
     C                   EVAL      Itm_RorefNum = STG_ROREF
     C                   EVAL      Itm_Pubcode = STG_PUBCODE
     C                   EVAL      Itm_Maxdis = STG_MAXDIS
     C                   IF        STG_MAXDIS = 9.999
     C                   EVAL      Itm_Net = 'Y'
     C                   ELSE
     C                   EVAL      Itm_Net = 'N'
     C                   ENDIF
     C                   EVAL      Itm_Kit = ' '
     C                   EVAL(H)   Itm_Minqty = STG_SCQTY / 3
     C                   IF        Itm_Minqty = 0
     C                   EVAL      Itm_Minqty = 1
     C                   ENDIF
     C                   EVAL      Itm_Stdtyp = 'N'
     C                   EVAL      Itm_Cntrtp = 'S'
     C                   EVAL      Itm_Cexcpt = 'Z'
     C                   EVAL      Itm_NIYN = 'N'
     C                   EVAL      Itm_Reruna = ' '
     C                   EVAL      Itm_Cprtun = 1
     C                   EVAL      Itm_Sellbl = STG_SELLBL
     C                   EVAL      Itm_Muskey = STG_MUSKEY
     C                   EVAL      Itm_Publcode = STG_PUBLCOD
     C                   EVAL      Itm_CtryOrigin = STG_CTRY
     C                   WRITE     IVPITEM$

     C                   IF        STG_UPC = 'Y'
     C                   EVAL      Itm_Upc# = 0
     C                   EVAL      Itm_Check# = 0
     C                   CALLP     UPC#2(Itm_Itmnum:Itm_Upc#:Itm_Check#)
     C                   ENDIF

     C                   CLEAR     ROPSALE$
     C                   EVAL      Rsl_Itmnum = WrkScoreItm
     C                   WRITE     ROPSALE$

     C                   CLEAR     IVPMAIN$
     C                   EVAL      Mnt_Itmnum = WrkScoreItm
     C                   EVAL      Mnt_Fldnam = 'ADDED'
     C                   EVAL      Mnt_MaintYYYY = %Subdt(%Date():*Y)
     C                   EVAL      Mnt_Maintmm = %Subdt(%Date():*M)
     C                   EVAL      Mnt_Maintdd = %Subdt(%Date():*D)
     C                   EVAL      Mnt_Maintwho = SdsUser
     C                   EVAL      Mnt_Before = '***** ITEM ADDED ************'
     C                   EVAL      Mnt_After = '***** ITEM ADDED ************'
     C                   EVAL      Mnt_Repcode = 'N'
     C                   EVAL      Mnt_Comment = *Blanks
     C                   WRITE     IVPMAIN$

     C                   EVAL      Prm$Itmnu = WrkScoreItm
     C                   EVAL      PrmDelete = ' '
     C                   EVAL      PrmReruna = ' '
     C                   EVAL      Prm$Ldesc = Itm_Ldesc
     C                   EVAL      PrmDivcat = %Char(WrkDivCat)
     C                   EVAL      PrmRorefNum2 = STG_ROREF
     C                   CALLP     IVRASKWD(IVRASKWDDS)
     C                   ENDIF

      * Advance loop to next row
     C                   READ      PCRSTAGE
     C                   ENDDO

     C                   EVAL      WrkMsg =
     C                             'Batch upload processed successfully.'
     C                   DSPLY     WrkMsg
     C                   EVAL      *INLR = *ON

      * Subroutine: Calculate Total Royalty Accrual Rate
     C     SbrRoyAcr     BEGSR

     C     STG_ROREF     CHAIN     ROLOWCTL1
     C                   IF        NOT %Found(ROLOWCTL1)
     C                   EVAL      Ctl_AdmFee = 0
     C                   ENDIF

     C                   IF        STG_PRICE <> 0
     C                   EVAL      WrkTmppr2 = STG_PRICE / 100
     C                   ELSE
     C                   EVAL      WrkTmppr2 = 0
     C                   ENDIF

     C                   EVAL      WrkTmpacm = STG_SNGRTE * WrkTmppr2
     C                   EVAL      WrkJvs01 = WrkTmpacm
     C                   EVAL      WrkAcrRate = WrkTmpacm

     C                   EVAL      WrkTmpacm = STG_CMPRTE * WrkTmppr2
     C                   EVAL      WrkJvs02 = WrkTmpacm
     C                   EVAL      WrkAcrRate = WrkAcrRate + WrkTmpacm

     C                   EVAL      WrkTmpacm = STG_ARRRTE * WrkTmppr2
     C                   EVAL      WrkJvs03 = WrkTmpacm
     C                   EVAL      WrkAcrRate = WrkAcrRate + WrkTmpacm

     C                   EVAL      WrkTmpacm = STG_IMGRTE * WrkTmppr2
     C                   EVAL      WrkJvs04 = WrkTmpacm
     C                   EVAL      WrkAcrRate = WrkAcrRate + WrkTmpacm

     C                   EVAL      WrkTmpacm = STG_OTHRTE * WrkTmppr2
     C                   EVAL      WrkJvs05 = WrkTmpacm
     C                   EVAL      WrkAcrRate = WrkAcrRate + WrkTmpacm

     C                   EVAL      WrkJvRate = 0
     C                   IF        STG_JVPC <> 0
     C                   EVAL      WrkJv00 = STG_PRICE * 0.50
     C                   EVAL      Wrk$Admf = 100.0 - Ctl_AdmFee
     C                   EVAL      Wrk$Admfd = Wrk$Admf / 100
     C                   EVAL      WrkJv01 = (WrkJv00 * Wrk$Admfd) - WrkJvs02 -
     C                             WrkJvs03 - WrkJvs04 - WrkJvs05
     C                   IF        STG_ROREF <> 726
     C                   EVAL      WrkJv01 = WrkJv01 - WrkJvs01 - STG_MECFEE
     C                   ENDIF
     C                   EVAL      WrkJv00 = STG_JVPC * 0.01
     C                   EVAL      WrkTmpacm = WrkJv00 * WrkJv01
     C                   IF        WrkTmppr2 <> 0
     C                   EVAL(H)   WrkJvRate = WrkTmpacm / WrkTmppr2
     C                   ENDIF
     C                   EVAL      WrkAcrRate = WrkAcrRate + WrkTmpacm
     C                   ENDIF

      * Agency is 50%
     C                   IF        STG_AGCRTE <> 0
     C                   EVAL(H)   WrkTmpacm = STG_AGCRTE * WrkTmppr2 * 0.50
     C                   EVAL      WrkAcrRate = WrkAcrRate + WrkTmpacm
     C                   ENDIF

     C                   EVAL      WrkAcrRate = WrkAcrRate + STG_MECFEE +
     C                             STG_OTHFEE

     C                   ENDSR