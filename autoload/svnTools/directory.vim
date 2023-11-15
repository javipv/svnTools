" Script Name: svnTools/directory.vim
 "Description: 
"
" Copyright:   (C) 2017-2022 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: 
"


"- functions -------------------------------------------------------------------


" Using svn st get the files changed/added/removed on path1 and path2
" Perform vimdiff on all files changed/added/remove between both paths.
" Arg: MODE. diff or vimdiff.
" Arg: [PATH1]. primary file/path to check for changes, if empty use current WD.
" Arg: PATH2 secondary sandbox path to compare changes. 
" Arg: [FLAGS]:
"  ALL:show all files modified.
"  BO:  show binaries only.
"  SB: skip binaries (default). 
"  EO: show equal files only.
"  SE: skip equal files (default). 
"  C1: compare only with svn changes on path1. 
"  C2: compare only with svn changes on path2. 
" Cmd: Svndc, Svnvdc.
function! svnTools#directory#CompareChanges(...)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    if a:0 < 2 || join(a:000) =~# "help"
        echo "Get all the files changed on the provided directories and compare them."
        echo "Handy to compare two sandboxes."
        echo "Arguments: MODE [PATH1] PATH2 [FLAGS]"
        echo "- MODE: diff or vimdiff."
        echo "- FLAGS: ALL (open all files, even equal or binaries)"
        echo "         EO (show equal files only), BO (show binaries only), SB (skip binaries) SE (skip equal)"
        echo "         C1 (check only path1 changes), C2 (check only path2 changes)"
        if join(a:000) !~# "help"
            call svnTools#tools#Error("Missing arguments: PATH")
        endif
        return
    endif

    let l:mode  = "diff"
    let l:path1 = ""
    let l:path2 = ""
    let l:path1Changes = "yes"
    let l:path2Changes = "yes"

    for l:arg in a:000
        if l:arg ==? "ALL" || l:arg ==? "BO" || l:arg ==? "SB" || l:arg ==? "EO" || l:arg ==? "SE" || l:arg[0] == '+' || l:arg[0] == '-'
            " Arguments meant for: svnTools#misc#FilterFilesListWithArgsList
        elseif l:arg ==? "C1"
            let l:path1Changes = "yes"
            let l:path2Changes = "no"
        elseif l:arg ==? "C2"
            let l:path1Changes = "no"
            let l:path2Changes = "yes"
        elseif l:arg == 'diff'
            let l:mode = "diff"
        elseif l:arg == 'vimdiff'
            let l:mode = "vimdiff"
        elseif !empty(glob(l:arg))
            if l:path1 == ""
                let l:path1 = l:arg
                let l:path1 = substitute(l:path1,'^\s\+','','g')
                let l:path1 = substitute(l:path1,'\s\+$','','g')
            else
                if l:path2 == ""
                    let l:path2 = l:arg
                    let l:path2 = substitute(l:path2,'^\s\+','','g')
                    let l:path2 = substitute(l:path2,'\s\+$','','g')
                else
                    call svnTools#tools#Warn("Path1 and Path2 already set. Skipping path: ".l:arg)
                    call confirm("Continue?")
                endif
            endif
        else
            call svnTools#tools#Warn("Unknown argument: ".l:arg)
            call confirm("Continue?")
        endif
    endfor

    if l:path1 == "./"
        let l:path1 = getcwd()
    endif
    if l:path2 == "./"
        let l:path2 = getcwd()
    endif

    if l:path1 != "" && l:path2 == ""
        let l:path2 = l:path1
        let l:path1 = getcwd()
        echohl DiffChange
        echo "Argument path2 missing. Using CWD ".l:path1." as path1."
        echohl None
    endif

    if l:path1 == "" || empty(glob(l:path1))
        call svnTools#tools#Error("Path1 not found ".l:path1)
        return
    endif
    if l:path2 == "" || empty(glob(l:path2))
        call svnTools#tools#Error("Path2 not found ".l:path2)
        return
    endif

    "----------------------------------------
    " Get path1 and/or path2 svn changes
    "----------------------------------------
    let l:tmpList = []

    echo  "Comparing changes between: '".l:path1."' and: '".l:path2."' "
    if l:path1Changes == "yes" && l:path2Changes == "no"
        echo " * C1: search only files changed on path1: ".l:path1
    elseif l:path1Changes == "no" && l:path2Changes == "yes"
        echo " * C2: search only files changed on path2: ".l:path2
    endif

    if l:path1Changes != "yes" && l:path2Changes != "yes"
        call svnTools#tools#Error("No path selected")
        return
    endif

    if l:path1Changes == "yes"
        echo " "
        echo "Searching files modified on: ".l:path1
        echo "This may take a while ..."

        " Get files changed on svn for path1
        let l:st1 = svnTools#status#GetStatusFilesString(l:path1, '^M\|^A\|^D')
        if l:st1 == ""
            echo "Files modified: none (".l:path1.")"
        else
            let l:st1 = substitute(l:st1, l:path1."/", '', 'g')
            let l:st1 = substitute(l:st1, l:path1, '', 'g')
            let l:tmpList1 = split(l:st1," ")
            let l:tmpList += l:tmpList1
            call svnTools#tools#LogLevel(1, expand('<sfile>'), "Dir1:  ".l:path1)
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "Files: ".l:st1)
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "")

            if len(l:tmpList1) == 0
                echo "Files modified: none (".l:path1.")"
            else
                echo "Files modified: ".len(l:tmpList1)." (".l:path1.")"
            endif
        endif
    endif

    if l:path2Changes == "yes"
        echo " "
        echo "Searching files modified on: ".l:path2
        echo "This may take a while ..."

        " Get files changed on svn for path2
        let l:st2 = svnTools#status#GetStatusFilesString(l:path2, '^M\|^A\|^D')
        if l:st2 == ""
            echo "Files modified: none (".l:path2.")"
        else
            let l:st2 = substitute(l:st2, l:path2."/", '', 'g')
            let l:st2 = substitute(l:st2, l:path2, '', 'g')
            let l:tmpList2 = split(l:st2," ")
            let l:tmpList += l:tmpList2
            call svnTools#tools#LogLevel(1, expand('<sfile>'), "Dir2:  ".l:path2)
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "Files: ".l:st2)
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "")

            if len(l:tmpList2) == 0
                echo "Files modified: none (".l:path2.")"
            else
                echo "Files modified: ".len(l:tmpList2)." (".l:path2.")"
            endif
        endif
    endif

    echo " "

    if len(l:tmpList) == 0
        echo ""
        call svnTools#tools#Warn("[svnTools.vim] No modifications found")
        call input("")
        return
    endif

    if l:path1Changes == "yes" && l:path2Changes == "yes"
        " Remove duplicated files
        " Sort files
        let l:sortedList = sort(copy(l:tmpList))
        call svnTools#tools#LogLevel(2, expand('<sfile>'), "Files sorted: ".join(l:sortedList))
        call svnTools#tools#LogLevel(2, expand('<sfile>'), "")
        " Uniq files
        let l:filesList = filter(copy(l:sortedList), 'index(l:sortedList, v:val, v:key+1)==-1')
        call svnTools#tools#LogLevel(2, expand('<sfile>'), "Files uniq: ".join(l:filesList))
        call svnTools#tools#LogLevel(2, expand('<sfile>'), "")
    else
        let l:filesList = l:tmpList
    endif

    "----------------------------------------
    "
    "----------------------------------------
    echo "Final files to be checked:"
    let l:n = 1
    for l:file in l:filesList
        echo " - File ".l:n." ".l:file
        let l:n += 1
    endfor
    echo " "
    echo "Found ".len(l:filesList)." files with changes."
    call confirm("continue?")


    "----------------------------------------
    " Filter files:
    " Filter acording to flags on arguments list, keep/skip binaries/equal-files/match-patterns.
    " Flags:
    "  ALL:show all files modified.
    "  BO:  show binaries only.
    "  SB: skip binaries (default). 
    "  EO: show equal files only.
    "  SE: skip equal files (default). 
    "  +KeepPattern  : pattern used to keep files with names matching.
    "  -SkipPattern  : pattern used to skip files with names not matching.
    "----------------------------------------
    echo "[svnTools.vim] Comparing changes between: '".l:path1."' and: '".l:path2."' "
    let l:filesList = svnTools#misc#FilterFilesListWithArgsList(a:000, l:filesList, l:path1, l:path2)

    if len(l:filesList) == 0
        echo ""
        call svnTools#tools#Warn("[svnTools.vim] No modifications found")
        call input("")
        return
    endif

    echo "Files to open: ".len(l:filesList)
    call confirm("Perform ".l:mode." on this ".len(l:filesList)." files?")


    "----------------------------------------
    " Perform diff/vimdiff between both paths for the same file.
    "----------------------------------------
    let l:diffText = ""
    let l:n = 0

    for file in l:filesList 
        let l:n += 1

        if l:mode == "vimdiff"
            echo "Vimdiff ".l:n.": ".l:file
            call svnTools#diffTools#VimDiffFiles(l:file, l:path2, l:path1)
        else
            echo "Diff ".l:n.": ".l:file
            let l:diffText .= svnTools#diffTools#DiffFiles(l:file, l:path2, l:path1)
        endif
    endfor

    if l:mode == "diff"
        call svnTools#tools#WindowSplitMenu(3)
        call svnTools#tools#WindowSplit()

        let @a = l:diffText
        silent put! a
        normal gg0

        silent  exec("0file")
        silent! exec("file _dirDiff.diff")
        set ft=diff
    endif

    call svnTools#tools#WindowSplitEnd()
    redraw
    echo " "
    echo "[svnTools.vim] Compare svn changes between directories ".l:path1." and ".l:path2." with vimdiff. ".len(l:filesList)." files."
endfunction


