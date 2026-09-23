# Re-run Repricing Suggestions (AS400)

Builds the suggestion step described in *Content. AS400 Repricing Suggestions*:
AS400 puts up a suggested price rise per catalogue, an editor approves or
overrides it, and a CNO keeps the book off the press at the old price while the
review is open.

Nothing here decides pricing policy. The policy is data in `IVPRPCRUL`, and the
programs match an item to a row and do the arithmetic.

## What was added

| Object | Kind | Purpose |
| --- | --- | --- |
| `IVPRPCCTL` | PF | One row per AS400 catalogue: phase, model, windows, CNO settings |
| `IVPRPCRUL` | PF | The pricing logic as data — price band x last-change window |
| `IVPRPCLAD` | PF | Price ladder rungs (Choral octavos) |
| `IVPRPCSUG` | PF | One suggestion per item per cycle, with its full audit |
| `IVPRPCSG1` | LF | Suggestions by catalogue and status — the editor queue and report path |
| `IVVRPCWRK` | DSPF | Work with Repricing Suggestions |
| `IVRRPCGEN` | RPGLE | Generates suggestions |
| `IVRRPCWRK` | RPGLE | Editor approves, overrides or rejects |
| `IVRRPCAPL` | RPGLE | Attaches, prices and releases CNOs; stages decisions; expires stale suggestions |
| `IVCRPCMTH` | CL | Monthly run |
| `IVCRPCBLD` | CL | Creates the objects |
| `IVPRPC*_seed.sql` | SQL | The published rules, transcribed |

## How the phases work

The release describes three phases. They are control data, not code versions —
a catalogue moves phase by having its `IVPRPCCTL.RPCPHASE` changed:

| Phase | Suggestion | CNO | Editor |
| --- | --- | --- | --- |
| `0` | none | none | full manual decision, as today |
| `1` | generated, editor enters the price | attached automatically | approve / override |
| `2` | generated and staged monthly | attached automatically | override (not recommended) |

Everything is seeded at phase `0`. Building and seeding on their own change no
prices; a catalogue takes part only when someone gives it a row.

## The pricing logic is a table, not code

Both published models fit one shape, so both are seeded and either can be
selected per catalogue (`RPCMODEL`):

- **`B` — Manual Price Change Brackets** (3 Jul 2026). Flat dollar uplift by
  catalogue x current-price band x last-price-change window. This is what
  editors apply by hand today, so phase 1 suggestions can be checked against
  current practice.
- **`P` — Evaluating Bulk Reissue Price Adjustments** (22 Jun 2026). Percentage
  uplift with minimum rises, increase caps, budget floors, snap to nearest .99
  and the Choral octavo ladder. `RPCSCEN` selects its Suggested or Aggressive
  column.

Order of operations in `IVRRPCGEN`, taken from the sources:

1. `raw = price + flat uplift`, or `price * (1 + percent)`
2. minimum rise applied — *"min $1.50"*
3. rise capped by percent, then by amount — *"+18%"*, *"cap $10"*
4. rounded — nearest `.99`, or up to the next ladder rung
5. budget floor re-asserted **last**, because the source states *"budget floor
   overrides the hard cap"*

A tie when snapping to `.99` rounds up: this is a price rise, and rounding a tie
down can cancel out the minimum rise just applied.

## Verification

The engine was run against all 20 worked examples published in the evaluating
document. **All 20 reproduce from the seeded rule table** — but only by using
different rate columns for different catalogues, which is a problem in the
source document rather than in the build.

That document gives two rates per cell and says its examples use the first
(stale) one: *"The examples below use the stale rate — titles last repriced
before 2022."* They do not, consistently:

| Reproduces under | Examples |
| --- | --- |
| stale rate only | all 4 Instrumental, plus Pop *Mandolin Favorites* |
| 2022-on rate only | 7 — Pop *Mika*, Pop *Hymn Fake Book*, all 3 remaining Classical, Education *Acoustic Jazz Guitarist*, Choral *Rock and Roll Forever* |
| either | the 3 Choral ladder octavos, Education *City Called Heaven*, Pop *Ukulele* |

