{ myvars, ... }:
{
  programs.ssh = myvars.networking.ssh;

  users.users.${myvars.username} = {
    description = myvars.userfullname;
    # Публичные ключи для входа на все мои ПК и серверы.
    #
    # Раз права такие широкие, усиливаем security:
    # 1. Соответствующий private key должен:
    #    1. Генерироваться локально на каждом доверенном клиенте, например:
    #      ```bash
    #      # KDF: bcrypt, 256 rounds
    #      # Passphrase: цифры + буквы + символы, 12+ символов
    #      ssh-keygen -t ed25519 -a 256 -C "ryan@xxx" -f ~/.ssh/xxx
    #      ```
    #    2. Никогда не покидать устройство и не передаваться по сети.
    # 2. Либо hardware security keys вроде Yubikey/CanoKey.
    openssh.authorizedKeys.keys = myvars.mainSshAuthorizedKeys;
  };
}
