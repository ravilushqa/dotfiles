# Dotfiles

My personal macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/)
and [Homebrew](https://brew.sh/).

## Quick Start (new Mac, one command)

On a brand-new Mac with nothing installed, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ravilushqa/dotfiles/main/bootstrap.sh)"
```

`bootstrap.sh` installs Homebrew (which also brings in the Xcode Command Line Tools and
`git`), clones this repo to `~/dotfiles`, and runs `make install`. It is idempotent — safe
to re-run.

After it finishes, do the manual follow-ups it prints:

```bash
gh auth login          # authenticate GitHub
make ssh-key           # generate + upload an SSH key (see below)
# then edit:
#   ~/.config/git/config.user   (Git name/email)
#   ~/.zshrc.local              (machine-specific env / secrets)
exec zsh               # restart your shell
```

## What `make install` does

`make install` runs these targets in order:

| Target        | Action |
|---------------|--------|
| `homebrew`    | Installs Homebrew if missing; puts it on PATH. |
| `brew-taps`   | Taps **and `brew trust`s** the custom taps `dex4er/tap` and `peonping/tap` (modern Homebrew blocks untrusted taps). |
| `brew-bundle` | Installs everything in the `Brewfile`. |
| `omz`         | Installs oh-my-zsh and clones `powerlevel10k`, `zsh-autosuggestions`, `zsh-syntax-highlighting` into `~/.oh-my-zsh/custom`. |
| `stow`        | Symlinks all config modules into `$HOME` (backing up any pre-existing real files to `~/.dotfiles-backup-<timestamp>/`). |
| `local-config`| Scaffolds `~/.config/git/config.user` and `~/.zshrc.local` from their `.example` templates (never overwrites). |

### Other targets

- `make ssh-key` — **opt-in, not part of `install`.** Generates an `ed25519` key if none exists,
  adds it to the macOS keychain/ssh-agent, and uploads the public key to GitHub via `gh`.
  Run it after `gh auth login`. If `gh` lacks the required scope it prints the
  `gh auth refresh -h github.com -s admin:public_key` hint.
- `make update` — `brew update && brew upgrade`.
- Individual pieces can be run on their own, e.g. `make stow`, `make omz`, `make brew-bundle`.

## Manual installation

```bash
git clone https://github.com/ravilushqa/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

## Modules

Stow packages linked into `$HOME`:

- **zsh** — Zsh + oh-my-zsh config, powerlevel10k prompt, aliases, functions, PATH, Homebrew env
- **git** — modular Git configuration (`~/.config/git/`)
- **ssh** — `~/.ssh/config` (default identity `~/.ssh/id_ed25519`)
- **ghostty**, **zed** — terminal / editor config
- **claude** — Claude Code config (`~/.claude/`)

## Customization

- **Git identity** — edit `git/.config/git/config.user` (gitignored; created by `make git-local`).
- **Machine-specific Zsh** — edit `~/.zshrc.local` (gitignored; sourced last; created by `make zsh-local`).

## Maintenance

- Re-link configs after adding files: `make stow`
- Update Homebrew packages: `make update`
- Install newly-added Brewfile packages: `make brew-bundle`

## Notes & caveats

- **Casks needing admin rights** (e.g. `wifiman`) prompt for your `sudo` password during
  `brew-bundle`. If `make install` ran unattended and one failed, re-run `make brew-bundle`
  in an interactive terminal.
- **MDM-managed apps** (e.g. `1password`, `jetbrains-toolbox`) may already be installed by
  your organization. Homebrew's post-install `chmod` step can then "fail" even though the app
  is present and usable — safe to ignore.
- **`tf`** (the terraform wrapper cask from `dex4er/tap`) calls a `terraform` binary at
  runtime. `asdf` is installed; add a terraform version via asdf (or install `terraform`
  separately) if you use it.
- **`claude/.claude/settings.json` is a symlink**, and Claude Code writes runtime settings
  (model, effort, theme) through it. Expect `git status` to occasionally show it as modified;
  commit or discard that churn as you see fit.

## License

MIT
