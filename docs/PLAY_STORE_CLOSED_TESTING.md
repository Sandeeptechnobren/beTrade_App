# BeTrade — Play Store Closed Testing Guide

**Goal:** get the signed AAB onto the Play **Closed testing** track with the least manual effort. Everything you need to paste is pre-drafted below.

> ⚠️ All steps here happen in **your** Google Play Console ([play.google.com/console](https://play.google.com/console)) — they require your Google account and (one-time) the $25 developer registration. They cannot be automated.

---

## 0. Pre-flight (do these once)

- [ ] Google Play Developer account created + **identity verification complete** (this can take 1–2 days — start immediately if not done)
- [ ] You have the signed **`app-release.aab`** ready (built with your release keystore — NOT debug)
- [ ] You have a **privacy policy URL** hosted somewhere public (see §6 for a fast option)

### Verify the AAB is correctly signed BEFORE uploading
If you copy the `.aab` to this machine, this confirms it won't bounce on upload:
```bash
# replace with your actual path
jarsigner -verify -verbose -certs path/to/app-release.aab
# should print "jar verified."
```
Or check the signing scheme:
```bash
"$ANDROID_HOME/build-tools/<version>/apksigner" verify --print-certs path/to/app-release.aab
```

---

## 1. Create the app (skip if already created)

Play Console → **Create app**
- App name: **BeTrade**
- Default language: English (or your market)
- App or game: **App**
- Free or paid: **Free**
- Tick the two declarations (developer program policies + US export laws)

---

## 2. Upload the AAB to Closed testing

- Left sidebar → **Testing → Closed testing**
- Use the default **Alpha** track (or **Create track**)
- **Create new release**
- **App signing**: on the first upload, accept **"Use Play App Signing"** (recommended — Google holds the real key, your keystore is just the upload key)
- **App bundles → Upload** → select `app-release.aab`
- **Release name:** `1.0.0 (closed test 1)`
- **Release notes:**
  ```
  <en-US>
  First closed test build. Sign-up, OTP login, market browsing, trade
  buy flow, wallet, and profile. Please report any crashes or UI issues.
  </en-US>
  ```
- **Save** (don't roll out yet — clear the gates in §3–§7 first)

---

## 3. Store listing (Grow → Store presence → Main store listing)

**App name:** `BeTrade`

**Short description** (max 80 chars — pick one):
```
Trade prediction markets — buy Yes/No shares and track your positions.
```

**Full description** (paste, edit to taste — keep it accurate, avoid over-promising returns):
```
BeTrade is a prediction-market trading app. Browse markets across
categories, see live prices, and take a position by buying Yes or No
shares on outcomes you believe in.

FEATURES
• Browse and search active markets by category
• Live price quotes before you trade
• Buy Yes / Buy No with a simple, fast flow
• Track your open positions and realised/unrealised P&L
• Wallet with deposit, withdrawal, and full transaction history
• Secure phone-number sign-in with OTP
• Profile, achievements, and customisable default trade amount
• Light and dark themes

Trade responsibly. Prices can move against you and you may lose the
amount you stake on a position.
```

**Graphics required:**
- App icon: **512 × 512** PNG (use a high-res export of `assets/logo/app_icon.png` — it's 1024×1024, downscale to 512)
- Feature graphic: **1024 × 500** PNG (a simple branded banner)
- Phone screenshots: **at least 2** (2–8 recommended). Capture from the running app: home market list, a trade detail/quote screen, portfolio, profile. PNG/JPG, 16:9 or 9:16, min 320px side.

---

## 4. Data safety form (App content → Data safety)

Based on what BeTrade actually collects (from the codebase audit), declare:

| Data type | Collected? | Shared? | Purpose | Notes |
|-----------|-----------|---------|---------|-------|
| **Name** (first/last) | Yes | No | Account management | from profile/KYC |
| **Email address** | Yes | No | Account management | signup |
| **Phone number** | Yes | No | Account management, Auth | OTP login |
| **User IDs** | Yes | No | Account management | backend user id, FCM token |
| **Photos** | Yes | No | Account management, App functionality | avatar + KYC document/selfie |
| **Gender / other personal info** | Yes | No | Account management | profile |
| **Financial info — purchase/wallet history** | Yes | No | App functionality | wallet, deposits, trades |
| **App activity** (in-app actions) | Yes | No | Analytics / App functionality | trades, positions |
| **Approximate/precise location** | No | — | — | app does not request location |

Other answers:
- **Is data encrypted in transit?** → **Yes** (HTTPS to api.buildacademy.io)
- **Can users request deletion?** → answer truthfully; if backend supports account deletion say Yes and provide the method, else "No" (but Google increasingly expects a deletion path)
- **Is data collected required or optional?** → Required for the listed account/auth data

---

## 5. Content rating (App content → Content ratings)

- Start questionnaire → category: **Finance** (or **Social** if Finance unavailable)
- Violence / sexual / language / drugs → **No** to all
- **Gambling / simulated gambling** → ⚠️ **This is the critical question.** BeTrade involves real-money positions. Answer **honestly** — if it's real-money wagering, you must say so, which triggers the gambling policy (see §8). If it's skill-based / virtual currency only, answer accordingly. **Get a definitive product/legal answer before submitting.**

---

## 6. Privacy policy (App content → Privacy policy)

Required, must be a **live URL**. Fast options if you don't have one:
- Host a simple page on Notion (publish to web), GitHub Pages, or your domain
- Use a free generator (e.g. termsfeed, freeprivacypolicy) — fill in: data collected (§4 list), how it's used, contact email, deletion request method
- Paste the public URL into Play Console

---

## 7. Other required gates (App content section)

- [ ] **Target audience & content** → select age groups (BeTrade is finance/real-money → 18+ is safest)
- [ ] **App access** → if the app is login-gated, choose "All or some functionality is restricted" and provide **reviewer test credentials**:
  - Give a working test phone number + how to get the OTP, OR
  - A demo account the reviewer can use. (I can help you set up a fixed test login if the backend supports one — ask.)
- [ ] **Ads** → declare whether the app shows ads (BeTrade: No, unless you've added an ad SDK)
- [ ] **Government apps / Financial features** → if Play asks, declare the financial nature truthfully

---

## 8. ⚠️ The make-or-break issue: gambling policy

BeTrade is a **real-money prediction market (GHS)**. Google Play's [Real-Money Gambling, Games, and Contests policy](https://support.google.com/googleplay/android-developer/answer/9858079):

- Real-money gambling apps are allowed **only in specific approved countries** and **only after you apply and are granted** the gambling permission.
- **Ghana is not in Google's default approved-countries list** for real-money gambling apps.
- If Google classifies BeTrade as gambling and you haven't been approved, **the app is rejected — even for closed testing review.**

**Action before you submit:** get a definitive answer from your team/legal on whether BeTrade is "real-money gambling" under this policy. If it is and Ghana isn't approvable, you may need to:
- Reposition as skill-based / virtual-currency (no cash payout), or
- Distribute off-Play for now (Firebase App Distribution / direct APK) until licensing is sorted.

---

## 9. Roll out + invite testers

- Back in **Testing → Closed testing → your release** → **Review release** → fix any red errors → **Start rollout to Closed testing**
- **Testers** tab → **Create email list** → add tester Gmail addresses → Save
- Copy the **opt-in URL** → send to testers → they tap "Become a tester" → install via Play Store
- Closed-track review is usually **a few hours to ~2 days**

---

## 10. Common upload errors & fixes

| Error | Fix |
|-------|-----|
| "App not signed correctly" / "Use a different key" | AAB signed with debug key. Rebuild with `key.properties` present (see `android/key.properties.template`). |
| "Version code N already used" | Bump `version:` in `pubspec.yaml` (e.g. `1.0.0+11`) and rebuild. Each upload needs a higher build number. |
| "You uploaded an APK" | Play wants AAB. Use `flutter build appbundle --release`, not `build apk`. |
| "Deobfuscation file missing" (warning) | Optional. Upload `build/app/outputs/mapping/release/mapping.txt` under the release's "App bundle explorer" for readable crash traces. |
| "target API level" rejection | Ensure `targetSdk` ≥ current Play requirement (you're on 34/36 — fine). |

---

## What Claude can still help with locally

- Verify your AAB's signature (`jarsigner -verify`) before you upload
- Bump `version:` in `pubspec.yaml` and rebuild if you hit a version-code clash
- Build a fresh signed AAB once `android/key.properties` exists on this machine
- Draft a privacy policy text you can host
- Set up a fixed reviewer test login (if backend supports it)
- Resize `app_icon.png` to 512×512 for the listing

Just ask for any of these.
