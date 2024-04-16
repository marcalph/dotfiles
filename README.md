# dotfiles

## Motivation

This repo is home the nixified setup that builts my system (currently  a M2 macbook air).  
It uses nix-darwin with home-manager to install the needed productivity tools I need.

### Requirements 

You will need to install `nix` and `brew` to get started. 
As of Q1 2024, the recommend way of going about it is :  
```shell
# the determinate systems installer provides a cleaner uninstall recipe and survives macOS updates
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Usage
Once requirements are installed the first time the system is setup is done walling:
```shell
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake flake.nix     
```
Next derivations are setup with an alias:  
```shell
nixswitch
```
