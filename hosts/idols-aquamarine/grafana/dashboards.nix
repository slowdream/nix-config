{

  # Декларативный provisioning дашбордов (и см. datasources.nix).
  # Алертинг Grafana не используем — Alertmanager.
  # https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
  services.grafana.provision.dashboards.settings = {
    apiVersion = 1;

    providers = [
      {
        # уникальное имя провайдера
        name = "Homelab";
        # организация — изоляция пользователей и ресурсов
        #
        # org id, по умолчанию 1; свой id — сначала создать org в Grafana
        orgId = 1;
        # тип провайдера, по умолчанию file
        type = "file";
        # запрет удаления дашбордов
        disableDeletion = true;
        # интервал сканирования JSON на диске
        updateIntervalSeconds = 20;
        # правки provisioned дашбордов из UI
        allowUiUpdates = false;
        options = {
          # путь к файлам дашбордов (для type=file)
          path = "/etc/grafana/dashboards/";
          # папки на диске → папки в Grafana
          foldersFromFilesStructure = true;
        };
      }
    ];
  };
}
