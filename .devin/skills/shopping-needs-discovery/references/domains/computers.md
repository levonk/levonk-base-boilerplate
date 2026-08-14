# Computers — Domain Reference

Domain-specific constraints for whole laptops, desktops, and all-in-ones
(Apple Mac, Windows PC, Chromebook, Linux). Referenced by
`references/constraint-attributes.md`. Load when the user is buying a complete
computer — **not** when building/upgrading a PC from components (use
`computer-parts/index.md` for that).

Computers are high-value, long-lived devices with security lifecycles
(macOS/Windows/ChromeOS update horizons), repair ecosystems with increasing
parts pairing, and — on the used market — a serious **lock and theft risk**
that can turn a working machine into a paperweight after the next erase or
update. Verification before payment is critical.

## OS Update Horizon

A computer that stops receiving security updates becomes a risk and loses app
compatibility. Check the specific model — support is tied to release year, not
purchase date.

| Platform | Typical support | How to verify |
|----------|-----------------|---------------|
| macOS | ~6–7 yr from release | Check the model against Apple's current macOS compatibility list; a Mac dropped from the latest macOS still gets ~2 yr of security-only updates |
| Windows | ~10 yr for OS version (Win10 EOL Oct 2025) | Check Microsoft's Windows lifecycle page; verify the CPU is on the Win11 support list (Intel 8th Gen+ / AMD Zen+ / Qualcomm 7c+) |
| ChromeOS | ~6.5–8 yr AUE (auto-update expiry) | Look up the model on Google's Auto Update policy page; AUE date is the hard cutoff |
| Linux | Indefinite (distro-dependent) | Check the distro's LTS support window; hardware drivers for very new or very niche hardware may lag |

**Always confirm the exact model year.** A "2020 MacBook Pro" and a "2020
(early) MacBook Pro" can land on different sides of a macOS cutoff.

## The Lock Problem — Read Before Any Used Computer Purchase

Used computers carry the same class of account-tied locks as phones. A machine
that boots to the desktop today can lock you out after the next erase, update,
or reset. The four lock types below are the dominant used-computer scam
vectors. **The only reliable test is to erase the machine and walk through
setup while the seller is present** — see
[`acquisition/references/handoff-verification.md`](../../../acquisition/references/handoff-verification.md)
for the full in-person procedure.

### Activation Lock (Apple)

Applies to any Mac running macOS Catalina (10.15) or later with a **T2 Security
Chip** (Intel Macs from ~2018+) or any **Apple Silicon (M-series)** Mac.

- Enabled automatically when the owner signs in with an Apple Account and turns
  on **Find My Mac**.
- Survives erasure and macOS reinstallation. Without the original owner's Apple
  Account password (or Apple removing it with the original proof of purchase),
  the Mac is unusable.
- Pre-2018 Intel Macs without T2 do **not** have Activation Lock — but they can
  still have a firmware/EFI password (below).

### MDM / Remote Management (Any platform, worst on Mac)

A Mobile Device Management profile lets a company or school enforce policies or
remotely lock/wipe the machine. The most aggressive form is tied to **Apple
Business Manager / Apple School Manager (ABM/ASM)** — the Mac re-enrolls on
setup even after a wipe.

- Wiping the drive does **not** remove ABM/ASM enrollment. The machine can be
  remotely locked weeks or months later by an admin who never touched it.
- Many "locked" used Macs were sold off by companies or governments that did
  not properly deaccession them — the machine works until the org notices.
- Windows has an equivalent: Azure AD / Intune enrollment, or Autopilot
  registration. ChromeOS has enterprise enrollment. Both survive a wipe.

### Firmware / EFI Password (Apple, some PCs)

Set in Recovery Mode or BIOS/UEFI. Blocks booting from external media and
modifying startup settings. Apple will only remove it for the original owner
with proof of purchase. **Test:** hold **Option** at boot — if a password
prompt appears before the boot picker, walk away.

### BitLocker / Windows Account Lock (Windows)

- **BitLocker** recovery key is tied to the owner's Microsoft Account or Active
  Directory. A wiped BitLocker-encrypted drive is unrecoverable without the
  key. Confirm the drive is decrypted (or get the recovery key) before buying.
- **Windows Autopilot / Intune** enrollment survives a reset — same risk as
  Apple ABM.

## Stolen-Device Risk

Apple maintains a stolen-device registry; a reported-stolen Mac can be
blacklisted. Buying stolen goods can also create legal problems for the buyer,
not just the seller. Red flags: price too good to be true, seller can't show
proof of purchase, cash-only + parking-lot meetup, serial number scratched off
or tampered with, seller can't answer basic spec questions.

