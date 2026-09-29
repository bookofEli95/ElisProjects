     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
       //***********************************************************************
       // AIRRELCTL
       // EDI: Amazon/Mirakl Best Buy Order Release/Shipping Doc
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       //
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // FIX     09/15/26 EFI Quick Fix -  Automate Release
       // H33926  06/24/26 RM  Amazon/Mirakl BBM Dropship - Auto release
       //***********************************************************************

       //***********************************************************************
       //* Prototypes *
       //**************
      /copy qcopysrc,statusds
      /copy qcopysrc,qcmdexc
      /copy qcopysrc,odrbldtype
      /copy qcopysrc,oerrelas

       // Used only by the control-file channel sweep (Sbr_Swp_*).
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

     D*PrmSdatc        S              6A
     D*WrkSddtea       S              6A
     D PrmOrdnum       S              8A
     D WrkCommand      S           1024A

       // Control-file channel sweep (Sbr_Swp_*) only
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

       Exec Sql declare cur_Bch cursor for
            select *
              from oepbchk
                where edtb# <> 0
                  and ucase(desc20) in (
                                        'MIRAKL EDI',
                                        'AMAZON.COM NOTE'
                                        )
            order by edtb#;

       Exec Sql Open cur_Bch;
       If Sqlcode < 0;
         Exec Sql Close cur_Bch;
         Exec Sql Open cur_Bch;
       Endif;
       Exec Sql Fetch cur_Bch Into :Bch@Ds;

       Dow SqlCod = 0;

         Exsr Sbr_Credit_Release;
         Exsr Sbr_Order_History;
         Exsr Sbr_Shipping_Doc;

         Exec Sql Fetch cur_Bch Into :Bch@Ds;
       Enddo;

       // Control-file channels (OEPEDTSWP), run after Mirakl/Amazon.
       // Monitored so an error here can never leave an inquiry message
       // that would hang AICCRTORD and stop Mirakl/Amazon.
       Monitor;
         Exsr Sbr_Swp_Sweep;
       On-Error;
         SwpMsgTxt = 'AIRRELCTL control-file sweep ended in error, status '
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
       //* Credit Release for Shipping
       //******************
       Begsr Sbr_Credit_Release;

         In Lda;
         $E = *Zero;
         $D = *Blanks;
         $E(1) = Bch@Ds.Edtb#;
         Out Lda;
         callp OERRELAS();

         // Lock Key and Edit Batch #s for Shipping Documents
         Exec Sql
           update oepbchk set bchsts = 'C'
             where keyb# = :Bch@Ds.keyb#;
         Exec Sql
           update oepbche set bchsts = 'L'
             where edtb# = :Bch@Ds.edtb#;

       Endsr;

       //***********************************************************************
       //* Generate Shipping Document
       //******************
       Begsr Sbr_Shipping_Doc;
         In Lda;
         $E = *Zero;
         $D = *Blanks;
         $E(1) = Bch@Ds.Edtb#;
         $D(1) = Bch@Ds.Desc20;
         $Source = Bch@Ds.Source;
         $Prtbs = Bch@Ds.Prtbs;
         Out Lda;

         // Enable these codes if release date needs to be next day
         // callp OERSDDAT(PrmSdatc);
         // WrkSddtea = PrmSdatc;

         WrkCommand = 'SBMJOB CMD(CALL PGM(OECPRTSD)) '
                    + 'JOB(SDOC_'
                    + $E#1
                    + ') '
                    + 'OUTQ(HP1N) '
                    + 'JOBD(OPERATOR) '
                    + 'MSGQ(*NONE)';
         callp QCMDEXC(%Trim(WrkCommand):%Len(%Trim(WrkCommand)));
       Endsr;

       //***********************************************************************
       //* Generate Order History
       //******************
       Begsr Sbr_Order_History;

         Exec Sql declare cur_Trk cursor for
              select Ordnum,
                     Keyb#,
                     Edtb#,
                     Phoncd
                from oeptrack
                  where keyb# = :Bch@Ds.keyb#
                    and edtb# = :Bch@Ds.edtb#;

         Exec Sql Open cur_Trk;
         If Sqlcode < 0;
           Exec Sql Close cur_Trk;
           Exec Sql Open cur_Trk;
         Endif;
         Exec Sql Fetch cur_Trk Into :Trk@Ds.Ordnum,
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
           If Trk@Ds.Phoncd = 'R';
             Hst@Ds.Ordsts   = 'W';
             Hst@Ds.PickMthd = 'R';
           Else;
             Hst@Ds.Ordsts   = 'W';
             Hst@Ds.PickMthd = 'M';
           Endif;

           Exec Sql
             INSERT INTO OEPORDHST
               VALUES(:Hst@Ds);

           //...Call ODRBLDTYPE to type all orders in batch
           PrmOrdnum = %Editc(Trk@Ds.Ordnum:'X');
           Callp ODRBLDTYPE(PrmOrdNum);

           Exec Sql Fetch cur_Trk Into :Trk@Ds.Ordnum,
                                       :Trk@Ds.Keyb#,
                                       :Trk@Ds.Edtb#,
                                       :Trk@Ds.Phoncd;
         Enddo;

       Endsr;

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
           SwpMsgTxt = 'AIRRELCTL released Edtb# ' + %Char(Bch@Ds.Edtb#)
                     + ' Keyb# ' + %Char(Bch@Ds.Keyb#)
                     + ' Desc ' + %Trim(Bch@Ds.Desc20)
                     + ' Orders ' + %Char(SwpOrdCnt);
           Exsr Sbr_Swp_Log;

           Exec Sql Fetch cur_Swp Into :Bch@Ds;
         Enddo;

         SwpMsgTxt = 'AIRRELCTL control-file run total - Batches '
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
