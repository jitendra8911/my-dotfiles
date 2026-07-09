return {
  "ThePrimeagen/git-worktree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim", -- Optional for Telescope UI
  },
  config = function()
    -- Basic setup
    require("git-worktree").setup({})

    -- Load telescope extension if telescope is installed
    require("telescope").load_extension("git_worktree")
  end,
  keys = {
    -- Keymaps to trigger the Telescope UI
    { "<leader>gwm", function() require('telescope').extensions.git_worktree.git_worktrees() end, desc = "Manage Worktrees" },
    { "<leader>gwc", function() require('telescope').extensions.git_worktree.create_git_worktree() end, desc = "Create Worktree" },
  },
}

