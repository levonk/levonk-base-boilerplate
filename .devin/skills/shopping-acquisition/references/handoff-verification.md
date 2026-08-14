# In-Person Handoff Verification — Lockable Devices

Canonical procedure for verifying a used **lockable device** at the point of
sale: phones, computers (laptops/desktops/Macs), tablets, and smartwatches.
These devices carry account-tied locks (Activation Lock, MDM/ABM, firmware
passwords, BitLocker, carrier financing) that can turn a working device into a
brick after the next erase, update, or reset — sometimes weeks later when a
remote admin notices.

**The core rule:** a device that works today is not proof it is yours
tomorrow. The only reliable test is to erase/reset the device and walk through
the setup screens **while the seller is still present, before money changes
hands**. Any seller who refuses this is a hard no.

This reference is shared by:

- `shopping-needs-discovery` → domain files (`mobile-phones.md`,
  `computers.md`) link here for the full procedure
- `shopping-acquisition` → the in-person handoff step of a marketplace purchase

## Why This Complicates a Sale

Unlike most used goods, lockable devices can be **remotely disabled** by
someone who never touches the device again:

- **Activation Lock / iCloud / Find My** (Apple) — survives a wipe; needs the
  original owner's Apple Account password.
- **MDM / Remote Management** (Apple Business/School Manager, Intune, Autopilot,
  ChromeOS enterprise enrollment) — re-enrolls on setup after a wipe; a remote
  admin can lock or wipe the device later.
- **Firmware / EFI password** — blocks boot from external media; manufacturer
  removes it only for the owner of record with proof of purchase.
- **Carrier financing / IMEI blacklist** (phones) — an unpaid installment plan
  lets the carrier blacklist the device after you buy it.
- **BitLocker / Microsoft Account** (Windows) — an encrypted drive is
  unrecoverable without the recovery key tied to the owner's account.

A device that boots to the desktop in a half-configured state can hide any of
these. The lock surfaces only when **you** erase, update, or reset it — by
which point the seller is gone with your cash. Cash marketplace sales have no
buyer protection; once you hand over cash, recovery is essentially impossible.

## Do With the Seller (Before Paying)

These steps must happen in the seller's presence, before any money changes
hands. If the seller won't allow them, walk away.

### 1. Confirm identity and model

- Get the **serial number** (phone: Settings → About; Mac: Apple menu → About
  This Mac; Windows: `wmic bios get serialnumber` or the bottom-case label).
- Run it through the manufacturer's warranty/coverage checker (Apple:
  `checkcoverage.apple.com`). This confirms the model/year — it does **not**
  confirm lock status.
- Confirm the serial is not scratched off or tampered with (stolen-goods red
  flag).

### 2. Inspect the signed-in account

- Boot to the desktop/home screen.
- Check the signed-in account: Apple → System Settings → Apple Account; Android
  → Settings → Accounts; Windows → Settings → Accounts.
- If someone else is signed in, require a **full sign-out** of every account
  (iCloud, App Store, iMessage, Google, Microsoft, Samsung) before paying.

### 3. Confirm locks are off / removed

- **Apple:** Find My Mac/Phone is OFF (Settings → Apple Account → Find My).
  Check for MDM profiles: System Settings → Privacy & Security → Profiles, or
  run `profiles list` in Terminal. Any profile = stop.
- **Android:** Factory reset protection (FRP) is cleared by the signed-out
  Google account. Confirm no Google account remains.
- **Windows:** Confirm the drive is decrypted (BitLocker off) or get the
  recovery key. Confirm no Autopilot/Intune enrollment.
- **Carrier (phones):** run the IMEI on the carrier's activation checker and a
  blacklist database (Swappa, CTIA Stolen Phone Checker). Test with **your**
  SIM to confirm activation and signal.

### 4. Erase / factory reset and walk through setup — THE critical step

This is the single most important step. It surfaces every lock before money
moves:

