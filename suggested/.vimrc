" way to comment in `.vimrc`:
"     http://vim.wikia.com/wiki/Backing_up_and_commenting_vimrc#Commenting_vimrc

" set location for backup and temporary file (default is `.`)
" from: http://vim.wikia.com/wiki/Remove_swap_and_backup_files_from_your_working_directory
set backupdir=./.backup,/tmp,.
set directory=./.backup,/tmp,.

" set indentation for each filetypes
" may use `filetype plugin indent on` and additional files to reach same result
" from: http://vim.wikia.com/wiki/Indenting_source_code#Different_settings_for_different_file_types
autocmd FileType html setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType ruby setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType c setlocal shiftwidth=4 softtabstop=4
autocmd FileType cpp setlocal shiftwidth=4 softtabstop=4