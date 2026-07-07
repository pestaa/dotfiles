-- Enable blink.cmp's built-in (experimental) signature help, replacing
-- lsp_signature.nvim. Themed to match the completion menu; shows on a
-- function's trigger character (e.g. `(`). Revert by setting enabled = false
-- and re-adding lsp_signature.nvim if the overload/multi-signature handling
-- proves too rough.

---@type LazySpec
return {
  "saghen/blink.cmp",
  opts = {
    signature = { enabled = true },
  },
}
