{
  description = "Elixir development environment and package for j1605_mqtt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        beamPackages = pkgs.beam.packagesWith pkgs.erlang_27;
        elixir = beamPackages.elixir_1_18;

        # Import dependencies from deps.nix
        mixDeps = import ./deps.nix {
          inherit (pkgs) lib;
          inherit beamPackages;
        };

        j1605_mqtt = beamPackages.mixRelease {
          pname = "j1605_mqtt";
          src = ./.;
          version = "0.1.0";
          inherit elixir;

          mixNixDeps = mixDeps;
          removeCookie = false;

          preConfigure = ''
            mkdir -p config
            for env in dev test prod; do
              if [ ! -f "config/''${env}.exs" ]; then
                echo "import Config" > "config/''${env}.exs"
              fi
            done
          '';
        };
      in
      {
        packages.default = j1605_mqtt;

        nixosModules.default =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            cfg = config.services.j1605-mqtt;
          in
          {
            options.services.j1605-mqtt = {
              enable = lib.mkEnableOption "j1605-mqtt";
              host = lib.mkOption {
                type = lib.types.str;
                default = "localhost";
                description = "MQTT broker host";
              };
            };

            config = lib.mkIf cfg.enable {
              systemd.services.j1605-mqtt = {
                description = "j1605_mqtt MQTT client";
                wantedBy = [ "multi-user.target" ];
                environment = {
                  J1605_MQTT_HOST = cfg.host;
                };
                serviceConfig = {
                  Restart = "always";
                  RestartSec = "5";
                  ExecStart = "${j1605_mqtt}/bin/j1605_mqtt start";
                };
              };
            };
          };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            helix
            elixir-ls
          ];
          buildInputs = [
            elixir
            pkgs.erlang_27
          ]
          ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.inotify-tools;

          shellHook = ''
            # Set up local hex and rebar paths
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH

            # Ensure local dependencies are used
            mkdir -p $MIX_HOME $HEX_HOME
          '';
        };
      }
    );
}
