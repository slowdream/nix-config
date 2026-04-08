# Глоссарий редакторов

### LSP - Language Server Protocol

> https://en.wikipedia.org/wiki/Language_Server_Protocol

> https://langserver.org/

Language Server Protocol (LSP) — это открытый протокол на базе JSON-RPC для взаимодействия между
редактором исходного кода (или IDE) и сервером, который предоставляет language-specific возможности,
например:

- перемещения (go-to-definition, find-references, hover)
- **code completion**
- **подсветка warnings и errors**
- **refactoring routines**
- syntax highlighting (лучше через Tree-sitter)
- code formatting (лучше отдельным formatter)

Цель протокола — позволить реализовывать и распространять поддержку языков программирования
независимо от конкретного редактора или IDE.

Изначально LSP разработали для Microsoft Visual Studio Code, а затем он стал открытым стандартом. В
начале 2020-х LSP быстро стал «нормой» для инструментов language intelligence.

### Tree-sitter

> https://tree-sitter.github.io/tree-sitter/

> https://www.reddit.com/r/neovim/comments/1109wgr/treesitter_vs_lsp_differences_ans_overlap/

Tree-sitter — это parser generator и библиотека **incremental parsing**. Он строит concrete syntax
tree для исходного файла и эффективно обновляет её по мере редактирования.

Используется многими редакторами и IDE для:

- **syntax highlighting**
- **indentation**
- **создания foldable code regions**
- **incremental selection**
- **простого рефакторинга в пределах одного файла**
  - например join/split lines, structural editing, cursor motion и т.д.

**Tree-sitter обрабатывает каждый файл независимо** и не знает семантики вашего кода. Например, он не
понимает, существует ли реально функция/переменная, и какой у неё type/return-type. Тут и нужен LSP.

LSP server парсит код глубже и **анализирует не только один файл, а весь проект**. Поэтому он может
понять, существует ли функция/переменная и совпадает ли её type/return-type. Если нет — отметит это
как ошибку.

**LSP понимает код семантически, а Tree-sitter заботится в основном о корректном синтаксисе**.

#### LSP vs Tree-sitter

- Tree-sitter: lightweight, fast, but limited knowledge of your code. mainly used for **syntax
  highlighting, indentation, and folding/refactoring in a single file**.
- LSP: heavy and slow on large projects, but it has a deep understanding of your code. mainly used
  for **code completion, refactoring in the projects, errors/warnings, and other semantic-aware
  features**.

### Formatter vs Linter

Linting отличается от Formatting, потому что:

1. **formatting** меняет только то, как выглядит код.
   1. `prettier` is a popular formatter.
1. **linting** анализирует код и ищет ошибки, а также может предлагать улучшения, например заменить
   `var` на `let` или `const`.

Formatters и Linters обычно обрабатывают каждый файл независимо — им не обязательно знать о других
файлах проекта.

- [ ]
