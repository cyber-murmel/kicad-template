let
  nixpkgs_rev = "10dcd43016cd9d1c5a9e691343a8ecd22f641e4d";
  nixpkgs_src = (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgs_rev}.tar.gz");
in

{
  pkgs ? import nixpkgs_src { }
}:

with pkgs;
let
  kicad-8_0_1 = kicad-unstable;

  custom_kicad = { kicadVersion, rev, sha256 }: kicad-unstable.override {
    srcs = {
      inherit kicadVersion;
      kicad = fetchFromGitLab {
        group = "kicad";
        owner = "code";
        repo = "kicad";
        inherit rev sha256;
      };
    };
  };

  kicad-master = custom_kicad {
    kicadVersion = "2024-04-02";
    rev = "77eaa75db1f310ba31913102655ff3169b687c6e";
    sha256 = "sha256-6o85J9IkIslUXm8/fROl399BqXqTyZdvKgUNQzZIxUI=";
  };

  duplicateproject = writeScriptBin "duplicateproject" ''
    set -euxo pipefail

    if [[ $# -ne 2 ]]; then
        echo "Usage: duplicateproject OLD_NAME NEW_NAME" >&2
        exit 2
    fi

    OLD_NAME=$1
    NEW_NAME=$2

    cp --recursive "$OLD_NAME" "$NEW_NAME"
    rename "$OLD_NAME" "$NEW_NAME" "$NEW_NAME"/*
    sed -i -e "s/$OLD_NAME/$NEW_NAME/g" "$NEW_NAME"/"$NEW_NAME".* Makefile
  '';
in
mkShell {
  buildInputs = [
    # kicad-8_0_1
    kicad-master
    zip
    poppler_utils
    (python3.withPackages (ps: with ps; [
      sexpdata
    ]))
    duplicateproject
  ];
}
