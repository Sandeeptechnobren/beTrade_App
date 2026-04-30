# Access & Credentials Guide
How to get access to everything needed for this project.

> **Project context**: Betrade is a Flutter mobile client app. There is no
> Betrade-owned backend repo, no database to access, and no CI server in this
> repo. The "backend" is a third-party REST API (`api.buildacademy.io`) operated
> elsewhere — its credentials and infrastructure live in a different system.

## GitHub Repository
- Repo: <https://github.com/Sandeeptechnobren/beTrade_App>
- Access: Ask [FILL IN tech lead name] to add you as collaborator.
- Setup SSH key: <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>
- After access granted, run:
  ```bash
  git clone https://github.com/Sandeeptechnobren/beTrade_App.git
  git config user.name  "Your Name"
  git config user.email "your@email.com"
  ```

## Environment Variables
- This project uses a single `.env` file at the repo root (loaded via `flutter_dotenv`).
- **Currently `.env` is committed** to the repo (see `docs/CODEBASE_AUDIT.md` §9). Do **not** add new secrets to it until that is fixed (`.env` should be in `.gitignore`).
- Required variables (see `docs/ARCHITECTURE.md` §10):
  - `BASE_URL` — REST API root (e.g., `https://api.buildacademy.io/projects/betrade/public/api`).
- After cleanup: copy `.env.example` to `.env` and request actual values from the tech lead via [FILL IN secure channel — NOT Slack/email].
- **NEVER** share `.env` files via email, Slack, or any unencrypted channel.

## Backend API Access
- Base URL: `https://api.buildacademy.io/projects/betrade/public/api`.
- Bearer-token auth via OTP — no shared API keys; each user signs in to obtain a token.
- Backend infra (server, database, deploys) is **outside this repo**. Operational owner: [FILL IN backend team / contact].

## Deployment / Server Access
- **No CI on `main`.** Codemagic config exists on the `feature/codemagic-testflight` branch but has not been merged. Builds today are produced manually with `flutter build apk` / `flutter build appbundle` / `flutter build ipa`.
- Android signing: release currently uses the **debug** keystore (`android/app/build.gradle.kts:30`). Must be replaced with a real keystore via `android/key.properties` before Play Store distribution.
- iOS signing: no `DEVELOPMENT_TEAM` / `PROVISIONING_PROFILE` set. Must be configured per developer (Xcode automatic) or per CI (manual provisioning) before distribution.
- Deploy command: `/deploy` is wired up but requires SSH access to a deployment target (see `docs/SSH_CONFIG.md`). Currently no deployment target exists.

### Server
| Server | Host/IP | SSH User | Purpose | Who Can Access |
|--------|---------|----------|---------|----------------|
| betrade-server | [FILL IN — none provisioned yet] | claude-server | TBD | TBD |

### SSH Setup for Claude Code
See `docs/SSH_CONFIG.md` for full setup instructions.
1. Generate SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/claude-server -C "claude-code-access"`
2. Send your **public** key (`~/.ssh/claude-server.pub`) to the tech lead.
3. Tech lead adds it to the server's `authorized_keys`.
4. Test connection: `ssh betrade-server "echo connected"`.
5. Claude Code will use your local SSH key automatically — no extra config needed.

### Deploy Flow (via Claude Code)
- `/deploy` — deploys to server autonomously (auto-fix loop with circuit breaker). Requires SSH set up.
- `/test-live` — tests against live server.
- `/monitor` — checks server health and resources.

## Third-Party Services (API Keys in `.env`)
- **None currently.** No payment gateway, no push notifications, no analytics, no third-party CDN, no third-party KYC vendor, no maps, no social-login SDK (the social-login buttons in `login_screen.dart` are UI-only stubs). See `docs/ARCHITECTURE.md` §8 for the full integrations table.
- If/when a service is added: list it here with how to get access and who manages it.

## Database Access
- **No application database.** The app does not connect to a database directly — all persistence is HTTP-mediated via the backend at `api.buildacademy.io`.
- Local persistence (in-app only): `SharedPreferences` keys for `token`, `theme_mode`, `onboardingDone`, `isFirstTime`. See `docs/ARCHITECTURE.md` §4.

## Who to Contact
- Tech Lead: [FILL IN name + contact]
- DevOps / Server: [FILL IN name + contact]
- Project Manager: [FILL IN name + contact]
- Backend API owner (api.buildacademy.io): [FILL IN]

## Security Reminders
- Each developer uses their **own** SSH key — never share keys.
- Rotate any credential immediately if you suspect it's compromised.
- Never commit `.env`, private keys, keystores (`*.jks`), or secrets to git.
- Use a password manager (1Password, Bitwarden) for shared team credentials.
- When migrating to a production server, generate **all** new credentials — never reuse dev credentials.
