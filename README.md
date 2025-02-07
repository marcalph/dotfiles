# dotfiles

## Motivation

This repo is home the nixified setup that builts my systems.  
It uses nix-darwin with home-manager to install the needed productivity tools I need.

### Requirements 

You will need to install `nix` and `brew` to get started. 
As of Q1 2024, the recommend way of going about it is :  
```shell
# the determinate systems installer provides a cleaner uninstall recipe and survives macOS updates
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
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

### disclaimer

some tools might require a build/dev env to build (e.g. to build `pyenv install 3.11.9` might require `xz, zlib, ncurse`) - until I flakeify all my dev envsm the hack I'm using is to build within a `nix develop nixpkgs#python3`  
