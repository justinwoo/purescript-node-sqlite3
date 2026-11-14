{ pkgs ? import <nixpkgs> { } }:
let
  easy-ps = import
    (pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "0ad5775c1e80cdd952527db2da969982e39ff592";
      sha256 = "0x53ads5v8zqsk4r1mfpzf5913byifdpv5shnvxpgw634ifyj1kg";
    })
    {
      inherit pkgs;
    };
in
pkgs.mkShell {
  buildInputs = [
    (easy-ps.purs-0_15_0.overrideAttrs (old: {
      version = "v0.15.4";
      installPhase = builtins.replaceStrings [ "patchelf --interpreter" ] [ "patchelf --no-sort --interpreter" ] old.installPhase;
      src = pkgs.fetchurl (
        if pkgs.stdenv.isDarwin then {
          url = "https://github.com/purescript/purescript/releases/download/v0.15.4/macos.tar.gz";
          sha256 = "cd08d63f62c7fcb553611352f07fd003bf2baf3239aaad1845e45e9498617a66";
        } else {
          url = "https://github.com/purescript/purescript/releases/download/v0.15.4/linux64.tar.gz";
          sha256 = "3e2a59dbac49564b7ceedb5b102eecf2b0b24765dbfcc1eed5ac4ea396c6e68e";
        }
      );
    }))
  ];
}
