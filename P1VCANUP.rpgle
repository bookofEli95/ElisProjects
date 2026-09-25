     H DEBUG OPTION(*SRCSTMT: *NODEBUGIO) ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
     H/DEFINE PROFOUNDUI

      //*****************************************************************
      // P1VCANUP
      // PCR: Batch Close/Cancel PCRs - Upload Screen
      //*****************************************************************
      // Program Information
      //
      // Program History
      // Project        Date       Int Description
      // H33975         09/25/26   EFI Create initial upload screen
      //*****************************************************************
      // Screen Files
     FP1DCANUP  CF   E             WORKSTN
     F                                     HANDLER('PROFOUNDUI(HANDLER)')

      //*****************************************************************
      // Variables
      //*****************************************************************
     D FullIFSPath     S            256A

      //*****************************************************************
      // MainLine
      //*****************************************************************
     C                   Dow       1=1
     C                   Exfmt     UPLOAD

     C                   If        btnUpload = *On
     C                   Eval      FullIFSPath = '/tmp/pcr_uploads/' +
     C                                           %Trim(UPLOADFILE)
     C                   Call      'P1CCANCL2'
     C                   Parm                    FullIFSPath
     C                   Leave
     C                   Endif

     C                   Enddo
     C                   Eval      *Inlr = *On
