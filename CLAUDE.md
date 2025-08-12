# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository that provides complete macOS system configuration using nix-darwin and home-manager. The configuration is declarative, reproducible, and supports multiple machines.

## Commands

### System Configuration
```bash
# Apply configuration changes (rebuild system)
nixswitch
# Or explicitly:
darwin-rebuild switch --flake flake.nix

# Enter development shell with build dependencies
nix develop

# Update flake dependencies
nix flake update
```

### Testing Changes
Before applying system-wide changes, test Nix configurations:
```bash
# Check for syntax errors
nix flake check

# Build without switching
darwin-rebuild build --flake flake.nix
```

## Architecture

### Configuration Structure
The repository uses a modular architecture with Nix flakes:

- **flake.nix**: Entry point defining machine configurations (air, rizoapro) and dependencies
- **modules/darwin/**: System-level macOS settings (Dock, Finder, security)
- **modules/home/**: User environment (packages, shell config, development tools)

### Key Design Principles
1. **Declarative Configuration**: All system state defined in Nix expressions
2. **Reproducibility**: flake.lock ensures consistent builds across time/machines
3. **Modularity**: Separate concerns between system and user configuration
4. **Multi-machine Support**: Single source for multiple machine configurations

### Adding New Configurations
- System settings: Edit `modules/darwin/default.nix`
- User packages/tools: Edit `modules/home/default.nix`
- New machines: Add configuration in `flake.nix` under `darwinConfigurations`

### Environment Variables
The configuration sets critical build flags for Python package compilation:
- LDFLAGS, CPPFLAGS for library paths
- PKG_CONFIG_PATH for package discovery
These are essential for packages requiring C extensions.

## Development Notes

### Package Management
- All packages managed through Nix (not Homebrew)
- Python packages: Use UV or Poetry (both installed)
- Node packages: Use PNPM (installed)
- System packages: Add to `home.packages` in `modules/home/default.nix`

### Shell Configuration
- Shell: Zsh with custom aliases
- Prompt: Starship
- Key alias: `nixswitch` for applying configuration changes

### Testing Configuration Changes
Always test configuration changes before applying:
1. Make changes to relevant .nix files
2. Run `nix flake check` to validate syntax
3. Run `darwin-rebuild build --flake flake.nix` to test build
4. Run `nixswitch` to apply if successful