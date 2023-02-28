{ pkgs ? import
    (builtins.fetchGit {
      name = "nixos-22.05-2022_08_27";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-22.05";
      rev = "b47d4447dc2ba34f793436e6631fbdd56b12934a";
    })
    { }
}:

let
  unstable = (import
    (builtins.fetchGit {
      name = "nixos-unstable-2023_02_25";
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-unstable";
      rev = "988cc958c57ce4350ec248d2d53087777f9e1949";
    })
    { });
in
with pkgs;
let
  # from https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/electronics/kicad/default.nix#L50
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

  kicad-6_0_11 = custom_kicad {
    kicadVersion = "6.0.11";
    rev = "cdf04d55821ea53f821678025b0fd85e9552fbac";
    sha256 = "sha256-eE4FXCd7LhaSGszFW6dBAAxzb33R3wrYDZsHkfSrH64=";
  };

  kicad-7_0_0 = unstable.kicad;
in
mkShell {
  buildInputs = [
    kicad-7_0_0
    # kicad-6_0_11
    # kicad # 6.0.5
    zip
    poppler_utils # for pdfunite
  ];
}
