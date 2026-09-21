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
4. **`RERUNSTS` values.** `RPCSTSLST` is blank, which means no status filter —
   wider than the internal approval queue the Redash report shows. The only
   value visible in existing code is `'J'` (PCR-created job, explicitly *not* an
   online re-run). Blocks phase 1.
5. **`IVPMAINT.FLDNAM` for a price change.** `RPCFLDLST` is seeded
   ` PRICE72 PRICE112 ` on the reasoning that field-level audit rows carry the
   field's own name, which is how `'ADDED'` behaves in `P1VBTCHUP`. `IVRRPCAPL`
   writes those same names, so the loop is self-consistent — but if the
   interactive price-maintenance program writes something else, its value has to
   be added or history will read as "never repriced".
6. **`IVPMAINT` retention.** If rows are purged, a title repriced long ago is
   indistinguishable from one never repriced, and both land on the oldest
   bracket — the largest uplift. Confirm retention before phase 2.
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
10. **`PRICE72` vs `PRICE112`.** Both move together by the same proportion when
    `RPCP112YN` is `'Y'`. Confirm that is right, and what should happen to score
    and part items within an Instrumental set.
11. **Re-run due date.** Taken as the earlier of `IVPORRITM.MINQTYDT` and the
    `RERUN8` planned finish date. The documents define due as *"stock depletes to
    reorder floor within 6 months at 2025 sell rate"* — if that forecast exists
    only in BI, it should feed in rather than being approximated here. The
    30-day look-back on `RERUN8` dates is a value to confirm.
12. **Kill-candidate disposition.** `RULDISP` carries the published disposition
    (`KILLCAND` / `WATCH` / `CULLREV`) on to each suggestion, but nothing acts on
    it yet and "dead" is undefined.

## Source documents

- `[2026-06-22] Content. Evaluating Bulk Reissue Price Adjustments` — model `P`
- `[2026-07-03] Content. Manual Price Change Brackets` — model `B`
- `[2026-05-08] Content. Pop & Classical / Instrumental / Choral / Self-Teach
  Q3 2026 Re-run Items` — the 18-month window, and the CNO in current practice
