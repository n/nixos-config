set nocompatible

" Color scheme
colorscheme slate
set background=dark

" Line numbers
set number
set relativenumber
set ruler

" Indent settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set smartindent " next line indents same as previous

" Disable line wrap
set nowrap

" Backup settings
set noswapfile
set nobackup
set undodir=$HOME/.vim/undo " `mkdir -p ~/.vim/undo`
set undofile

" Search settings
set hlsearch    " highlight matches
set incsearch   " incremental searching
set showmatch   " show matching braces ...
set matchtime=3 " ... for 3 seconds
set ignorecase  " searches are case insensitive ...
set smartcase   " ... unless they contain at lease one capital letter
set scrolloff=10 " 10 lines after search result

" Code settings
syntax on
filetype on
set colorcolumn="80"
autocmd BufNewFile,BufRead * setlocal formatoptions-=cro " Disable continuation of comments for next line

" MacVim settings
if has("gui_running")
    let macvim_skip_colorscheme=1
	set guifont=SF\ Mono:h14 " Font must be installed
	set go-=T                " Disable menu bar
	set lines=60 columns=80  " Window size
	set guioptions=aAace     " Don't show scrollbar in MacVim
endif
