# qt6ct-kde-flake
Flake which adds patched qt6ct package using [patchset from the AUR](https://aur.archlinux.org/packages/qt6ct-kde) with better support for KDE themes.

## Why?
Specifically for my usecase, QT themes which use KColorScheme are not fully supported by upstream qt6ct, which leads to incorrect coloring of text in Dolphin, making it unreadable and borderline unusable. This patchset fixes that issue.

## Using the flake
Simply add it as an input
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/unstable";
    
    qt6ct-kde.url = "github:username/qt6ct-kde-flake";
    qt6ct-kde.follows = nixpkgs;
  }; 
```
Then use the provided overlay which replaces the original package.
```nix
{pkgs, inputs, ...}:
{
  nixpkgs.overlays = [inputs.qt6ct-kde.overlays.default];
  environment.systemPackages = with pkgs;[
    qt6Packages.qt6ct
  ];
}
```
Or just call the provided package directly.
