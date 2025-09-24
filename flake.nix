{
  description = "Slacky built with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    packages.aarch64-linux.slacky = pkgs.buildNpmPackage (finalAttrs: {
      pname = "slacky";
      version = "0.0.5";

      src = ./.;

      npmDepsHash = "sha256-Vqpg+j2mIv5XKzX//ptt9gT+SWPXpVSKSCM+E5cmuCQ=";

      makeCacheWritable = true;
      npmFlags = [ "--legacy-peer-deps" ];

      npmPackFlags = [ "--ignore-scripts" ];

      nativeBuildInputs = with pkgs; [
        electron
        copyDesktopItems
      ];

      env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

      postInstall = ''
        mkdir -p $out/share/icons
        ln -s $out/lib/node_modules/slacky/build/icons/icon.png $out/share/icons/slacky.png
        makeWrapper ${pkgs.electron}/bin/electron $out/bin/slacky \
          --add-flags $out/lib/node_modules/slacky/
      '';

      desktopItems = pkgs.lib.singleton (pkgs.makeDesktopItem {
        name = "slacky";
        exec = "slacky %u";
        icon = "slacky";
        desktopName = "Slacky";
        comment = "An unofficial Slack desktop client for arm64 Linux";
        startupWMClass = "com.andersonlaverde.slacky";
        type = "Application";
        categories = [
          "Network"
          "InstantMessaging"
        ];
        mimeTypes = [
          "x-scheme-handler/slack"
        ];
      });

      passthru.updateScript = pkgs.nix-update-script { };

      meta = {
        description = "Unofficial Slack desktop client for arm64 Linux";
        homepage = "https://github.com/andirsun/Slacky";
        changelog = "https://github.com/andirsun/Slacky/releases/tag/v${finalAttrs.version}";
        license = pkgs.lib.licenses.mit;
        maintainers = with pkgs.lib.maintainers; [ awwpotato ];
        platforms = [ "aarch64-linux" ];
        mainProgram = "slacky";
      };
    });

    packages.aarch64-linux.default = self.packages.aarch64-linux.slacky;

  };
}
