     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
       //***********************************************************************
       // AIRRELCTL2
       // EDI: Control-file channel Order Release/Shipping Doc (OEPEDTSWP)
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Sweeps every channel active in OEPEDTSWP through screens 7 and 8:
       // OERRELAS + BCHSTS C/L, order history per OERSLSD (incl. PLPEBDESC)
       // + ODRBLDTYPE, then OERSDDAT date and SBMJOB PLCCHKSGL.
       // MIRAKL EDI and AMAZON.COM NOTE are excluded - AIRRELCTL owns them.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // FIX     09/29/26 EFI Automate Release - OEPEDTSWP channels
       //***********************************************************************

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,statusds
      /copy qcopysrc,qcmdexc
      /copy qcopysrc,odrbldtype
      /copy qcopysrc,oerrelas

       Dcl-PR OERSDDAT ExtPgm('OERSDDAT');
         Sdatc Char(6);
       End-PR;

       // Writes one line to the job log. Error code has bytes-provided = 8
       // so a failure is returned, never raised.
       Dcl-PR QMHSNDPM ExtPgm('QMHSNDPM');
         MsgID       Char(7)   Const;
         QualMsgF    Char(20)  Const;
         MsgDta      Char(132) Const;
         MsgDtaLen   Int(10)   Const;
         MsgType     Char(10)  Const;
         CallStkEnt  Char(10)  Const;
         CallStkCnt  Int(10)   Const;
         MsgKey      Char(4);
         ErrorCode   Char(8);
       End-PR;

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************

     D Bch@Ds        E DS                  Extname(OEPBCHK) Qualified
     D Trk@Ds        E DS                  Extname(OEPTRACK) Qualified
     D Hst@Ds        E DS                  Extname(OEPORDHST) Qualified

     D Lda             DS                  Dtaara(*LDA)
     D  $Source              513    513
     D  $Prtbs               514    514
     D  $E                   515    544  0
     D                                     DIM(10)
     D  $E#1                 515    517
     D  $D                   545    744
     D                                     DIM(10)

     D SwpOrdnum       S              8A
     D SwpSdatc        S              6A
     D SwpPickPut      S              1A
     D SwpPlpFnd       S              1A
     D SwpCommand      S           1024A
     D SwpMsgTxt       S            132A
     D SwpMsgKey       S              4A
     D SwpErrCde       S              8A   Inz(x'0000000800000000')
     D SwpOrdCnt       S              5  0
     D SwpTotBch       S              5  0 Inz(0)
     D SwpTotOrd       S              7  0 Inz(0)

       //***********************************************************************
       //* Main Line *
       //*************
       Exec Sql Set Option Commit=*None, CloSqlCsr=*EndMod;

       // Monitored so an error can never leave an inquiry message that
       // would hang AICCRTORD (and with it Mirakl/Amazon).
       Monitor;
         Exsr Sbr_Swp_Sweep;
       On-Error;
         SwpMsgTxt = 'AIRRELCTL2 ended in error, status '
                   + %Char(%Status);
         Exsr Sbr_Swp_Log;
       Endmon;

       *InLR = *On;

       //*****************
       //* End Main Line *
       //***********************************************************************

       // /****************************************************************\ *
       //< SUBROUTINES >*
       // \****************************************************************/ *


       //***********************************************************************
       //* Control-file channel sweep - every active OEPEDTSWP channel
       //* except Mirakl/Amazon, which are handled above and never here.
       //******************
       Begsr Sbr_Swp_Sweep;

         Exec Sql declare cur_Swp cursor for
              select b.*
                from oepbchk b
                  where b.edtb# <> 0
                    and b.bchsts <> 'C'
                    and ucase(b.desc20) not in ('MIRAKL EDI',
                                                'AMAZON.COM NOTE')
                    and ucase(rtrim(b.desc20)) in
                        (select ucase(rtrim(s.desc))
                           from oepedtswp s
                          where s.active = 'Y')
              order by b.edtb#;

         Exec Sql Open cur_Swp;
         If Sqlcode < 0;
           Exec Sql Close cur_Swp;
           Exec Sql Open cur_Swp;
         Endif;
         Exec Sql Fetch cur_Swp Into :Bch@Ds;

         Dow SqlCod = 0;

           Exsr Sbr_Swp_Credit_Release;
           Exsr Sbr_Swp_Order_History;
           Exsr Sbr_Swp_Shipping_Doc;

           SwpTotBch += 1;
           SwpTotOrd += SwpOrdCnt;
           SwpMsgTxt = 'AIRRELCTL2 released Edtb# ' + %Char(Bch@Ds.Edtb#)
                     + ' Keyb# ' + %Char(Bch@Ds.Keyb#)
                     + ' Desc ' + %Trim(Bch@Ds.Desc20)
                     + ' Orders ' + %Char(SwpOrdCnt);
           Exsr Sbr_Swp_Log;

           Exec Sql Fetch cur_Swp Into :Bch@Ds;
         Enddo;

         SwpMsgTxt = 'AIRRELCTL2 run total - Batches '
                   + %Char(SwpTotBch) + ' Orders ' + %Char(SwpTotOrd);
         Exsr Sbr_Swp_Log;

       Endsr;

       //***********************************************************************
       //* Control-file sweep: Credit Release (screen 7)
       //******************
       Begsr Sbr_Swp_Credit_Release;

         In Lda;
         $E = *Zero;
         $D = *Blanks;
         $E(1) = Bch@Ds.Edtb#;
         Out Lda;
         callp OERRELAS();

         // The screen does this, OERRELAS does not
         Exec Sql
           update oepbchk set bchsts = 'C'
             where keyb# = :Bch@Ds.keyb#;
         Exec Sql
           update oepbche set bchsts = 'L'
             where edtb# = :Bch@Ds.edtb#;

       Endsr;

       //***********************************************************************
       //* Control-file sweep: Shipping Documents (screen 8)
       //******************
       Begsr Sbr_Swp_Shipping_Doc;
         In Lda;
         $E = *Zero;
         $D = *Blanks;
         $E(1) = Bch@Ds.Edtb#;
         $D(1) = Bch@Ds.Desc20;
         $Source = Bch@Ds.Source;
         $Prtbs = Bch@Ds.Prtbs;
         Out Lda;

         // Same as OERSLSD: date from OERSDDAT, then submit PLCCHKSGL
         callp OERSDDAT(SwpSdatc);

         SwpCommand = 'SBMJOB CMD(CALL PGM(PLCCHKSGL) '
                    + 'PARM('''
                    + SwpSdatc
                    + ''')) '
                    + 'JOB(SDOC_'
                    + $E#1
                    + ') '
                    + 'OUTQ(HP1N) '
                    + 'JOBD(OPERATOR) '
                    + 'DATE('
                    + SwpSdatc
                    + ') '
                    + 'MSGQ(*NONE)';
         callp QCMDEXC(%Trim(SwpCommand):%Len(%Trim(SwpCommand)));
       Endsr;

       //***********************************************************************
       //* Control-file sweep: Order History (as OERSLSD, incl. PLPEBDESC)
       //******************
       Begsr Sbr_Swp_Order_History;

         SwpOrdCnt = 0;

         Exec Sql declare cur_SwpTrk cursor for
              select Ordnum,
                     Keyb#,
                     Edtb#,
                     Phoncd
                from oeptrack
                  where keyb# = :Bch@Ds.keyb#
                    and edtb# = :Bch@Ds.edtb#;

         Exec Sql Open cur_SwpTrk;
         If Sqlcode < 0;
           Exec Sql Close cur_SwpTrk;
           Exec Sql Open cur_SwpTrk;
         Endif;
         Exec Sql Fetch cur_SwpTrk Into :Trk@Ds.Ordnum,
                                        :Trk@Ds.Keyb#,
                                        :Trk@Ds.Edtb#,
                                        :Trk@Ds.Phoncd;
         Dow SqlCod = 0;
           Exec Sql
             DELETE from OEPORDHST
               WHERE ordnum = :Trk@Ds.ordnum;

           clear Hst@Ds;
           Hst@Ds.Ordnum  = Trk@Ds.Ordnum;
           Hst@Ds.Keyb#   = Trk@Ds.Keyb#;
           Hst@Ds.KeyDesc = Bch@Ds.Desc20;
           Hst@Ds.Edtb#   = Trk@Ds.Edtb#;
           Hst@Ds.EdtDesc = Bch@Ds.Desc20;
           Hst@Ds.StsDate = %Dec(%Date():*USA);

           // A PLPEBDESC row for the description wins; otherwise phone code
           SwpPickPut = *Blanks;
           SwpPlpFnd = 'N';
           Exec Sql
             select PickPut into :SwpPickPut
               from PLPEBDESC
                 where Desc20 = :Bch@Ds.Desc20
                 fetch first row only;
           If Sqlcode = 0;
             SwpPlpFnd = 'Y';
           Endif;

           If SwpPlpFnd = 'Y';
             If SwpPickPut = 'K';
               Hst@Ds.Ordsts   = 'W';
               Hst@Ds.PickMthd = 'T'; // Change to PUT
             Elseif SwpPickPut = 'T';
               Hst@Ds.Ordsts   = 'W';
               Hst@Ds.PickMthd = 'T';
             Endif;
           Else;
             If Trk@Ds.Phoncd = 'R';
               Hst@Ds.Ordsts   = 'W';
               Hst@Ds.PickMthd = 'R';
             Else;
               Hst@Ds.Ordsts   = 'W';
               Hst@Ds.PickMthd = 'M';
             Endif;
           Endif;

           Exec Sql
             INSERT INTO OEPORDHST
               VALUES(:Hst@Ds);

           SwpOrdnum = %Editc(Trk@Ds.Ordnum:'X');
           Callp ODRBLDTYPE(SwpOrdnum);
           SwpOrdCnt += 1;

           Exec Sql Fetch cur_SwpTrk Into :Trk@Ds.Ordnum,
                                          :Trk@Ds.Keyb#,
                                          :Trk@Ds.Edtb#,
                                          :Trk@Ds.Phoncd;
         Enddo;

       Endsr;

       //***********************************************************************
       //* Control-file sweep: write one line to the job log
       //******************
       Begsr Sbr_Swp_Log;
         Callp QMHSNDPM('CPF9898':'QCPFMSG   *LIBL':SwpMsgTxt:
                         %Len(%Trimr(SwpMsgTxt)):'*INFO':'*':0:
                         SwpMsgKey:SwpErrCde);
       Endsr;
