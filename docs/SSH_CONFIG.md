# SSH Config for Claude Code

> **Note**: This is a client-only Flutter app — the deployable artefacts are
> mobile binaries (APK/AAB/IPA), not a server image. The SSH and `claude-server`
> setup below applies if/when the team adds a build server, deployment server,
> or backend host for which Claude Code needs autonomous access. Until then,
> `/deploy`, `/test-live`, `/monitor`, and `/logs` will fail their SSH pre-check
> with a pointer to this file.

Add to your `~/.ssh/config` on the machine running Claude Code.
Replace `[FILL IN]` with actual values.

```
Host betrade-server
    HostName [FILL IN server IP]
    User claude-server
    IdentityFile ~/.ssh/claude-server
```

## Server User Setup (run once as root)
```bash
adduser claude-server --disabled-password
usermod -aG docker claude-server
usermod -aG www-data claude-server
```

## Generate Claude's SSH key
```bash
ssh-keygen -t ed25519 -f ~/.ssh/claude-server -C "claude-code-access"
ssh-copy-id -i ~/.ssh/claude-server.pub claude-server@[server-ip]
```

## Test connection
```bash
ssh betrade-server "echo connected"
```

## Security rules
- Each developer uses their **own** SSH key — never share keys.
- `claude-server` is a dedicated user; do **not** grant it sudo or root.
- Rotate keys immediately if suspected compromised.
- Revoke keys (`~claude-server/.ssh/authorized_keys`) when a team member leaves.
- Server firewall should allow SSH only from known IPs / VPN.