Within Pop alone, two examples only work on the stale rate and two only on the
2022-on rate, so no single reading of the table generates its own example set.
**Before any catalogue goes to phase 1, someone has to confirm which column the
examples were meant to show**, because across ~9k SKUs it is the difference
between the top and the bottom of the range.

The Choral ladder reproduces exactly: `$2.50 -> $2.65`, `$2.99 -> $3.25`,
`$3.50 -> $3.75`.

### The bracket model is dangerous for Choral octavos

The brackets table has one band for everything under $10 and applies `+$3` to it
in the oldest window. On a per-copy octavo that is not a small rise:

| Title | Current | Bracket model | Ladder (model `P`) |
| --- | --- | --- | --- |
| Noel | $2.50 | **$5.50 (+120%)** | $2.65 (+6%) |
| Cheap Thrills | $2.99 | **$5.99 (+100%)** | $3.25 (+9%) |
| The Night Will Never Stay | $3.50 | **$6.50 (+86%)** | $3.75 (+7%) |

The other document handles exactly these titles with the ladder and says why per
copy pricing needs the lighter touch: *"a $2.99 octavo rising to $3.25 is
trivial per copy, but across a 50-copy choir order it's roughly +$13 on the
invoice."*

So **keep Choral on `RPCMODEL 'P'`**, where the ladder rows cover everything
under $5. `IVPRPCRUL_seed.sql` ends with a commented-out `UPDATE` that caps the
Choral bracket rows, for use if Choral is ever put on model `B`.

## What the program listings settled

`IVRMAINT`, `IVRMAINT2`, `IVRITEMSM4`, `IVRPRCUPD` and `IVRNOPUPD` resolved four
things that had been guesses, and one of them was a live bug.

**A list price change is logged under three different `FLDNAM` values.**

| Program | Writes | When |
| --- | --- | --- |
| `IVRMAINT` | `'PRICE '` | list price change (`Sbr_PriceChg`) |
| `IVRMAINT2` | `'PRICE72'` | the interactive price screen |
| `IVRPRCUPD` | `'PRICE72'` and `'PRICE112'` | price upload |

`RPCFLDLST` was seeded ` PRICE72 PRICE112 `, which would have missed
`IVRMAINT` — the main item maintenance program. Every price change made through
it would have read as "never repriced", putting those titles in the oldest
bracket at the largest uplift. Now seeded ` PRICE PRICE72 PRICE112 `.

Matching is also case-insensitive now, because the same library writes both
`'HLCOST'` and `'HLCost'` for one field. `MAPPRICE` and `REFPRICE` are
deliberately excluded — they are the reference price on `IVPREFPRC`, not the
list price.

**`PRICE72` and `PRICE112` are one price in two fields.** Both programs that
change a list price set them from a single number — `IVRMAINT2` from the price an
editor types, `IVRPRCUPD` from the uploaded MSRP. The generator no longer
reprices `112` on its own base and the screen no longer scales it
proportionally; it takes the same number. Anything else would drift the two
apart.

**`RERUNSTS 'J'` means *not* in the re-run queue.** `IVRMAINT` sets it with a
blank `Hold` to take an item off the queue, logging action `canceled`, and
`P1VBTCHUP` writes it for a job created outside the queue. So it is an exclusion,
not a candidate. New control field `RPCSTSEXC`, seeded `' J '` — which matters
precisely because the inclusion list is still blank.

**Approving a suggestion now requires price authority.** `IVRMAINT2` gates price
changes behind `CHECKSEC( SdsProgram : 'PRICE72' : ... )`. `IVRRPCWRK` was a way
round that check; it now makes the same call and runs read-only without it.

**And a bug of my own.** All three programs declared their own program status
structure as `D SdsUser SDS`, which names the *whole* structure — so
`WrkUser = SdsUser` took positions 1-10, the program name, and would have written
that into `MAINTWHO` and `RPCEDITR` instead of the user. Every program in the
library uses `/copy qcopysrc,statusds`, which supplies a properly named `SdsUser`
and `SdsProgram`. All three now do the same.

