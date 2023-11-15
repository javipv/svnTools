" Script Name: svnTools/vimdiff.vim
 "Description: 
"
" Copyright:   (C) 2017-2022 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: jobs.vim
"
"

"- functions -------------------------------------------------------------------


" Vimdiff single file. 
" Arg1: file to check, if empty use current file.
" Commands: Svnvdf
function! svnTools#vimdiff#File(file)
    let l:list = svnTools#status#GetStatusFilesList(a:file, '^M \|^A \|^D ')
    if len(l:list) == 0
        call svnTools#tools#Warn("[svnTools.vim] No modifications found.")
        return
    endif

    echo "This may take a while ..."
    "silent! call svnTools#diffTools#VimDiffFileRev(a:file,"","","")
    "
    if expand("%") == a:file && winnr('$') == 1
        " Open new tab to open both vimdiff files.
        call svnTools#diffTools#VimDiffThisFileRev(a:file,"","","")
    else
        " Use current buffer as left split for vertical vimddiff.
        call svnTools#diffTools#VimDiffFileRev(a:file,"","","")
    endif
    redraw
endfunction


" Simple Vimdiff on path 
" Arg1: file to check, if empty use current file.
" Commands: Svnvd, Svnvda, Svnvdd, SvnvdA.
function! svnTools#vimdiff#Path(path)
    echo "Getting modified files on ".a:path."..."

    let l:list = svnTools#status#GetStatusFilesList(a:path, '^[MAD] ')
    let l:n = len(l:list)

    if l:n == 0
        call svnTools#tools#Warn("[svnTools.vim] No modifications found")
        return
    elseif l:n > 1
        " Show the final list with the files to open with vimdiff.
        redraw
        echo "Modified Files:"
        for file in l:list 
            echo "- ".l:file
        endfor
        echo ""
    else
        " Only ONE file modified
        " Open vimdiff without asking user
        call svnTools#tools#WindowSplitMenu(3)
        call svnTools#tools#WindowSplit()
        echo "This may take a while ..."
        silent! call svnTools#diffTools#VimDiffFileRev(l:list[0],"","","")
        call svnTools#tools#WindowSplitEnd()
        return
    endif

    echo " "
    echo "Getting every file vimdiff..."
    echo ""

    " Perform svn diff on each selected file.
    " Open each file with vimdiff on new tab
    let l:n = 0
    for l:file in l:list 
        echo "- ".l:file
        silent! call svnTools#diffTools#VimDiffFileRev(l:file,"","","")
        let l:n += 1
    endfor

    redraw
    echo " "
    echo "[svnTools.vim] Show svn changes on ".a:path." using vimdiff. ".l:n." files."
endfunction


" Vimdiff path with advanced options 
" Arg: PATH. Path to check for changed files.
" Arg: [FLAGS]: 
"  ALL:show all files modified.
"  BO: show binaries only.
"  SB: skip binaries (default). 
"  EO: show equal files only.
"  SE: skip equal files (default). 
"  +KeepPattern: keep files matching pattern.
"  -SkipPattern: skip files matching pattern.
" Commands: SvnvD, SvnvDA, SvnvDD.
function! svnTools#vimdiff#PathAdv(...)
    if a:0 == 0 || join(a:000) =~# "help"
        echo "Get vimdiff changes on the selected path."
        echo "Arguments: PATH [FLAGS]"
        echo "- FLAGS: "
        echo "   B  (show binaries)."
        echo "   +keepFilePattern"
        echo "   -skipFilePattern" 
        if join(a:000) !~# "help"
            call svnTools#tools#Error("Missing arguments: PATH")
        endif
        return
    endif

    let l:path = ""
    let l:equals = "skip"

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

    if empty(glob(l:path) )
        call svnTools#tools#Error("Path not found ".l:path)
        return
    endif

    "----------------------------------------
    " Get files modified on subversion:
    "----------------------------------------
    echo "Getting modified files on ".l:path."..."
    let l:filesList = svnTools#status#GetStatusFilesList(l:path, '^[MAD] ')

    if len(l:filesList) == 0
        call svnTools#tools#Warn("[svnTools.vim] No modifications found")
        return []
    endif

    echo "Modified Files:"
    for l:file in l:filesList 
        echo "- ".l:file
    endfor
    echo " "
    if len(l:filesList) == 0
        call svnTools#tools#Warn("No files found.")
        return
    endif
    echo "Found ".len(l:filesList)." modified files"
    call confirm("continue?")

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
    "redraw
    echo "[svnTools.vim] Filter files on: '".l:path
    let l:filesList = svnTools#misc#FilterFilesListWithArgsList(a:000, l:filesList, l:path, "")

    echo "Files to open compare with head revision: ".len(l:filesList)
    call confirm("Perform vimdiff on this ".len(l:filesList)." files?")


    "----------------------------------------
    " Get the subversion file and perform vimdiff with current one.
    "----------------------------------------
    echo "Getting every file vimdiff..."
    let l:n = 0
    for l:file in l:filesList 
        echo "- ".l:file." vimdiff"
        silent! call svnTools#diffTools#VimDiffFileRev(l:file,"","","")

        " Check if there are differences between both windows.
        "if foldclosed('.') != -1 && foldclosedend('.') != -1
            "let l:filesEqual = 1
        "else
            "let l:filesEqual = 0
        "endif

        "if l:equals == "skip" && l:fileEqual == 1
            "call svnTools#tools#Warn("Closing: ".expand("%").". No changes found.")
            "tabclose
        "endif
        "if l:equals == "only" && l:fileEqual == 0
            "call svnTools#tools#Warn("Closing: ".expand("%").". Changes found.")
            "tabclose
        "endif
        let l:n += 1
    endfor

    "redraw
    echo " "
    echom "[svnTools.vim] Show svn changes on ".l:path." using vimdiff. ".l:n." files found."
