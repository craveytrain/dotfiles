# 1Password CLI Module

This module provides the 1Password command-line interface for secure credential management and automation workflows.

## Core Features

The module delivers:

- **1Password CLI (op)** for password and secret management
- **Secure credential access** from the command line
- **Automation support** for scripts and CI/CD pipelines
- **Secret injection** into environment variables

## Installation Components

**Homebrew casks installed:**
- 1password-cli

**Configuration files:**
- None (authentication managed per-user)

## Prerequisites

To use 1Password CLI, you need:
- An active 1Password account (Individual, Family, Teams, or Business)
- 1Password desktop app installed (recommended for easier authentication)

## Initial Setup

### Sign In

**First-time authentication:**
```bash
op signin
```

Follow the interactive prompts to:
1. Enter your 1Password account subdomain
2. Provide your email address
3. Enter your Secret Key
4. Enter your Master Password

### Session Management

**Start a new session:**
```bash
eval $(op signin)
```

**Check session status:**
```bash
op whoami
```

## Basic Usage

### List Items

```bash
op item list                     # List all items
op item list --categories=Login  # List only logins
op item list --vault=Personal    # List items in specific vault
```

### Get Item Details

```bash
op item get "GitHub"             # Get item by name
op item get <item-id>            # Get item by ID
op item get "GitHub" --format=json  # JSON output
```

### Retrieve Passwords

```bash
op item get "GitHub" --fields password
op read "op://Personal/GitHub/password"
```

### Get Specific Fields

```bash
op item get "GitHub" --fields username
op item get "GitHub" --fields website
op item get "AWS" --fields "access key"
```

## Advanced Usage

### Secret References

Use secret references in scripts:
```bash
export API_KEY="op://Personal/API Keys/production key"
op run -- ./deploy.sh            # Injects secrets into environment
```

### Create Items

```bash
op item create --category=login \
  --title="New Service" \
  --vault=Personal \
  username=user@example.com \
  password=$(op generate-password)
```

### Generate Passwords

```bash
op generate-password             # Random strong password
op generate-password --length=32 # Specific length
```

### One-Time Passwords (TOTP)

```bash
op item get "GitHub" --otp       # Get current TOTP code
```

## Integration Examples

### Environment Variables

```bash
# Set env var from 1Password
export GITHUB_TOKEN=$(op item get "GitHub PAT" --fields token)

# Or use op run
echo 'GITHUB_TOKEN=op://Personal/GitHub PAT/token' > .env
op run --env-file=.env -- github-cli-command
```

### SSH Key Management

```bash
# Load SSH key from 1Password
op item get "SSH Key" --fields private_key > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```

### Script Automation

```bash
#!/bin/bash
# Script with 1Password integration
eval $(op signin)

DB_PASSWORD=$(op item get "Production DB" --fields password)
psql -U admin -h db.example.com -W "$DB_PASSWORD"
```

## Common Workflows

### Quick Password Retrieval

```bash
# Copy password to clipboard
op item get "GitHub" --fields password | pbcopy
```

### Search Items

```bash
op item list --tags=work         # Filter by tags
op item list | grep -i github    # Search by name
```

### Update Items

```bash
op item edit "GitHub" password=$(op generate-password)
```

## Security Best Practices

1. **Session timeout:** Sessions expire for security; re-authenticate as needed
2. **Avoid plaintext:** Never log passwords or store them in files
3. **Use secret references:** Prefer `op run` over manual secret extraction
4. **Audit access:** Regularly review item access in 1Password app
5. **Secure scripts:** Ensure scripts using `op` have appropriate permissions

## Troubleshooting

**Verify installation:**
```bash
op --version
```

**Not signed in:**
```bash
eval $(op signin)
```

**Session expired:**
Re-authenticate:
```bash
eval $(op signin)
```

**Item not found:**
- Verify item name (case-sensitive)
- Check vault access permissions
- Use `op item list` to confirm item exists

**Authentication issues:**
- Ensure 1Password desktop app is installed
- Verify your account credentials
- Check network connectivity

**CLI not finding desktop app:**
The CLI integrates with the desktop app for biometric unlock. Ensure:
- 1Password app is running
- You're signed in to the desktop app
- Desktop app integration is enabled in preferences

## Documentation

For comprehensive documentation:
```bash
op --help
op item --help
op signin --help
```

Or visit: https://developer.1password.com/docs/cli
