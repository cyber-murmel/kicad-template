let
  #nixpkgs_rev = "bfb7a882678e518398ce9a31a881538679f6f092"; # "nixos-unstable" on 2024-05-28
  nixpkgs_rev = "67a8b308bae9c26be660ccceff3e53a65e01afe1"; # "nixos-24.05" on 2024-05-28
  nixpkgs_src = (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgs_rev}.tar.gz");
in

{ pkgs ? import nixpkgs_src { }
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "template";
  version = "";

  src = ./.;

  patchPhase = ''
    patchShebangs --build scripts/*.py
  '';

  buildPhase = ''
    runHook preBuildHook

    export HOME=$(pwd)

    make clean
    make

    runHook postBuildHook
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out

    cp exports/plots/* $out
    cp production/gbr/${pname}.zip $out/${pname}-gbr.zip
    cp production/bom/${pname}.csv $out/${pname}-bom.csv
    cp production/pos/${pname}.csv $out/${pname}-pos.csv

    runHook postInstall
  '';

  buildInputs = [
    kicad-small
    zip
    poppler_utils
    (python3.withPackages (ps: with ps; [
      sexpdata
    ]))
  ];
}


