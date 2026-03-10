---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      -- Disable formatting capabilities for specific language servers
      disabled = {
        "intelephense",
      },
      -- Optional: bump the timeout just in case php-cs-fixer is slow on large files
      timeout_ms = 10000,
    },
  },
}