Two smaller conventions adopted: `MNT_COMMENT` carries the program name
(`'IVRRPCAPL'`), as `IVRPRCUPD` and `IVRITEMSM4` do; and the item update is
`Update IVPITEM$ %Fields(ITM_PRICE72 : ITM_PRICE112)` rather than a full-record
write, so it cannot undo another job's change to an unrelated field.

## What the online re-run programs settled

`IVRORRNEWP`, `IVRORRNBR`, `IVRORRIVP2` and `IVRORRCLN` changed the design in
three places.

**The re-run queue already has a pending-price field: `IVPORRITM.NEWPRICE`.**
`IVRORRNEWP` — *Online Rerun System Items with New Price* — reports every
approved item whose `NEWPRICE` differs from `PRICE72`, so production knows the
new printing needs a new price. That is the existing home for "the price this
book should have when it is reprinted", and until now it has been filled by
hand. **Approved prices are now staged there by default** (`RPCAPLTGT 'Q'`)
instead of written to `IVPITEMS`.

The reason is the cover. While the price is still printed on the book, raising
`PRICE72` at approval would put the system price out of step with every copy
already in stock, for however long the reprint takes. Staging on `NEWPRICE`
lets the price move with the new printing, through whatever moves it today —
and `IVRORRNEWP` then tells production about it with no new code. Writing
straight to the item is still available (`RPCAPLTGT 'I'`) for when the price
comes off the back of the book.

Two consequences, both handled:

- A title whose queue row **already** carries a `NEWPRICE` has been priced by a
  person. The generator skips it, and the applier will not overwrite one that
  appeared after the suggestion was made.
- Staging writes **no** `IVPMAINT` row. A `'PRICE72'` row would tell the
  generator the title had just been repriced and restart its eligibility clock
  on a price nobody has printed. The row is written by whatever moves `PRICE72`
  at the new printing — and until then the generator leaves the title alone,
  because its queue row now carries a `NEWPRICE`. The loop closes by itself.

**The CNO is a correction on `NOTEPADI`, written exactly the way the house
writes one.** `IVRORRNEWP` treats a price change as covered when a correction
contains the word `PRICE` and the new price. `IVRICNO` (the pop-up note pad) and
`IVRCNOUPD` (mass corrections upload) show how a correction is actually stored,
and it is not one note per record:

- A `NOTEPADI` record is a **page** (`RCDNBR` 1–4). `NOTE1` + `NOTE2` are 13
  lines of 34 characters, and one page holds several corrections one after
  another.
- A correction is a header line, `Correction MM/YY <name>` (the name from
  `MFPUSERS`), then body lines of at most 34 characters. It goes in the first
  gap on the first page with room, after one blank separator line, and nothing
  already on the page moves.
- Adding one sets `IVPORRITM.CNO = 'M'` (if blank) and `IVPITEMS.CORRCD = 'C'`.
- When a removal leaves all four pages empty, `IVRICNO` deletes the four records
  and clears `CORRCD`.

This process now follows those rules to the letter:

| Stage | Four lines on the note pad |
| --- | --- |
| Suggestion raised | `Correction  9/26 <name>` / `Price review pending (IVRRPC)` / `Do not reprint at the current` / `price until new price is set.` |
| Approved and staged | same four lines rewritten: `Correction  9/26 <name>` / `Price change on rerun (IVRRPC)` / `New price 13.99` / `Reprint at the new price.` |
| Rejected, expired, stale, no longer rerun | the four lines blanked; `IVRICNO`'s empty-pad rule applied |

Guarantees, each simulated against realistic note pads before committing:

- **Editors' corrections are never touched.** The process finds its own block by
  the `(IVRRPC)` marker — so it is still found if an editor adds lines above it —
  and changes those four lines only. If an editor removes the marker, the lines
  are theirs.
- **The pad is only deleted when it is empty**, and `CORRCD` only cleared then.
  `IVPORRITM.CNO` is only cleared if this process was the one that set it
  (`RPCCNOSET`).
- **`IVRORRNEWP` always recognises the approved correction.** `NOTE1` ends 18
  characters into line 8 and the report scans `NOTE1` and `NOTE2` separately, so
  a price on line 8 could be split and missed. Blocks are never placed with the
  price on line 8.
