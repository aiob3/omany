# Security

Please report security problems privately through
[GitHub's private vulnerability reporting](https://github.com/aiob3/omany/security/advisories/new),
not in a public issue.

omany starts agents with the same approval-skipping flags as `omarchy agent`; that is
documented behavior, not a vulnerability. It never uses `sudo`, never installs
software, and only writes the files listed under "What it writes" in the README.
