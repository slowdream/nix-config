{
  nu_scripts,
  ...
}:
{
  programs.nushell = {
    # алиасы для work
    # файл должен существовать, иначе nushell ругается
    #
    # условного source в nushell пока нет
    # https://github.com/nushell/nushell/issues/8214
    extraConfig = ''
      source /etc/agenix/alias-for-work.nushell

      $env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
      $env.CLAUDE_CODE_ATTRIBUTION_HEADER = "0"
      # claude-code с kimi llm
      # https://platform.moonshot.cn/docs/guide/agent-support
      # $env.ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic/"
      # $env.ANTHROPIC_AUTH_TOKEN = $env.MOONSHOT_API_KEY
      # $env.ANTHROPIC_MODEL = "kimi-k2-thinking"
      # $env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "kimi-k2-thinking-turbo"

      # claude-code с glm llm
      # https://docs.bigmodel.cn/cn/coding-plan/tool/claude
      # $env.ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
      # $env.ANTHROPIC_AUTH_TOKEN = $env.ZAI_API_KEY
      # $env.ANTHROPIC_MODEL = "glm-4.7"
      # $env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"

      # claude-code с minimax llm
      # https://platform.minimax.io/docs/token-plan/claude-code
      # $env.ANTHROPIC_BASE_URL = "https://api.minimax.io/anthropic"
      # $env.ANTHROPIC_AUTH_TOKEN = $env.MINIMAX_API_KEY
      # $env.ANTHROPIC_MODEL = "MiniMax-M2.7"
      # $env.ANTHROPIC_SMALL_FAST_MODEL = "MiniMax-M2.7"
      # $env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "MiniMax-M2.7"


      # Каталоги из этой константы ищут команды `use` и `source`.
      const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}']

      # -*- completion -*-
      use custom-completions/cargo/cargo-completions.nu *
      use custom-completions/curl/curl-completions.nu *
      use custom-completions/git/git-completions.nu *
      use custom-completions/glow/glow-completions.nu *
      use custom-completions/just/just-completions.nu *
      use custom-completions/make/make-completions.nu *
      use custom-completions/man/man-completions.nu *
      use custom-completions/nix/nix-completions.nu *
      use custom-completions/ssh/ssh-completions.nu *
      use custom-completions/tar/tar-completions.nu *
      use custom-completions/tcpdump/tcpdump-completions.nu *
      use custom-completions/zellij/zellij-completions.nu *
      use custom-completions/zoxide/zoxide-completions.nu *

      # -*- alias -*-
      use aliases/git/git-aliases.nu *
      use aliases/eza/eza-aliases.nu *
      use aliases/bat/bat-aliases.nu *
      use ${./aliases/gcloud.nu} *

      # -*- modules -*-
      # argx и lg нужны модулю kubernetes
      use modules/argx *
      use modules/lg *
      # k8s/helm: алиасы, completions
      use modules/kubernetes *
      # обёртка вокруг jc: вывод CLI → таблицы nushell
      # use modules/jc
    '';
  };
}
