# CPU & Motherboard — Sub-Domain Reference

Constraints specific to the processor and motherboard — the foundation of
every PC build. Load when the user is buying a CPU, motherboard, or both.
For cross-component compatibility, see `index.md`.

The CPU and motherboard lock in the platform: socket, chipset, memory
generation, and upgrade path. Getting this pair wrong forces a return or
a full rebuild. Verify socket and chipset compatibility before anything
else.

## CPU Socket Compatibility

| Vendor | Current sockets | Longevity |
|--------|----------------|-----------|
| Intel | LGA 1700 (12th/13th/14th gen), LGA 1851 (Core Ultra 200S) | Intel changes sockets roughly every 2 generations — limited upgrade path |
| AMD | AM5 (Ryzen 7000/8000/9000) | AMD has committed to AM5 support through 2027+ — longevity advantage for upgraders |

- The CPU must match the motherboard socket exactly. An LGA 1700 CPU does
  not fit an LGA 1851 board, and vice versa.
- Even within the same socket, a **BIOS update may be required** to support
  a newer CPU on an older board (see BIOS Update below).

## CPU Cooler Clearance

- **Air coolers**: check cooler height (mm) against the case's max CPU
  cooler height. A 165mm tower cooler won't fit a case with a 160mm limit.
  Also check RAM clearance — tall heat spreaders may block the front fan.
- **AIO liquid coolers**: check radiator thickness + fans (typically 27mm
  radiator + 25mm fan = 52mm total) against case radiator support. Verify
  the case supports the radiator size (240/280/360mm) at the intended mount
  location (top/front).

## TDP and Cooling

| TDP range | Class | Cooling needed |
|-----------|-------|---------------|
| 65W | Stock / entry | Stock cooler acceptable (loud under load) |
| 95–105W | Mid-range | Aftermarket air cooler ($30–60) |
| 125–170W | High-end | Large air or 240mm+ AIO |
| 200W+ | Enthusiast | 280/360mm AIO recommended |

Higher TDP needs a better cooler. Undersizing causes thermal throttling —
the CPU slows itself to avoid damage.

## Integrated Graphics vs Dedicated

- **APUs with iGPU** (AMD Ryzen G-series, Intel non-F CPUs): fine for
  office work, web browsing, media playback, and light/old games.
- **Gaming, video editing, AI/ML, 3D rendering**: requires a dedicated
  GPU. An iGPU will not drive modern titles or accelerate CUDA workloads.
- CPUs with an "F" suffix (Intel) or non-G Ryzen lack an iGPU — a
  dedicated GPU is mandatory or the system has no display output.

## Motherboard Chipset Tiers

| Tier | Intel | AMD | Unlocks |
|------|-------|-----|---------|
| Entry | B-series (B760) | B-series (B650) | Basic features, no CPU OC |
| Mid | H-series (H770) | — | More PCIe lanes, USB ports |
| High | Z-series (Z790) | X-series (X670) | CPU overclocking, more PCIe lanes, better VRM |

- B-series is sufficient for most users. Pay for Z/X only if overclocking
  or running high-end CPUs that stress the VRM.

## VRM Quality

The VRM (Voltage Regulator Module) delivers stable power to the CPU.

- **Critical for high-end CPUs** — a weak VRM overheats and throttles under
  sustained load.
- Check **VRM heatsink** size and **phase count** (more phases = better
  load distribution, less heat per phase).
- Review sites (Hardware Unbox, Gamers Nexus) test VRM thermals — consult
  these for high-end CPU pairings.

## BIOS Update

- A newer CPU may require a BIOS update on an older motherboard.
- Some boards have **BIOS Flashback** — update the BIOS from a USB stick
  without a CPU or RAM installed. Essential when buying an older board for
  a newer CPU with no compatible CPU on hand.
- Otherwise you need a compatible older CPU to boot and flash.

## Form Factor

| Form factor | Size | Case support |
|-------------|------|-------------|
| ATX | Full size | ATX, E-ATX cases |
| Micro-ATX (mATX) | Mid | mATX, ATX cases |
| Mini-ITX (ITX) | Smallest | ITX, mATX, ATX cases |

The motherboard form factor must match a case that supports it. A larger
case can hold a smaller board; a smaller case cannot hold a larger board.

## PCIe Version

- PCIe 4.0 vs 5.0 — GPU and NVMe performance differences are **minimal
  currently**. Don't overpay for 5.0 unless buying top-tier NVMe for
  sustained workloads.
- GPUs are backwards compatible (a PCIe 4.0 GPU works in a PCIe 3.0 slot,
  with negligible performance loss).

## M.2 Slots

- Count the M.2 slots and their PCIe version (3.0/4.0/5.0).
- Some M.2 slots **share lanes with the GPU** or SATA ports — installing an
  NVMe may disable a SATA port or downgrade the GPU to x8. Check the
  motherboard manual's lane-sharing table.

## Rear I/O

Verify the rear I/O panel covers the user's needs:

- Enough USB ports (count + type: USB-A, USB-C, USB 3.2 Gen 2)?
- DisplayPort and/or HDMI if using integrated graphics?
- WiFi/Bluetooth included, or does the user need a separate adapter?
- Ethernet speed (1GbE standard, 2.5GbE on mid+, 10GbE on high-end)?

<!-- vim: set ft=markdown -->
