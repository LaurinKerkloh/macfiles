-- The terminal split used under dvim, reused by every run.
local term = { win = nil, buf = nil }

local function split_and_run(command)
    -- Under dvim nvim runs in the devcontainer, where the host's tmux is out of reach.
    if vim.env.DVIM == "1" then
        if term.win and vim.api.nvim_win_is_valid(term.win) then
            vim.api.nvim_set_current_win(term.win)
        else
            vim.cmd("botright vsplit | vertical resize " .. math.floor(vim.o.columns / 3))
            term.win = vim.api.nvim_get_current_win()
        end
        local previous = term.buf
        vim.cmd.terminal(command)
        term.buf = vim.api.nvim_get_current_buf()
        -- Stops the previous run along with its buffer.
        if previous and vim.api.nvim_buf_is_valid(previous) then
            vim.api.nvim_buf_delete(previous, { force = true })
        end
        return
    end

    local pane_id = vim.fn.system({ "tmux", "split-window", "-h", "-p 33", "-P", "-F", "#{pane_id}" }):gsub("%s+$", "")

    while vim.fn.system({ "tmux", "display-message", "-p", "-t", pane_id, "#{pane_current_command}" }):gsub("%s+$", "") ~= "zsh" do
        vim.wait(10)
    end

    vim.fn.system({ "tmux", "send-keys", "-t", pane_id, command, "Enter" })
end

local function watchexec(command)
    return "watchexec --clear --on-busy-update=queue -- " .. command
end


vim.keymap.set("n", "<leader>ss", function()
    local rspec_command = watchexec("bin/rspec " .. vim.fn.expand("%:o") .. ":" .. vim.fn.getpos(".")[2])
    split_and_run(rspec_command)
end)

vim.keymap.set("n", "<leader>sf", function()
    local rspec_command = watchexec("bin/rspec " .. vim.fn.expand("%:o"))
    split_and_run(rspec_command)
end)

-- A tab running the app (rails server, plus vite if the project has it), reused once started.
local server_tab

vim.keymap.set("n", "<leader>rs", function()
    if server_tab and vim.api.nvim_tabpage_is_valid(server_tab) then
        vim.api.nvim_set_current_tabpage(server_tab)
        return
    end
    vim.cmd("tabnew")
    server_tab = vim.api.nvim_get_current_tabpage()
    -- Bind to all interfaces so the browser on the host can reach a server in a devcontainer.
    vim.cmd.terminal("bin/rails server -b 0.0.0.0")
    if vim.fn.executable("bin/vite") == 1 then
        vim.cmd("vsplit")
        vim.cmd.terminal("bin/vite dev")
    end
end)

vim.keymap.set("n", "<leader>ob", function()
    vim.ui.open("http://" .. (vim.env.DVIM_HOST or "localhost") .. ":3000")
end)

vim.keymap.set("n", "<leader>sd", function()
    local rspec_command = "bin/rspec --dry-run --format documentation " .. vim.fn.expand("%:o")
    split_and_run(rspec_command)
end)
