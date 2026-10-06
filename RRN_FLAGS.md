# RRN screens: printed price and third-party approval (SOS-2092, SOS-2520)

Edits to the four existing online re-run (RRN) members so the two `IVPPRTPRT`
flags can be seen on the marketing list and changed on the change screen,
with every change written to `IVPMAINT` like any other item field.

These members are not in this repository, so the edits are given as inserts
against the SEU listings of 10/01/26 and 10/05/26. Sequence numbers are the
ones in those listings. Make them in the H33979 copies first.

| Member | Change |
|---|---|
| `IVSORRMKT` (DSPF) | two 1-character columns at the right of the summary list; two fields on the detail view |
| `IVRORRMKT` (RPG) | read `IVPPRTPRT` for each line loaded |
| `IVSORRMKTC` (DSPF) | two entry fields on line 12 |
| `IVRORRMKTC` (RPG) | load, confirm and save the flags; one `IVPMAINT` row per flag changed |

Values: printed price `Y` / `N` / `S` (stickered) / blank (not known);
third-party approval `Y` / `N` / blank. Blank is a valid choice - an item can
stay blank until someone has physically checked it.

---

## 1. IVSORRMKT

**History** - add under the `------- -------- ---` line of File History:

```
     A* H33979  10/06/26 EFI Show printed price and 3rd party approval flags
```

**Summary list, record `SFL1`** - after the `PAGES` field and its `N50 DSPATR(HI)`
line (just before the `****` lines that end SFL1). Row 8 ends at column 123
(`BINDNG`), so these sit in the free space at 126 and 130:

```
     A            PRTPRC         1A  O  8126
     A N50                                  DSPATR(HI)
     A            TPAPRV         1A  O  8130
     A N50                                  DSPATR(HI)
```

**Column headings, record `SFLCTL1`** - after the `'Binding'` heading and its
two lines. Row 7 is taken at 121-127 by `Binding`, so the headings use rows 5
and 6, the way `Last Price / Change` does:

```
     A                                  5125'Prt'
     A                                      DSPATR(RI)
     A                                      COLOR(GRN)
     A                                  6125'Prc'
     A                                      DSPATR(RI)
     A                                      COLOR(GRN)
     A                                  5129'3rd'
     A                                      DSPATR(RI)
     A                                      COLOR(GRN)
     A                                  6129'Pty'
     A                                      DSPATR(RI)
     A                                      COLOR(GRN)
```

**Detail view, record `SFL2`** - after `FRUNDT2` and its `N50 DSPATR(HI)` line
on row 10 (it ends at column 78):

```
     A                                 10 80'PrtPrc'
     A            PRTPRC2        1A  O 10 87
     A N50                                  DSPATR(HI)
     A                                 10 89'3rdPty'
     A            TPAPRV2        1A  O 10 96
     A N50                                  DSPATR(HI)
```

The header of IVRORRMKT says a change here may also need one in `IVVORRMKT`;
the header of this DDS says `IVDORRMKT`. Neither has been found - check
`WRKOBJ *ALL/IVDORRMKT` before assuming there is nothing to change.

---

## 2. IVRORRMKT

**History** - first line under the `------- -------- ---` line (seq 4100):

```
       // H33979  10/06/26 EFI Show printed price and 3rd party approval flags
```

**File** - after `FIVPITSPC` (seq 13400):

```
     FIVPPRTPRT IF   E           K DISK    Prefix(Ppr_)
```

**Variable** - after `D WrkItmNum` (seq 20100):

```
     D WrkPprItm       S              8S 0
```

**Summary list, both loops** - immediately before
`Exsr Sbr_Get_Last_Price_Change_Date;` at seq 61800 and again at seq 84900:

```
                 WrkPprItm = Scn_ItmNum;
                 Exsr Sbr_Get_Price_Flags;
```

**Detail view, both loops** - immediately before `Write SFL2;` at seq 109600
and again at seq 130100:

```
                 WrkPprItm = Scn_ItmNum2;
                 Exsr Sbr_Get_Price_Flags;
```

**New subroutine** - before the comment box of `Sbr_Update_Date_and_Time`
(seq 224700):

```
       //***********************************************************************
       //* Printed price and third-party approval (IVPPRTPRT) **
       //***********************************************************************
       Begsr Sbr_Get_Price_Flags;

          // No row means neither is known yet, shown as blank.
          Scn_PrtPrc = *Blanks;
          Scn_TpAprv = *Blanks;
          Chain WrkPprItm IVPPRTPRT;
          If %Found(IVPPRTPRT);
             Scn_PrtPrc = Ppr_PrtPrc;
             Scn_TpAprv = Ppr_TpAprv;
          Endif;
          Scn_PrtPrc2 = Scn_PrtPrc;
          Scn_TpAprv2 = Scn_TpAprv;

       Endsr;
```

---

## 3. IVSORRMKTC

**History** - add under the `------- -------- ---` line of File History:

```
      * H33979  10/06/26 EFI Add printed price and 3rd party approval flags
```

**Record `SCREEN1`** - anywhere among the fields (for example after the
`QUOTEWHO` field on row 12). Row 12 is free from column 46; both fields are
protected in the Milwaukee view (indicator 51) like the other entry fields:

```
     A                                 12 46'Printed Price:'
     A            PRTPRC         1A  B 12 61VALUES(' ' 'Y' 'N' 'S')
     A                                      DSPATR(HI)
     A N51                                  DSPATR(UL)
     A  51                                  DSPATR(PR)
     A                                 12 64'3rd Pty Apv:'
     A            TPAPRV         1A  B 12 77VALUES(' ' 'Y' 'N')
     A                                      DSPATR(HI)
     A N51                                  DSPATR(UL)
     A  51                                  DSPATR(PR)
```

