{
  pkgs,
  config,
  ...
}:
# обработка аудио/видео
{
  home.packages = with pkgs; [
    ffmpeg-full

    # изображения
    viu # просмотр картинок в терминале (iTerm, Kitty)
    imagemagick
    graphviz
  ];
}
