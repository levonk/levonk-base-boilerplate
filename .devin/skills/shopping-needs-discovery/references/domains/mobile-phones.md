# Mobile Phones — Domain Reference

Domain-specific constraints for smartphones. Referenced by
`references/constraint-attributes.md`. Load when the user is buying a mobile
phone (new or used). Phones are high-cost, rapidly depreciating devices with
complex carrier compatibility, security lifecycles, and repair ecosystems.
The used market carries significant fraud and lock risk — verification is
critical.

## OS Update Horizon

The single most important longevity factor — a phone that stops receiving
updates becomes a security risk and loses app compatibility.

| Manufacturer | Typical support | Notes |
|-------------|----------------|-------|
| Apple | 5–7 yr | Longest in industry; check specific model |
| Google Pixel | 7 yr (Pixel 8+) | 4 yr (Pixel 6–7); 3 yr (Pixel 5 and earlier) |
| Samsung | 4–7 yr | 7 yr on Galaxy S24+; 4 yr on mid-range |
| OnePlus | 3–4 yr | Varies by model |
| Motorola | 1–3 yr | Budget models often 1 yr only |
| Most other Android | 1–2 yr | Check the specific model — varies widely |

**Always check the specific model** — a Samsung A-series may get 2 yr while
S-series gets 7. Check manufacturer's policy or GSMArena.

## Battery Health

**iPhone**: Settings > Battery > Battery Health & Charging — shows max
capacity % and cycle count (iOS 17.5+ on iPhone 15/16). **Android**:
AccuBattery app or `*#*#4636#*#*` dialer code (Testing > Battery info — not
on all devices). Some manufacturers (Samsung, Pixel) expose it in Settings.

| Health % | Action |
|----------|--------|
| 100–90% | Like new — no action |
| 89–80% | Noticeable range reduction — monitor |
| Below 80% | Replace — Apple considers this "degraded" |
| Below 70% | Significant degradation — replace immediately |

**Battery replacement**: $50–$100 (third-party), $80–$110 (manufacturer).
For used phones, ask for cycle count and health %. A phone at 85% with 500
cycles has more life than one at 85% with 1000 cycles.

## Carrier Compatibility

| Check | How to verify |
|-------|--------------|
| IMEI status | Run IMEI on carrier's activation checker website |
| AT&T VoLTE whitelist | AT&T requires device be on their approved list — many unlocked phones won't activate |
| 5G band support | Check phone specs against carrier's deployed bands |
| CDMA vs GSM | Largely obsolete (LTE/5G), but Verizon/Sprint legacy still relevant for older phones |

**5G bands vary by model**: A phone for T-Mobile may lack AT&T's low-band
5G. Check carrier bands and cross-reference. **Carrier-financed phones** may
be locked until paid off — verify with a SIM from another carrier.

## Storage

| Capacity | Usable (after OS) | Recommendation |
|----------|-------------------|----------------|
| 64 GB | ~45 GB | Insufficient for most users in 2024+ |
| 128 GB | ~105 GB | Minimum recommendation |
| 256 GB | ~230 GB | Good for photo/video-heavy users |
| 512 GB | ~480 GB | Pro video, large offline media |
| 1 TB | ~960 GB | Niche — most users don't need this |

**OS takes 15–25 GB**. 4K at 60fps uses ~400 MB/min. 128 GB minimum; 256 GB
for photo/video-heavy users. Cloud isn't a substitute if frequently offline.

## Repairability

| Repair | Typical cost | Notes |
|--------|-------------|-------|
| Screen | $150–$400 | OLED screens cost more than LCD |
| Battery | $50–$100 | Declines with age — plan on 2–3 yr |
| Back glass | $100–$300 | Often requires full housing replacement |
| Camera module | $80–$250 | Lens replacement cheaper than full module |

**iFixit score**: Fairphone (9/10), iPhone (7/10), Samsung/Pixel (7–8/10).
**Parts pairing (Apple)**: Apple pairs components to the logic board.
Third-party replacement may disable features (True Tone, Face ID, battery
health) until calibrated with proprietary tools. See `attributes/repairability.md`.

## Water Resistance

| Rating | Meaning | Practical use |
|--------|---------|---------------|
| IP67 | 1m, 30 min | Splashes, brief submersion |
| IP68 | 1.5m+, 30 min | Rain, pool, accidental drops |

