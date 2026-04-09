{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    # https://starship.rs/config/
    settings = {
      # completions редактора по JSON schema конфига
      "$schema" = "https://starship.rs/config-schema.json";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      # Дефолты модулей не использую — для меня бесполезно, выключено.
      # Предпочитаю вручную добавлять --project, --region к каждой команде gcloud/aws.
      aws.disabled = true;
      gcloud.disabled = true;

      kubernetes = {
        symbol = "⛵";
        disabled = false;
      };
      os.disabled = false;
    };
  };
}
