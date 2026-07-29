# CLAUDE.md — dotfiles

GNU Stow + Homebrew macOS dotfiles. Entry points: `bootstrap.sh` (cold start) and `make install`
(homebrew → brew-taps → brew-bundle → omz → stow → local-config). See README for targets.

## Gotchas
- **Secret-read hook blocks Bash commands containing secret-file patterns** (`*.local`,
  `.zshrc.local`, `.gitconfig.local`, `*.pem`, `*.key`) — from `claude/.claude/hooks/block-secret-reads.sh`.
  A `git commit -m`/`gh pr create --body` that merely *mentions* those paths is rejected.
  Workaround: write the message/body to a temp file and use `-F` / `--body-file`.
- **Machine-local config is gitignored**: `~/.config/git/config.user`, `~/.zshrc.local`
  (scaffolded from `.example` by `make local-config`). Never move corporate/secret values into tracked files.
- **`claude/.claude/settings.json` is a stow symlink the running app writes** (model/effort/theme),
  so `git status` shows it modified — don't sweep that drift into unrelated commits.

## Conventions
- Custom taps (`dex4er/tap`, `peonping/tap`) need `brew trust` — handled by `make brew-taps`.
- `make stow` backs up conflicting real files to `~/.dotfiles-backup-<ts>/` (no `--adopt`).
- Recipes must resolve brew via `$(BREW)` + `eval "$$($(BREW) shellenv)"` (PATH isn't set on a fresh Mac).
