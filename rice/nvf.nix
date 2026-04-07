#this file is actually using nixvim 
{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nixvim.homeModules.nixvim];

  programs.nixvim = {
    enable = true;

    # Make nixvim provide the main nvim/vim/vi commands.
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals.mapleader = " ";

    opts = {
      # Show absolute line numbers in the gutter.
      number = true;
      # Show relative line numbers for faster motion.
      relativenumber = true;
      # Preview matches while typing a search.
      incsearch = true;
      # Keep long lines on one line.
      wrap = false;
      # Match your existing tab preferences.
      tabstop = 4;
      shiftwidth = 2;
    };

    clipboard.register = "unnamedplus";

    colorschemes.retrobox.enable = true;

    plugins = {
      # Syntax-aware highlighting and indentation.
      treesitter.enable = true;

      # File and content search.
      telescope.enable = true;

      # Show pending keybinds in a popup as you press prefixes.
      which-key.enable = true;

      # Statusline at the bottom.
      lualine.enable = true;

      # File explorer sidebar.
      neo-tree.enable = true;

      # Terminal inside Neovim.
      toggleterm.enable = true;

      # Buffer tabs across the top.
      bufferline.enable = true;

      # Explicit because implicit enablement is deprecated.
      web-devicons.enable = true;

      # Comment motions like gcc/gc.
      comment.enable = true;

      # Auto-close brackets and quotes.
      nvim-autopairs.enable = true;

      # Git signs in the gutter.
      gitsigns.enable = true;

      # Better notifications/popups.
      notify.enable = true;

      # Highlight actual color codes inline, but do not paint words like "Red".
      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      # Markdown preview command.
      markdown-preview.enable = true;

      # Useful mark/jump workflow.
      harpoon.enable = true;

      # Nix file support and tooling.
      nix.enable = true;

      # Completion UI with documentation and signature help.
      blink-cmp = {
        enable = true;
        settings = {
          signature.enabled = true;
          keymap = {
            # Use Tab / Shift-Tab to move through completion items.
            "<Tab>" = ["select_next" "fallback"];
            "<S-Tab>" = ["select_prev" "fallback"];
            # Use Enter to accept the currently selected completion item.
            "<CR>" = ["accept" "fallback"];
            # Keep arrow keys working inside the completion menu.
            "<Up>" = ["select_prev" "fallback"];
            "<Down>" = ["select_next" "fallback"];
          };
          completion.documentation.auto_show = true;
          completion.documentation.auto_show_delay_ms = 50;
          list.selection = {
            preselect = true;
            auto_insert = true;
          };
        };
      };

      # Built-in LSP client configuration.
      lsp = {
        enable = true;
        inlayHints = true;

        # Keep standard LSP motions so hover/definition work like an IDE.
        keymaps = {
          silent = true;
          diagnostic = {
            "<leader>dj" = "goto_next";
            "<leader>dk" = "goto_prev";
          };
          lspBuf = {
            "K" = "hover";
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
          };
        };

        # Explicitly enable language servers for the languages you use.
        servers = {
          nil_ls.enable = true;
          basedpyright.enable = true;
          clangd.enable = true;
          gopls.enable = true;
          lua_ls.enable = true;
          marksman.enable = true;
          r_language_server = {
            enable = true;
            package = null;
          };
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          superhtml.enable = true;
          tinymist.enable = true;
          ts_ls.enable = true;
          zls.enable = true;
        };
      };
    };

    keymaps = [
      {
        key = "<leader>a";
        mode = "n";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Add file to Harpoon";
      }
      {
        key = "<C-e>";
        mode = "n";
        action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
        options.desc = "Toggle Harpoon menu";
      }
      {
        key = "<leader>1";
        mode = "n";
        action.__raw = "function() require('harpoon'):list():select(1) end";
        options.desc = "Go to Harpoon file 1";
      }
      {
        key = "<leader>2";
        mode = "n";
        action.__raw = "function() require('harpoon'):list():select(2) end";
        options.desc = "Go to Harpoon file 2";
      }
      {
        key = "<leader>3";
        mode = "n";
        action.__raw = "function() require('harpoon'):list():select(3) end";
        options.desc = "Go to Harpoon file 3";
      }
      {
        key = "<leader>4";
        mode = "n";
        action.__raw = "function() require('harpoon'):list():select(4) end";
        options.desc = "Go to Harpoon file 4";
      }
      {
        key = "jk";
        mode = "i";
        action = "<Esc>";
        options.desc = "Exit insert mode quickly";
      }
      {
        key = "<leader>?";
        mode = "n";
        action = "<cmd>Telescope keymaps<CR>";
        options.desc = "Open keymap cheatsheet";
      }
      {
        key = "<leader>nh";
        mode = "n";
        action = ":nohl<CR>";
        options.desc = "Clear search highlights";
      }
      {
        key = "<leader>ff";
        mode = "n";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find files by name";
      }
      {
        key = "<leader>lg";
        mode = "n";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Search text in project";
      }
      {
        key = "<leader>fe";
        mode = "n";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        key = "<leader>e";
        mode = "n";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        key = "<C-h>";
        mode = "i";
        action = "<Left>";
        options.desc = "Move left in insert mode";
      }
      {
        key = "<C-j>";
        mode = "i";
        action = "<Down>";
        options.desc = "Move down in insert mode";
      }
      {
        key = "<C-k>";
        mode = "i";
        action = "<Up>";
        options.desc = "Move up in insert mode";
      }
      {
        key = "<C-l>";
        mode = "i";
        action = "<Right>";
        options.desc = "Move right in insert mode";
      }
      {
        key = "<leader>dl";
        mode = "n";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show line diagnostics";
      }
      {
        key = "<leader>dt";
        mode = "n";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "List diagnostics";
      }
      {
        key = "gr";
        mode = "n";
        action = "<cmd>Telescope lsp_references<CR>";
        options.desc = "Show references";
      }
      {
        key = "<leader>td";
        mode = "n";
        action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>";
        options.desc = "Toggle diagnostics";
      }
      {
        key = "<leader>t";
        mode = "n";
        action = "<cmd>ToggleTerm<CR>";
        options.desc = "Toggle terminal";
      }
      {
        key = "<leader>mp";
        mode = "n";
        action = "<cmd>MarkdownPreview<CR>";
        options.desc = "Open markdown preview";
      }
      {
        key = "<C-h>";
        mode = "n";
        action = "<C-w>h";
        options.desc = "Move to left window";
      }
      {
        key = "<C-j>";
        mode = "n";
        action = "<C-w>j";
        options.desc = "Move to lower window";
      }
      {
        key = "<C-k>";
        mode = "n";
        action = "<C-w>k";
        options.desc = "Move to upper window";
      }
      {
        key = "<C-l>";
        mode = "n";
        action = "<C-w>l";
        options.desc = "Move to right window";
      }
      {
        key = "<S-h>";
        mode = "n";
        action = ":bprevious<CR>";
        options.desc = "Previous buffer";
      }
      {
        key = "<S-l>";
        mode = "n";
        action = ":bnext<CR>";
        options.desc = "Next buffer";
      }
    ];

    extraPackages = with pkgs; [
      nil
      basedpyright
      clang-tools
      gopls
      lua-language-server
      marksman
      rPackages.languageserver
      cargo
      rustc
      rust-analyzer
      superhtml
      tinymist
      typescript-language-server
      zls
    ];

    extraConfigLua = ''
      require("which-key").add({
        { "<leader>f", group = "Find" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>t", group = "Toggle" },
        { "<leader>m", group = "Markdown" },
        { "<leader>r", group = "Refactor" },
        { "<leader>c", group = "Code" },
        { "<leader>n", group = "Search" },
      })
    '';
  };
}
