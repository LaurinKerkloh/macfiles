-- Only active when nvim runs as a dvim server inside a devcontainer (see ~/.local/bin/dvim).
if vim.env.DVIM ~= "1" then
    return
end

-- The UI runs on the host, so the clipboard has to go through the terminal.
vim.g.clipboard = "osc52"

-- Each server belongs to one dvim pane: once no UI is attached anymore, exit.
local function quit_if_detached()
    if #vim.api.nvim_list_uis() > 0 then
        return
    end
    local modified = vim.iter(vim.api.nvim_list_bufs()):any(function(buf)
        return vim.bo[buf].modified
    end)
    if modified then
        -- Exit without cleanup so the swap files of unsaved buffers stay around for recovery.
        vim.cmd("silent! preserve")
        vim.uv.kill(vim.uv.os_getpid(), "sigkill")
    else
        vim.cmd("qall!")
    end
end

vim.api.nvim_create_autocmd("UILeave", {
    callback = function()
        vim.schedule(quit_if_detached)
    end,
})

-- Don't leave a server behind if its client never managed to attach.
vim.defer_fn(quit_if_detached, 30000)
