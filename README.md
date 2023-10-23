# leap-by-word.nvim

Use with [leap.nvim](https://github.com/ggandor/leap.nvim) and leap better, faster, stronger.

This allows you to leap by using only *1 letter* as your query.
It will highlight the *first letter* of all words that match your query.
The goal is to make `leap` easy peasy lemon squeezy, just look at the first letter, forget about looking at the second one.

So the steps are:

1. **Mentally** choose a word that you want to leap to.
2. Use your keybind to activate `leap-by-word`.
3. Input the **first letter** of the word that you picked, this will give it a label on your screen.
4. Input the **letter of the label** that showed on your word, this will let you **leap** to it.

<details>
<summary>
  
## Screenshots

</summary>

#### Before searching

<img width="483" alt="Screenshot 2023-10-23 at 00 29 28" src="https://github.com/Sleepful/leap-by-word.nvim/assets/7144046/c7cec654-916e-4c00-88b0-1d2922bfe70c">

#### Searching for words that start with `j`

<img width="483" alt="Screenshot 2023-10-23 at 00 29 35" src="https://github.com/Sleepful/leap-by-word.nvim/assets/7144046/628985ff-25c2-451f-9aff-e9b6d20e6d68">

#### Leap to `j` and then searching for words that start with `o`

<img width="483" alt="Screenshot 2023-10-23 at 00 38 55" src="https://github.com/Sleepful/leap-by-word.nvim/assets/7144046/a11f985e-54cf-4ddd-9ed8-a0ee99b2a620">

</details>

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
require('leap-by-word').leap({direction = "upwards"})
```

## Future road map

Allow this plugin to work with [leap-spooky.nvim](https://github.com/ggandor/leap-spooky.nvim).
