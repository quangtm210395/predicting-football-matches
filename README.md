# football-match-predictor

A [Claude Code](https://claude.com/claude-code) **skill** for honest pre-match
football analysis and value betting — built for the **2026 FIFA World Cup** but
usable for any fixture.

It gathers the real pre-match picture (projected XI, injuries, head-to-head,
recent form, tournament context), turns it into outcome probabilities with a
Poisson model, then compares those to the bookmaker's vig-free odds and surfaces
**only positive-expected-value (+EV) bets** — in the market style you choose
(European 1X2 or Asian handicap / tài xỉu).

## Philosophy: value, not "sure wins"

> "Give me high-win-rate picks" is a trap. Backing heavy favourites wins often and
> loses money long-term, because the market already prices their strength. The only
> durable edge is **+EV**: when your estimated probability beats the market's
> vig-free probability.

The skill always reframes a "sure win" request into a value-betting analysis, sizes
stakes with fractional Kelly, refuses to fabricate data, and ships responsible-
gambling framing. **No method guarantees winning bets. Gamble responsibly.**

## Features

- **Real-data workflow** — pulls live lineups/injuries/form/odds via web search;
  marks anything it can't find as *unknown* instead of inventing it.
- **Choose your market** — European 1X2 / Double Chance / O/U, **or** Asian
  handicap (kèo chấp) and Asian over/under (tài xỉu) with full/half/quarter lines.
- **Poisson + value engine** (`scripts/match_model.py`) — outcome/total/BTTS
  probabilities, no-vig fair odds, EV, and push-aware fractional Kelly staking.
- **World Cup 2026 context** — 48-team format & third-place qualification maths,
  altitude (Estadio Azteca), heat & roofed stadiums, travel/rotation.
- **Bilingual output** (Tiếng Việt / English) tuned for "soi kèo" workflows.

## Install

Copy the skill into your personal skills directory:

```bash
./install.sh          # copies skills/predicting-football-matches -> ~/.claude/skills/
```

or manually:

```bash
cp -R skills/predicting-football-matches ~/.claude/skills/
```

Restart Claude Code (or start a new session). The skill auto-triggers on requests
like *"dự đoán trận …"*, *"soi kèo …"*, or *"predict / analyse match X vs Y"*.

> Personal-skill paths differ by agent: Claude Code uses `~/.claude/skills/`.
> Adjust the target if you use a different agent.

## The model script

`scripts/match_model.py` is plain Python 3 (stdlib only) and works standalone:

```bash
cd skills/predicting-football-matches/scripts

# European 1X2 value (no-vig, EV, Kelly)
python3 match_model.py value  --home-xg 1.65 --away-xg 0.80 \
    --odds-home 1.55 --odds-draw 4.00 --odds-away 6.50

# Asian handicap (kèo chấp) — quarter lines supported
python3 match_model.py asian  --home-xg 1.65 --away-xg 0.80 \
    --line -0.75 --side home --odds 1.95

# Asian over/under (tài xỉu)
python3 match_model.py atotals --home-xg 1.65 --away-xg 0.80 \
    --line 2.25 --side under --odds 1.90

python3 match_model.py --help   # all commands
```

`--home-xg` / `--away-xg` are **your** expected-goals estimates derived from the
data — not magic numbers. Garbage in, garbage out.

## How it's built

Authored with the Test-Driven-Development-for-skills method: an agent attempts the
task *without* the skill (baseline), the skill is written to close the exact gaps
observed, then re-tested with the skill until an agent applies it correctly —
including refusing a deliberately fabricated, non-existent fixture.

## Responsible gambling

This project is probabilistic analysis and education, **not financial advice**.
Variance is real and can bankrupt a true edge if over-staked. Bet only what you can
afford to lose, never chase losses, and seek help if gambling stops being fun:
[BeGambleAware](https://www.begambleaware.org/) ·
[ncpgambling.org](https://www.ncpgambling.org/) (US 1-800-GAMBLER).

## License

[MIT](LICENSE) — change the copyright holder line to your name before publishing.
