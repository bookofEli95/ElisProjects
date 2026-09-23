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
| `IVRRPCGEN` | RPGLE | Generates suggestions, attaches the CNO |
| `IVRRPCWRK` | RPGLE | Editor approves, overrides or rejects |
| `IVRRPCAPL` | RPGLE | Applies decisions, releases CNOs, expires stale suggestions |
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
| `2` | generated and applied monthly | attached automatically | override (not recommended) |

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

**The attachment mechanism is provisional.** It is written as an item code on
`IVPITMCODE`, the only per-item marker of that kind visible in existing code
(`P1VBTCHUP` writes `'PUR'`). The code is control data (`RPCCNOCOD`), and all
CNO changes go through `Sbr_Attach_CNO` in `IVRRPCGEN` and `Sbr_Release_CNO` in
`IVRRPCAPL` — two subroutines and one control field when the real process is
confirmed. The Pop & Classical re-run page shows the practice already exists
("A CNO has been added to each book to use new files on rerun"), so this is
hooking into something real, not inventing it.

## Running it

```
CALL OBJECT/IVCRPCMTH PARM('*CUR  ' '*ALL   ' '*REPORT')   /* dry run */
CALL OBJECT/IVCRPCMTH PARM('*CUR  ' '*ALL   ' '*PROD  ')   /* monthly */
CALL OBJECT/IVRRPCWRK                                      /* editor screen */
```

Report mode writes nothing and attaches no CNO, so a catalogue can be shown what
it would be told before it is opened in to phase 1.

## Open items

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
4. **`RERUNSTS` values — half settled.** `'J'` is confirmed as *not in the
   queue* and is now excluded via `RPCSTSEXC`. The **inclusion** list is still
   unknown: `RPCSTSLST` is blank, so the candidate set remains wider than the
   internal approval queue the Redash report shows. Blocks phase 1.
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
11. **Re-run due date.** Taken as the earlier of `IVPORRITM.MINQTYDT` and the
    `RERUN8` planned finish date. The documents define due as *"stock depletes to
    reorder floor within 6 months at 2025 sell rate"* — if that forecast exists
    only in BI, it should feed in rather than being approximated here. The
    30-day look-back on `RERUN8` dates is a value to confirm.
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
`HLCOST`, tier pricing) and `IVRNOPUPD`.

## Source documents

- `[2026-06-22] Content. Evaluating Bulk Reissue Price Adjustments` — model `P`
- `[2026-07-03] Content. Manual Price Change Brackets` — model `B`
- `[2026-05-08] Content. Pop & Classical / Instrumental / Choral / Self-Teach
  Q3 2026 Re-run Items` — the 18-month window, and the CNO in current practice
