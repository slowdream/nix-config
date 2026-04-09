{
  config,
  mysecrets,
  ...
}:
{
  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
    #  $GNUPGHOME/trustdb.gpg — уровни доверия из `programs.gpg.publicKeys`.
    #
    # При `mutableTrust` = false trustdb.gpg перезаписывается при каждой активации.
    # Обновлять trustdb только через home-manager.
    mutableTrust = false;

    # $GNUPGHOME/pubring.kbx — публичные ключи из `programs.gpg.publicKeys`.
    #
    # При `mutableKeys` = false pubring.kbx — иммутабельная ссылка в Nix store, правки запрещены.
    # Обновлять pubring только через home-manager
    mutableKeys = false;
    publicKeys = [
      # https://www.gnupg.org/gph/en/manual/x334.html
      {
        source = "${mysecrets}/public/ryan4yin-gpg-keys-2014-01-27.pub";
        trust = 5;
      } # ultimate — свои ключи
    ];

    # По туториалу ниже — устойчивая схема
    # https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1
    # ~/.gnupg/gpg.conf
    settings = {
      # без copyright-баннера
      no-greeting = true;

      # не вшивать версию в ASCII armor
      no-emit-version = true;
      # не писать comment packets
      no-comments = false;
      # минимальный экспорт ключей
      # убирает подписи кроме последней self-signature на каждом user ID
      export-options = "export-minimal";

      # длинные key ID
      keyid-format = "0xlong";
      # список ключей с отпечатками
      with-fingerprint = true;

      # валидность user ID при листинге
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity show-keyserver-urls";

      # самый сильный шифр
      personal-cipher-preferences = "AES256";
      # самый сильный digest
      personal-digest-preferences = "SHA512";
      # для новых ключей и дефолт для setpref в edit menu
      default-preference-list = "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed";

      cipher-algo = "AES256";
      digest-algo = "SHA512";
      # digest при подписи ключа
      cert-digest-algo = "SHA512";
      compress-algo = "ZLIB";

      # слабый алгоритм выключить
      disable-cipher-algo = "3DES";
      weak-digest = "SHA1";

      # симметричное шифрование паролем
      s2k-cipher-algo = "AES256";
      s2k-digest-algo = "SHA512";
      s2k-mode = "3";
      s2k-count = "65011712";
    };
  };
}
