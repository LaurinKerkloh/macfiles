-- Execute lua
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<cr>")
vim.keymap.set("n", "<leader>x", ":.lua<cr>")
vim.keymap.set("v", "<leader>x", ":lua<cr>")

-- Center view when navigating
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "{", "{zz")

-- Move lines
vim.keymap.set("n", "<m-j>", "<cmd>m .+1<cr>==")
vim.keymap.set("n", "<m-k>", "<cmd>m .-2<cr>==")
vim.keymap.set("i", "<m-j>", "<esc><cmd>m .+1<cr>==gi")
vim.keymap.set("i", "<m-k>", "<esc><cmd>m .-2<cr>==gi")
vim.keymap.set("v", "<m-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<m-k>", ":m '<-2<cr>gv=gv")

-- tmux-sessionizer
vim.keymap.set("n", "<c-f>", "<cmd>silent !tmux new-window tmux-sessionizer<cr>")

-- tmux-worktreeizer
vim.keymap.set("n", "<c-g>", function()
    vim.fn.system({ "tmux", "new-window", "-c", vim.fn.getcwd(), "tmux-worktreeizer" })
end)

-- Format using 'formatexpr'
vim.keymap.set("n", "<leader>f", "mpgggqG`p")
