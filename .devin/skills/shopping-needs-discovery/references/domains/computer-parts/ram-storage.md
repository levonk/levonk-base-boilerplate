# RAM & Storage — Sub-Domain Reference

Constraints specific to system memory and storage drives. Load when the
user is buying RAM, an SSD, NVMe drive, or HDD. For motherboard memory
support and M.2 slot details, see `cpu-motherboard.md`.

RAM and storage are frequently under- or over-specified. The right
capacity, speed, and NAND type depend heavily on the workload.

## RAM Speed and Timing

| Generation | Sweet spot | Notes |
|------------|-----------|-------|
| DDR4 | 3200–3600 MHz | CL16 or lower at 3200; CL18 acceptable at 3600 |
| DDR5 | 6000–6400 MHz | CL30 or lower at 6000 is ideal |

- **CL (CAS latency) matters** — lower is better. A 3600 CL18 kit is
  roughly equivalent to a 3200 CL16 kit in real-world performance.
- Check the **motherboard QVL** (Qualified Vendor List) for compatible
  kits. Kits not on the QVL usually work but aren't guaranteed.
- DDR4 and DDR5 are **not interchangeable** — the motherboard supports one
  or the other, never both.

## RAM Capacity

| Capacity | Use case |
|----------|----------|
| 8 GB | Minimum for office/web; insufficient for modern gaming |
| 16 GB | Standard for gaming and general use |
| 32 GB | Heavy multitasking, content creation, some video editing |
| 64 GB+ | Professional workloads (3D rendering, large datasets, VMs) |

## RAM Configuration

- **2 sticks are better than 4** for stability and speed — dual-channel
  bandwidth is the same, but 4 sticks stress the memory controller and
  often force lower speeds.
- Populate **matching slots** per the motherboard manual (typically A2/B2
  for 2 sticks) to enable dual-channel mode.
- Mixing kits (different speed, timing, or brand) is risky — the system
  runs at the slowest common settings, and may not boot at all.

## ECC RAM

- Only on **workstation/server platforms** — Intel Xeon, AMD Threadripper
  PRO, some Ryzen desktop CPUs with Pro suffix.
- Not needed for consumer use — ECC adds cost and limits motherboard
  choice. Skip unless the user has a specific reliability requirement
  (ZFS storage, mission-critical servers).

## NVMe vs SATA SSD

| Interface | Sequential speed | Best for |
|-----------|-----------------|----------|
| NVMe (PCIe 4.0) | 3.5–7 GB/s | Large file transfers, video editing, OS drive |
| NVMe (PCIe 5.0) | 10–14 GB/s | Enthusiast, sustained workloads |
| SATA SSD | 500–550 MB/s | Budget OS drive, bulk storage |

- NVMe is **7–14x faster** on paper but **barely noticeable for everyday
  use** (web, office, light gaming). It matters for large file transfers,
  video editing, and game load times in some titles.
- For a boot drive, any NVMe is fine. For bulk game storage, a SATA SSD or
  cheap NVMe is cost-effective.

## NVMe Form Factor and Protocol

- **M.2 2280** is the most common form factor — verify the motherboard has
  a matching slot.
- **PCIe 3.0/4.0/5.0** — check motherboard support. A PCIe 4.0 NVMe works
  in a 3.0 slot at 3.0 speeds.
- Some NVMe drives **need a heatsink** — check if the motherboard includes
  an M.2 heatsink, or add one. PCIe 5.0 drives run hot and generally
  require one.

## DRAM Cache on SSD

- SSDs with a **DRAM cache** perform better under sustained writes — the
  cache holds the flash translation layer mapping for fast lookups.
- **DRAM-less SSDs** slow down dramatically when the SLC cache fills
  during sustained writes — fine for OS/light use, bad for large transfers.
- Check the spec sheet for DRAM presence (don't rely on marketing).

## TBW Endurance

- **TBW (Terabytes Written)** is the rated write endurance — the warranty
  expires when TBW is reached OR the time limit passes, whichever first.
- **TLC NAND** is better than **QLC NAND** (QLC has lower endurance and
  slower sustained writes).
- For OS drives, **600+ TBW** is recommended for longevity.

## HDD for Bulk Storage

- Still relevant for **mass storage** (media libraries, backups, archives).
- **5400 vs 7200 RPM**: 7200 is faster but louder and hotter; 5400 is fine
  for archival storage.
- **CMR vs SMR**:
  - CMR (Conventional Magnetic Recording) — standard, good for all uses
  - SMR (Shingled Magnetic Recording) — overlapping tracks; **terrible for
    RAID and sustained writes** — avoid for NAS use. Often not clearly
    labeled; check reviews/model numbers.

## Used SSD Risk

- Check health with **CrystalDiskInfo** (Windows) or **smartctl**
  (Linux/macOS):
  - **TBW consumed** vs rated TBW — a drive at 90% of its TBW is near end
    of life
  - **Reallocated sectors** — a sign of failing NAND
  - **Power-on hours** — high hours with low writes is fine; high writes
    is not
- Avoid SSDs with **high write amplification** — indicates heavy mixed
  workload use that wears NAND faster than the raw TBW suggests.

<!-- vim: set ft=markdown -->
