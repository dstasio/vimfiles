vim.cmd('source ~/.vimrc')

if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    -- vim.o.guifont = "Source Code Pro:h14" -- text below applies for VimScript

    vim.g.neovide_padding_bottom = 50

    -- vim.g.neovide_transparency = 0.7
    vim.g.neovide_scroll_animation_length = 0.15

    -- lower to preserve battery life?
    -- vim.g.neovide_refresh_rate = 60
    -- vim.g.neovide_refresh_rate_idle = 5
    -- vim.g.neovide_cursor_antialiasing = true


    vim.g.neovide_cursor_animation_length = 0.01
    -- vim.g.neovide_cursor_trail_size       = 0.08


    -- vim.g.neovide_cursor_unfocused_outline_width = 0.125
end -- Neovide Config


