{ pkgs ? import
    (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/cf28ee258fd5f9a52de6b9865cdb93a1f96d09b7.tar.gz") # nixos-23.11 on 2023-12-15
    { }
}:

with pkgs;
let
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
  kicad-7_0_8 = custom_kicad {
    kicadVersion = "7.0.8";
    rev = "063d9c830514d46de163bd0ae2bb1df66309f11e";
    sha256 = "sha256-xOueBxJwS+0LwcYTBJCsbDKWpiTUSv/O8luNCsdAUr0=";
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
    kicad # 7.0.7
    # kicad-7_0_8
    zip
    poppler_utils
    (python3.withPackages(ps: with ps; [
      sexpdata
    ]))
    duplicateproject
  ];
}
