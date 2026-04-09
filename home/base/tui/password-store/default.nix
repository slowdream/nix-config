{
  pkgs,
  config,
  lib,
  ...
}:
let
  passwordStoreDir = "${config.xdg.dataHome}/password-store";
in
{
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      # OTP-токены
      # NOTE: хранить пароль и OTP вместе противоречит идее второго фактора!
      # exts.pass-otp

      # exts.pass-import # импорт из других менеджеров
      exts.pass-update # простой сценарий обновления паролей
    ]);
    # См. pass(1) «Environment variables» и man страниц расширений.
    settings = {
      PASSWORD_STORE_DIR = passwordStoreDir;
      # Переопределяет gpg key id из init.
      # Лучше hex fingerprint.
      # Несколько ключей — через пробел.
      PASSWORD_STORE_KEY = lib.strings.concatStringsSep " " [
        "EF824EB73CFD6CC7" # E — Ryan Yin (только pass и SSH) <ryan4yin@linux.com>
      ];
      # Все .gpg-id и несистемные расширения подписываются detached signature этим GPG-ключом
      #   (40 символов fingerprint, upper-case).
      # Несколько fingerprint — через пробел, подпись должна совпасть хотя бы с одним.
      # init поддерживает подписи .gpg-id в актуальном состоянии.
      PASSWORD_STORE_SIGNING_KEY = lib.strings.concatStringsSep " " [
        "C2A313F98166C942" # S — Ryan Yin (только pass и SSH) <ryan4yin@linux.com>
      ];
      PASSWORD_STORE_CLIP_TIME = "60";
      PASSWORD_STORE_GENERATED_LENGTH = "12";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    };
  };

  # расширения password-store для браузеров
  # нужно поставить расширение в браузер
  # https://github.com/browserpass/browserpass-extension
  programs.browserpass = {
    enable = true;
    browsers = [
      "chrome"
      "chromium"
      "firefox"
    ];
  };
}
