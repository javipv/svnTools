" Script Name: svnTools/diff.vim
 "Description: 
"
" Copyright:   (C) 2017-2022 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: jobs.vim, svn.
"
"

"- functions -------------------------------------------------------------------


" Svn diff file/path 
" Command: Svnd, Svndf, Svnda, Svndd, SvndA
function! svnTools#diff#Diff(path)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:date = strftime("%y%m%d_%H%M")

    let l:path = svnTools#tools#PathToFile(a:path)
    if l:path != ""
        let l:path = "_".l:path
    endif

    let name = "_".l:date."_svnDiff".l:path.".diff"

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let command  = l:svnCmd." --non-interactive diff --diff-cmd=diff ".a:path
    "let command  = g:svnTools_svnCmd." --non-interactive diff --diff-cmd=diff ".a:path
    let callback = ["svnTools#diff#SvnDiffEnd", l:name]

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#SystemCmd0(command,callback,1)
    redraw
endfunction


function! svnTools#diff#SvnDiffEnd(name,resfile)
    if !exists('a:resfile') || empty(glob(a:resfile)) 
        call svnTools#tools#Warn("Svn diff empty")
    endif

    call svnTools#tools#WindowSplit()
    put = readfile(a:resfile)
    silent  exec("set syntax=diff")

    " Rename buffer
    silent! exec("0file")
    silent! exec("bd! ".a:name)
    silent! exec("file! ".a:name)
    normal gg
    let @/ = '^+ \|^- '
    call svnTools#tools#WindowSplitEnd()
endfunction


" Svn diff file/path with advanced options
" Arg: PATH. Path to check for changed files.
" Arg: [FLAGS]: 
"  ALL:show all files modified.
"  BO: show binaries only.
"  SB: skip binaries (default). 
"  EO: show equal files only.
"  SE: skip equal files (default). 
"  +KeepPattern: keep files matching pattern.
"  -SkipPattern: skip files matching pattern.
" Command: SvnD, SvnDA, SvnDD.
function! svnTools#diff#DiffAdv(...)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    if a:0 == 0 || join(a:000) =~# "help"
        echo "Get diff changes on the selected path."
        echo "Arguments: PATH [FLAGS]"
        echo "- FLAGS: "
        echo "   B (show binaries)."
        echo "   +keepFilePattern"
        echo "   -skipFilePattern" 
        if join(a:000) !~# "help"
            call svnTools#tools#Error("Missing arguments: PATH")
        endif
        return
    endif

    let l:equals = "skip"
    let l:path = ""

    for l:arg in a:000
        if l:arg ==? "BO" || l:arg ==? "SB" || l:arg[0] == '+' || l:arg[0] == '-'
            " Arguments meant for: svnTools#misc#FilterFilesListWithArgsList
        elseif l:arg ==? "ALL"
            let l:equals = ""
        elseif l:arg ==? "EO"
            let l:equals = "only"
        elseif l:arg ==? "SE"
            let l:equals = "skip"
        elseif !empty(glob(l:arg))
            let l:path .= l:arg." "
            let l:path = substitute(l:path,'^\s\+','','g')
            let l:path = substitute(l:path,'\s\+$','','g')
        else
            call svnTools#tools#Warn("Unknown argument: ".l:arg)
            call confirm("Continue?")
        endif
    endfor

    if empty(glob(l:path)) 
        call svnTools#tools#Error("Path not found ".l:path)
        return
    endif

    let name = "_svnDiff_".l:path.".diff"
    echo ""

    "----------------------------------------
    " Get files modified on subversion:
    "----------------------------------------
    echo "Getting modified files on ".l:path."..."
    let l:filesList = svnTools#status#GetStatusFilesList(l:path, '^[MAD] ')

    if len(l:filesList) == 0
        call svnTools#tools#Warn("[svnTools.vim] No modifications found")
        return
    endif

    redraw
    echo "Modified Files:"
    for l:file in l:filesList 
        echo "- ".l:file
    endfor
    echo " "
    echo "Found ".len(l:filesList)." modified files"

    "call confirm("Perform diff on this ".len(l:filesList)." files?")
    call confirm("continue?")
    redraw


    "----------------------------------------
    " Filter files:
    " Filter acording to flags on arguments list, keep/skip binaries/equal-files/match-patterns.
    " Flags:
    "  ALL:show all files modified.
    "  BO: show binaries only.
    "  SB: skip binaries (default). 
    "  EO: show equal files only.
    "  SE: skip equal files (default). 
    "  +KeepPattern: keep files matching pattern.
    "  -SkipPattern: skip files matching pattern.
    "----------------------------------------
    redraw
    echo "[svnTools.vim] Filter files on: '".l:path
    let l:filesList = svnTools#misc#FilterFilesListWithArgsList(a:000, l:filesList, l:path, "")

    echo "Files to open compare with head revision: ".len(l:filesList)
    call confirm("Perform diff on this ".len(l:filesList)." files?")


    "----------------------------------------
    " Get the svn diff for all files.
    "----------------------------------------
    echo "Getting every file diff..."

    let l:svnCmd  = g:svnTools_svnCmd
    let command  = l:svnCmd." --non-interactive diff --diff-cmd=diff ".join(l:filesList)
    let callback = ["svnTools#diff#SvnDiffEnd", l:name]

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#SystemCmd0(command,callback,1)
    redraw
    echo "[svnTools.vim] Show svn changes on ".l:path." using diff. ".len(l:filesList)." files found."
endfunction

