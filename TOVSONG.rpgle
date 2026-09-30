     H DEBUG OPTION(*SRCSTMT: *NODEBUGIO) ALWNULL(*USRCTL)
     H DFTACTGRP(*NO)
     H/DEFINE PROFOUNDUI

       //***********************************************************************
       // TOVSONG
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // PCR: TOC File Upload Screen
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // NEW     08/31/26 ELI Create initial upload program

      // Screen Files
     FTODSONGUP CF   E             WORKSTN
     F                                     HANDLER('PROFOUNDUI(HANDLER)')

      //*****************************************************************
      // Variables
      //*****************************************************************
      // UPLOADFILE is the upload widget's "upload response": a 3-digit
      // file count, the 256-byte target directory, then a 256-byte name
      // per uploaded file. Only the first uploaded file is processed.
     D UploadDir       S            256A
     D UploadName      S            256A
     D FullIFSPath     S            256A

      //*****************************************************************
      // MainLine
      //*****************************************************************
     C                   Dow       1=1
     C                   Exfmt     ADD

     C                   If        btnUpload = *On
     C                   Eval      UploadDir  = %Subst(UPLOADFILE : 4 : 256)
     C                   Eval      UploadName = %Subst(UPLOADFILE : 260 : 256)
     C                   Eval      FullIFSPath = %TrimR(UploadDir) + '/' +
     C                                           %Trim(UploadName)
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