endfunction


" Vimdiff current file with the selected revision 
" Arg1: revision number
" Arg2: file to check, if empty use current file.
function! s:VimdiffRev(rev,file)
    let l:confirm = ""

    if a:file == ""
        let l:file = expand('%')
    else
        let l:file = a:file
    endif

    if l:file == ""
        call svnTools#tools#Warn("File path not found")
        return
    endif

    if a:rev == ""
        let l:rev = expand('<cword>')
        let l:confirm = "yes"
    else
        let l:rev = a:rev
    endif

    if l:rev == ""
        call svnTools#tools#Warn("Revision number not found")
        return
    endif

    if l:confirm != ""
        if confirm("Check file: ".l:file,"Rev: ".l:rev."? &yes\n&no\n",2) == 2
            return
        endif
    endif

    echo "This may take a while ..."
    call svnTools#tools#WindowSplitMenu(3)
    call svnTools#tools#WindowSplit()
    call svnTools#diffTools#VimDiffFileRev(l:file,l:rev,"","")
    call svnTools#tools#WindowSplitEnd()
endfunction


" Vimdiff current file with the selected revision 
" Arg1: revision number
" Arg2: file to check, if empty use current file.
function! s:VimdiffRev(rev,file)
    let l:confirm = ""

    if a:file == ""
        let l:file = expand('%')
    else
        let l:file = a:file
    endif

    if l:file == ""
        call svnTools#tools#Warn("File path not found")
        return
    endif

    if a:rev == ""
        let l:rev = expand('<cword>')
        let l:confirm = "yes"
    else
        let l:rev = a:rev
    endif

    if l:rev == ""
        call svnTools#tools#Warn("Revision number not found")
        return
    endif

    if l:confirm != ""
        if confirm("Check file: ".l:file,"Rev: ".l:rev."? &yes\n&no\n",2) == 2
            return
        endif
    endif

    echo "This may take a while ..."
    call svnTools#tools#WindowSplitMenu(3)
    call svnTools#tools#WindowSplit()
    call svnTools#diffTools#VimDiffFileRev(l:file,l:rev,"","")
    call svnTools#tools#WindowSplitEnd()
endfunction


" On a unified diff file. Extract file path and revision number
" Parse the file and perform diff between the paths found starting with
" string: --- or string: +++.
" Diff line format expected:
" Ex: 
" --- path/file.cpp	(revision 188593)
" +++ path/file.cpp	(revision 188594)
let s:DiffFile = ""
let s:DiffRev = ""

function! s:DiffGetFileRev()
    let s:DiffFile = ""
    let s:DiffRev = ""

    normal 0yiW
    let l:tmp = @"
    if l:tmp != "---" && l:tmp != "+++"
        call svnTools#tools#Warn("Diff line format '".l:tmp."' unknown")
        return 1
    endif

    if l:tmp =~ "revision" | return 1 | endif

    normal wyiW
    if @" == "" | return 1 | endif
    let s:DiffFile = @"

    normal Wwwyiw
    if @" == "" || @" == ")" || @" == "copy" | return 1 | endif
    let s:DiffRev = @"

    return 0
endfunction


" On a unified diff file and current line with format Ex:
" --- path/file.cpp	(revision 188593)
"  or
" +++ path/file.cpp	(revision 188594)
"
" Open vimdiff with file path and revision number
function! s:VimdiffRevDiffFile()
    let l:rev0 = ""
    let l:rev1 = ""

    if s:DiffGetFileRev() == 1
        call svnTools#tools#Warn("Revision number not found")
        return 1
    endif

    let match = matchstr(getline('.'), '.*--- ') " regex match
    if(!empty(match))
        let l:rev0 = s:DiffRev
        normal j
    else
        let l:rev1 = s:DiffRev
        normal k
    endif

    if s:DiffGetFileRev() == 1
        call svnTools#tools#Warn("Revision number not found")
        return 1
    endif

    let match = matchstr(getline('.'), '.*+++ ') " regex match
    if(!empty(match))
        let l:rev1 = s:DiffRev
    else
        let l:rev0 = s:DiffRev
    endif

    if confirm("Vimdiff file: ".s:DiffFile,"Rev: ".l:rev0.":".l:rev1."? &yes\n&no\n",2) == 2
        return
    endif
    call svnTools#diffTools#VimDiffFileRev(s:DiffFile,l:rev0,l:rev1,"")
    return 0
endfunction


