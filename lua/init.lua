local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("SwapNext", require("ts-node-swap.swap").swap_next, {})

  vim.api.nvim_create_user_command("SwapPrev", require("ts-node-swap.swap").swap_previous, {})

  vim.api.nvim_create_user_command("NodeAncestors", function()
    local node = ts_utils.get_node_at_cursor()
    if not node then return end

    local tree = { node:type() }
    while node:parent() do
      table.insert(tree, node:parent():type())
      node = node:parent()
    end

    P(tree)
  end,
    {})
end

return M
