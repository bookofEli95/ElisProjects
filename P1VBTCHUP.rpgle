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
      // UPLOADFILE is the upload widget's "upload response": a 3-digit
      // file count, the 256-byte target directory, then a 256-byte name
      // per uploaded file. Only the first uploaded file is processed.
     D UploadDir       S            256A
     D UploadName      S            256A
     D FullIFSPath     S            256A
     D UpperName       S            256A
     D NameLen         S              5I 0
     D NameExt         S              4A

      /copy qcopysrc,uplow

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

      // CPYFRMIMPF can only read a delimited text file - an Excel
      // workbook (.xlsx) makes the CL crash with a program dump
     C                   Eval      UpperName = %Xlate(WrkLow : WrkUp :
     C                                                UploadName)
     C                   Eval      NameLen = %Len(%TrimR(UpperName))
     C                   Eval      NameExt = *Blanks
     C                   If        NameLen >= 4
     C                   Eval      NameExt = %Subst(UpperName : NameLen - 3 : 4)
     C                   Endif
     C                   If        NameExt <> '.CSV'
     C                   Eval      Message = 'Please upload a .csv file ' +
     C                             '(Excel: Save As, CSV Comma delimited)'
     C                   Iter
     C                   Endif

     C                   Eval      FullIFSPath = %TrimR(UploadDir) + '/' +
     C                                           %Trim(UploadName)
     C                   Call(E)   'P1CBTCHUP'
     C                   Parm                    FullIFSPath
     C                   If        Not %Error
     C                   Leave
     C                   Endif
     C                   Eval      Message = 'Upload failed - check the file ' +
     C                                       'and try again'
     C                   Endif

     C                   Enddo
     C                   Eval      *Inlr = *On
