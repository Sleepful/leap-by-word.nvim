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

local function get_targets(winid, char, direction)
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
      -- this works fine with columns that are outside of the screen to the left
      -- it also works fine with columns that are outside of the screen to the right
      -- BUT leap does not display labels for targets that are beyond the right border,
      -- although it does display labels for targets that are beyond the left border
      local current_line = line
      print(" current_line:" .. current_line)
      local col = first_col
      -- while col <= last_col do
      while true do -- search beyond last column
        -- shift current_line with whitespace to match easily with pattern even the first character
        current_line = " " .. current_line
        local lower_char = string.lower(char)
        local upper_char = string.upper(char)
        -- Case sensitive pattern:
        -- local pattern = "%W" .. char .. "[%w_-]*[%W]*"
        -- Ignore case pattern:
        local pattern = "%W[" .. lower_char .. upper_char .. "][%w_-]*[%W]*"
        local start_pos, end_pos = string.find(current_line, pattern)
        if start_pos == nil then
          break
        end
        -- go back to normal values
        current_line = string.sub(current_line, 2, -1)
        start_pos = start_pos - 1
        end_pos = end_pos - 1
        -- values are as if current_line was not right shifted with whitespace
        local match_col = col + start_pos
        -- increase end_pos by 1 because otherwise we are including last character from prev match
        current_line = string.sub(current_line, end_pos + 1)
        print("Match, line:" .. lnum .. " col:" .. match_col)
        table.insert(targets, { pos = { lnum, match_col } })
        col = col + end_pos
      end
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

return function(opts)
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
    require("leap").leap({
      target_windows = { winid },
      targets = targets,
    })
  else
    print("No matches")
  end
end
