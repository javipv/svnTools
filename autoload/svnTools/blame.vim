" Script Name: svnTools/blame.vim
 "Description: 
"
" Copyright:   (C) 2017-2021 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: jobs.vim
"
"

"- functions -------------------------------------------------------------------


" Svn blame and Svn blame -v
" Commands: Svnbl, Svnblv.
function! svnTools#blame#Blame(opt)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let file = expand("%")
    let name = expand("%:t")
    let path = expand("%:h")

    let pos = line('.')
    let ext = svnTools#tools#GetSyntax()

    let path = svnTools#tools#PathToFile(l:path)
    let name = "_svnBlame_".l:path.".".l:ext

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let l:command  = l:svnCmd." blame ".a:opt." ".l:file
    let l:callback = ["svnTools#blame#BlameEnd", a:opt, l:pos, l:ext, l:name]

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#SystemCmd0(l:command, l:callback, 1)
endfunction

function! svnTools#blame#BlameEnd(opt,pos,ext,name,resfile)
    if exists('a:resfile') && !empty(glob(a:resfile)) 
        " On vertical split synchronize scroll
        if exists('w:split')
            if w:split == 2 | set crb! | endif
        endif

        let l:split = w:split
        let l:winh = winheight(0)
        if l:split == 1 || split == 2
            " synchronize scroll and cursor
            set cursorbind
            set scrollbind
        endif
        call svnTools#tools#WindowSplit()
        put = readfile(a:resfile)

        " Set syntax highlight
        silent exec("set ft=".a:ext)

        " Restore previous position
        silent exec("normal ".a:pos."G")
        silent exec("normal zz")

        " Rename buffer
        silent! exec("0file")
        silent! exec("bd! ".a:name)
        silent! exec("file! ".a:name)
        call svnTools#tools#WindowSplitEnd()

        if l:split == 1 || split == 2
            " synchronize scroll and cursor
            set cursorbind
            set scrollbind

            " Autocommand to reset cursor and scroll sync on buffer exit.
            silent exec("silent! autocmd! BufLeave ".a:name." call s:BlameExit()")
        endif

        " Restore previous position
        silent exec("normal ".a:pos."G")

        if l:split == 1 " Horizontal split:
            " Resize to half original window: 
            silent exe "resize ".l:winh/2
        elseif l:split == 2 " Vertical split:
            " Check resize widht: search where position of first character ')'
            if a:opt =~ "v"
                silent normal 0f)
            else
                silent normal 03W
            endif
            let l:width = col('.')
            " Resize window
            let l:winw = winwidth(0)
            if l:winw > l:width
                echom "resize to ".l:width
                silent exe "vertical resize ".l:width
            endif
            silent normal 0
        endif
        redraw
    else
        call svnTools#tools#Warn("Svn blame empty")
    endif
endfunction


" Reset cursor and scroll bind on buffer exit.
function! s:BlameExit()
    windo set noscb
    windo set nocrb
endfunction



