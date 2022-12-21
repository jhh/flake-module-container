{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      packages.${system}.default = pkgs.poetry2nix.mkPoetryApplication {
        projectDir = self;
      };

      nixosModules.hello = { config, lib, pkgs, ... }:
        let
          cfg = config.j3ff.hello;
        in
        {
          options.j3ff.hello.enable = lib.mkEnableOption "Enable the Hello service";

          config = lib.mkIf cfg.enable {
            systemd.services.hello = {
              description = "Hello service";
              wantedBy = [ "multi-user.target" ];

              serviceConfig =
                let
                  pkg = self.packages.${system}.default.dependencyEnv;
                in
                {
                  ExecStart = "${pkg}/bin/gunicorn --bind=0.0.0.0 hello:app";
                };
            };
          };
        };

      nixosConfigurations.container = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.hello
          ({ ... }: {
            boot.isContainer = true;
            networking.useDHCP = false;
            networking.firewall.enable = false;
            j3ff.hello.enable = true;
          })
        ];
      };

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          (poetry2nix.mkPoetryEnv { projectDir = self; })
          poetry
        ];
        FLASK_APP = "hello";
      };

    };
}
