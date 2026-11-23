# hugo-update-script

A shell script to update to the latest version of the [Hugo](https://gohugo.io/) static web site generator.

Forked from [dkebler's Gist](https://gist.github.com/dkebler/1188d098d62166fdc6065fb2658a71dd).

Changes from dkebler's version:

2024: Work on any Linux distro (original was limited to systems with the 'arch' command) and presumably BSD, OSX, other unix based OSes.
2026: Removed references to extended Hugo version. (As of v0.170.0 Hugo no longer has an extended version.)

## How to use

- Copy this script into `/usr/local/bin`.
- Make it executable.
- Run script as root `sudo hugo-update.sh`.
- Latest version of Hugo is installed in `/usr/local/bin`.