" On a unified diff file. Search all lines starting on --- and get the
" filename and revision number, then perform vimdiff.
" Ex: line format:
" --- path/file.cpp	(revision 188593)
function! s:VimdiffRevDiffAll()
    echo "Perform vimdiff on each modified file:"
    let l:list = [ ]
    if l:dir = ""

    let file = readfile(expand("%:p")) " read current file
    let cmd = "" | let File = "" | let rev = ""
    for line in file
        let match = matchstr(line, '.*--- ') " regex match
        if(!empty(match))
            if l:cmd != ""
                echo " - Diff: ".l:cmd
                call insert(l:list, l:cmd)
                let File = ""
                let rev = ""
            endif

            new
            setlocal bt=nofile
            let @a = l:line
            put! a
            normal ggdd0

            if s:DiffGetFileRev() == 0
                let cmd = s:DiffFile." ".s:DiffRev
                let File = s:DiffFile
                let rev = s:DiffRev
            endif
            silent! execute 'bd!'
        endif

        let match = matchstr(line, '.*+++ ') " regex match
        if(!empty(match))
            new
            setlocal bt=nofile
            let @a = l:line
            put! a
            normal ggdd0

            if s:DiffGetFileRev() == 0
                if l:rev != "" && l:File == s:DiffFile
                    let cmd .= " ".s:DiffRev
                    let dir = s:DiffRev
                endif
            endif
            silent! execute 'bd!'
        endif

        " Goto first change line.
        normal gg0
        normal ]c
    endfor

    if l:cmd != ""
        echo " - Diff: ".l:cmd
        call insert(l:list, l:cmd)
    endif

    if len(l:list) <= 0 
        call svnTools#tools#Warn("[svnTools.vim] No modifications found")
        return
    endif

    let l:saveDir = ""
    if l:dir != ""
        if confirm("","Save/get dir: _r".l:dir."? &yes\n&no\n",2) == 1 
            " Create new directory named after with revision number
            let l:saveDir = "_r".l:dir
            if !isdirectory(l:saveDir)
                call mkdir(l:saveDir)
            endif
        endif
    endif

    let l:open = 1
    for cmd in l:list 
        let args  = split(l:cmd, " ") 
        let file  = get(l:args, 0, "")
        let rev0  = get(l:args, 1, "")
        let rev1  = get(l:args, 2, "")

        if l:open != 3
            echo ""
            let l:open = confirm("Vimdiff: ".l:file,"Rev: ".l:rev0."/".l:rev1."? &yes\n&no\nopen &all\n",1)
            if  l:open == 2 | continue | endif
        endif

        call svnTools#diffTools#VimDiffFileRev(l:file,l:rev0,l:rev1,l:saveDir)
    endfor

    if l:saveDir != ""
        " Save current vim session
        exec("mksession! ".l:saveDir."/vdiff.vim")
    endif
endfunction


" Perform vimdiff on all modified files on revision2 with the same files on revision1
" When no revision number provided as argument, try get word under cursor as the
" revision number.
" When REV2 not provided set REV2=REV1, and dreacrese REV1.
" Arg1: [optional] revision1
" Arg2: [optional] revision2
" Cmd: Svnvdr
function! svnTools#vimdiff#RevisionsCompare(...)
    let rev1 = ""
    let rev2 = ""

    if a:0 >= 2
        let rev1 = a:1
        let rev2 = a:2
    elseif a:0 == 1
        let rev2 = a:1
    else
        let rev2 = expand("<cword>")
    endif

    if l:rev2 == ""
        call svnTools#tools#Error("Missing revision number")
        return
    endif

    let rev2 = substitute(l:rev2, '[^0-9]*', '', 'g')
    if l:rev2 == ""
        call svnTools#tools#Error("Wrong revision number ". l:rev2)
        return
    endif

    if l:rev1 == ""
        let l:rev1 = l:rev2 -1
    else
        let rev1 = substitute(l:rev1, '[^0-9]*', '', 'g')
        if l:rev1 == ""
            call svnTools#tools#Error("Wrong revision number ". l:rev1)
            return
        endif
    endif

    " Get diff file
    echo "Getting r". l:rev2 ." log and diff..."
    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    " On Subversion versions after 1.7:
    let command  = l:svnCmd." log -vr ".l:rev2." --diff" 
    "let command  = "svn log -vr ".l:rev2." --diff" 
    let text = system(l:command)

    " Extract from diff file, the list of modified files.
    tabnew
    put=l:text
    normal ggdd
    let l:list = svnTools#diffFile#GetModifiedFilesList()
    silent! exec("0file")
    silent! exec("file! _r". l:rev2 .".diff")
    set ft=diff
    normal gg
  
    redraw
    for file in l:list
        echo l:file
    endfor
    call confirm(len(l:list) ." modified files found. Continue?")

    " Perform vimdiff for each file and revision.
    redraw
    echo "Opening ". l:rev1 .":". l:rev2 ." modifications with vimdiff:"
    for file in l:list
        echo "- ". l:file
        silent call svnTools#diffTools#VimDiffFileRev(l:file, l:rev1, l:rev2, 0)
    endfor
endfunction


