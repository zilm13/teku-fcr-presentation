# Teku FCR Presentation

Markdown slides about the Fast Confirmation Rule and its implementation in
[Teku](https://github.com/Consensys/teku), based on the
[Ethereum consensus specifications](https://github.com/ethereum/consensus-specs).

Edit `slides.md`. Keep diagrams and other local assets in `assets/`.

## Convert

With Docker running, execute from the repository root:

```sh
sh ./convert.sh html
sh ./convert.sh pdf
sh ./convert.sh pptx
```

Outputs go to `build/`. When sharing HTML, include its `assets/` folder.

## Commit checks

After cloning, enable checks for common secrets and personal paths:

```sh
git config --local core.hooksPath .githooks
```
