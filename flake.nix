{
  description = "Utilities to use arkenfox's user.js for Firefox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    master = {
      flake = false;
      url = "github:arkenfox/user.js";
    };
    "93.0" = {
      flake = false;
      url = "github:arkenfox/user.js/93.0";
    };
    "94.0" = {
      flake = false;
      url = "github:arkenfox/user.js/94.0";
    };
    "95.0" = {
      flake = false;
      url = "github:arkenfox/user.js/95.0";
    };
    "96.0" = {
      flake = false;
      url = "github:arkenfox/user.js/96.0";
    };
    "97.0" = {
      flake = false;
      url = "github:arkenfox/user.js/97.0";
    };
    "98.0" = {
      flake = false;
      url = "github:arkenfox/user.js/98.0";
    };
    "99.0" = {
      flake = false;
      url = "github:arkenfox/user.js/99.0";
    };
    "100.0" = {
      flake = false;
      url = "github:arkenfox/user.js/100.0";
    };
    "101.0" = {
      flake = false;
      url = "github:arkenfox/user.js/101.0";
    };
    "102.0" = {
      flake = false;
      url = "github:arkenfox/user.js/102.0";
    };
    "103.0" = {
      flake = false;
      url = "github:arkenfox/user.js/103.0";
    };
    "104.0" = {
      flake = false;
      url = "github:arkenfox/user.js/104.0";
    };
    "105.0" = {
      flake = false;
      url = "github:arkenfox/user.js/105.0";
    };
    "106.0" = {
      flake = false;
      url = "github:arkenfox/user.js/106.0";
    };
    "107.0" = {
      flake = false;
      url = "github:arkenfox/user.js/107.0";
    };
    "108.0" = {
      flake = false;
      url = "github:arkenfox/user.js/108.0";
    };
    "109.0" = {
      flake = false;
      url = "github:arkenfox/user.js/109.0";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
    inherit (pkgs) lib callPackage;
    inherit (lib) mapAttrs mapAttrs' nameValuePair;
    js = builtins.removeAttrs inputs ["self" "nixpkgs"];

    extractor = callPackage ./extractor {};
    extract = import ./extractor/extract.nix {inherit pkgs extractor;};
    versions = builtins.attrNames js;

    ppVer = builtins.replaceStrings ["."] ["_"];
    docs = pkgs:
      (mapAttrs'
        (version: extracted:
          nameValuePair "arkenfox-v${ppVer version}-doc-static"
          (pkgs.callPackage ./doc {inherit extracted version;}))
        self.lib.arkenfox.extracted)
      // (mapAttrs'
        (version: extracted:
          nameValuePair "arkenfox-v${ppVer version}-doc"
          (pkgs.callPackage ./doc {
            inherit extracted version;
            css = "/style.css";
          }))
        self.lib.arkenfox.extracted);

    type = extracted:
      import ./type.nix {
        inherit extracted pkgs;
        lib = pkgs.lib;
      };
  in {
    packages.x86_64-linux =
      {
        arkenfox-extractor = extractor;
        arkenfox-doc-css = pkgs.writeText "style.css" (builtins.readFile ./doc/style.css);
        default = extractor;
      }
      // (docs pkgs);

    overlays = {
      arkenfox = final: prev: ({
          arkenfox-extractor = prev.callPackage ./extractor {};
          arkenfox-doc-css = pkgs.writeText "style.css" (builtins.readFile ./doc/style.css);
        }
        // (docs prev));
    };
    overlay = self.overlays.arkenfox;

    lib.arkenfox = {
      supportedVersions = versions;
      extracted = mapAttrs (_: v: import "${extract v}") js;
      types = mapAttrs (_: type) self.lib.arkenfox.extracted;
    };

    hmModules = {
      arkenfox = import ./hm.nix self.lib.arkenfox.supportedVersions self.lib.arkenfox.extracted;
      default = self.hmModules.arkenfox;
    };
  };
}
