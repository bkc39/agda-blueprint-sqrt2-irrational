{
  description =
    "√2 is irrational — an agdablueprint blueprint over Kono's automaton-in-agda proof";

  inputs = {
    # agdablueprint is pinned to the Phase-4 branch until it merges to master.
    agdablueprint.url = "github:bkc39/agdablueprint/phase-4-cli-and-e2e";
    # Follow agdablueprint's nixpkgs so we get the exact agda-stdlib (2.3) that
    # automaton-in-agda's `.agda-lib` `depend:`s on.
    nixpkgs.follows = "agdablueprint/nixpkgs";
    # Shinji Kono's proof (MIT). Consumed as a plain source tree.
    automaton = {
      url = "github:shinji-kono/automaton-in-agda";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, agdablueprint, automaton }:
    let
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems
          (system: f { inherit system; pkgs = import nixpkgs { inherit system; }; });

      # automaton-in-agda as an Agda library. We compile only root2 and its
      # dependency cone (not the whole 41-file course repo): this both keeps the
      # build fast and installs the `.agdai` interfaces, so the consumer Agda
      # reuses them instead of trying to rewrite them into the read-only store.
      automatonLib = pkgs: pkgs.agdaPackages.mkDerivation {
        pname = "automaton-in-agda";
        version = "unstable";
        src = automaton;
        buildInputs = [ pkgs.agdaPackages.standard-library ];
        buildPhase = ''
          runHook preBuild
          agda -i src src/root2.agda
          runHook postBuild
        '';
        meta.description = "Shinji Kono's automaton-in-agda (root2 cone)";
      };

      # Agda with the standard library and the automaton-in-agda proof on its
      # library path, so `depend: standard-library automaton-in-agda` resolves.
      agdaWith = pkgs:
        pkgs.agda.withPackages (p: [ p.standard-library (automatonLib pkgs) ]);
    in
    {
      devShells = forAllSystems ({ system, pkgs }: {
        default = pkgs.mkShell {
          packages = [
            (agdaWith pkgs)
            pkgs.graphviz
            # `agdablueprint` + `plastex` (plugin importable); supplies the CLI,
            # we supply agda above.
            agdablueprint.packages.${system}.blueprintEnv
            # plasTeX uses `kpsewhich` to resolve \input{macros/…}; texliveSmall
            # provides it (we don't build a PDF, so the full scheme is overkill).
            pkgs.texliveSmall
          ];
        };
      });
    };
}
