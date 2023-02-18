local M = {}

local helpers  = require("ts-node-swap.helpers")
local ts_utils = require("nvim-treesitter.ts_utils")

local function line_delta(range1, range2, text1, text2)
  local delta = 0
  if range1["end"].line < range2["start"].line
      or (range1["end"].line == range2["start"].line and range1["end"].character <= range2["start"].character)
  then
    delta = #text2 - #text1
  end

  return delta
end

local function character_delta(range1, range2, text1, text2, delta_l)
  local delta = 0

  if range1["end"].line == range2["start"].line and range1["end"].character <= range2["start"].character then
    if delta_l ~= 0 then
      delta = #text2[#text2] - range1["end"].character

      if range1["start"].line == range2["start"].line + delta_l then
        delta = delta + range1["start"].character
      end
    else
      delta = #text2[#text2] - #text1[#text1]
    end
  end

  return delta
end

local function update_cursor(range1, range2, text1, text2)
  local delta_l = line_delta(range1, range2, text1, text2)
  local delta_c = character_delta(range1, range2, text1, text2, delta_l)

  vim.api.nvim_win_set_cursor(0, { range2.start.line + 1 + delta_l, range2.start.character + delta_c })
end

local function swap_nodes(node_1, node_2)
  local range1 = ts_utils.node_to_lsp_range(node_1)
  local range2 = ts_utils.node_to_lsp_range(node_2)

  local text1 = helpers.get_node_text(node_1)
  local text2 = helpers.get_node_text(node_2)

  vim.lsp.util.apply_text_edits({
    { range = range1, newText = table.concat(text2, "\n") },
    { range = range2, newText = table.concat(text1, "\n") }
  }, vim.api.nvim_get_current_buf(), "utf-8")

  update_cursor(range1, range2, text1, text2)
end

local function swap(node, direction, set_jump)
  if not node then return end

  node = helpers.swappable_node(node)

  local swap_node = helpers.find_swap(node, direction)

  if not swap_node then
    local parent = node:parent()

    if direction == "prev" then
      for i = 0, parent:named_child_count() - 2 do
        swap(parent:named_child(i), "next", false)
      end
    else
      for i = parent:named_child_count() - 1, 1, -1 do
        swap(parent:named_child(i), "prev", false)
      end
    end

    helpers.set_jump()
  else
    swap_nodes(node, swap_node)

    -- We want to be able to skip setting jumps while sending a
    -- node from the back to the front and vice-versa.
    if set_jump then
      helpers.set_jump()
    end
  end
end

function M.swap_previous()
  swap(ts_utils.get_node_at_cursor(), "prev", true)
end

function M.swap_next()
  swap(ts_utils.get_node_at_cursor(), "next", true)
end

return M
