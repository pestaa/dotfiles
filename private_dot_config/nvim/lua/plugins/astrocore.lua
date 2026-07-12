-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
      },
    },
    -- mappings can be configured here (see `:h astrocore-mappings`)
    mappings = {
      n = {
        -- GitHub (snacks `gh` module) — remote actions, distinct from the
        -- local `<Leader>g` git maps. `<Leader>gp` is taken (Preview Git hunk).
        ["<Leader>gh"] = { desc = "󰊤 GitHub" },
        ["<Leader>ghp"] = { function() Snacks.picker.gh_pr() end, desc = "Pull requests (open)" },
        ["<Leader>ghP"] = { function() Snacks.picker.gh_pr { state = "all" } end, desc = "Pull requests (all)" },
        ["<Leader>ghi"] = { function() Snacks.picker.gh_issue() end, desc = "Issues (open)" },
        ["<Leader>ghI"] = { function() Snacks.picker.gh_issue { state = "all" } end, desc = "Issues (all)" },
        -- gh_diff requires a PR number (bare call errors), so prompt for one
        ["<Leader>ghd"] = {
          function()
            vim.ui.input({ prompt = "PR number: " }, function(n)
              n = tonumber(n)
              if n then Snacks.picker.gh_diff { pr = n } end
            end)
          end,
          desc = "PR diff (by number)",
        },
      },
    },
  },
}
