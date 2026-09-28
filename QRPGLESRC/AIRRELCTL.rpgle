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

       Dcl-PR OERSDDAT ExtPgm('OERSDDAT');
         PrmSdatc Char(6);
       End-PR;

       // Writes one free-text line to the job log (CPF9898 is IBM's
       // generic "send this text as-is" message - no custom message
       // file needed).
       Dcl-PR QMHSNDPM ExtPgm('QMHSNDPM');
         MsgID       Char(7)   Const;
         QualMsgF    Char(20)  Const;
         MsgDta      Char(132) Const;
         MsgDtaLen   Int(10)   Const;
         MsgType     Char(10)  Const;
         CallStkEnt  Char(10)  Const;
         CallStkCnt  Int(10)   Const;
         MsgKey      Char(4);
         ErrorCode   Char(8)   Const;
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

     D PrmOrdnum       S              8A
     D PrmSdatc        S              6A
     D WrkPickPut      S              1A
     D WrkCommand      S           1024A

     D WrkMsgTxt       S            132A
     D WrkMsgKey       S              4A
     D WrkErrCde       S              8A   Inz(x'0000000000000000')
     D WrkOrdCnt       S              5  0
     D WrkTotBch       S              5  0 Inz(0)
     D WrkTotOrd       S              7  0 Inz(0)

       //***********************************************************************
       //* Main Line *
       //*************
       Exec Sql Set Option Commit=*None, CloSqlCsr=*EndMod;

       Exec Sql declare cur_Bch cursor for
            select b.*
              from oepbchk b
                join oepedtswp s
                  on ucase(rtrim(s.desc)) = ucase(rtrim(b.desc20))
                    where b.edtb# <> 0
                      and b.bchsts <> 'C'
                      and s.active = 'Y'
            order by b.edtb#;

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

         WrkTotBch += 1;
         WrkTotOrd += WrkOrdCnt;
         WrkMsgTxt = 'AIRRELCTL released Edtb# ' + %Char(Bch@Ds.Edtb#)
                   + ' Keyb# ' + %Char(Bch@Ds.Keyb#)
                   + ' Desc ' + %Trim(Bch@Ds.Desc20)
                   + ' Orders ' + %Char(WrkOrdCnt);
         Exsr Sbr_Log;

         Exec Sql Fetch cur_Bch Into :Bch@Ds;
       Enddo;

       WrkMsgTxt = 'AIRRELCTL run total - Batches ' + %Char(WrkTotBch)
                 + ' Orders ' + %Char(WrkTotOrd);
       Exsr Sbr_Log;

       *InLR = *On;

       //*****************
       //* End Main Line *
       //***********************************************************************

       // /****************************************************************\ *
       //< SUBROUTINES >*
       // \****************************************************************/ *

       //***********************************************************************
       //* Write one line to the job log
       //******************
       Begsr Sbr_Log;
         Callp QMHSNDPM('CPF9898':'QCPFMSG   *LIBL':WrkMsgTxt:
                         %Len(%Trimr(WrkMsgTxt)):'*INFO':'*':0:
                         WrkMsgKey:WrkErrCde);
       Endsr;

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

         // URGENT restore: Mirakl/Amazon keep AIRRELCTL's original
         // behavior - submit OECPRTSD directly with no assigned
         // shipping-doc date. Every other channel still gets the
         // OERSDDAT/PLCCHKSGL date logic.
         If Ucase(%Trim(Bch@Ds.Desc20)) = 'MIRAKL EDI'
         or Ucase(%Trim(Bch@Ds.Desc20)) = 'AMAZON.COM NOTE';
           WrkCommand = 'SBMJOB CMD(CALL PGM(OECPRTSD)) '
                      + 'JOB(SDOC_'
                      + $E#1
                      + ') '
                      + 'OUTQ(HP1N) '
                      + 'JOBD(OPERATOR) '
                      + 'MSGQ(*NONE)';
           callp QCMDEXC(%Trim(WrkCommand):%Len(%Trim(WrkCommand)));
         Else;
           // Get the shipping-document date (rolls to next business day
           // off the DPPDAYS calendar unless the batch is Rush or
           // Milwaukee - same rule OERSLSD applies for a manual release).
           callp OERSDDAT(PrmSdatc);

           // Submit PLCCHKSGL with the ship-doc date, same as OERSLSD -
           // PLCCHKSGL decides pick/put single-line handling and P&S-
           // only routing before it submits OECPRTSD itself.
           WrkCommand = 'SBMJOB CMD(CALL PGM(PLCCHKSGL) '
                      + 'PARM('''
                      + PrmSdatc
                      + ''')) '
                      + 'JOB(SDOC_'
                      + $E#1
                      + ') '
                      + 'OUTQ(HP1N) '
                      + 'JOBD(OPERATOR) '
                      + 'DATE('
                      + PrmSdatc
                      + ') '
                      + 'MSGQ(*NONE)';
           callp QCMDEXC(%Trim(WrkCommand):%Len(%Trim(WrkCommand)));
         Endif;
       Endsr;

       //***********************************************************************
       //* Generate Order History
       //******************
       Begsr Sbr_Order_History;

         WrkOrdCnt = 0;

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

           // Same Ordsts/PickMthd rules OERSLSD applies on a manual release -
           // a batch-description override in PLPEBDESC wins, otherwise fall
           // back to the order's phone code.
           WrkPickPut = *Blanks;
           Exec Sql
             select PickPut into :WrkPickPut
               from PLPEBDESC
                 where Desc20 = :Bch@Ds.Desc20
                 fetch first row only;

           If Sqlcode = 0;
             If WrkPickPut = 'K';
               Hst@Ds.Ordsts   = 'W';
               Hst@Ds.PickMthd = 'T'; // Change to PUT
             Elseif WrkPickPut = 'T';
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

           //...Call ODRBLDTYPE to type all orders in batch
           PrmOrdnum = %Editc(Trk@Ds.Ordnum:'X');
           Callp ODRBLDTYPE(PrmOrdNum);
           WrkOrdCnt += 1;

           Exec Sql Fetch cur_Trk Into :Trk@Ds.Ordnum,
                                       :Trk@Ds.Keyb#,
                                       :Trk@Ds.Edtb#,
                                       :Trk@Ds.Phoncd;
         Enddo;

       Endsr;
