{ pkgs, ... }:
{
  #============================= Audio (PipeWire) =======================

  # Пакеты в system profile. Поиск:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pulseaudio # даёт `pactl`, нужен некоторым приложениям (например sonic-pi)
  ];

  # PipeWire — low-level multimedia framework.
  # Захват и воспроизведение аудио/видео с минимальной задержкой.
  # Совместимость с приложениями на PulseAudio, JACK, ALSA и GStreamer.
  # Хорошая поддержка Bluetooth; альтернатива PulseAudio.
  #     https://nixos.wiki/wiki/PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Для JACK-приложений раскомментируйте
    jack.enable = true;
    wireplumber.enable = true;
  };
  # rtkit опционален, но рекомендуется
  security.rtkit.enable = true;
  # Отключить pulseaudio — конфликтует с pipewire.
  services.pulseaudio.enable = false;

  #============================= Bluetooth =============================

  # bluetooth и GUI для pairing — blueman
  # или CLI:
  # $ bluetoothctl
  # [bluetooth] # power on
  # [bluetooth] # agent on
  # [bluetooth] # default-agent
  # [bluetooth] # scan on
  # ...включите режим pairing на устройстве и дождитесь [hex-address]...
  # [bluetooth] # pair [hex-address]
  # [bluetooth] # connect [hex-address]
  # Автоподключение устройств через bluetoothctl:
  # [bluetooth] # trust [hex-address]
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #================================= Misc =================================

  services = {
    printing.enable = true; # CUPS для печати
    geoclue2.enable = true; # геолокация

    udev.packages = with pkgs; [
      gnome-settings-daemon
      # platformio # udev rules для platformio
      # openocd # нужен для platformio, см. https://github.com/NixOS/nixpkgs/issues/224895
      # openfpgaloader
    ];

    # Демон переназначения клавиш для Linux.
    # https://github.com/rvaiya/keyd
    keyd = {
      enable = true;
      keyboards.default.settings = {
        main = {
          # capslock: по tap — escape, при удержании — control
          capslock = "overload(control, esc)";
          esc = "capslock";
        };
      };
    };
  };
}