- **No number but the new price.** The report matches `%Char(NEWPRICE)` as a
  substring, so a current price of `13.99` in the pending note would later hide a
  hand-set `3.99`. The pending lines carry no price at all, and the price is
  formatted from a field declared `LIKE(ORR_NEWPRICE)`.
- **No room on any page** — nobody's correction is moved. The suggestion goes
  ahead without one, and the staged `NEWPRICE` puts the item on the *Items with
  New Price* report instead.

All of this lives in one program, `IVRRPCAPL`. The generator raises suggestions
only; `IVRRPCAPL` attaches the correction to every open suggestion that lacks
one, which in the monthly job is minutes later. That keeps every write to the
note pad and its flags in one place.

`IVRORRNEWP`'s substring scan has one weakness this cannot remove: if `NEWPRICE`
is later changed by hand from `13.99` to `3.99`, the correction still "covers"
it. That is equally true of every hand-typed correction; the fix belongs in
`IVRORRNEWP`.

**`RERUNSTS` now has meanings, from the programs that test each value.**

| Value | Meaning | Evidence |
| --- | --- | --- |
| blank | hit minimum qty, not yet actioned | `IVRORRIVP2` selects exactly these |
| `A K B I P` | approved / active | `IVRORRNEWP` selects these (`P` only for dept `BO`) |
| `N` | not to be rerun | `IVRORRNBR` reports exactly these |
| `J` | taken off the queue | `IVRMAINT` sets it to remove an item |

Seeded as `RPCSTSLST ' *BLANK A K B I P '` and `RPCSTSEXC ' J N '`. The
generator previously required a non-blank status, which excluded the Min Qty
Online population — the earliest point a title can be priced — and let `N`
through. Both are fixed. A blank is written `*BLANK` because a blank cannot be a
token. What `A`, `K`, `B`, `I` and `P` each mean individually is still not
stated anywhere.

**And the due date is now the forecast.** `IVRORRIVP2` prints
`IVPORRITM.ESTBODT`, the estimated back-order date, alongside quantity available
and sales — a forecast of when stock runs out, which is what the pricing
documents mean by due. The generator now uses it, falling back to `MINQTYDT`.
`MINQTYDT` on its own could not discriminate: it is the date stock *reached*
its minimum, so it is already past for nearly everything in the queue and the
6-month horizon would have let almost all of it through.

`IVRORRCLN` also shows items leave the queue routinely — its whole job is
deleting records for items no longer on `IVPORRITM`. So the applier re-checks
for the queue row at approval time, not just at generation.

## Guardrails

- **Eligibility.** A title repriced within `RPCELGMO` months is left alone.
- **Caps.** `RULCAPPCT` and `RULCAPAMT` limit the rise; the budget floor may
  lift a price back above a cap, which the source explicitly allows.
- **Pricing authority.** Titles under a third-party agreement are held or
  skipped (`RPCAUTCOD` / `RPCAUTACT`). See the open items — the AS400 field that
  identifies them is not yet confirmed, so this is a hook, not a finished check.
- **Overrides.** An override below the current price is refused outright. An
  override past the cap is held at status `G` and needs a second, deliberate
  action to authorise, recorded against the editor. The guardrail is advisory,
  because editors know things the rule table does not — but going past it cannot
  happen by accident.
- **Stale suggestions.** If an item's price moved after a suggestion was made,
  `IVRRPCAPL` rejects it rather than applying a number worked out from a price
  that no longer exists.
- **One price path.** Only `IVRRPCAPL` writes a price. The screen records
  decisions; it never updates `IVPITEMS`.

## The CNO

Attached when a suggestion is raised, released when it is applied, rejected or
expired. **Expiry is the important half**: an abandoned review would otherwise
keep its CNO for ever, and the CNO is what stops the book being reprinted — so a
forgotten suggestion would quietly block production. After `RPCEXPCY` cycles the
suggestion expires and the CNO comes off, which also lets the next run raise the
title again rather than forget it.

The mechanism is a correction on `NOTEPADI` in the house format — see *What the
online re-run programs settled* for the lines written at each stage and the
guarantees around editors' corrections. It lives entirely in `IVRRPCAPL`
(`Sbr_Attach_CNO`, `Sbr_Price_CNO`, `Sbr_Release_CNO` and the `Sbr_Cno_*`
helpers) and is switched by `RPCCNOYN`.

