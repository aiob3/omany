# Contributing to omany

Thanks for helping. omany is the first plugin of
[omonorepo](https://github.com/aiob3/omonorepo), and every change follows the same
rules as the rest of the series.

## Before you open a pull request

1. **Fork and branch** from `main`. One topic per pull request.
2. **Run the compliance check** from a local copy of
   [omonorepo](https://github.com/aiob3/omonorepo):

   ```bash
   omonorepo/compliance/bin/omono-check path/to/your/omany
   ```

   On a machine with Omarchy it also validates the manifest with
   `omarchy plugin validate` and checks every key in the README against your live
   Hyprland bindings. The same check runs automatically on every pull request
   (`.github/workflows/compliance.yml`); it must pass before a merge.
3. **Test it in real use** on Omarchy: press the keys, open the panel, and say in the
   pull request what you tried and on which versions of Omarchy, Herdr and the agents.

## Rules that matter most

The full list, with sources, is in
[compliance/RULES.md](https://github.com/aiob3/omonorepo/blob/main/compliance/RULES.md).

- **Consent.** omany never changes user configuration without an explicit user action:
  `shell.json`, `bindings.lua`, bar placement, or Omarchy's default agent.
- **Never run an agent binary to inspect it.** Some of Omarchy's launchers install the
  agent the first time they run. Read the file or ask `mise where`.
- **Keys.** A key suggested in the README must be free on a stock Omarchy (rule K1)
  and should avoid letters terminals use with Ctrl, such as P, N, R, L, U, W, K (K2).
- **Follow the system's defaults.** Work in `~/Work` and with the user's own Herdr
  session, as `omarchy agent` does; do not change a default to make a change easier.
- **English** for documentation, comments and commit messages. The README closes
  with a Portuguese section, after the `tupiniquim` anchor; keep it in sync when you
  change what omany does.
- **No personal data** in code, docs or screenshots.

## Reporting results for an untested agent

The README lists which agents were tested in real use. If you run one of the others
with omany, open an issue with the **Agent test report** template. That is how an agent
moves to "tested".

## Releases

Maintainers release. A release bumps `version` in `manifest.json`, tags `v<version>`,
publishes a GitHub release, and asks the Omarchy marketplace to verify the new commit
through its *Plugin verification* form ("Verify and publish a newer upstream commit").
