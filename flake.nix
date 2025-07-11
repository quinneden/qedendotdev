{
  description = "Quinn Edenfield's portfolio website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    moonwalk-hugo = {
      url = "github:arkhamcookie/moonwalk-hugo";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      forEachSystem =
        f:
        lib.genAttrs [ "aarch64-darwin" "aarch64-linux" ] (
          system: f { pkgs = import nixpkgs { inherit system; }; }
        );
    in
    {
      packages = forEachSystem (
        { pkgs }:
        rec {
          default = qedenDotDev;

          qedenDotDev = pkgs.stdenv.mkDerivation {
            name = "qeden.dev";

            src = builtins.filterSource (
              path: type: !(type == "directory" && (baseNameOf path == "themes" || baseNameOf path == "public"))
            ) ./.;

            nativeBuildInputs = [ pkgs.hugo ];

            buildPhase = ''
              mkdir -p themes
              ln -s ${inputs.moonwalk-hugo} themes/moonwalk-hugo
              hugo --gc --minify build
            '';

            installPhase = ''
              install -Dt $out public
            '';
          };
        }
      );

      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            name = "qeden.dev";
            buildInputs = [ pkgs.hugo ];
          };
        }
      );
    };
}
