{
  config,
  pkgs,
  ...
}:
{
  # безопасность через polkit
  security.polkit.enable = true;
  # gnome-keyring
  services.gnome = {
    gnome-keyring.enable = true;
    # SSH Agent из gnome-keyring
    # https://wiki.gnome.org/Projects/GnomeKeyring/Ssh
    gcr-ssh-agent.enable = false;
  };
  # seahorse — GUI для GNOME Keyring
  programs.seahorse.enable = true;
  # OpenSSH agent хранит private keys,
  # чтобы не вводить passphrase при каждом SSH-подключении.
  # Ключи добавлять через `ssh-add`.
  programs.ssh.startAgent = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # gpg agent с pinentry
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = false;
    settings.default-cache-ttl = 4 * 60 * 60; # 4 часа
  };
}
