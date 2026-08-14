# GPU — Sub-Domain Reference

Constraints specific to the graphics card. Load when the user is buying a
GPU for gaming, AI/ML, video editing, or 3D rendering. For PSU and case
compatibility, see `psu-case-cooling.md`; for the display the GPU drives,
see `monitor-peripherals.md`.

The GPU is usually the most expensive single component and the primary
determinant of gaming performance. Getting VRAM, power, or fit wrong is
costly.

## Power Supply Requirements

- Check the **recommended PSU wattage** for the card — typically 550W for
  mid-range up to 1000W for high-end (RTX 4090, RX 7900 XTX).
- Verify the PSU has the correct **PCIe power connectors**:
  - 8-pin (6+2) PCIe — standard for most cards
  - **12VHPWR** (16-pin) — required for RTX 40-series; some ATX 3.0 PSUs
    include it natively, older PSUs use an adapter (often 2x or 3x 8-pin
    to 12VHPWR)
- Total system draw is usually well below the recommendation — the headroom
  covers transient spikes that can trip PSU protections.

## Case Clearance

- **GPU length is the #1 fit issue.** Check the case's max GPU length
  against the card's length. Some cases list separate limits with and
  without front fans/radiators installed.
- **Thick cards (2.5–3.5 slots)** may block adjacent PCIe slots — verify
  the user doesn't need the slot below the GPU (capture cards, extra NVMe
  cards, sound cards).
- Check GPU power connector clearance — some cards have side-facing
  connectors that need extra case width.

## VRAM

| Resolution / use | Minimum VRAM | Recommended |
|------------------|-------------|-------------|
| 1080p gaming | 8 GB | 12 GB |
| 1440p gaming | 12 GB | 16 GB |
| 4K / modern AAA titles | 16 GB | 16–24 GB |
| AI/ML (inference) | 16 GB | 24 GB+ |
| Video editing | 8 GB | 12–16 GB |

VRAM-starved cards drop to **unplayable framerates** (stuttering, texture
pop-in, crashes) when a game exceeds available memory. VRAM cannot be
upgraded — buy enough at purchase time.

## Driver Support Horizon

- Nvidia and AMD support cards with new drivers for roughly **4–6 years**
  after launch.
- After end-of-support, no new game optimizations or feature updates —
  cards still work but performance in new titles degrades.
- Check whether the card is still in **active driver support** before
  buying used. A 5-year-old card nearing EOL is a poor long-term value.

## Used GPU Risks

- **Mining cards**: 24/7 operation wears fans and degrades thermal paste.
  - Check fans for noise/wobble
  - **Repaste** the GPU die (thermal paste dries out)
  - **Stress test** under load (3DMark Time Spy, FurMark) for 30+ min
  - Check for **artifacts** (visual glitches, colored squares) under load —
    a sign of dying VRAM or core
- **Warranty transfer**: most GPU warranties are **NOT transferable** —
  they're tied to the original purchaser with a receipt. A used card with
  no warranty is a risk for an expensive component.

## Ray Tracing Performance

- **RT cores**: first-gen RTX (20-series) struggles with RT enabled —
  framerates drop sharply. 30/40-series are much better.
- **DLSS / FSR support**: upscaling recovers much of the RT performance
  hit. DLSS (Nvidia) and FSR (AMD) matter when RT is enabled.
- If the user wants RT, recommend 30-series or newer (Nvidia) or RX 7000
  series (AMD).

## Productivity Use

| Workload | Preferred vendor | Why |
|----------|-----------------|-----|
| Video editing (Premiere, DaVinci) | Nvidia | CUDA acceleration widely supported |
| AI/ML training and inference | Nvidia | CUDA ecosystem (PyTorch, TensorFlow) dominant |
| 3D rendering (Blender, Octane) | Nvidia | OptiX/CUDA; AMD via HIP slower |
| Streaming | Either | NVENC (Nvidia) slightly better than AMF |

- **VRAM matters more for AI/ML** than raw compute — models must fit in
  VRAM or they won't run at all.
- **Compute performance differs from gaming performance** — a card that
  wins in games may lose in CUDA workloads. Check productivity-specific
  benchmarks, not just game FPS.

## Display Connectivity

| Port | Max typical | Use case |
|------|------------|----------|
| HDMI 2.1 | 4K 120/144 Hz | TVs, some monitors |
| DisplayPort 1.4a | 4K 144 Hz (with DSC) | Most high-refresh monitors |
| DisplayPort 2.1 | 4K 240 Hz / 8K | RX 7000 series, newest monitors |

- Check the monitor's input ports and cable compatibility against the
  GPU's outputs. An HDMI 2.0 GPU cannot drive a 4K 144 Hz monitor over
  HDMI — needs DisplayPort or HDMI 2.1.

<!-- vim: set ft=markdown -->