- **Apple:** erase the Mac/iPhone via Settings → General → Transfer or Reset →
  Erase All Content and Settings (or Recovery for a Mac). Walk through the
  setup screens to the home screen.
- **Android:** factory reset via Settings → System → Reset options. Walk
  through setup to the home screen.
- **Windows:** Settings → System → Recovery → Reset this PC (Remove
  everything). Walk through OOBE to the desktop.
- **Watch for:** an **Activation Lock** screen, a **"Remote Management" / "This
  device is supervised"** screen, a **FRP / "Verify your account"** screen, or
  an **Autopilot enrollment** screen. Any of these = walk away immediately.

### 5. Test firmware / boot lock (computers)

- **Mac:** hold **Option** at boot. If a password prompt appears before the
  boot picker, a firmware/EFI password is set — walk away.
- **PC:** enter BIOS/UEFI (F2/Del/Esc). If a supervisor password blocks it,
  walk away.

### 6. Get the original receipt and a bill of sale

- Require the seller's **original receipt/invoice** and a **bill of sale**
  transferring ownership to you (date, seller name, serial number, price,
  signature).
- Photograph the receipt and the device serial number together before parting.
- See **Receipt Retention** below for why this is non-negotiable.

### 7. Pay with a protected method

- Use a **credit card** or a service with buyer protection (PayPal Goods &
  Services). Avoid cash, Zelle, Venmo Friends & Family, wire transfer, or
  cryptocurrency for marketplace purchases — these offer no recourse if the
  device is later blacklisted or locked remotely.

## Do Later (After a Clean Handoff)

These steps are safe to do after you've confirmed the device is clean and
you've paid:

- **Set up your own accounts** (Apple Account, Google, Microsoft) and enable
  Find My / your own device management.
- **Install OS updates** and confirm the device still activates afterward (a
  clean device will; a borderline one might not).
- **Run hardware diagnostics:** Apple Diagnostics (boot holding D), Windows
  Memory Diagnostic, battery health report (`powercfg /batteryreport` on
  Windows; System Information → Power on Mac).
- **Check recall status** by serial number (CPSC, manufacturer recall pages).
- **Transfer or verify warranty** (e.g., AppleCare+ transfers via Apple
  Support with the original receipt).
- **Back up the receipt** — scan it and store it with the serial number and
  date of purchase.

## Receipt Retention — The Only Key to a Forgotten Lock

**Save the original receipt for every account-tied device, regardless of where
you bought it.** Manufacturers will only remove an Activation Lock, firmware
password, or MDM/ABM enrollment for the **owner of record with original proof
of purchase**. This is true for Apple, and the same principle applies to
phones, tablets, and any account-tied device.

- **From the manufacturer or an authorized distributor:** keep the invoice. A
  refurb can ship with a leftover lock, or you may forget your own firmware
  password years later — the receipt is your only recourse.
- **From a third party / marketplace:** require the seller's original receipt
  **plus** a bill of sale. Without proof of ownership, the manufacturer will
  not remove a lock, and you have no defense if the device is reported stolen
  later.
- **Back it up:** paper fades and gets lost. Scan or photograph the receipt
  with the serial number visible, date it, and store it alongside your other
  purchase records. Cloud storage with the device's serial in the filename
  makes it findable years later.

## Walk-Away Triggers (No Exceptions)

Walk away from the sale if **any** of these are true:

- The device shows an Activation Lock, Remote Management, FRP, or Autopilot
  screen after a wipe.
- A firmware/EFI/supervisor password is set and the seller can't remove it.
- The seller can't or won't sign out of their account.
- The IMEI is blacklisted or carrier-financed and unpaid (phones).
- The seller can't produce the original receipt and won't allow a wipe test.
- Price is too good to be true + cash-only + parking-lot meetup + scratched
  serial.
- The seller is in a rush, can't answer basic spec questions, or refuses to
  meet at a carrier store / Apple Store / police-station safe-exchange zone.

<!-- vim: set ft=markdown -->
