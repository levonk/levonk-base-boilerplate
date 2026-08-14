# Obsolescence & Lifecycle Risks — Attribute Reference

Constraint attribute: applies when the item has software, firmware, cloud
service, or ecosystem dependencies. Referenced by
`references/constraint-attributes.md`.

## OS / Firmware Update Horizon

How long will the manufacturer provide security updates? A device past its
update horizon is a security risk — unpatched vulnerabilities.

| Manufacturer | Typical support window | Notes |
|-------------|----------------------|-------|
| Apple (iOS) | 5–7 years from release | Longest in the industry |
| Apple (macOS) | ~7 years | Security-only updates after that |
| Google Pixel | 3–7 years (varies by model) | Pixel 8+: 7 years |
| Samsung Galaxy | 3–4 years for flagships | Less for budget models |
| Most Android OEMs | 1–2 years | Check the specific model |
| Windows laptops | ~5 years (Microsoft) | OEM driver support may be shorter |
| IoT / smart home | 2–3 years | Often less — check the company |
| Chromebooks | Auto-update expiration date | Published by Google, check before buying |

**If the device is already past its update horizon, it's a security risk.**
Buying a used device that's end-of-life means buying a device that will
never get safer. Recommend buying new or a used model still within its
support window.

## Company Viability

Is the manufacturer likely to exist in 3–5 years? If a startup makes the
product, what happens to it if the company dies?

**Cloud-dependent devices brick when the company shuts down the server.**
Known precedents:

| Product | What happened |
|---------|--------------|
| Revolv hub | Google/Nest shut down server; device became useless |
| Staples Connect | Discontinued; hubs bricked |
| Lowe's Iris | Service terminated; devices stopped working |
| Insteon | Company shut down abruptly; devices went dark (later partially rescued) |
| Pebble | Acquired by Fitbit; watches lost cloud features |
| Sproutling | Baby monitor bricked when company folded |

**Prefer products that work locally without cloud dependency**, or that have
an open-source firmware alternative (Home Assistant, Tasmota, ESPHome,
Homebridge). If the product requires a cloud account to function, research
the company's funding stage, revenue, and user base before committing.

## Proprietary Ecosystem Lock-In

Buying into a dying or niche ecosystem means accessories, software, and
support will disappear. Examples of dead/dying ecosystems:

- Windows Phone, BlackBerry OS, Firefox OS, WebOS (as a phone OS)
- Google Reader, Nest's original API, Fitbit (being sunset by Google)
- Amazon Dash buttons, Google Stadia

Check ecosystem health: active developer community, app availability,
accessory market, and manufacturer commitment signals (roadmaps, conference
presence, R&D spending).

## Right-to-Repair Hostility

Manufacturers that actively block third-party repair make long-term ownership
expensive. Known hostile manufacturers:

| Manufacturer | Tactics |
|--------------|---------|
| Apple | Serialized components, parts pairing, proprietary service tools |
| John Deere | ECU pairing, software locks on repairs |
| Tesla | Parts pairing, service mode locks |
| Dyson | Serialized batteries, proprietary connectors |

Factor in higher lifetime repair costs when buying from hostile
manufacturers. For products expected to last 5+ years, repairability
matters — see `attributes/repairability.md`.

## Planned Obsolescence

Some manufacturers are known for deliberately short support windows or
engineered failure points. Research the brand's reputation for longevity
before recommending. Search `<brand> planned obsolescence` and
`<brand> premature failure` on forums and consumer advocacy sites.

<!-- vim: set ft=markdown -->
