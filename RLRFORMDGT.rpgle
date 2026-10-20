     H DEBUG OPTION(*SRCSTMT:*NODEBUGIO) ALWNULL(*USRCTL)
       //***********************************************************************
       // RLRFORMDGT
       // RL: Build statements work file - HLE digital
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
       // FIX     07/24/25 SAC Digital In School, In Store Sales
       // H31966  05/27/25 TAK Process HLE digital royalties
       //***********************************************************************

       // Input Files
     FHEWITEMSR IF   E           K DISK    Prefix(Hit_)
     FHELDGTSUM2IF   E           K DISK    Prefix(Sls_)
     FHELDGTINS2IF   E           K DISK    Prefix(Sls_)
     FIVPITEMS  IF   E           K DISK    Prefix(Itm_)

       // Update Files
     FRLMFORMHL1UF A E           K DISK    Prefix(Hle_)

       //***********************************************************************
       //* Prototypes *
       //**************

       //***********************************************************************
       //* Entry Parameters *
       //********************

       //***********************************************************************
       //* Variables *
       //*************

       // Work Variables
     D WrkPubcode      S             50A   Inz('HLEROYD')

       //***********************************************************************
       //* Main Line *
       //*************

       Dow 1 = 1;
          Read HEWITEMSR;
          If %Eof(HEWITEMSR);
             Leave;
          Endif;

          // Instore
          Setll Hit_Itmnum HELDGTINS2;
          Dow 1 = 1;
             Reade Hit_Itmnum HELDGTINS2;
             If %Eof(HELDGTINS2);
                Leave;
             Endif;

             // Process current period
             If Sls_Year = 2025
               and Sls_Month in %List(1:2:3:4:5:6);

             Else;
                Iter;
             Endif;

             // Store all sales where the price changed
             Chain (Hit_Itmnum:
                    Sls_FCC:
                    Sls_Year:
                    Sls_Month:
                    Sls_Price112:
                    WrkPubcode) RLMFORMHL1;
             If %Found(RLMFORMHL1);
                Hle_InvQty    += Sls_Qty;
                Hle_SlsAmtGBP += Sls_Extdol;
                Hle_ExtdolUSD += Sls_ExtdolUSD;
                Hle_ExtdolGBP += Sls_ExtdolGBP;
                Update RL$FORMHLE %Fields(Hle_InvQty:
                                          Hle_SlsAmtGBP:
                                          Hle_ExtdolUSD:
                                          Hle_ExtdolGBP);

             Else;

                Clear RL$FORMHLE;

                Hle_Itmnum    = Hit_Itmnum;

                Hle_FCC       = Sls_FCC;

                Hle_Year      = Sls_Year;
                Hle_Month     = Sls_Month;

                Chain Hit_Itmnum IVPITEMS;

                Hle_Desc      = Itm_Sdesc;
                Hle_Price112  = Sls_Price112;
                Hle_InvQty    = Sls_Qty;
                Hle_SlsAmtGBP = Sls_Extdol;
                Hle_NetPrice  = Sls_NetPrice;
                Hle_PriceUSD  = Sls_PriceUSD;
                Hle_PriceGBP  = Sls_PriceGBP;
                Hle_ExtdolUSD = Sls_ExtdolUSD;
                Hle_ExtdolGBP = Sls_ExtdolGBP;

                Hle_Pubcode   = 'HLEROYD';

                Hle_Currency  = Sls_Currency;

                Write RL$FORMHLE;

             Endif;

          Enddo;


          // Digital API
          Setll Hit_Itmnum HELDGTSUM2;
          Dow 1 = 1;
             Reade Hit_Itmnum HELDGTSUM2;
             If %Eof(HELDGTSUM2);
                Leave;
             Endif;

             // Process current period
             If Sls_Year = 2025
               and Sls_Month in %List(1:2:3:4:5:6);

             Else;
                Iter;
             Endif;

             // Store all sales where the price changed
             Chain (Hit_Itmnum:
                    Sls_FCC:
                    Sls_Year:
                    Sls_Month:
                    Sls_Price112:
                    WrkPubcode) RLMFORMHL1;
             If %Found(RLMFORMHL1);
                Hle_InvQty    += Sls_Qty;
                Hle_SlsAmtGBP += Sls_Extdol;
                Hle_ExtdolUSD += Sls_ExtdolUSD;
                Hle_ExtdolGBP += Sls_ExtdolGBP;
                Update RL$FORMHLE %Fields(Hle_InvQty:
                                          Hle_SlsAmtGBP:
                                          Hle_ExtdolUSD:
                                          Hle_ExtdolGBP);

             Else;

                Clear RL$FORMHLE;

                Hle_Itmnum    = Hit_Itmnum;

                Hle_FCC       = Sls_FCC;

                Hle_Year      = Sls_Year;
                Hle_Month     = Sls_Month;

                Chain Hit_Itmnum IVPITEMS;

                Hle_Desc      = Itm_Sdesc;
                Hle_Price112  = Sls_Price112;
                Hle_InvQty    = Sls_Qty;
                Hle_SlsAmtGBP = Sls_Extdol;
                Hle_NetPrice  = Sls_NetPrice;
                Hle_PriceUSD  = Sls_PriceUSD;
                Hle_PriceGBP  = Sls_PriceGBP;
                Hle_ExtdolUSD = Sls_ExtdolUSD;
                Hle_ExtdolGBP = Sls_ExtdolGBP;

                Hle_Pubcode   = 'HLEROYD';

                Hle_Currency  = Sls_Currency;

                Write RL$FORMHLE;

             Endif;

          Enddo;
       Enddo;

       *Inlr = *On;
