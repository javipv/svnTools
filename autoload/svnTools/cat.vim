" Script Name: svnTools/cat.vim
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


"- functions -------------------------------------------------------------------



" Get the current file's selected svn revision.
" Arg1: revision number to search.
" Commands: SvnCatRev, Svncr.
function! svnTools#cat#GetRevision(rev)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:file = expand("%")
    let l:ext = expand("%:e")
    let l:name = expand("%:t")

    if a:rev == ""
        let l:rev = substitute(expand("<cword>"), 'r', '', '')
    else
        let l:rev = substitute(a:rev, 'r', '', '')
    endif
    if l:rev == ""
        call svnTools#tools#Warn("Argument 1: revision number not found.")
        return
    endif
    let file = "r".l:rev.".diff"
    let filepath = expand("%")
    let filename = expand("%:t:r")

    echo "Get file: ".l:filename." revision: ".l:rev

    call svnTools#tools#WindowSplitMenu(3)
    call svnTools#tools#WindowSplit()

    echo "svn cat -r ".l:rev." ".l:filepath
    echo "This may take a while ..."

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    exec("r! ".l:svnCmd." cat -r ".l:rev." ".l:filepath)
    "exec("r! svn cat -r ".l:rev." ".l:filepath)

    if line('$') == 1
        call svnTools#tools#WindowSplitEnd()
        call svnTools#tools#Warn("Not found")
        return
    endif

    call svnTools#tools#SetSyntax(l:ext)

    silent exec("0file")
    silent! exec("file _svnCat_".l:name."_r".l:rev.".".l:ext)

    call svnTools#tools#WindowSplitEnd()
endfunction


