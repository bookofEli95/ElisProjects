# RRN screens: suggested price on the re-run approval screens

The re-run repricing suggestion moves onto the existing online re-run (RRN)
screens, so marketing decides the re-run quantity and the price together, in
one place, with the sales, price and stock figures those screens already show.
The separate editor screen (`IVRRPCWRK`) is no longer needed for this.

These members are not in this repository, so the edits are given as inserts
against the SEU listings of 11/09/26, as in `RRN_FLAGS.md`. Sequence numbers
are the ones in those listings. Make them in the H33979 copies first, after
the `RRN_FLAGS.md` edits (both sets of edits share the same insert points
without clashing).

## What the screens already had

| Screen | Already shows |
|---|---|
| `IVRORRMKT` list | price (New Price in reverse image when set), last price change date, qty available, BO and consignment qty |
| `IVRORRMKT` detail (F4) | new price, current price, 12-month / last-year / 2-year sales, last run qty, quote |
| `IVRORRMKTC` change | current price, an editable **New Price** (saved to `IVPORRITM.NEWPRICE`, logged in `IVPORRMNT`), code price 1 (`IVPMSTOV.ROY1OV72`), new code price (`IVPORRITM.CODPR272`), and the "Is a new code price needed?" prompt |

## What changes

| Member | Change |
|---|---|
| `IVSORRMKT` (DSPF) | list: the price shows pink when a price change is waiting; detail: suggested price and the reason |
| `IVRORRMKT` (RPG) | read the open suggestion for each line loaded |
| `IVSORRMKTC` (DSPF) | line 12: suggested price and the reason |
| `IVRORRMKTC` (RPG) | show the suggestion, fill New Price with it, record the decision on the suggestion |

How the change screen works:

1. **Opening an item with a suggestion waiting.** Line 12 shows the suggested
   price and why. If New Price is empty it is filled in with the suggestion,
   and the message line says so.
2. **Deciding.** Keep the price, type another one, or blank it - then Enter,
   as for any change. A filled-in price always asks "Press Enter to confirm
   change." first, so a suggestion is never saved by an Enter that was meant
   for something else.
3. **Saving** writes New Price exactly as today, and records the decision on
   the suggestion (`IVPRPCSUG`):

   | New Price saved | Suggestion becomes |
   |---|---|
   | the suggested price | `A` approved |
   | any other price above the current one | `O` overridden, at that price |
   | blank, or not above the current price | `R` rejected |

   A price typed on this screen is a deliberate decision, so an override past
   the catalogue cap is recorded as authorised (`RPCOVRAUT 'Y'`) rather than
   held.

4. **Not touched from this screen:**
   - The Milwaukee views (`PrmOrrMilw` `Y`/`X`), where New Price is protected:
     nothing is filled in and the suggestion is left alone.
   - A **held** suggestion (`G`: third-party approval needed, or an override
     waiting to be authorised). It is shown, so marketing knows a price change
     is coming, but New Price is not filled in and the suggestion is not
     changed.

The monthly job (`IVRRPCAPL`) does the rest, unchanged: for `A`/`O` it finds
New Price already on the queue row, accepts it, rewrites the correction note to
the price note and marks the suggestion `X`; for `R` it releases the
correction note. Suggestions nobody acts on still expire.

One difference to know about: `IVRORRMKTC` reads the queue row by item number
only (the newest row), while the suggestion records the row it was raised
against (`RPCMINQDT`). For an item with two queue rows, `IVRRPCAPL` may stage
the price on the older row as well. The price is the same either way.

---

## 1. IVSORRMKT

**History** - add under the `------- -------- ---` line of File History:

```
     A* H33979  11/09/26 EFI Show the suggested price on the rerun screens
```

**Summary list, record `SFL1`** - under the `PRICE72` field, after its
`52 DSPATR(RI)` line (seq 11600):

```
     A  64                                  COLOR(PNK)
```

**Legend, record `SFLCTL1`** - after the `'Current '` heading and its line
(seq 19800). Row 4 is empty:

```
     A                                  4 63'Pink price = price suggested'
     A                                      COLOR(PNK)
```

**Detail view, record `SFL2`** - after `LRQTY2` and its `N50 DSPATR(HI)` line
(seq 35100). Rows 8 and 9 are free from column 80:

```
     A                                  8 81'SugPri'
     A                                  8 90'Why'
     A            SUGPRICE2      7Y 2O  9 81EDTCDE(4)
     A N50                                  DSPATR(HI)
     A                                      COLOR(PNK)
     A            SUGNOTE2      40A  O  9 90
     A                                      COLOR(PNK)
```

---

## 2. IVRORRMKT

**History** - first line under the `------- -------- ---` line (seq 4100):

```
       // H33979  11/09/26 EFI Show the suggested price on the rerun screens
```

**Variables** - after `D WrkItmNum` (seq 20100):

```
     D WrkSugItm       S              8S 0
     D WrkSugStat      S              1A
     D WrkSugPrc       S              9S 2
     D WrkSugNote      S             60A
```

