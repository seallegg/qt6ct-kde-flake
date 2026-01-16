{
  description = "Flake which adds patched qt6ct package with better support for KDE themes.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    patchset.url = "https://aur.archlinux.org/cgit/aur.git/plain/qt6ct-shenanigans.patch?h=qt6ct-kde";
    patchset.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    patchset,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    mkPackage = qt6ctBase: kdePackages:
      qt6ctBase.overrideAttrs (oldAttrs: {
        pname = "qt6ct-kde";

        patches =
          (oldAttrs.patches or [])
          ++ [
            patchset
          ];

        buildInputs =
          oldAttrs.buildInputs
          ++ (with kdePackages; [
            kconfig
            kcolorscheme
            kiconthemes
          ]);

        nativeBuildInputs =
          oldAttrs.nativeBuildInputs
          ++ (with kdePackages; [
            extra-cmake-modules
          ]);

        cmakeFlags =
          oldAttrs.cmakeFlags
          ++ [
            "-DKF6Config_DIR=${kdePackages.kconfig}/lib/cmake/KF6Config"
            "-DKF6ColorScheme_DIR=${kdePackages.kcolorscheme}/lib/cmake/KF6ColorScheme"
            "-DKF6IconThemes_DIR=${kdePackages.kiconthemes}/lib/cmake/KF6IconThemes"
          ];
      });
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      qt6ct-kde = mkPackage pkgs.qt6Packages.qt6ct pkgs.kdePackages;
      default = self.packages.${system}.qt6ct-kde;
    });

    overlays.default = final: prev: {
      qt6Packages =
        prev.qt6Packages
        // {
          qt6ct = mkPackage prev.qt6Packages.qt6ct final.kdePackages;
        };
    };
  };
}
