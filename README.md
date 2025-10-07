# dotfiles

Nix-based dotfiles repository providing complete macOS system configuration using nix-darwin and home-manager. Declarative, reproducible, and multi-machine compatible.

## Features

- **Complete System Configuration**: macOS settings, applications, and development environment
- **Deterministic Package Management**: All packages managed through Nix
- **Multi-machine Support**: Single configuration for multiple machines
- **Pre-configured Build Environment**: Ready for Python packages requiring C extensions

## Requirements

Install Nix using the Determinate Systems installer (recommended for macOS):

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

This installer provides cleaner uninstall and survives macOS updates.

## Initial Setup

First-time system setup:

```shell
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake flake.nix
```

## Daily Usage

Apply configuration changes:

```shell
sudo darwin-rebuild switch --flake flake.nix
❯ sudo darwin-rebuild build --flake .        
```

**Note**: Recent nix-darwin updates require `sudo` for system activation.

## Development Environment

The configuration includes a development shell with build dependencies:

```shell
nix develop
```

This provides gcc, make, and libraries needed for compiling Python packages with C extensions.

## Package Management

- **Python**: Use uv (0.8.2+) or Poetry
- **Node.js**: Use PNPM  
- **Rust**: Via rustup
- **System packages**: Add to `modules/home/default.nix`

## Architecture

- **flake.nix**: Main configuration entry point
- **modules/darwin/**: System-level macOS settings
- **modules/home/**: User environment and packages

See `CLAUDE.md` for detailed development guidance.  
