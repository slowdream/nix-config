{ ... }:
{
  # TuneD — механизм доставки tuning-профилей для Linux
  # Современная замена PPD (power-profiles-daemon)
  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
    ppdSupport = true; # трансляция вызовов power-profiles-daemon API в TuneD
    ppdSettings.main.default = "balanced"; # balanced / performance / power-saver
  };
  # DBus-сервис power management для приложений
  # Нужен `tuned-ppd` для смены источника питания
  services.upower.enable = true;

  services.power-profiles-daemon.enable = false; # конфликтует с tuned
  services.tlp.enable = false; # конфликтует с tuned
}
