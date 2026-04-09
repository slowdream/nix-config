{
  config,
  mysecrets,
  ...
}:
{
  home.file.".ssh/romantic.pub".source = "${mysecrets}/public/romantic.pub";

  programs.ssh = {
    enable = true;

    # конфиг по умолчанию отключён
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      # при аутентификации приватный ключ попадёт в ssh-agent, если он запущен
      addKeysToAgent = "yes";
      compression = true;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

    matchBlocks = {
      "github.com" = {
        # SSH к GitHub через порт HTTPS
        # (порт 22 иногда режут прокси / firewall)
        hostname = "ssh.github.com";
        port = 443;
        user = "git";

        # только явно заданный identity, без дефолтных ключей первым
        identitiesOnly = true;
      };

      "192.168.*" = {
        # безопасно использовать локальный SSH agent на удалённой машине
        # эквивалент `ssh -A user@host`
        forwardAgent = true;
        # romantic — ключ для homelab
        identityFile = "/etc/agenix/ssh-key-romantic";
        identitiesOnly = true;
      };
    };
  };
}
