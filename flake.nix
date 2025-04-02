{
  description = "The flake that Compiles the latex documents.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { 
    self, 
    nixpkgs, 
    flake-utils, 
    ... 
  } @ inputs: flake-utils.lib.eachDefaultSystem ( system:
    let

      pkgs = import nixpkgs { inherit system; };
      
    in rec {

      #| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Flake Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |#

      checks.default = self.packages.${system}.default;

      #| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Develop ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |#

      devShells.default = pkgs.mkShell {
        
        buildInputs = with pkgs; [ 
          texliveFull  # Compile the latex manually.
          act          # Run GitHub Actions locally.
        ];

        shellHook = (''
          # if the terminal supports color. display the message with color, else just use black and white.
          if [[ -n "$(tput colors)" && "$(tput colors)" -gt 2 ]]; then
            export PS1="(\033[1;35mDev-Shell\033[0;37m) $PS1"
          else 
            export PS1="(Dev-Shell) $PS1"
          fi''
        );
      };

      #| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |#

      packages = {

        default = self.packages.${system}.all-documents;

        all-documents = pkgs.stdenv.mkDerivation rec {
          name = "all-documents";
          src = ./.;
          buildInputs = with self.packages.${system}; [ assignment-1 assignment-2 final-report peer-review ];
          
          installPhase = ''
            runHook preInstall

            mkdir --parents $out/doc
            cp ${self.packages.${system}.assignment-1}/share/doc/*.pdf $out/doc
            cp ${self.packages.${system}.assignment-2}/share/doc/*.pdf $out/doc
            cp ${self.packages.${system}.final-report}/share/doc/*.pdf $out/doc
            cp ${self.packages.${system}.peer-review}/share/doc/*.pdf $out/doc
            
            runHook postInstall
          '';
        };

        assignment-1 = pkgs.stdenv.mkDerivation rec {
          name = "assignment-1";
          src = ./assignment-1/src;
          buildInputs = with pkgs; [ texliveFull ];

          buildPhase = ''
            runHook preBuild 

            pdflatex --halt-on-error --file-line-error --interaction=nonstopmode --output-directory=. ./main.tex
            
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir --parents $out/doc
            mv ./main.pdf $out/doc/assignment-1.pdf
            
            runHook postInstall
          '';
        };

        assignment-2 = pkgs.stdenv.mkDerivation rec {
          name = "assignment-2";
          src = ./assignment-2/src;
          buildInputs = with pkgs; [ texliveFull ];

          buildPhase = ''
            runHook preBuild 

            pdflatex --halt-on-error --file-line-error --interaction=nonstopmode --output-directory=. ./main.tex
            
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir --parents $out/doc
            mv ./main.pdf $out/doc/assignment-2.pdf
            
            runHook postInstall
          '';
        };

        final-report = pkgs.stdenv.mkDerivation rec {
          name = "final-report";
          src = ./final-report;
          buildInputs = with pkgs; [ texliveFull ];

          buildPhase = ''
            runHook preBuild 

            pdflatex --interaction=nonstopmode --output-directory=. ./src/main.tex
            
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir --parents $out/doc
            mv ./main.pdf $out/doc/final-report.pdf
            
            runHook postInstall
          '';
        };

        peer-review = pkgs.stdenv.mkDerivation rec {
          name = "peer-review";
          src = ./peer-review/src;
          buildInputs = with pkgs; [ texliveFull ];

          buildPhase = ''
            runHook preBuild 

            pdflatex --halt-on-error --file-line-error --interaction=nonstopmode --output-directory=. ./main.tex
            
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir --parents $out/doc
            mv ./main.pdf $out/doc/peer-review.pdf
            
            runHook postInstall
          '';
        };
      };

      #| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |#
    }
  );
}