**Summary list, both loops** - immediately before
`Exsr Sbr_Get_Last_Price_Change_Date;` at seq 61800 and again at seq 84900:

```
                 WrkSugItm = Scn_ItmNum;
                 Exsr Sbr_Get_Suggestion;
```

**Detail view, both loops** - immediately before `Write SFL2;` at seq 109600
and again at seq 130100:

```
                 WrkSugItm = Scn_ItmNum2;
                 Exsr Sbr_Get_Suggestion;
```

**New subroutine** - before the comment box of `Sbr_Update_Date_and_Time`
(seq 224400). The program already uses embedded SQL (seq 59600), so this reads
the suggestion the same way, through the library list:

```
       //***********************************************************************
       //* Open price suggestion for the item (IVPRPCSUG) **
       //***********************************************************************
       Begsr Sbr_Get_Suggestion;

          // Only one suggestion is open for an item at a time. An
          // override shows the price the editor chose.
          WrkSugStat = *Blanks;
          WrkSugPrc  = *Zeros;
          WrkSugNote = *Blanks;
          Exec Sql
             Select RpcStat,
                    Case When RpcStat = 'O' Then RpcApp72
                         Else RpcSug72 End,
                    RpcNote
               Into :WrkSugStat, :WrkSugPrc, :WrkSugNote
               From IVPRPCSUG
              Where ItmNum = :WrkSugItm
                And RpcStat In ('S', 'G', 'A', 'O')
              Order By RpcCycl Desc
              Fetch First 1 Row Only;
          If SqlCod <> 0;
             WrkSugStat = *Blanks;
             WrkSugPrc  = *Zeros;
             WrkSugNote = *Blanks;
          Endif;

          // Pink on the list: a price change is waiting for a decision
          *In64 = (WrkSugStat = 'S' Or WrkSugStat = 'G');

          Scn_SugPrice2 = WrkSugPrc;
          Scn_SugNote2  = WrkSugNote;

       Endsr;
```

---

## 3. IVSORRMKTC

**History** - add under the `------- -------- ---` line of File History:

```
      * H33979  11/09/26 EFI Show the suggested price on the change screen
```

**Record `SCREEN1`** - after the `QUOTEWHO` field on row 12 (seq 19300). Row 12
is free from column 33. The heading only shows when there is a suggestion
(indicator 63), and the price and reason are blank otherwise:

```
     A  63                             12 33'Suggested:'
     A            SUGPRICE       7Y 2O 12 44EDTCDE(M)
     A                                      DSPATR(HI)
     A                                      COLOR(PNK)
     A            SUGNOTE       27A  O 12 54COLOR(PNK)
```

This takes row 12, where `RRN_FLAGS.md` first put the printed price and
third-party fields. Those now go on row 15 - see `RRN_FLAGS.md`, section 3.

---

## 4. IVRORRMKTC

**History** - first line under the `------- -------- ---` line (seq 1800):

```
       // H33979  11/09/26 EFI Show the suggested price on the change screen
```

**File** - after `FIVPORRMNT` (seq 7100):

```
     FIVPRPCSUG UF   E           K DISK    Prefix(Sug_)
```

**Variables** - after `D SavFlipToPOD` (seq 11600):

```
     D WrkSugFnd       S              1A   Inz('N')
     D WrkSugFill      S              1A   Inz('N')
     D WrkSugCycl      S              6S 0
     D WrkSugNewSt     S              1A
```

**Load** - after `Scn_CodPr272 = Orr_CodPr272;` (seq 19200):

```
          // Suggested price (re-run repricing). Shown on line 12; when no
          // new price has been set yet it is put in New Price for the user
          // to keep, change or blank. Not in the Milwaukee views, where New
          // Price is protected, and not while the suggestion is held.
          Exsr Sbr_Get_Suggestion;
          If WrkSugFnd = 'Y' And Sug_RpcStat = 'S'
             And Scn_NewPrice = *Zeros
             And PrmOrrMilw <> 'Y' And PrmOrrMilw <> 'X';
             Scn_NewPrice = Sug_RpcSug72;
             WrkSugFill   = 'Y';
             Scn_Msg = 'New Price filled in with the suggested price.';
          Endif;
```

**Save** - after `SavFlipToPOD = Scn_FlipToPOD;` (seq 21000):

```
          // A filled-in suggestion counts as a change the first time round,
          // so it is never saved without the user confirming it.
          If WrkSugFill = 'Y';
             SavNewPrice = *Zeros;
             WrkSugFill  = 'N';
          Endif;
```

**Update** - after `Update IV$ORRITM;` (seq 44300):

```
             Exsr Sbr_Upd_Suggestion;
```

**New subroutines** - before the comment box of `SbrUpdDtTm` (seq 52500):

