# leap-by-word.nvim

Use with [leap.nvim](https://github.com/ggandor/leap.nvim) and leap better, faster, stronger.

This allows you to leap by using only *1 letter* as your query.
It will highlight the *first letter* of all words that match your query.

So the steps are:

1. **Mentally** choose a word that you want to leap to.
2. Use your keybind to activate `leap-by-word`.
3. Input the **first letter** of the word that you picked, this will give it a label on your screen.
4. Input the **letter of the label** that showed on your word, this will let you **leap** to it.

## Requirements

* Neovim >= 0.7.0
* [leap.nvim](https://github.com/ggandor/leap.nvim)

## Installation

Use your preferred plugin manager - no extra steps needed.

## Usage

Just pick your mapping:

```lua
-- example to map it to `s` key:
vim.keymap.set({'n', 'x', 'o'}, 's', function() require('leap-by-word').leap() end, {})
```

You can also pass a direction if you want:
```lua
-- can use "upwards" or "downwards" for direction, this means it will search only
-- in that direction from your cursor position. By default it uses "both" directions.
function() require('leap-by-word').leap({direction = "upwards"})
```

## Future road map

Allow this plugin to work with [leap-spooky.nvim](https://github.com/ggandor/leap-spooky.nvim).
