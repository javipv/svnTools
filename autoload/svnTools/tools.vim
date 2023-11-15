" Script Name: svnTools.vim
 "Description: 
"
" Copyright:   (C) 2017-2021 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: jobs.vim, jpLib.vim(optional)
"
" NOTES:
"

"- functions -------------------------------------------------------------------

" Check if the repository is available
" Return: 1 if available otherwhise return 0.
function! svnTools#tools#isSvnAvailable()
    let l:svnCmd = g:svnTools_svnCmd
    let l:desc   = system(l:svnCmd." info")
    let l:desc   = substitute(l:desc,'','','g')
    let l:desc   = substitute(l:desc,'\n','','g')
    if l:desc =~ "E155007" || l:desc =~ "not a working copy"
        return l:desc
    else
        return 1
    endif
endfunction


function! svnTools#tools#CheckSvnUserAndPsswd()
    if g:svnTools_userAndPsswd == 0
        return
    endif

    " Get svn user:
    if g:svnTools_svnUser == ""
        let g:svnTools_svnUser = input("Svn user: ")
    endif
    if g:svnTools_svnUser == ""
        call svnTools#tools#Error("Not valid svn user.")
        return
    endif

    " Get svn password:
    let l:tmp = ""
    if exists("g:svnTools_tmp")
        if g:svnTools_tmp != ""
            let l:tmp = g:svnTools_tmp
        endif
    endif
    " Set svn password:
    if l:tmp == ""
        let l:tmp = inputsecret("Svn user: ".g:svnTools_svnUser.". Enter password: ")
        if g:svnTools_storeSvnPsswd == 1
            echo ""
            echo ""
            echo "[svnTools.vim] Svn password set for current session."
            let g:svnTools_tmp = l:tmp
        endif
    endif
    if l:tmp == ""
        call svnTools#tools#Error("Not valid svn password.")
        return
    endif

    return " --non-interactive --no-auth-cache --username ".g:svnTools_svnUser." --password ".l:tmp
endfunction


" Set upser and password
" Command: Svnpwd
function! svnTools#tools#SetUserAndPsswd()
    if g:svnTools_svnUser != ""
        if confirm("Change svn user: ".g:svnTools_svnUser."?", "&yes\n&no", 2) == 1
            let g:svnTools_svnUser = ""
        endif
        echo ""
        echo ""
    endif
    silent! unlet g:svnTools_tmp
    call svnTools#tools#CheckSvnUserAndPsswd()
endfunction


function! svnTools#tools#Error(mssg)
    echohl ErrorMsg | echom "[SvnTools] ".a:mssg | echohl None
endfunction


function! svnTools#tools#Warn(mssg)
    echohl WarningMsg | echom a:mssg | echohl None
endfunction


function! svnTools#tools#SetLogLevel(level)
    let s:LogLevel = a:level
endfunction


" Debug function. Log message
function! svnTools#tools#LogLevel(level,func,mssg)
    if s:LogLevel >= a:level
        echom "[SvnTools : ".a:func."] ".a:mssg
    endif
endfunction


" Debug function. Log message and wait user key
function! svnTools#tools#LogLevelStop(level,func,mssg)
    if s:LogLevel >= a:level
        call input("[SvnTools : ".a:func."] ".a:mssg." (press key)")
    endif
endfunction


func! svnTools#tools#Verbose(level)
    if a:level == ""
        call s:LogLevel(0, expand('<sfile>'), "Verbose level: ".s:LogLevel)
        return
    endif
    let s:LogLevel = a:level
    call svnTools#tools#LogLevel(0, expand('<sfile>'), "Set verbose level: ".s:LogLevel)
endfun


function! svnTools#tools#SetSyntax(ext)
    if a:ext == "h"
        let l:ext = "cpp"
    elseif a:ext == "hpp"
        let l:ext = "cpp"
    else
        let l:ext = a:ext
    endif
    "silent exec("set syntax=".l:ext)
    silent exec("set ft=".l:ext)
endfunction


function! svnTools#tools#GetSyntax()
    let l:ext = expand("%:e")
    if l:ext == "h"
        return "cpp"
    elseif l:ext == "hpp"
        return "cpp"
    else
        return l:ext
    endif
endfunction


function! svnTools#tools#WindowSplitMenu(default)
    let w:winSize = winheight(0)
    "echo "w:winSize:".w:winSize | call input("continue")
    let text =  "split hor&izontal\n&split vertical\nnew &tab\ncurrent &window"
    let w:split = confirm("", l:text, a:default)
    redraw
    call svnTools#tools#LogLevel(1, expand('<sfile>'), "Choosed split:".w:split)
endfunction


function! svnTools#tools#WindowSplit()
    if !exists('w:split')
        return
    endif

    let l:split = w:split
    let l:winSize = w:winSize

    call svnTools#tools#LogLevel(1, expand('<sfile>'), "New split:".w:split)

    if w:split == 1
        silent exec("sp! | enew")
    elseif w:split == 2
        silent exec("vnew")
    elseif w:split == 3
        silent exec("tabnew")
    elseif w:split == 4
        silent exec("enew")
    endif

    let w:split = l:split
    let w:winSize = l:winSize
endfunction


function! svnTools#tools#WindowSplitEnd()
    if exists('w:split')
        if w:split == 1
            if exists('w:winSize')
                "echo "w:winSize:".w:winSize | call input("continue")
                let lines = line('$') + 2
                if l:lines <= w:winSize
                    "echo "resize:".l:lines | call input("continue")
                    exe "resize ".l:lines
                else
                    "echo "resize:".w:winSize | call input("continue")
                    exe "resize ".w:winSize
                endif
            endif
            exe "normal! gg"
        endif
    endif
    silent! unlet w:winSize
    silent! unlet w:split
endfunction


function! svnTools#tools#PathToFile(path)
    if a:path == ""
        return ""
    endif
    let path = a:path
    let path = substitute(path, getcwd(), '', 'g')
    let path = substitute(path, '/', '_', 'g')
    let path = substitute(path, '-$', '', '')
    let path = substitute(path, '_-', '', '')
    let path = substitute(path, '-_', '', '')
    return l:path
endfunction


function! svnTools#tools#SystemCmd0(command,callback,async)
    if !exists("g:VimJobsLoaded")
        call svnTools#tools#Error("Plugin jobs.vim not loaded.")
        return
    endif

    let jobName = "svnTools"

    if g:svnTools_runInBackground == 0 || a:async == 0
        let l:async = 0
    else
        let l:async = 1
    endif
    if g:svnTools_userAndPsswd != 1
        let cmd = "let @a = \"".a:command."\" \| normal G! \| exec(\"put a\")"
        call histadd(':', l:cmd)
    endif
    call jobs#RunCmd(a:command,a:callback,l:async,l:jobName)
endfunction


function! svnTools#tools#SystemCmd0(command,callbackList,async)
    if !exists("g:VimJobsLoaded")
        call svnTools#tools#Error("Plugin jobs.vim not loaded.")
        return
    endif

    let jobName = "svnTools"

    if g:svnTools_runInBackground == 0 || a:async == 0
        let l:async = 0
    else
        let l:async = 1
    endif
    
    " Do not add command with user password from history
    if g:svnTools_userAndPsswd != 1
        let cmd = "let @a = \"".a:command."\" \| normal G! \| exec(\"put a\")"
        call histadd(':', l:cmd)
    endif
    call jobs#RunCmd0(a:command,a:callbackList,l:async,l:jobName)

endfunction


"- initializations ------------------------------------------------------------

let s:LogLevel = 0

