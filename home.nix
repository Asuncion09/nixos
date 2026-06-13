{ inputs, pkgs, config, ... }: {

  imports = [
      inputs.spicetify-nix.homeManagerModules.default
      inputs.nix4nvchad.homeManagerModules.default
  ];


  home.username = "daniel";
  home.homeDirectory = "/home/daniel";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # System
    tree lsd btop htop fastfetch nitch xdg-user-dirs

    # hyprland
    waybar rofi hyprlock hypridle hyprpaper hyprpolkitagent hyprshot swaynotificationcenter swayosd
    brightnessctl pavucontrol bluetui nwg-look quickshell

    # Apps
    nautilus ghostty kitty papers loupe cine google-chrome 
    vscode protonup-qt r2modman zapzap antigravity
    code-cursor bluetui dbeaver-bin jetbrains-toolbox
    postman mongodb-compass jetbrains.idea-oss zed-editor
    obs-studio obs-studio-plugins.obs-pipewire-audio-capture
    qt6.qtdeclarative

     # flakes
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.nmrs.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Themes
    morewaita-icon-theme adw-gtk3 

     # Desktop items con nvidia-offload
    (pkgs.makeDesktopItem { name = "steam"; desktopName = "Steam"; 
      exec = "env XCURSOR_THEME=Breeze_Light XCURSOR_SIZE=24 nvidia-offload steam %U"; 
      icon = "steam"; categories = [ "Game" ];
    })
    (pkgs.makeDesktopItem { name = "com.heroicgameslauncher.hgl"; desktopName = "Heroic Games Launcher"; 
      exec = "nvidia-offload heroic %U"; icon = "heroic"; categories = [ "Game" ];
    })
  ];

  # Theming
  gtk = {
    theme = {
      name = "adw-gtk3-dark";
    };
    cursorTheme = {
      name = "Breeze_Light";
    };
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = true;
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark"; # "default" para modo claro
      gtk-theme = "adw-gtk3-dark";  # Controla las "Legacy Applications"
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Breeze_Light";
    package = pkgs.kdePackages.breeze;
    size = 24;
  };
  home.sessionVariables = {
    XCOMPOSECACHE = "${config.xdg.cacheHome}/compose";
  };

  # Programs
  programs.git = {
    enable = true;
    settings = {
      user.name = "Daniel De La Asuncion";
      user.email = "danieldlasuncion@gmail.com";
    };
  };

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    enable = true;
    theme = spicePkgs.themes.text;
  };
 
  programs.nvchad = {
    enable = true;
    backup = false;

    extraPackages = with pkgs; [
      ripgrep fd
      lua-language-server stylua
      nil prettierd
      vscode-css-languageserver
    ];

    gcc = pkgs.gcc16;

    chadrcConfig = ''
      local M = {}
      M.base46 = {
        theme = "oxocarbon",
        transparency = true,
        hl_override = {
          Comment = { italic = true },
          ["@comment"] = { italic = true },
        },
      }
      M.nvdash = { load_on_startup = true }
      M.ui = {
        tabufline = { lazyload = false }
      }
      M.plugins = "custom.plugins"
      return M
    '';

    extraConfig = ''
      vim.opt.shiftwidth = 2
    '';
  };

  home.file.".config/nvim/lua/custom/lsp.lua".text = ''
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    vim.lsp.config("qmlls", {
      cmd = { "qmlls", "-E" },
      filetypes = { "qml", "qmljs" },
    })
    vim.lsp.enable("qmlls")
  '';

  home.file.".config/nvim/lua/custom/plugins.lua".text = ''
    return {
      {
        "neovim/nvim-lspconfig",
        config = function()
          require("custom.lsp")
        end,
      },
    }
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http"           = "zen.desktop";
      "x-scheme-handler/https"          = "zen.desktop";
      "x-scheme-handler/chrome"         = "zen.desktop";
      "text/html"                        = "zen.desktop";
      "application/x-extension-htm"     = "zen.desktop";
      "application/x-extension-html"    = "zen.desktop";
      "application/x-extension-shtml"   = "zen.desktop";
      "application/xhtml+xml"           = "zen.desktop";
      "application/x-extension-xhtml"   = "zen.desktop";
      "application/x-extension-xht"     = "zen.desktop";
      "video/mp4"       = "io.github.diegopvlk.Cine.desktop";
      "video/mkv"       = "io.github.diegopvlk.Cine.desktop";
      "video/x-matroska" = "io.github.diegopvlk.Cine.desktop";
      "video/webm"      = "io.github.diegopvlk.Cine.desktop";
      "video/avi"       = "io.github.diegopvlk.Cine.desktop";
      "image/jpeg"               = "org.gnome.Loupe.desktop";
      "image/png"                = "org.gnome.Loupe.desktop";
      "image/gif"                = "org.gnome.Loupe.desktop";
      "image/webp"               = "org.gnome.Loupe.desktop";
      "image/svg+xml"            = "org.gnome.Loupe.desktop";
      "application/pdf"          = "org.gnome.Papers.desktop";
      "inode/directory"          = "org.gnome.Nautilus.desktop";
    };
  };

  programs.home-manager.enable = true;
}
