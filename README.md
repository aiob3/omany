# omany

Open Omarchy's default coding agent **inside [Herdr](https://github.com/herdrdev/herdr)** instead of a
loose terminal window.

Omarchy's agent key starts Claude Code, Codex, or whichever agent you picked as
the default in its own terminal. Each press opens another isolated window. With
omany, every agent lands in the same Herdr window:

- **First press:** opens Herdr (starting its server if needed) with a dedicated
  `agents` workspace, and starts your default agent there.
- **Next presses:** bring that window forward and open a **new tab** with one more
  agent. The window is never duplicated.
- **Named agents:** each agent gets a unique Herdr name (`claude`, `claude-2`,
  `codex`...), so agents can find and prompt each other with `herdr agent prompt`.
- **Omarchy-aware from the first turn:** Claude Code and Codex get the `omarchy`
  skill loaded as soon as they start, if the skill is installed for them.

<!-- screenshots: assets/ -->

## Requirements

- Omarchy with the Quattro shell (`omarchy plugin` commands)
- [Herdr](https://github.com/herdrdev/herdr) (`herdr` on `PATH`)
- A default agent: `omarchy default agent <name>`
- `jq`

omany falls back to the stock `omarchy agent` launcher in two cases: Herdr is not
installed, or your default agent is one Herdr cannot drive (crush, openclaw, muse).

## Install

```bash
omarchy plugin add https://github.com/aiob3/omany.git --enable
```

Then point the agent key at omany in `~/.config/hypr/bindings.lua`:

```lua
hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + SHIFT + CTRL + A", "Agent in Herdr", "omarchy-shell shell toggle io.github.aiob3.omany")
```

Check the result with `hyprctl reload && hyprctl configerrors`.

## Settings

Optional. Put plain shell assignments in `~/.config/omany/config`:

```bash
OMANY_WORKSPACE="agents"   # label of the Herdr workspace
OMANY_CWD=""               # empty = same rule as `omarchy agent` (~/Work when launched from $HOME)
OMANY_LOAD_SKILL=true      # load the omarchy skill on the first turn (Claude Code, Codex)
OMANY_SESSION=""           # named Herdr session; empty = the default one
```

Each named session gets its own window.

## Heads-up: unattended mode

omany starts agents with the **same flags `omarchy agent` uses**, and those skip
approval prompts: `claude --permission-mode auto`, `codex --approve-for-me`,
`gemini --yolo` and so on. That is Omarchy's default for this key. If you want
approvals back, launch that agent yourself inside Herdr instead.

When an agent stops at a startup question (folder trust, login...), omany waits
up to a minute for you to answer it. If nobody answers, it skips the skill and
sends a notification instead.

## Troubleshooting

Everything omany does is logged to `~/.local/state/omany.log`.

## Uninstall

```bash
omarchy plugin remove io.github.aiob3.omany
```

Then remove the two binding lines above. The default key comes back.

## License

MIT
