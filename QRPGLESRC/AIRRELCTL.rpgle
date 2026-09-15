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

     D OERSDDAT        PR
     D  PrmSdatc                     6A

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
     D WrkSddtea       S              6A
     D WrkPickPut      S              1A

     D WrkSbmJob       S            114A   Inz('SBMJOB CMD(CALL PGM(PLCCHKSGL) -
     D                                          PARM(''xxxxxx'')) JOB(SDOC_xxx)-
     D                                           JOBD(OPERATOR) OUTQ(HP1N) DATE-
     D                                          (xxxxxx) MSGQ(*NONE)')
     D WrkLength       S             15  5 Inz(114)

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

         // Get the shipping-document date (rolls to next business day off
         // the DPPDAYS calendar unless the batch is Rush or Milwaukee -
         // same rule OERSLSD applies for a manual release).
         callp OERSDDAT(PrmSdatc);
         WrkSddtea = PrmSdatc;

         // Submit PLCCHKSGL with the ship-doc date, same as OERSLSD -
         // PLCCHKSGL decides pick/put single-line handling and P&S-only
         // routing before it submits OECPRTSD itself.
         %Subst(WrkSbmJob:57:3) = $E#1;
         %Subst(WrkSbmJob:38:6) = WrkSddtea;
         %Subst(WrkSbmJob:96:6) = WrkSddtea;

         Call 'QCMDEXC'
           Parm WrkSbmJob
           Parm WrkLength
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

           // Same Ordsts/PickMthd rules OERSLSD applies on a manual release -
           // a batch-description override in PLPEBDESC wins, otherwise fall
           // back to the order's phone code.
           WrkPickPut = *Blanks;
           Exec Sql
             select PickPut into :WrkPickPut
               from PLPEBDESC
                 where Desc = :Bch@Ds.Desc20
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

           Exec Sql Fetch cur_Trk Into :Trk@Ds.Ordnum,
                                       :Trk@Ds.Keyb#,
                                       :Trk@Ds.Edtb#,
                                       :Trk@Ds.Phoncd;
         Enddo;

       Endsr;
