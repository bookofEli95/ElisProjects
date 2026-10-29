     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // ARRHRUPL
       // AR: Cash Receipts Posting Upload
       //***********************************************************************

       //***********************************************************************
       // Program Information
       //-----------------------------------------------------------------------
       // Reads the raw High Radius CSV lines in ARWCASHUP3, splits each line
       // into columns and writes the parsed fields to ARWCASHUP4 for ABRCASHRP.
       //***********************************************************************

       //***********************************************************************
       // Program History
       //-----------------------------------------------------------------------
       // Project   Date   Int Description
       // ------- -------- --- -------------------------------------------------
       // H33949  09/29/26 EFI Quick Fix -  Invoice: use col 11 (Original
       //                      Reference), fall back to col 10 (Invoice Number)
       //                      when col 11 is not an invoice on the customer
       //***********************************************************************

       // Input Files
     FARWCASHUP3IF   E             DISK    Prefix(Up1_)
     F                                     Rename(ARWCASHUP3:AR$CASHUP3)

     FOPNITM1   IF   E           K DISK    Prefix(Opn_)

       // Output Files
     FARWCASHUP4UF A E           K DISK    Prefix(Csh_)

       //***********************************************************************
       //* Prototypes *
       //**************

      /copy qcopysrc,dprgettok4
      /copy qcopysrc,arrcashup1

       //***********************************************************************
       //* Variables *
       //*************

     D ARRHRUPL        PI
     D PrmError                     200A

      /copy qcopysrc,uplow

     D WrkArrToken     S            100A   Dim(100)
     D WrkElemSep      S              1A   Inz(',')
     D PrmRecord       S           5000A
     D WrkElement      S              3  0
     D WrkColumn       S            100A
     D WrkRow          S             15S 0
     D WrkCustNo       S                   Like(Csh_CUSTNO)
     D WrkChkAmt       S                   Like(Csh_CHKAMT)
     D WrkCust7        S                   Like(Csh_CUSTNO)
     D WrkCust8        S                   Like(Csh_CUSTNO)
     D WrkCheck#       S                   Like(Csh_CHECK#)
     D WrkChkDte       S                   Like(Csh_CHKDTE)
     D WrkInvNum       S                   Like(Csh_INVNUM)
     D WrkInv10        S                   Like(Csh_INVNUM)
     D WrkInv11        S                   Like(Csh_INVNUM)
     D WrkTestInv      S                   Like(Csh_INVNUM)
     D WrkFound        S               N
     D WrkAplAmt       S                   Like(Csh_APLAMT)
     D WrkAplDis       S                   Like(Csh_APLDIS)
     D RunCmd          PR                  ExtPgm('QCMDEXC')
     D  CmdString                  3000A   Const Options(*VarSize)
     D  CmdLength                    15P 5 Const

     D EmailCmd        S            500A

       //***********************************************************************
       //* Main Line **
       //**************

         Dow 1 = 1;
           Read ARWCASHUP3;
           If %Eof(ARWCASHUP3);
             Leave;
           Endif;

           Clear WrkArrToken;
           PrmRecord  = %Trim(Up1_ARWCASHUP3);
           Callp DPRGETTOK4 (PrmRecord : WrkElemSep : WrkArrToken);
           WrkRow += 1;
           If WrkRow = 1;
              Iter;
           Endif;

           // --- 0. Clear variables ---
           WrkCustNo = 0;
           WrkCheck# = *Blanks;
           WrkChkDte = *Blanks;
           WrkInvNum = *Blanks;
           WrkAplAmt = 0;
           WrkAplDis = 0;
           WrkChkAmt = 0;

           // --- 1. Extract Customer Number (Columns 7 and 8) ---
           WrkCust7 = 0;
           WrkCust8 = 0;

           // Get Column 7
           WrkArrToken(7) = %ScanRpl('"' : '' : WrkArrToken(7));
           WrkColumn = %Trim(WrkArrToken(7));
           If WrkColumn <> *Blanks;
              Monitor;
                 WrkCust7 = %Int(WrkColumn);
              On-Error;
              Endmon;
           Endif;

           // Get Column 8
           WrkArrToken(8) = %ScanRpl('"' : '' : WrkArrToken(8));
           WrkColumn = %Trim(WrkArrToken(8));

           If WrkColumn <> *Blanks;
              // Reject value if it contains a decimal point
              If %Scan('.' : WrkColumn) > 0;
                 WrkCust8 = 0;
              Else;
                 Monitor;
                    WrkCust8 = %Int(WrkColumn);
                 On-Error;
                    WrkCust8 = 0;
                 Endmon;
              Endif;
           Endif;

           // Apply Logic: Use Col 8 if different from Col 7,
           // UNLESS Col 8 is 0 (blank/invalid cast) or 1.
           If WrkCust8 <> WrkCust7 AND WrkCust8 <> 0 AND WrkCust8 <> 1;
              WrkCustNo = WrkCust8;
           Else;
              WrkCustNo = WrkCust7;
           Endif;

           // --- 2. Extract Check Number
           WrkArrToken(2) = %ScanRpl('"' : '' : WrkArrToken(2));
           WrkCheck# = %Trim(WrkArrToken(2));

           // --- 3. Extract Check Date - MM/DD/YYYY
           WrkArrToken(1) = %ScanRpl('"' : '' : WrkArrToken(1));
           WrkChkDte = %Trim(WrkArrToken(1));

           // --- 4. Extract Invoice Number
           // Column 11 (Original Reference) is preferred. When it is not an
           // invoice on this customer, fall back to column 10 (Invoice Number)
           // if THAT is. If neither is found, keep column 11 as before.
           WrkArrToken(11) = %ScanRpl('"' : '' : WrkArrToken(11));
           WrkColumn = %Trim(%Xlate(WrkLow:WrkUp:WrkArrToken(11)));
           WrkInv11 = *Blanks;
           If WrkColumn <> *Blanks;
              WrkInv11 = %Trim(WrkColumn);
           Endif;

           WrkArrToken(10) = %ScanRpl('"' : '' : WrkArrToken(10));
           WrkColumn = %Trim(%Xlate(WrkLow:WrkUp:WrkArrToken(10)));
           WrkInv10 = *Blanks;
           If WrkColumn <> *Blanks;
              WrkInv10 = %Trim(WrkColumn);
           Endif;

           WrkInvNum = WrkInv11;
           If WrkInv10 <> *Blanks;
              WrkTestInv = WrkInv11;
              Exsr Sbr_InvOnCust;
              If Not WrkFound;
                 WrkTestInv = WrkInv10;
                 Exsr Sbr_InvOnCust;
                 If WrkFound;
                    WrkInvNum = WrkInv10;
                 Endif;
              Endif;
           Endif;

           // --- 4.5. Fallback Customer Lookup ---
           If WrkCustNo = 0;
              Chain WrkInvNum OPNITM1;

              If %Found(OPNITM1);
                 WrkCustNo = Opn_Ocust#;
              Else;
                 // Invoice not found, no customer provided. Alert, drop row.
                 EmailCmd = 'SNDSMTPEMM RCPT((ELIASI@HALLEONARD.COM)) ' +
                            'SUBJECT(''High Radius Upload Failure'') ' +
                            'NOTE(''Check: ' + %Trim(WrkCheck#) +
                            ' Invoice: ' + %Trim(WrkInvNum) +
                            ' failed. No customer number and invoice not +
                            found.'')';
                 Monitor;
                    RunCmd(%Trim(EmailCmd) : %Len(%Trim(EmailCmd)));
                 On-Error;
                 Endmon;

                 Iter;
              Endif;
           Endif;

           // --- 5. Extract Apply Amount (Column 13) ---
           WrkArrToken(13) = %ScanRpl('"' : '' : WrkArrToken(13));
           WrkColumn = %Trim(WrkArrToken(13));
           If WrkColumn <> *Blanks;
              Monitor;
                 WrkAplAmt = %Dec(WrkColumn:9:2);
              On-Error;
              Endmon;
           Endif;

           // --- 6. Extract Discount Amount (Column 14) ---
           WrkArrToken(14) = %ScanRpl('"' : '' : WrkArrToken(14));
           WrkColumn = %Trim(WrkArrToken(14));
           If WrkColumn <> *Blanks;
              Monitor;
                 WrkAplDis = %Dec(WrkColumn:6:2);
              On-Error;
              Endmon;
           Endif;

           // --- 7. Extract Total Check Amount (Column 3) ---
           WrkArrToken(3) = %ScanRpl('"' : '' : WrkArrToken(3));
           WrkColumn = %Trim(WrkArrToken(3));
           If WrkColumn <> *Blanks;
              WrkColumn = %ScanRpl(',' : '' : WrkColumn);
              WrkColumn = %ScanRpl('$' : '' : WrkColumn);
              Monitor;
                 WrkChkAmt = %Dec(WrkColumn:9:2);
              On-Error;
                 WrkChkAmt = 0;
              Endmon;
           Endif;

           // --- Write to ARWCASHUP4 ---
           Clear AR$CASHUP4;
           Csh_CustNo = WrkCustNo;
           Csh_Check# = WrkCheck#;
           Csh_ChkDte = WrkChkDte;
           Csh_InvNum = WrkInvNum;
           Csh_AplAmt = WrkAplAmt;
           Csh_AplDis = WrkAplDis;
           Csh_ChkAmt = WrkChkAmt;

           Write AR$CASHUP4;
         Enddo;

         *InLr = *On;

       //***********************************************************************
       // Sbr_InvOnCust - Is WrkTestInv an invoice on customer WrkCustNo?
       //   In : WrkTestInv, WrkCustNo (0 = customer unknown, any customer)
       //   Out: WrkFound
       //***********************************************************************
         Begsr Sbr_InvOnCust;
            WrkFound = *Off;
            Setll WrkTestInv OPNITM1;
            Reade WrkTestInv OPNITM1;
            Dow Not %Eof(OPNITM1);
               If WrkCustNo = 0 Or Opn_Ocust# = WrkCustNo;
                  WrkFound = *On;
                  Leave;
               Endif;
               Reade WrkTestInv OPNITM1;
            Enddo;
         Endsr;
