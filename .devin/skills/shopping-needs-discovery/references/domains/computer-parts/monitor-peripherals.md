# Monitor & Peripherals — Sub-Domain Reference

Constraints specific to monitors, keyboards, and mice. Load when the user
is buying a display or input devices. For the GPU that drives the monitor,
see `gpu.md`. These are the parts the user interacts with directly — a
great PC with a bad monitor feels worse than a modest PC with good
peripherals. Match the display to the GPU's output capability.

## Monitor Panel Types

| Panel | Color | Contrast | Response | Notes |
|-------|-------|----------|----------|-------|
| IPS | Best | Moderate (~1000:1) | Moderate | Slight IPS glow in corners; standard for most users |
| VA | Good | Best (~3000:1+) | Slower | Good for media; dark scenes look better than IPS |
| OLED | Perfect | Perfect (infinite) | Fast | Burn-in risk; expensive; best image quality |
| TN | Poor | Poor | Fast | Mostly obsolete — only for budget competitive gaming |

## Resolution vs Refresh Rate

| Combo | Use case | GPU needed |
|-------|----------|-----------|
| 1080p 144 Hz | Budget gaming | Mid-range (RTX 4060 / RX 7600) |
| 1440p 144 Hz | Sweet spot | Upper-mid (RTX 4070 / RX 7800 XT) |
| 4K 60 Hz | Productivity / media | Mid-range (sufficient for desktop) |
| 4K 144 Hz | High-end gaming | Top-tier (RTX 4080/4090) |

Match the monitor to the GPU — a 4K 144 Hz monitor with a mid GPU
delivers neither 4K nor 144 Hz in games. Conversely, a 1080p 60 Hz
monitor wastes a high-end GPU.

## HDR

- **True HDR 600+** (DisplayHDR 600/1000 certification) is the minimum for
  visible HDR benefit.
- **"HDR400" is fake HDR** — accepts an HDR signal but can't display it
  properly (insufficient brightness, no local dimming). Treat as SDR-only.
  OLED delivers true HDR without certification via per-pixel dimming.

## Color Accuracy

| Standard | Coverage | Use case |
|----------|----------|----------|
| sRGB | 99%+ | General use, web, most games |
| DCI-P3 | 90%+ | Creative work, video editing, modern games |
| Adobe RGB | 95%+ | Print work, professional photography |

A **factory calibration report** (Delta E < 2) means the monitor is
accurate out of the box without a colorimeter.

## Monitor Connectivity

| Port | Max signal | Use case |
|------|-----------|----------|
| HDMI 2.1 | 4K 120/144 Hz | TVs, consoles, some monitors |
| DisplayPort 1.4a | 4K 144 Hz (with DSC) | Most high-refresh monitors |
| USB-C (DP Alt Mode) | Varies | Single-cable for laptops — check power delivery wattage |

For laptops, a USB-C monitor with DP Alt Mode + power delivery charges
the laptop and drives the display over one cable — verify the monitor's PD
wattage meets the laptop's charging requirement.

## Monitor Ergonomics & Size

- **Stand adjustment**: height, tilt, swivel, pivot (portrait rotation) —
  budget monitors often only tilt.
- **Monitor arm** ($30–100): full adjustment if the stand is limited.
- **VESA mount compatibility**: 75x75 or 100x100 mm — verify before buying.

| Size | Ideal resolution | Problem resolution |
|------|-----------------|-------------------|
| 24" | 1080p | — |
| 27" | 1440p | 1080p (pixels visible) |
| 32" | 4K | 1440p (pixels visible) |
| 34" ultrawide | 3440x1440 | 2560x1080 (pixels visible) |

Don't buy too large for the resolution — pixel density below ~90 PPI looks
soft. 4K on a 24" display scales text very small; OS scaling helps but
isn't perfect.

## Keyboard Switch Types & Layout

| Switch | Feel | Best for |
|--------|------|----------|
| Linear | Smooth, no bump | Gaming (fast, no resistance) |
| Tactile | Bump at actuation | Typing (feedback without noise) |
| Clicky | Tactile + audible click | Typing (loud — not for shared spaces) |

**Hot-swappable boards** let you change switches without soldering —
recommended for users unsure of their switch preference.

| Layout | Keys | Use case |
|--------|------|----------|
| Full | 104+ | Numpad needed (data entry, finance) |
| TKL | 87 | Saves space, keeps nav cluster + arrows |
| 75% | ~84 | Compact, keeps function row + arrows |
| 60% | ~61 | Minimal; no arrows/F-keys (use layers) |

A 60% board saves space but requires layer shortcuts for arrows and
function keys — not for everyone.

## Mouse Sensor & Wireless

- **Optical vs laser**: optical is standard and more accurate on most
  surfaces; laser works on glass but tracks worse on cloth pads.
- **DPI range**: most sensors offer 100–26,000 DPI; most players use
  400–1600 DPI. High DPI is marketing, not a real advantage.
- **Polling rate**: 1000 Hz standard; 4000 Hz+ for competitive gaming
  (marginal benefit, higher CPU use).
- **Weight**: lighter is better for FPS — 60–80 g sweet spot. Heavy mice
  (100g+) cause fatigue in long sessions.

| Wireless type | Latency | Use case |
|---------------|---------|----------|
| 2.4 GHz dongle | Low | Gaming (near-wired performance) |
| Bluetooth | Higher | Office, convenience (no dongle needed) |

Some peripherals support **both** — dongle for gaming, Bluetooth for
laptop/office. Check if both are supported if the user switches devices.

<!-- vim: set ft=markdown -->
