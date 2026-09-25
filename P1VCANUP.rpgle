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
      // Must match the upload widget's target directory on P1DCANUP
     D UploadDir       C                   '/home/ELIASI/'
     D FullIFSPath     S            256A

      //*****************************************************************
      // MainLine
      //*****************************************************************
     C                   Dow       1=1
     C                   Exfmt     ADD

     C                   If        btnUpload = *On
     C                   Eval      FullIFSPath = UploadDir +
     C                                           %Trim(UPLOADFILE)
     C                   Call(E)   'P1CCANCL2'
     C                   Parm                    FullIFSPath
      // On failure P1CCANCL2 has cleared PCRCANSTG and logged the
      // reason in the job log; stay on the screen so the user can retry
     C                   If        Not %Error
     C                   Leave
     C                   Endif
     C                   Endif

     C                   Enddo
     C                   Eval      *Inlr = *On