## Running it

```
CALL OBJECT/IVCRPCMTH PARM('*CUR  ' '*ALL   ' '*REPORT')   /* dry run */
CALL OBJECT/IVCRPCMTH PARM('*CUR  ' '*ALL   ' '*PROD  ')   /* monthly */
CALL OBJECT/IVRRPCWRK                                      /* editor screen */
```

Report mode writes nothing and attaches no CNO, so a catalogue can be shown what
it would be told before it is opened in to phase 1.

## Open items

**Settled: nothing moves `NEWPRICE` into `PRICE72`. A person does it.**
A search of `SOURCE/QRPGLESRC` finds 26 members that mention `NEWPRICE`, and
not one assigns it to `PRICE72`. For every item whose queue row shows the new
price applied (`NEWPRICE = PRICE72`), the `IVPMAINT` row for that price change
was written by a named user. What the code does with `NEWPRICE`:

| Role | Programs |
| --- | --- |
| **Typed in** on a screen | `IVRORRINV1` (inventory), `IVRORRMKTC` (marketing change), `IVRORRPRDC` (production change), `MIVPOAPRV` (purchasing) |
| **Written by batch** | `IVRORRNWPR` — sets it from another file; no description on the member |
| **Cleared** | `PCRNTFYPO` (item added to the queue from an agency PO) |
| **Shown instead of the current price**, highlighted | `IVRORRMKT`, `IVRORRPB` (print buyer), `IVRIMPAGCY`, `IVRIMPORD` |
| **Printed / tested** | `IVRORRNEWP`, `IVRORRPRD1`, `IVRORRPRD2`, `IVRCALCDT`, `IVRORRUPD1` |

So the house flow is: the new price is shown to production and the print buyer
in place of the old one, and someone keys it into item maintenance around the
reprint. This process fits that as built — phase 1 hands them a calculated
number instead of one they work out.

What it means for **phase 2**: "applies automatically" needs a step that does
not exist today — something that moves `NEWPRICE` into `PRICE72` when the
reprint happens. The natural trigger is the job closing or the stock arriving;
`ACRCLSJOB`, `JOBMAINT` and `JOBACD` read the queue and can update the item, so
one of them is the place to look. That step must also call `IVRUDRLITM`, below.

Two things to check before a pilot:

