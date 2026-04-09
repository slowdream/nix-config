{ pkgs, llm-agents, ... }:
{
  home.packages =
    with pkgs;
    [
      mitmproxy # прокси http/https
      wireshark # анализатор сети
    ]
    # AI Agent Tools
    ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      # Agents
      codex
      cursor-cli
      claude-code
      gemini-cli
      opencode

      # Utilities
      rtk # CLI-прокси, снижает расход LLM-токенов
    ]);
}
