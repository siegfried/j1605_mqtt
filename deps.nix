{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    gen_state_machine = buildMix rec {
      name = "gen_state_machine";
      version = "3.0.0";

      src = fetchHex {
        pkg = "gen_state_machine";
        version = "${version}";
        sha256 = "0a59652574bebceb7309f6b749d2a41b45fdeda8dbb4da0791e355dd19f0ed15";
      };

      beamDeps = [];
    };

    j1605 = buildMix rec {
      name = "j1605";
      version = "0.3.0";

      src = fetchHex {
        pkg = "j1605";
        version = "${version}";
        sha256 = "a8cf0a7f4e13d5355bcb2ef626c33a13e042befc7561d0b66ee533bc3e3f85ff";
      };

      beamDeps = [];
    };

    mqtt = buildMix rec {
      name = "mqtt";
      version = "0.3.3";

      src = fetchHex {
        pkg = "mqtt";
        version = "${version}";
        sha256 = "0c794a71a59e45f3e29580db42fd89edba9c75f8f090c4cdcd926ae2923f2997";
      };

      beamDeps = [];
    };

    tortoise = buildMix rec {
      name = "tortoise";
      version = "0.10.0";

      src = fetchHex {
        pkg = "tortoise";
        version = "${version}";
        sha256 = "926d97b03cd0d2f6e0e1ebf06c1efa50101de96d0317dea5604c1c9e43e66735";
      };

      beamDeps = [ gen_state_machine ];
    };
  };
in self