## Receipt Retention — Critical for Lock Removal

**Keep the original receipt, no matter where you buy.** Apple (and most
manufacturers) will only remove an Activation Lock, firmware password, or ABM
enrollment for the **owner of record with original proof of purchase**. This
applies whether you buy from Apple, an authorized distributor, or a third
party:

- **Buying new/refurbished from Apple or an authorized reseller:** save the
  invoice — it is your proof of ownership if a lock ever needs removing (e.g.,
  you forget your firmware password, or a refurb ships with a leftover lock).
- **Buying used from a third party:** require the seller's original receipt and
  a bill of sale transferring ownership to you. Without it, Apple will not help
  you remove a lock, and you have no recourse if the machine is later reported
  stolen.
- **Scan and back it up.** Paper fades and gets lost; store a dated scan/photo
  with the serial number visible alongside your other purchase records.

The same principle applies to phones (see `mobile-phones.md`) and any
account-tied device — the receipt is the only key that unlocks a forgotten or
contested lock.

## Battery Health

| Platform | How to check | Replace below |
|----------|-------------|---------------|
| MacBook | System Information → Power → Cycle Count (compare to rated max, ~1000 cycles) | 80% capacity or >80% of rated cycles |
| Windows laptop | `powercfg /batteryreport` (run in Command Prompt) | Noticeable runtime drop or >30% capacity loss |
| Chromebook | crosh shell → `battery_health` | Noticeable runtime drop |

Budget for a battery replacement ($100–$200, often requires partial disassembly)
when buying a 3+ year-old laptop.

## Repairability & Parts Pairing

| Repair | Typical cost | Notes |
|--------|-------------|-------|
| Battery | $100–$200 | Often glued in; Apple self-service available for some models |
| Screen | $200–$600 | Apple pairs the display to the logic board — third-party swap can disable True Tone |
| Keyboard (MacBook) | $200–$500 | Butterfly keyboards (2015–2019) are failure-prone; verify the model's keyboard |
| SSD | Varies | Many modern laptops (MacBook Air/Pro, Surface) have **soldered storage** — not upgradable |

**Parts pairing (Apple):** Apple pairs components (display, battery, Touch ID,
camera) to the logic board. Third-party replacement may disable features until
calibrated with proprietary tools. See `attributes/repairability.md`.

**Soldered RAM/storage:** Verify whether RAM and SSD are upgradable before
counting on a future upgrade. Many ultrabooks and all Apple Silicon Macs have
no user-upgradable RAM or storage — buy the config you need for the device's
life.

## Storage & RAM

| Use case | RAM | Storage |
|----------|-----|---------|
| Web/office | 8 GB minimum (16 GB preferred) | 256 GB |
| Photo/light video | 16 GB | 512 GB |
| Dev / heavy multitasking | 16–32 GB | 512 GB–1 TB |
| Pro video / ML | 32 GB+ | 1 TB+ |

For Apple Silicon Macs, RAM and storage are fixed at purchase — not upgradable.
For Windows laptops, check whether RAM/SSD are soldered or socketed before
planning upgrades.

## Used Computer Verification — Quick Reference

The full in-person procedure (with the "do with seller" vs "do later" split) is
in
[`acquisition/references/handoff-verification.md`](../../../acquisition/references/handoff-verification.md).
The computer-specific essentials:

1. **Get the serial number** (bottom case, or Apple menu → About This Mac /
   Settings → System → About) and run it through `checkcoverage.apple.com`
   (Apple) or the manufacturer's warranty checker. This confirms model/year —
   it does **not** confirm Activation Lock status.
2. **Boot to the desktop and check the signed-in account.** Apple: System
   Settings → Apple Account. Windows: Settings → Accounts. If someone else is
   signed in, require a full sign-out before paying.
3. **Confirm Find My Mac is OFF** (Apple) and no MDM profile is installed
   (System Settings → Privacy & Security → Profiles, or run `profiles list` in
   Terminal).
4. **Erase the machine and walk through setup while the seller is still
   there.** This surfaces Activation Lock and any MDM/Remote Management
   enrollment screen before money changes hands. If you see "Activation Lock"
   or "Remote Management," walk away.
5. **Hold Option at boot** to test for a firmware/EFI password.
6. **Get the original receipt and a bill of sale.** Save both — they are the
   only way to remove a lock later.

<!-- vim: set ft=markdown -->
