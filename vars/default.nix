{ lib }:
{
  username = "slowdream";
  userfullname = "Ryan Yin";
  useremail = "xiaoyin_c@qq.com";
  networking = import ./networking.nix { inherit lib; };
  # Сгенерировано: mkpasswd -m yescrypt --rounds=11
  # Password: длинная случайная строка (полный charset)
  # Rotation policy: раз в год
  # Purpose: только пароль для входа в систему
  # https://man.archlinux.org/man/crypt.5.en
  initialHashedPassword = "$y$jFT$TaOZFqTbLCr.OOSVRRrpq0$4UMGJbeR/7KFnldb/KQ.zN7S4bNaZcssRxkdBIVjOC/";
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
  mainSshAuthorizedKeys = [
    # основные ssh-ключи на каждый день
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOO49hCa+nHAVI6UuQvIAS1RtIcUKHo+QUPO2A+XKHCS slowdream@idols-ai"
  ];
  secondaryAuthorizedKeys = [
    # запасные ssh-ключи на случай disaster recovery
    #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzYT0Fpcp681eHY5FJV2G8Mve53iX3hMOLGbVvfL+TF ryan@romantic"
  ];
}
