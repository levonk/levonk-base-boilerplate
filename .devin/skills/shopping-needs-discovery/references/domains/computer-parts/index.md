# Computer Parts — Domain Index

Domain-specific constraints for desktop PC components, peripherals, and
related hardware. Referenced by `references/constraint-attributes.md`.
Load when the user is buying computer parts or building/assembling a PC.

Computer parts are unique among consumer goods because **every component
must be compatible with every other component**. A wrong socket, a too-long
GPU, or an underpowered PSU turns a $2,000 build into an expensive paper
weight. Compatibility is the #1 issue — verify it before recommending any
specific part.

## How to Use This Index

1. Read the generic constraints below (apply to all PC builds and upgrades)
2. Identify the component categories involved and load the matching sub-domain file
3. Surface all identified constraints in the Needs Discovery Brief

## Sub-Domain Files

| Sub-domain | When to load | Reference |
|------------|-------------|-----------|
| **CPU & Motherboard** | User is buying a processor, motherboard, or both | `cpu-motherboard.md` |
| **GPU** | User is buying a graphics card (gaming, AI/ML, video editing) | `gpu.md` |
| **RAM & Storage** | User is buying memory, SSDs, NVMe, or HDDs | `ram-storage.md` |
| **PSU, Case & Cooling** | User is buying a power supply, case, or CPU cooler | `psu-case-cooling.md` |
| **Monitor & Peripherals** | User is buying a monitor, keyboard, or mouse | `monitor-peripherals.md` |

Load multiple sub-domain files when the build spans categories (a full new
build typically loads all five).

## Generic Constraints (All Computer Parts)

### Compatibility — The #1 Issue

Every part must be compatible with the motherboard and with each other.
Before recommending any specific part, verify:

- **CPU socket matches motherboard socket** (Intel LGA 1700/1851, AMD AM5,
  etc.) — see `cpu-motherboard.md`
- **RAM generation matches motherboard** (DDR4 vs DDR5 — not interchangeable)
- **GPU fits the case** (length is the #1 fit issue) and PSU has the right
  PCIe connectors — see `gpu.md`
- **PSU wattage covers total system draw + headroom** — see `psu-case-cooling.md`
- **Case supports the motherboard form factor, GPU length, cooler height,
  and radiator size** — see `psu-case-cooling.md`
- **Cooler is compatible with the CPU socket** and clears the case side panel

**Use [PCPartPicker](https://pcpartpicker.com/) to verify compatibility.**
It cross-checks socket, form factor, wattage, clearance, and connector
compatibility automatically. Do not recommend a parts list that has not
been through a compatibility check.

### Bottleneck Analysis

A build is only as fast as its slowest component for a given workload.
Identify the bottleneck for the user's primary use case:

| Use case | Typical bottleneck | What to prioritize |
|----------|-------------------|-------------------|
| 1080p gaming | CPU (at high FPS) | Strong single-core CPU, mid GPU |
| 1440p/4K gaming | GPU | Strong GPU, mid CPU is fine |
| Video editing | CPU + RAM + NVMe | Many cores, 32GB+ RAM, fast NVMe |
| AI/ML training | GPU VRAM + compute | Nvidia GPU, max VRAM affordable |
| Streaming | CPU (encoding) | Cores for x264/x265, or GPU NVENC |
| Office/web | Nothing demanding | Any modern APU, 16GB RAM |

Don't pair a $800 GPU with a $150 CPU for 1080p gaming — the CPU will
starve the GPU. Conversely, don't pair a $500 CPU with a $200 GPU for 4K
gaming — the GPU is the ceiling. Match component tiers to the use case.

### Used Market

The used market is viable for some components and dangerous for others.
Be explicit about the risk per category:

| Component | Used safety | Notes |
|-----------|------------|-------|
| **CPU** | Very safe | No moving parts; rarely fails. Verify pins (Intel) or contacts (AMD) are undamaged. |
| **RAM** | Very safe | No moving parts; long lifespan. Test with MemTest86. |
| **GPU** | Caution | Mining cards ran 24/7 — fans worn, thermal paste degraded. Check for artifacts under load, repaste, stress test. Most warranties are NOT transferable. |
| **SSD** | Caution | Check TBW consumed and reallocated sectors via CrystalDiskInfo/smartctl. Avoid drives near their TBW limit. |
| **Motherboard** | Caution | VRM/capacitor wear invisible; bent socket pins common. Test before trusting. |
| **PSU** | Never | Internal degradation is invisible. A failing PSU can destroy every component. Buy new only. |

### Warranty

Warranty length signals manufacturer confidence and affects long-term value:

| Component | Typical warranty | Notes |
|-----------|-----------------|-------|
| CPU | 1–3 years | OEM varies; boxed retail longer than tray |
| GPU | 2–3 years | Some 3+ years (EVGA historically, XFX for AMD) |
| Motherboard | 3 years | Standard across most brands |
| RAM | Lifetime | Crucial, Corsair, G.Skill offer lifetime |
| SSD | 3–5 years OR TBW limit | Whichever comes first |
| PSU | 5–10 years | Quality units only; cheap PSUs 1–3 years |

For GPUs specifically, verify whether the warranty is transferable — most
are tied to the original purchaser with a receipt.

<!-- vim: set ft=markdown -->
