local M = {}

local container_patterns = {
  "hash", "array", "object", "parameters", "argument", "imports",
  "dictionary", "touple", "set", "program", "list", "body", "chunk",
  "table", "block"
}

local commands = {
  { name = "SwapNext", fn = require("ts-node-swap.swap").swap_next },
  { name = "SwapPrev", fn = require("ts-node-swap.swap").swap_previous },
  { name = "NodeAncestors", fn = require("ts-node-swap.helpers").print_ancestors },
}

function M.setup(opts)
  M.container_patterns = vim.tbl_flatten(
    { container_patterns, opts.container_patterns or {} }
  )

  for _, command in ipairs(commands) do
    vim.api.nvim_create_user_command(command.name, command.fn, {})
  end
end

return M