---

## 4. IVRORRMKTC

**History** - first line under the `------- -------- ---` line (seq 1800):

```
       // H33979  10/06/26 EFI Add printed price and 3rd party approval flags
```

**File** - after `FIVPORRMNT` (seq 7100):

```
     FIVPPRTPRT UF A E           K DISK    Prefix(Ppr_)
```

**Variables** - after `D SavFlipToPOD` (seq 11600):

```
     D SavPrtPrc       S              1A
     D SavTpAprv       S              1A
     D WrkPprFnd       S              1A
     D WrkOldPrt       S              1A
     D WrkOldTpa       S              1A
```

**Load** - after `Scn_CodPr272 = Orr_CodPr272;` (seq 19200):

```
          // Printed price / third-party approval (SOS-2092, SOS-2520)
          Scn_PrtPrc = *Blanks;
          Scn_TpAprv = *Blanks;
          Chain(N) Scn_ItmNum IVPPRTPRT;
          If %Found(IVPPRTPRT);
             Scn_PrtPrc = Ppr_PrtPrc;
             Scn_TpAprv = Ppr_TpAprv;
          Endif;
```

**Save** - after `SavFlipToPOD = Scn_FlipToPOD;` (seq 21000):

```
          SavPrtPrc    = Scn_PrtPrc;
          SavTpAprv    = Scn_TpAprv;
```

**Confirm** - so a change to either flag asks "Press Enter to confirm change."
like every other field. Replace seq 35400:

```
                 Or Scn_FlipToPOD <> SavFlipToPOD;
```

with:

```
                 Or Scn_FlipToPOD <> SavFlipToPOD
                 Or Scn_PrtPrc    <> SavPrtPrc
                 Or Scn_TpAprv    <> SavTpAprv;
```

**Update** - after `Update IV$ORRITM;` (seq 44300):

```
             Exsr Sbr_Upd_Price_Flags;
```

**New subroutine** - before the comment box of `SbrUpdDtTm` (seq 52500). The
`IVPMAINT` fields are filled exactly as this program already does for
`MINQTY`, so the history shows up the same way:

```
       //***********************************************************************
       //* Save printed price / third-party approval, with history **
       //***********************************************************************
       Begsr Sbr_Upd_Price_Flags;

          Chain Scn_ItmNum IVPPRTPRT;
          If %Found(IVPPRTPRT);
             WrkPprFnd = 'Y';
             WrkOldPrt = Ppr_PrtPrc;
             WrkOldTpa = Ppr_TpAprv;
          Else;
             WrkPprFnd = 'N';
             WrkOldPrt = *Blanks;
             WrkOldTpa = *Blanks;
          Endif;

          // Nothing changed - leave the file and the history alone
          If Scn_PrtPrc = WrkOldPrt and Scn_TpAprv = WrkOldTpa;
             If WrkPprFnd = 'Y';
                Unlock IVPPRTPRT;
             Endif;
             Leavesr;
          Endif;

          // One IVPMAINT row per flag changed, as for any item field
          Mnt_Itmnum    = Scn_Itmnum;
          Mnt_MaintMM   = SdsJobDateMM;
          Mnt_MaintDD   = SdsJobDateDD;
          Mnt_MaintYYYY = SdsJobDateYY;
          Mnt_MaintWho  = SdsUser;
          Mnt_RepCode   = 'N';
          If Scn_PrtPrc <> WrkOldPrt;
             Mnt_Fldnam = 'PRTPRC';
             Mnt_Before = WrkOldPrt;
             Mnt_After  = Scn_PrtPrc;
             Write IVPMAIN$;
          Endif;
          If Scn_TpAprv <> WrkOldTpa;
             Mnt_Fldnam = 'TPAPRV';
             Mnt_Before = WrkOldTpa;
             Mnt_After  = Scn_TpAprv;
             Write IVPMAIN$;
          Endif;

          Ppr_PrtPrc  = Scn_PrtPrc;
          Ppr_TpAprv  = Scn_TpAprv;
          Ppr_ChgTs   = %Timestamp();
          Ppr_ChgUser = SdsUser;
          If WrkPprFnd = 'Y';
             Update IV$PRTPRT %Fields(Ppr_PrtPrc : Ppr_TpAprv
                                    : Ppr_ChgTs : Ppr_ChgUser);
          Else;
             Ppr_Itmnum  = Scn_Itmnum;
             Ppr_AddTs   = %Timestamp();
             Ppr_AddUser = SdsUser;
             Write IV$PRTPRT;
          Endif;

       Endsr;
```

---

## Compile and test (H33979)

```
CRTDSPF FILE(H33979/IVSORRMKT)  SRCFILE(H33979/QDDSSRC)
CRTDSPF FILE(H33979/IVSORRMKTC) SRCFILE(H33979/QDDSSRC)
```

Then compile `IVRORRMKT` and `IVRORRMKTC` into H33979 the way they are
normally compiled (both use embedded SQL or /copy members, so use the usual
PDM option). With H33979 first in the library list:

1. Open the change screen for an item, set Printed Price to `N`, press Enter
   twice. The list should show `N` under Prt/Prc.
2. `SELECT * FROM H33979.IVPPRTPRT WHERE ITMNUM = <item>` - one row, `PRTPRC`
   `N`, `ADDUSER` you.
3. `SELECT * FROM H33979.IVPMAINT WHERE ITMNUM = <item> AND FLDNAM = 'PRTPRC'`
   - one row, before blank, after `N`.
4. Set it back to blank - a second `IVPMAINT` row, `N` to blank.
