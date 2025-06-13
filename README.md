# bufferline.lua
![bufferline](https://github.com/nvoid-lua/bufferline.lua/assets/94284073/d090e833-7b74-43c3-8ff4-ba91c51b65f9)

A fast bufferline based on nvchad's tabufline

## Install

### Packer

```lua
use {
    "nvoid-lua/bufferline.lua",
    requires = 'echasnovski/mini.icons',
    config = function()
        require("bufferline").setup({ kind_icons = true })
    end,
},
```

### Lazy

```lua
{
    "nvoid-lua/bufferline.lua",
    dependencies = 'echasnovski/mini.icons',
    config = function()
        require("bufferline").setup({ kind_icons = true })
    end,
},
```

## Setup

```lua
require("bufferline").setup {
  always_show = false,
  show_numbers = false,
  kind_icons = true,
  -- Icons are now primarily sourced from 'mini.icons' if available.
  -- Fallback icons are used internally if 'mini.icons' is not found or specific icons are missing.
  -- You no longer need to configure the 'icons' table here for default behavior.
}
```

## Highlights

```
TblineFill
TbLineBufOn
TbLineBufOff
TbLineBufOnModified
TbBufLineBufOffModified
TbLineBufOnClose
TbLineBufOffClose
TblineTabNewBtn
TbLineTabOn
TbLineTabOff
TbLineTabCloseBtn
TBTabTitle
TbLineCloseAllBufsBtn
```