```
       //***********************************************************************
       //* Find the open price suggestion for the item **
       //***********************************************************************
       Begsr Sbr_Get_Suggestion;

          WrkSugFnd    = 'N';
          Scn_SugPrice = *Zeros;
          Scn_SugNote  = *Blanks;
          *In63        = *Off;

          // Newest cycle first. Only one suggestion is open for an item
          // at a time.
          Setgt WrkItmNum IVPRPCSUG;
          Readpe(N) WrkItmNum IVPRPCSUG;
          Dow Not %Eof(IVPRPCSUG);
             If Sug_RpcStat = 'S' Or Sug_RpcStat = 'G'
                Or Sug_RpcStat = 'A' Or Sug_RpcStat = 'O';
                WrkSugFnd  = 'Y';
                WrkSugCycl = Sug_RpcCycl;
                Leave;
             Endif;
             Readpe(N) WrkItmNum IVPRPCSUG;
          Enddo;

          If WrkSugFnd = 'Y';
             *In63 = *On;
             If Sug_RpcStat = 'O';
                Scn_SugPrice = Sug_RpcApp72;
             Else;
                Scn_SugPrice = Sug_RpcSug72;
             Endif;
             Scn_SugNote = Sug_RpcNote;
          Endif;

       Endsr;

       //***********************************************************************
       //* Record the price decision on the suggestion **
       //***********************************************************************
       Begsr Sbr_Upd_Suggestion;

          // New Price is protected in the Milwaukee views, so no price
          // decision was made there.
          If WrkSugFnd <> 'Y'
             Or PrmOrrMilw = 'Y' Or PrmOrrMilw = 'X';
             Leavesr;
          Endif;

          Chain (WrkItmNum : WrkSugCycl) IVPRPCSUG;
          If Not %Found(IVPRPCSUG);
             Leavesr;
          Endif;

          // A held suggestion waits on a third party, or on an override
          // being authorised - neither of which this screen gives.
          If Sug_RpcStat <> 'S' And Sug_RpcStat <> 'A'
             And Sug_RpcStat <> 'O';
             Unlock IVPRPCSUG;
             Leavesr;
          Endif;

          Select;
          When Scn_NewPrice = Sug_RpcSug72;
             WrkSugNewSt = 'A';
          When Scn_NewPrice > Sug_RpcCur72;
             WrkSugNewSt = 'O';
          Other;
             WrkSugNewSt = 'R';
          Endsl;

          // Nothing new to record
          If WrkSugNewSt = Sug_RpcStat
             And (WrkSugNewSt <> 'O' Or Sug_RpcApp72 = Scn_NewPrice);
             Unlock IVPRPCSUG;
             Leavesr;
          Endif;

          Sug_RpcStat  = WrkSugNewSt;
          Sug_RpcEditr = SdsUser;
          Sug_RpcActTs = %Timestamp();
          Select;
          When WrkSugNewSt = 'A';
             Sug_RpcApp72  = Sug_RpcSug72;
             Sug_RpcApp112 = Sug_RpcSug112;
             Sug_RpcNote   = 'APPROVED ON THE RERUN SCREEN';
          When WrkSugNewSt = 'O';
             // PRICE112 takes the same number, as IVRRPCWRK does. A price
             // typed here is deliberate, so a cap breach is authorised.
             Sug_RpcApp72  = Scn_NewPrice;
             Sug_RpcApp112 = Scn_NewPrice;
             Sug_RpcOvrAut = 'Y';
             Sug_RpcNote   = 'NEW PRICE SET ON THE RERUN SCREEN';
          Other;
             Sug_RpcNote   = 'NO PRICE CHANGE - RERUN SCREEN';
          Endsl;
          Update IV$RPCSUG;

       Endsr;
```

---

## Compile and test (H33979)

```
CRTDSPF FILE(H33979/IVSORRMKT)  SRCFILE(H33979/QDDSSRC)
CRTDSPF FILE(H33979/IVSORRMKTC) SRCFILE(H33979/QDDSSRC)
```

Then compile `IVRORRMKT` and `IVRORRMKTC` into H33979 the usual way (PDM
option). With H33979 first in the library list, and an item that has an open
suggestion in `H33979.IVPRPCSUG` (status `S`):

1. **List.** The item's price is pink. F4: the detail view shows `SugPri` and
   the reason.
2. **Change screen.** Line 12 shows the suggested price; New Price is filled
   in and the message says so. Press Enter: "Press Enter to confirm change."
   Enter again (answer the code price prompt if it asks).
3. Check the suggestion and the queue:

   ```
   SELECT RPCSTAT, RPCAPP72, RPCEDITR, RPCNOTE
     FROM H33979.IVPRPCSUG WHERE ITMNUM = <item>;
   SELECT NEWPRICE FROM H33979.IVPORRITM WHERE ITMNUM = <item>;
   ```

   `A`, the suggested price, you, `APPROVED ON THE RERUN SCREEN`; `NEWPRICE`
   the suggested price.
4. Repeat on another item, typing a different price: `O` at that price. On a
   third, blank New Price: `R`.
5. `CALL IVRRPCAPL PARM('A' ' ')` (apply only, no new suggestions): the `A`
   and `O` items go to `X` and their correction note becomes the price note;
   the `R` item's note is removed.