**Water damage not covered by warranty.** IP ratings are lab conditions —
real-world seals degrade. Treat as accidental protection only.

## 5G & mmWave

- **mmWave**: Ultra-fast, ultra-short range. Only matters in dense urban
  areas, stadiums. Most users never encounter it.
- **Sub-6 GHz**: The practical 5G most people get. Moderate speed over LTE.
- **Check band support**: Missing your carrier's sub-6 bands is worse than
  having no mmWave.

## Used Phone Red Flags

| Red flag | What it means | Action |
|----------|--------------|--------|
| Activation/iCloud lock | Locked to previous owner's account | Must be removed before purchase — walk away if seller can't remove |
| ESN/IMEI blacklist | Reported lost/stolen or unpaid balance | Check on Swappa, carrier site, or IMEI checker — blacklisted = unusable |
| Carrier-financed (unpaid) | Still on installment plan | Seller must pay off before sale; otherwise carrier can blacklist |
| "No returns" + low price | Often stolen or broken | Avoid |
| Seller can't meet at carrier store | Can't verify activation | Meet at carrier store to test activation |

## Used Phone In-Person Verification

A phone that boots to the home screen today can lock you out after the next
reset — Activation Lock, Factory Reset Protection (FRP), and carrier
blacklisting all survive a "wipe" and can surface only when **you** reset the
device. The only reliable test is to factory reset and walk through setup
**while the seller is present, before paying**. For the full procedure
(do-with-seller vs do-later split, walk-away triggers, payment protection),
see
[`acquisition/references/handoff-verification.md`](../../../acquisition/references/handoff-verification.md).

### Do with the seller (before paying)

1. **Get the IMEI/serial** (`*#06#` or Settings → About) and run it on the
   carrier's activation checker **and** a blacklist database (Swappa, CTIA
   Stolen Phone Checker). Blacklisted = unusable. Walk away.
2. **Confirm the seller's accounts are signed out** (Apple Account, Google,
   Samsung). If signed in, require a full sign-out before paying.
3. **Confirm Find My / FRP is off.** Apple: Settings → Apple Account → Find My
   → Find My iPhone off. Android: no Google account remaining after sign-out
   clears FRP.
4. **Factory reset and walk through setup to the home screen.** Watch for an
   Activation Lock screen (Apple) or "Verify your account" / FRP screen
   (Android). Any lock screen = walk away.
5. **Test with your SIM** — confirm activation and signal on your carrier.
   Meet at a carrier store if possible; they can verify activation on the spot.
6. **Get the original receipt and a bill of sale** (date, seller name, IMEI,
   price, signature). Photograph the receipt next to the IMEI. See **Receipt
   retention** below.
7. **Pay with a protected method** (credit card or PayPal Goods & Services).
   Avoid cash / Zelle / Venmo Friends & Family — no recourse if the phone is
   blacklisted later.

### Do later (after a clean handoff)

- Set up your own accounts and enable Find My.
- Install OS updates and confirm the phone still activates.
- Check battery health (Settings → Battery → Battery Health on iOS;
  AccuBattery on Android).
- Inspect screen for OLED burn-in and touch dead-zones; test cameras,
  speakers, microphones, buttons.
- Check recall status by model (CPSC, manufacturer recall pages).
- Back up the receipt (scan/photo with IMEI visible, dated).

## Receipt Retention — Critical for Lock Removal

**Keep the original receipt for every phone, no matter where you buy it.**
Apple and carriers will only remove an Activation Lock or lift a contested
blacklist for the **owner of record with original proof of purchase**. This
applies whether you buy from the manufacturer, an authorized distributor, or a
third party:

- **From the manufacturer or an authorized distributor:** save the invoice. A
  refurb can ship with a leftover lock, or you may need to prove ownership
  years later to remove a forgotten lock.
- **From a third party / marketplace:** require the seller's original receipt
  **plus** a bill of sale. Without proof of ownership, Apple/carrier will not
  remove a lock, and you have no defense if the phone is reported stolen later.
- **Back it up:** scan or photograph the receipt with the IMEI visible, date
  it, and store it with your purchase records. Paper fades and gets lost.

The same principle applies to computers and any account-tied device — see
`computers.md` and
[`acquisition/references/handoff-verification.md`](../../../acquisition/references/handoff-verification.md).

<!-- vim: set ft=markdown -->
