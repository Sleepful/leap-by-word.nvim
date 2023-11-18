-- Taking a lot from Leap's source
local api = vim.api

local function replace_keycodes(s)
  return api.nvim_replace_termcodes(s, true, false, true)
end

local function get_input()
  local ok, ch = pcall(vim.fn.getcharstr)
  local esc = replace_keycodes("<esc>")
  if ok and (ch ~= esc) then
    return ch
  else
    return nil
  end
end

-- patterns and functions for testing if a character should be considered a target
local matches = {
  upper = [=[\v[[:upper:]]\C]=],
  lower = [=[\v[[:lower:]]\C]=],
  digit = [=[\v[[:digit:]]\C]=],
  word  = [=[\v[[:upper:][:lower:][:digit:]]\C]=],
}
local function test(char, match)
  if char == nil then return false -- vim.fn.match returns false for nil char, but not if pattern contains `[:lower:]`
  else return vim.fn.match(char, match) == 0 end
end

local function test_split_identifiers(chars, cur_i)
  local cur_char = chars[cur_i]

  local is_match = false

  if test(cur_char, matches.upper) then
    local prev_char = chars[cur_i - 1]
    if not test(prev_char, matches.upper) then is_match = true
    else
      local next_char = chars[cur_i + 1]
      is_match = test(next_char, matches.word) and not test(next_char, matches.upper)
    end
  elseif test(cur_char, matches.digit) then
    is_match = not test(chars[cur_i - 1], matches.digit)
  elseif test(cur_char, matches.lower) then
    is_match = not test(chars[cur_i - 1], matches.word) or test(chars[cur_i - 1], matches.digit)
  else
    local prev_char = chars[cur_i - 1]
    is_match = prev_char ~= cur_char -- matching only first character in ==, [[ and ]]
  end

  return is_match
end

local function get_targets(winid, char, direction)
  -- Case sensitive version: "\\v[[="..char.."=]]\\C"
  local match_regex = "\\v[[="..char.."=]]\\c"

  local wininfo = vim.fn.getwininfo(winid)[1]
  local lnum = wininfo.topline
  local botline = wininfo.botline
  local width = wininfo.width
  -- this "first_col" refers to the position of the window,
  -- the window's columns are actually always 1 to "width"
  --
  -- local first_col = wininfo.wincol
  local first_col = 1
  local last_col = wininfo.width - first_col
  print("first_col:" .. first_col .. " last_col:" .. last_col)
  local targets = {}
  local cursor_line = vim.fn.line(".")
  local begin = nil
  local finish = nil
  if direction == "upwards" then
    finish = cursor_line
  end
  if direction == "downwards" then
    lnum = cursor_line
    finish = botline
  end
  if direction == "both" or direction == nil then
    finish = botline
  end
  while lnum <= finish do
    local fold_end = vim.fn.foldclosedend(lnum)
    -- Skip folded ranges.
    if fold_end ~= -1 then
      lnum = fold_end + 1
    else
      local line = vim.fn.getline(lnum)
      local chars = vim.fn.split(line, '\\zs')

      -- this works fine with columns that are outside of the screen to the left
      -- it also works fine with columns that are outside of the screen to the right
      -- BUT leap does not display labels for targets that are beyond the right border,
      -- although it does display labels for targets that are beyond the left border
      local col = 1
      for i, cur in ipairs(chars) do -- search beyond last column
        -- v  first_col <= col and col <= last_col and
        if test(cur, match_regex) and test_split_identifiers(chars, i) then
          table.insert(targets, { pos = { lnum, col } })
        end
        col = col + string.len(cur)
      end
      assert(string.len(line) == col - 1)

      lnum = lnum + 1
    end
  end
  -- Sort them by vertical screen distance from cursor.
  local cur_screen_row = vim.fn.screenpos(winid, cursor_line, 1)["row"]
  local function screen_rows_from_cur(t)
    local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])["row"]
    return math.abs(cur_screen_row - t_screen_row)
  end
  table.sort(targets, function(t1, t2)
    return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
  end)
  if #targets >= 1 then
    return targets
  end
end

local function leap(opts, leap_override_opts)
  opts = opts or {}
  local direction = opts.direction or "both"
  print("Search word with letter:")
  local char = get_input()
  if char == nil then
    print("Canceled")
    return
  end
  local winid = vim.api.nvim_get_current_win()
  local targets = get_targets(winid, char, direction)
  if targets ~= nil then
    print("Match found")
    require("leap").leap(vim.tbl_extend("force", {
      target_windows = { winid },
      targets = targets,
    }, leap_override_opts or {}))
  else
    print("No matches")
  end
end

local function leap_spooky(opts, spooky_override_opts)
  local action = require("leap-spooky").spooky_action(
    function () return "vE" end,
    { keeppos = true, on_return = (vim.v.operator == 'y') and 'p', }
  )
  local leap_override_opts = { action = action }
  leap({}, leap_override_opts)
end

return { leap = leap, EXPERIMENTAL_spooky_leap = leap_spooky }
