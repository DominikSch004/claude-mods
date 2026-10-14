# claude-mods

The Claude Code mods I want on every machine, as one plugin marketplace (`dominik-mods`).
Each entry points at the mod's upstream repo.

| Mod | What it does | Upstream |
|---|---|---|
| `savvy-progress` | Progress bar above the prompt and a live agents panel (`/agents-info`) | [JohnnyVizz/claude-kit](https://github.com/JohnnyVizz/claude-kit/tree/main/plugins/savvy-progress) |
| `savvy-flow` | Not a mod but its companion: `/savvy-flow:savvy-flow <task>` plans, hands the work to five tiered agents (Fable, Opus xhigh/high/medium/low) and reviews it. Their runs get the animated costumes in `savvy-progress` | [JohnnyVizz/claude-kit](https://github.com/JohnnyVizz/claude-kit/tree/main/plugins/savvy-flow) |
| `filetree` | IDE-style file tree with git status; shimmers on files Claude reads and writes | [data-goblin/claude-code-filetree](https://github.com/data-goblin/claude-code-filetree) |
| `skins` | Tool rows with icons, diff/table/Mermaid cards, usage band, fifteen themes (`/skin`) | [hellosverre/claude-skins](https://github.com/hellosverre/claude-skins) |

`setup.sh` also installs [ECC](https://github.com/affaan-m/everything-claude-code) (`ecc@ecc`, its own marketplace): all its agents, skills, commands and hooks, all its npm packages, and every rule pack in `~/.claude/rules/ecc` (language packs load only for matching files). Its hooks need Node.js and npm.

Mods need Claude Code 2.1.287 or later.

## Set up a machine

Linux and macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/DominikSch004/claude-mods/main/setup.sh | bash
```

Windows (PowerShell), or anywhere without bash:

```powershell
claude plugin marketplace add https://github.com/DominikSch004/claude-mods.git
claude plugin install savvy-progress@dominik-mods
claude plugin install savvy-flow@dominik-mods
claude plugin install filetree@dominik-mods
claude plugin install skins@dominik-mods
claude plugin marketplace add https://github.com/affaan-m/everything-claude-code.git
claude plugin install ecc@ecc
```

For ECC, also run `npm ci` in its folder under `~/.claude/plugins/cache/ecc/ecc/<version>`, and copy every folder in its `rules/` into `~/.claude/rules/ecc/`.

Then restart Claude Code. Re-running `setup.sh` is safe: it refreshes the marketplace, installs whatever is missing and uninstalls `blast-radius` if an older run put it there.

## Update

```bash
claude plugin marketplace update dominik-mods
claude plugin update skins@dominik-mods   # likewise for the others
```

After `claude plugin update ecc@ecc`, re-run `setup.sh`: the new version's folder doesn't have ECC's npm packages yet, and its hooks crash until it does. Rule packs aren't refreshed; delete one under `~/.claude/rules/ecc` to have `setup.sh` copy it fresh.

## Add a mod

1. Add an entry to `.claude-plugin/marketplace.json`. Use an `https://` URL: GitHub over SSH has stalled clones here.
   For a plugin that lives in a subfolder of a repo, use a `git-subdir` source with `path`.
2. Add its name to `MODS` in `setup.sh`.
3. `claude plugin validate .`, commit, push, then re-run `setup.sh` on each machine.

## Notes

- Sources follow each upstream's default branch; nothing is pinned. To pin one, add `"sha": "<commit>"` to its source.
- `filetree` shows in the terminal only in the fullscreen layout (`/tui fullscreen`) at 110+ columns.
