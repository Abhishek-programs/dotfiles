# Dotfiles

## Install

Run from the repository in Terminal:

```bash
./install.sh
```

The interactive menu uses these keys:

- `A`: Full setup: clear the Dock if needed, run the package/configuration setup, clear any app icons added during installation, then create or show the SSH key.
- `D`: Clear all pinned Dock apps and folders, and disable suggested/recent Dock items.
- `I`: Run the package/configuration setup only.
- `S`: Create or show the default Ed25519 SSH key with the `personal_mac` comment.

You can also pass a key directly, for example `./install.sh D` or `./install.sh A`.
The installer installs Node LTS through NVM, installs Corepack if the selected Node
version does not provide it, activates pnpm, and configures Ghostty and macOS
Terminal to use JetBrainsMono Nerd Font Mono for fixed-width text and terminal icons.

The SSH helper creates the default `~/.ssh/id_ed25519` key with a passphrase prompt, configures an OpenSSH GitHub host entry, starts or reuses `ssh-agent`, and adds the key with Apple Keychain support when it has a passphrase. It reuses an existing default key without overwriting it.
