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
