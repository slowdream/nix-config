{
  # NTP в материковом Китае
  networking.timeServers = [
    "ntp.aliyun.com" # Aliyun NTP
    "ntp.tencent.com" # Tencent NTP
  ];

  # динамически править /etc/hosts для тестов
  # при switch конфигурации изменения пропадут
  environment.etc.hosts.mode = "0644";
}