- **`IVRORRNWPR` — read, and no conflict.** It is a 2022 program (*"Auto
  populate the New Price field in the rerun program for items needing price
  increases"*): for queue rows with a blank status it copies a price from a
  staging file, `IVPORRPRCU`, into `NEWPRICE`, after checking `PRICE112` has not
  changed since the price was staged. It **only writes when `NEWPRICE` is zero**,
  so it cannot overwrite a price this process staged; and this process will not
  overwrite one it set. First writer wins, both ways.

  And **it is live: `IVPORRPRCU` holds 4,382 staged prices** (row count, 23
  Sep 2026). So an earlier version of this idea already exists and has been
  loaded at scale, whatever the release page says about no suggestion step
  existing. Each row waits for its title to reach the re-run queue with a blank
  status, then becomes `NEWPRICE`.

  The generator now **skips any title with a current row in `IVPORRPRCU`**
  (current meaning `PRICE112` has not moved since it was staged — the same test
  `IVRORRNWPR` applies before using one). Otherwise an editor could approve a
  suggestion only for `IVRORRNWPR` to overtake it. Report mode counts these as
  *Skip in PRCU*, so a dry run shows the overlap per catalogue.

  Still unknown: when those rows were loaded, from what, and by which rule. If
  they came from the pricing documents, they are also the best available test of
  the rule table here — real prices someone already decided on.
- **The search covered `SOURCE/QRPGLESRC` only.** Older RPG III source in
  `QRPGSRC`, or source in another library, was not searched. The
  cross-reference found programs that read the queue and can update the item
  without mentioning `NEWPRICE` at all. The three CNO programs among them
  (`IVRCNOUPD`, `IVRICNO`, `IVVICNO`) are now read, and confirm `NOTEPADI` is
  where corrections live.

**Price changes propagate through `IVRUDRLITM`.** When a hardgood's price
changes, `IVRUDRLITM(item, price)` gives its related item the same price and
every eBook the same price, less 20% for an HL digital book, with `IVPMAINT`
rows marked *"Change made by IVRUDRLITM"*. `IVRMAINT`'s history says eBook
price updates are *"now done in IVRUDRLITM"*. The direct-to-item path
(`RPCAPLTGT 'I'`) now calls it; before this it would have left eBooks at the old
price. Nothing read so far calls it directly. It is not a trigger: `IVPITEMS` has two,
`SYNC_IVPITEMS_INS` and `SYNC_IVPITEMS_UPD` (program `STT00303`), and by their
names they replicate the item master elsewhere rather than reprice eBooks. So
the explicit call stays. It is probably reached today through `IVRUPDTPRC`,
which `IVRMAINT` copies in.

Worth knowing about those triggers: every update this process makes to
`IVPITEMS` — the price in `'I'` mode, and `CORRCD` for a correction — fires
`SYNC_IVPITEMS_UPD`, the same as any other program's update.

**Unidentified: `DADSYUGI`.** Most recent `IVPMAINT` price rows carry it as
`MAINTWHO`, and it is neither a program nor a current user. Candidates, with the
command that confirms each:

- a display device — `WRKDEVD DEVD(DADSYUGI)`. For an interactive job the job
  name *is* the device name, so a program writing the job name instead of the
  user into `MAINTWHO` would produce exactly this.
- a deleted or service profile — `DSPUSRPRF USRPRF(DADSYUGI)`, and the dates
  below: rows that stop on one day suggest someone who left.
- a batch job name — `WRKJOBSCDE` for a scheduled entry of that name.

Which program writes it shows up in the audit rows themselves:

```sql
SELECT MAINTWHO, UPPER(TRIM(FLDNAM)) AS FLD, COMMENT, COUNT(*) AS N,
       MIN(MAINTYYYY * 10000 + MAINTMM * 100 + MAINTDD) AS FIRST_DT,
       MAX(MAINTYYYY * 10000 + MAINTMM * 100 + MAINTDD) AS LAST_DT
  FROM OBJECT/IVPMAINT
 WHERE UPPER(TRIM(FLDNAM)) IN ('PRICE', 'PRICE72', 'PRICE112')
   AND MAINTYYYY >= 2025
 GROUP BY MAINTWHO, UPPER(TRIM(FLDNAM)), COMMENT
 ORDER BY N DESC
```

It matters here because a `MAINTWHO` that is really a device or a batch job
means some price changes cannot be traced to a person — relevant if phase 2 is
ever audited.

These are gaps in what could be confirmed, not loose ends in the build. Each one
is control data rather than a hard-coded guess, so closing it is a data change.

1. **Which rate column** the evaluating document's examples use — see
   Verification. Blocks phase 1.
2. **`DIVCAT` -> catalogue group.** The documents name 4-5 groups; AS400 keys on
   a 7-digit `DIVCAT`. Populate `RPCCATG` per catalogue. Until it is populated a
   catalogue produces no suggestions, which is the safe failure.
3. **Education vs Self-Teach.** The brackets document tables
   *Classical / Self-Teach* and no Education; the evaluating document tables
   Education and no Self-Teach. If they are one group, map those `DIVCAT`s
   accordingly; if not, one bracket set and one percentage set are missing.
   Seeded faithfully, so model `B` has no `EDU` rows and model `P` no `SFT` rows.
4. ~~**`RERUNSTS` values.**~~ **Settled** — see the table under *What the
   online re-run programs settled*. Left open: the individual meaning of each of
   `A K B I P`, and whether `P` should count outside dept `BO`.
5. ~~**`IVPMAINT.FLDNAM` for a price change.**~~ **Settled** — three spellings,
   all three now seeded. See *What the program listings settled*.
6. **`IVPMAINT` retention.** If rows are purged, a title repriced long ago is
   indistinguishable from one never repriced, and both land on the oldest
   bracket — the largest uplift. Confirm retention before phase 2.

   There may be a better source than `MAX()` over history: **`IVPMAINTDT`** is
   keyed on `(ITMNUM, FLDNAM)` and holds a single `MAINTDT`. `IVRMAINT` appears
   to write it only for `MINQTYUSG`, so it is no use as it stands — but if any
   program populates it for the price fields, a keyed read would replace the
   aggregate and be immune to history being purged. Worth one look.
7. **Pricing-authority field.** Which AS400 field marks a title we are not free
   to reprice (`PBLSHRNUM`? `RORefNum`? `CNTRTP`?). The evaluating document flags
   this twice: *"question marks over our ability to raise prices under third
   party agreements"* and *"Faber-linked — subject to the pricing-authority
   check"*.
8. **Eligibility window.** Three appear in the sources: 18 months (all four
   quarterly re-run pages), 12 months (brackets document), and an Aug-2025 cutoff
   (evaluating document). Seeded at 18. `RPCELGMO`.
9. **Do brackets snap to `.99`?** The brackets document says nothing, so bracket
   rows are seeded `RULROUND 'NONE'` and produce prices like `$61.00` from a
   `$45.00` base. The percentage model snaps, because its source says to.
10. ~~**`PRICE72` vs `PRICE112`.**~~ **Settled** — one price in two fields, set
    from the same number. Still open: what should happen to score and part items
    within an Instrumental set, which the sources price as a set.
11. **Re-run due date — mostly settled.** Now `IVPORRITM.ESTBODT`, the
    estimated back-order date, with `MINQTYDT` as a fallback and the `RERUN8`
    planned finish date where earlier. Still to confirm: that back-order (stock
    out) is close enough to the documents' *"reorder floor"*, and how
    `ORR_FLG6MO` is set — the only comment on it reads *"if < 6 months, show
    blanks"*, which is not enough to build on.
12. **Kill-candidate disposition.** `RULDISP` carries the published disposition
    (`KILLCAND` / `WATCH` / `CULLREV`) on to each suggestion, but nothing acts on
    it yet and "dead" is undefined.
13. **`RERUNA` and `IVPRERUN`.** `IVPITEMS.RERUNA` is a re-run action code
    validated against `IVPRERUN`, and `IVRMAINT` shows `'9'` means substitution —
    it requires a substitution item number. A title being substituted rather than
    re-run probably should not be repriced, but the rest of that code table is
    not visible here, so nothing is excluded on it yet. Send `IVPRERUN`'s
    contents and this becomes another control-data exclusion.
14. **Authority on the batch apply.** `IVRRPCWRK` now calls `CHECKSEC` for
    `'PRICE72'`, matching `IVRMAINT2`. `IVRRPCAPL` runs as a batch job user and
    does not. For phase 2 — where it applies prices with no editor involved —
    decide whether that job user should have to hold the same authority.

## Programs read

`IVRMAINT` (inventory maintenance), `IVRMAINT2` (interactive price change),
`IVRITEMSM4` (`IVPITEMS` maintenance), `IVRPRCUPD` (price upload: MSRP, MAP,
`HLCOST`, tier pricing), `IVRNOPUPD`, `IVRORRNEWP` (items with new price),
`IVRORRNBR` (items not to be rerun), `IVRORRIVP2` (min qty online print),
`IVRORRCLN` (nightly cleanup), `IVRUDRLITM` (price propagation to related
items and eBooks), `IVRORRNWPR` (auto-populate new price), `IVRCNOUPD` (mass
corrections upload), `IVRICNO` and `IVVICNO` (the item note pad). Plus a `FNDSTRPDM` of `NEWPRICE` across `SOURCE/QRPGLESRC`
and a `DSPPGMREF` cross-reference of programs that read the re-run queue and can
update the item master.

## Source documents

- `[2026-06-22] Content. Evaluating Bulk Reissue Price Adjustments` — model `P`
- `[2026-07-03] Content. Manual Price Change Brackets` — model `B`
- `[2026-05-08] Content. Pop & Classical / Instrumental / Choral / Self-Teach
  Q3 2026 Re-run Items` — the 18-month window, and the CNO in current practice
