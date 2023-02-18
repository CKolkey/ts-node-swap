local M = {}

local container_patterns = {
  "hash", "array", "object", "parameter", "argument", "imports",
  "dictionary", "touple", "set", "program", "list", "body", "chunk",
  "block"
}

local function parent_is_containter(node)
  local parent_type = node:parent():type()

  for _, pattern in ipairs(container_patterns) do
    local match, _ = parent_type:match(pattern)
    if match then
      return true
    end
  end

  return false
end

function M.swappable_node(node)
  while not parent_is_containter(node) do
    node = node:parent()
  end

  return node
end

function M.find_swap(node, direction)
  if direction == "prev" then
    return node:prev_named_sibling()
  else
    return node:next_named_sibling()
  end
end

-- TODO: Cleanup
function M.get_node_text(node)
  -- We have to remember that end_col is end-exclusive
  local start_row, start_col, end_row, end_col = node:range()

  if start_row ~= end_row then
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
    if next(lines) == nil then
      return {}
    end
    lines[1] = string.sub(lines[1], start_col + 1)
    -- end_row might be just after the last line. In this case the last line is not truncated.
    if #lines == end_row - start_row + 1 then
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
    return lines
  else
    local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
    -- If line is nil then the line is empty
    return line and { string.sub(line, start_col + 1, end_col) } or {}
  end
end

function M.set_jump()
  vim.cmd("normal! m'")
end

return M
