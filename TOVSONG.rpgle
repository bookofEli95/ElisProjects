     H DEBUG OPTION(*SRCSTMT: *NODEBUGIO) ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
     H/DEFINE PROFOUNDUI

      //*****************************************************************
      // TOVSONG
      // PCR: TOC File Upload Screen
      //*****************************************************************
      // Program Information
      //
      // Program History
      // Project        Date       Int Description
      // NEW            08/31/26   ELI Create initial upload program
      // NEW            09/25/26   ELI Upload dir /home/ELIASI, CALL(E)
      //*****************************************************************
      // Screen Files
     FTODSONGUP CF   E             WORKSTN
     F                                     HANDLER('PROFOUNDUI(HANDLER)')

      //*****************************************************************
      // Variables
      //*****************************************************************
      // Must match the upload widget's target directory on TODSONGUP
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
     C                   Call(E)   'TOCUPCL'
     C                   Parm                    FullIFSPath
      // On failure TOCUPCL has cleared TOCSTAGE and logged the reason
      // in the job log; stay on the screen so the user can retry
     C                   If        Not %Error
     C                   Leave
     C                   Endif
     C                   Endif

     C                   Enddo
     C                   Eval      *Inlr = *On
