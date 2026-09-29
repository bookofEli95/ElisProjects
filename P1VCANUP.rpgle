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
     C                   Eval      Message = *Blanks

     C                   If        BtnExit = *On
     C                   Leave
     C                   Endif

     C                   If        BtnUpload = *On
     C                   Eval      UploadDir  = %Subst(UPLOADFILE : 4 : 256)
     C                   Eval      UploadName = %Subst(UPLOADFILE : 260 : 256)
     C                   If        UploadName = *Blanks
     C                   Eval      Message = 'Please upload a CSV file first'
     C                   Iter
     C                   Endif

     C                   Eval      FullIFSPath = %TrimR(UploadDir) + '/' +
     C                                           %Trim(UploadName)
     C                   Call(E)   'P1CCANCL2'
     C                   Parm                    FullIFSPath
     C                   If        Not %Error
     C                   Leave
     C                   Endif
     C                   Eval      Message = 'Close failed - check the file ' +
     C                                       'and try again'
     C                   Endif

     C                   Enddo
     C                   Eval      *Inlr = *On
