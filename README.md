# jdd.nvim

A Neovim plugin that integrates with [Johnny Decimal Daemon (jdd)](https://github.com/mahyarmirrashed/jdd), allowing you to automatically organize files in a directory according to the [Johnny Decimal](https://johnnydecimal.com/) system—directly from your editor.

## Features

- Seamlessly runs the JDD process in the foreground from Neovim
- Fully configurable: all `jdd` CLI options are available via Lua
- Supports exclusion patterns, dry-run mode, and custom config files
- Automatically stops the JDD process when Neovim exits

## Requirements

- [Neovim](https://neovim.io/) 0.5.0 or later
- [jdd](https://github.com/mahyarmirrashed/jdd) binary in your `$PATH`
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (for async process management)

## Installation

Install using your preferred Neovim package manager.

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "mahyarmirrashed/jdd.nvim",
  requires = { "nvim-lua/plenary.nvim" },
  config = function()
    require("jdd").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'mahyarmirrashed/jdd.nvim'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "mahyarmirrashed/jdd.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("jdd").setup()
  end,
}
```

## Usage

Configure and start JDD with the `setup()` function. All options map directly to the corresponding CLI flags.

### Example

```lua
require("jdd").setup({
  root = "~/Documents",
  log_level = "info",
  dry_run = true,
  exclude = { ".git/**", "tmp/**" },
  -- config = "/path/to/.jd.yaml", -- optional
  start = true,
})
```

To manually control the process:

```lua
require("jdd").setup({ start = false })
require("jdd").start() -- Start JDD
require("jdd").stop()  -- Stop JDD
```

## How It Works

- JDD runs as a foreground process managed by Neovim.
- All logs and errors are shown as Neovim notifications.
- The process is automatically stopped when Neovim exits.

## License

[MIT License](./LICENSE)
