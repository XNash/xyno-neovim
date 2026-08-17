local set = vim.keymap.set

set("i", "jk", "<Esc>")
set("n", "<leader>pv", vim.cmd.Ex)

set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")

set("n", "<leader>y", [["+y]])
set("v", "<leader>y", [["+y]])
set("n", "<leader>Y", [["+Y]])

set("n", "<leader>w", "<cmd>w<CR>")
set("n", "<leader>q", "<cmd>q<CR>")

set("n", "<C-h>", "<C-w>h")
set("n", "<C-j>", "<C-w>j")
set("n", "<C-k>", "<C-w>k")
set("n", "<C-l>", "<C-w>l")
