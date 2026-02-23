{pkgs, ...}: let
  enableEvilHelix = true; # Set to true to enable the configuration
in {
  home.packages = with pkgs; (
    if enableEvilHelix
    then [
      evil-helix
      cmake-language-server
      jsonnet-language-server
      luaformatter
      lua-language-server
      marksman
      taplo
      nil
      jq-lsp
      vscode-langservers-extracted
      bash-language-server
      awk-language-server
      vscode-extensions.llvm-vs-code-extensions.vscode-clangd
      clang-tools
      docker-compose-language-service
      docker-compose
      docker-language-server
      typescript-language-server
      rust-analyzer
      astro-language-server
      protobuf-language-server
      protols
      gopls
      buf
    ]
    else []
  );

  home.file.".config/helix/languages.toml".text =
    if enableEvilHelix
    then ''
            [language-server.nil]
            command = "nil"

            [language-server.lua]
            command = "lua-language-server"

            [language-server.json]
            command = "vscode-json-languageserver"

            [language-server.markdown]
            command = "marksman"

            [language-server.gopls]
            command = "gopls"

            [language-server.protols]
            command = "protols"

            [[language]]
            name = "go"
            auto-format = true
            language-servers = [ "gopls" ]

            [[language]]
            name = "protobuf"
            auto-format = true
            language-servers = [ "protols" ]

            [language-server.rust-analyzer]
             command = "rust-analyzer"

      [language-server.rust-analyzer.config]
      check.command = "clippy"

      [[language]]
      name = "rust"
      auto-format = true
      language-servers = [ "rust-analyzer" ]
    ''
    else "";

  home.file.".config/helix/config.toml".text =
    if enableEvilHelix
    then ''
      theme = "autumn"
      #theme = "ao"

      [editor]
      evil = true
      bufferline = "multiple"
      end-of-line-diagnostics = "hint"
      auto-pairs = true
      mouse = true
      middle-click-paste = true
      shell = ["zsh", "-c"]
      line-number = "absolute"
      auto-completion = true
      path-completion = true
      auto-info = true
      color-modes = true
      popup-border = "all"
      clipboard-provider = "wayland"
      indent-heuristic = "hybrid"

      [editor.cursor-shape]
      insert = "bar"

      [keys.normal]
      esc = ["collapse_selection", "keep_primary_selection"]



      [editor.statusline]
      left = ["mode", "spinner"]
      center = ["file-absolute-path", "total-line-numbers", "read-only-indicator", "file-modification-indicator"]
      right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"]
      separator = "│"
      mode.normal = "NORMAL"
      mode.insert = "INSERT"
      mode.select = "SELECT"

      [editor.lsp]
      enable = true
      display-messages = true
      display-progress-messages = true

      [editor.inline-diagnostics]
      cursor-line = "hint"
      other-lines = "hint"
    ''
    else "";
}
