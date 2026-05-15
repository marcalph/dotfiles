# dotfiles

My nixified dotfiles, holds all my tooling for the few machines I own.


## Requirements

The detminate systems' nix. (I'm trying lix we'll see).

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```


## Initial Setup

First-time system setup (allowing nix-command and flakes) and depending on the Host:
```shell
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake flake.nix
```

## Daily Usage


```shell
sudo darwin-rebuild switch --flake flake.nix --show-trace -L -v
sudo nixos-rebuild switch --flake /path/to/your/flake#your-hostname
```


## Development Environment

The configuration includes a development shell with build dependencies:

```shell
nix develop
```
This provides gcc, make, and libraries needed for compiling Python packages with C extensions.


## Architecture

- **flake.nix**: Main configuration entry point
- **modules/darwin/**: System-level macOS settings
- **modules/home/**: User environment and packages

