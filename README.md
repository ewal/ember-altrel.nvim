# ember-altrel.nvim
Neovim plugin for opening related files. Supports project mix of typescript and javascript.

## Installation

```lua
-- lazy.nvim
{
  'ewal/ember-altrel.nvim',
  opts = { },
  -- lazy = false, -- make command(s) available at startup
}
```

## Commands
Rotate between related files
```
:EmberRelNext
```

## Changelog

### 2024-12-26
* Added a new command, `:EmberRelPrev` to go to rotate files in the opposite direction
### 2024-05-28
* Added support for rotating between component class and template
