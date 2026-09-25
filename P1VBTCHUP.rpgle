     H DEBUG OPTION(*SRCSTMT: *NODEBUGIO) ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
     H/DEFINE PROFOUNDUI

      //*****************************************************************
      // P1VBTCHUP
      // PCR: Batch Upload - Upload Screen
      //*****************************************************************
      // Program Information
      //
      // Program History
      // Project        Date       Int Description
      // H33975         09/25/26   EFI Create initial upload screen
      //*****************************************************************
      // Screen Files
     FP1DBTCHUP CF   E             WORKSTN
     F                                     HANDLER('PROFOUNDUI(HANDLER)')

      //*****************************************************************
      // Variables
      //*****************************************************************
      // Must match the upload widget's target directory on P1DBTCHUP
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
     C                   Call(E)   'P1CBTCHUP'
     C                   Parm                    FullIFSPath
      // On failure P1CBTCHUP has cleared PCRSTAGE and logged the
      // reason in the job log; stay on the screen so the user can retry
     C                   If        Not %Error
     C                   Leave
     C                   Endif
     C                   Endif

     C                   Enddo
     C                   Eval      *Inlr = *On
