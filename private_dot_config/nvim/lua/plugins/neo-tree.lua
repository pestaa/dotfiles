---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    source_selector = {
      winbar = false, -- Disables the top tab header completely
      statusline = false, -- Ensures it doesn't pop up at the bottom
    },
  },
}
