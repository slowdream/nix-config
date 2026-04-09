{ pkgs, ... }:
{
  # Пакеты в system profile. Поиск: nix search wget
  environment.systemPackages = with pkgs; [
    # syscalls
    strace
    ltrace # library calls
    lsof # открытые файлы

    # eBPF
    # https://github.com/bpftrace/bpftrace
    bpftrace
    bpftop
    bpfmon

    # мониторинг
    sysstat
    iotop-c
    iftop
    nmon
    sysbench
    systemctl-tui
    pv

    # системные утилиты
    psmisc # killall/pstree/…
    lm_sensors # `sensors`
    ethtool
    pciutils # lspci
    usbutils # lsusb
    hdparm
    dmidecode # SMBIOS/DMI из BIOS
    parted
    smartmontools # smartctl
    nvme-cli
  ];

  # BCC — IO/network/monitoring на BPF
  # https://github.com/iovisor/bcc
  programs.bcc.enable = true;
}
