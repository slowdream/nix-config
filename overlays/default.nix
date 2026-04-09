args:
# выполнить и импортировать все overlay-файлы в этой директории с переданными args
builtins.map (f: (import (./. + "/${f}") args)) # выполнить и импортировать overlay-файл

  (
    builtins.filter # найти все overlay-файлы в этой директории

      (
        f:
        f != "default.nix" # пропустить default.nix
        && f != "README.md" # пропустить README.md
      )
      (builtins.attrNames (builtins.readDir ./.))
  )
