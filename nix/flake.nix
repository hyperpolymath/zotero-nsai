{
  description = "NSAI - Neurosymbolic Research Validator for Zotero";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # ReScript toolchain
            nodejs_20  # For ReScript compiler (temporary)

            # Deno runtime
            deno

            # Documentation
            pandoc
            asciidoctor
            zola

            # Quality tools
            hunspell
            hunspellDicts.en_US

            # Build tools
            just
            cue

            # Spell checking
            aspell
            aspellDicts.en
          ];

          shellHook = ''
            echo "NSAI Development Environment"
            echo "  ReScript: $(rescript -v 2>/dev/null || echo 'install with: npm i -g rescript')"
            echo "  Deno: $(deno --version | head -1)"
            echo "  Pandoc: $(pandoc --version | head -1)"
            echo ""
            echo "Commands:"
            echo "  just build    - Build project"
            echo "  just test     - Run tests"
            echo "  just package  - Create XPI"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nsai";
          version = "0.1.0";

          src = ../.;

          nativeBuildInputs = with pkgs; [
            deno
            just
          ];

          buildPhase = ''
            just build
          '';

          installPhase = ''
            mkdir -p $out/lib/zotero/extensions
            cp -r . $out/lib/zotero/extensions/nsai@hyperpolymath
          '';

          meta = with pkgs.lib; {
            description = "Neurosymbolic Research Validator for Zotero";
            homepage = "https://github.com/Hyperpolymath/zotero-nsai";
            license = licenses.agpl3Plus;
            platforms = platforms.all;
          };
        };
      }
    );
}
