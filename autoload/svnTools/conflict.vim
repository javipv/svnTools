" Script Name: svnTools/conflict.vim
 "Description: 
"
" Copyright:   (C) 2017-2021 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"

" Merge window layout 2.
" Window layout 2:
"   --------------------------
"   |            |           |
"   |  Current   |   Right   |
"   |            |           |
"   --------------------------
function! MergeLayout2(list)
    let fileNum = len(a:list)
    if l:fileNum < 4
        call svnTools#tools#Error("Merge file list not compleat. Only ". l:fileNum ." files provided.")
        return
    endif
    let fileCenter = a:list[1]
    let fileRight  = a:list[3]

    tabnew
    let n = 0

    if !empty(glob(l:fileCenter))
        silent exec("edit ". l:fileCenter)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            if expand('%') == l:fileCenter
                let n += 1
            else
                call svnTools#tools#Warn("missing file: ". l:fileCenter)
                quit
            endif
        endif
    else
        call svnTools#tools#Warn("missing file: ". l:fileCenter)
    endif

    if !empty(glob(l:fileRight))
        if l:n != 0
            silent exec("vert new") 
        endif
        silent exec("edit ". l:fileRight)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            if expand('%') != l:fileRight
                call svnTools#tools#Warn("missing file: ". l:fileRight)
                quit
            else
                let n += 1
            endif
        endif
    else
        call svnTools#tools#Warn("Missing or empty file: ". l:fileRight)
    endif

    if l:n == 0
        silent! tabclose
    elseif l:n > 1
        silent exec("windo diffthis")
    endif
endfunction


" Merge window layout 3.
" Window layout 3:
"   --------------------------
"   |      |         |       |
"   | Left | Current | Right |
"   |      |         |       |
"   --------------------------
function! MergeLayout3(list)
    let fileNum = len(a:list)
    if l:fileNum < 4
        call svnTools#tools#Error("Merge file list not compleat. Only ". l:fileNum ." files provided.")
        return
    endif
    let fileCenter = a:list[1]
    let fileLeft   = a:list[2]
    let fileRight  = a:list[3]

    tabnew
    let n = 0

    if !empty(glob(l:fileLeft))
        silent exec("edit ". l:fileLeft)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            if expand('%') != l:fileLeft 
                call svnTools#tools#Warn("missing file: ". l:fileLeft)
                quit
            else
                let n += 1
            endif
        endif
    else
        call svnTools#tools#Warn("Missing or empty file: ". l:fileLeft)
    endif

    if !empty(glob(l:fileCenter))
        if l:n != 0
            silent exec("vert new") 
        endif
        silent exec("edit ". l:fileCenter)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            if expand('%') == l:fileCenter
                let n += 1
            else
                call svnTools#tools#Warn("missing file: ". l:fileCenter)
                quit
            endif
        endif
    else
        call svnTools#tools#Warn("missing file: ". l:fileCenter)
    endif

    if !empty(glob(l:fileRight))
        if l:n != 0
            silent exec("vert new") 
        endif
        silent exec("edit ". l:fileRight)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            if expand('%') != l:fileRight
                call svnTools#tools#Warn("missing file: ". l:fileRight)
                quit
            else
                let n += 1
            endif
        endif
    else
        call svnTools#tools#Warn("Missing or empty file: ". l:fileRight)
    endif

    if l:n == 0
        silent! tabclose
    elseif l:n > 1
        silent exec("windo diffthis")
    endif
endfunction


" Merge window layout 4.
" Window layout 4:
" --------------------------
" |      |         |       |
" | Left | Working | Right |
" |      |         |       |
" --------------------------
" |        Current         |
" --------------------------
function! MergeLayout4(list)
    let fileNum = len(a:list)
    if l:fileNum < 4
        call svnTools#tools#Error("Merge file list not compleat. Only ". l:fileNum ." files provided.")
        return
    endif

    let fileDown   = a:list[0]
    let fileCenter = a:list[1]
    let fileLeft   = a:list[2]
    let fileRight  = a:list[3]

    "echom "MergeLayout4: ".a:list[0]. " ".a:list[1]. " ".a:list[2]. " ".a:list[3]

    tabnew
    let n = 0

    if !empty(glob(l:fileLeft))
        silent exec("edit ". l:fileLeft)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            let fileName = fnamemodify(l:fileLeft, ':t')
            if expand('%:t') == l:fileName
                let n += 1
            else
                call svnTools#tools#Warn("Missing file (left): ". l:fileLeft.", found: ".expand('%'))
                quit
            endif
        endif
    else
        call svnTools#tools#Warn("Missing or empty file: ". l:fileLeft)
    endif

    if !empty(glob(l:fileCenter))
        if l:n != 0
            silent exec("vert new") 
        endif
        silent exec("edit ". l:fileCenter)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            let fileName = fnamemodify(l:fileCenter, ':t')
            if expand('%:t') == l:fileName
                let n += 1
            else
                call svnTools#tools#Warn("Missing file (center): ". l:fileCenter.", found: ".expand('%'))
                quit
            endif
        endif
    else
        call svnTools#tools#Warn("Missing or empty file: ". l:fileCenter)
    endif

    if !empty(glob(l:fileRight))
        if l:n != 0
            silent exec("vert new") 
        endif
        silent exec("edit ". l:fileRight)

        if line('$') == 1 && getline(".") == ""
            quit
        else
            let fileName = fnamemodify(l:fileRight, ':t')
            if expand('%:t') == l:fileName
                let n += 1
            else
                call svnTools#tools#Warn("Missing file (right): ". l:fileRight.", found: ".expand('%'))
                quit
            endif
        endif
    else
        call svnTools#tools#Warn("Missing or empty file: ". l:fileRight)
    endif

    if l:n == 0
        silent! tabclose
    elseif l:n > 1
        silent exec("windo diffthis")
    endif

    if !empty(glob(l:fileDown))
        if l:n != 0
            silent exec("new") 
            silent wincmd J
            silent resize 20
        endif
        silent exec("edit ". l:fileDown)

        let fileName = fnamemodify(l:fileDown, ':t')
        if expand('%:t') == l:fileName
            let n += 1
        else
            call svnTools#tools#Warn("Missing file (down): ".l:fileName.", found: ".expand('%:t'))
            quit
        endif
    else
        call svnTools#tools#Warn("Missing or empty file (down): ".l:fileDown)
    endif

    if l:n == 0
        silent! tabclose
    endif
endfunction


" Reorder the files related to the merge in the order to be displayed on
" screen.
" Arg1: list with files related to the merge (file.mine, file.working, 
" file.rxxxxx, file.left, file.right).
" Return: list with the files ordered, first the one to display on the left,
" center, right and down.
function! s:MergeFilesArrange(list)
    let l:list = ["", "", "", ""]
    let revFlag = 0

    for file in sort(a:list)
        call svnTools#tools#LogLevel(2, expand('<sfile>'), "Check file: ". l:file)

        if l:file =~ ".working"
            let l:list[1] = l:file
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "working")
        elseif l:file =~ ".mine"
            let l:list[1] = l:file
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "mine")
        elseif l:file =~ ".merge.left.r[0-9]"
            let l:list[2] = l:file
            call svnTools#tools#LogLevel(2, expand('<sfile>'), ".merge.left.r")
        elseif l:file =~ ".merge.right.r[0-9]"
            let l:list[3] = l:file
            call svnTools#tools#LogLevel(2, expand('<sfile>'), ".merge.right.r")
        elseif l:file =~ "left.r[0-9]"
            let l:list[2] = l:file
            call svnTools#tools#LogLevel(2, expand('<sfile>'), "left.r")
        elseif l:file =~ "right.r[0-9]"
            let l:list[3] = l:file
            call svnTools#tools#LogLevel(0, expand('<sfile>'), "right.r")
        elseif l:file =~ ".r[0-9]"
            if l:revFlag == 1
                let l:list[3] = l:file
                call svnTools#tools#LogLevel(2, expand('<sfile>'), ".r second")
            else
                let l:list[2] = l:file
                call svnTools#tools#LogLevel(2, expand('<sfile>'), ".r first")
            endif
            let revFlag = 1
        else
            let l:list[0] = l:file
            call svnTools#tools#LogLevel(0, expand('<sfile>'), "original")
        endif
    endfor

    call svnTools#tools#LogLevel(1, expand('<sfile>'), "Original: ". l:list[0])
    call svnTools#tools#LogLevel(1, expand('<sfile>'), "Center:   ". l:list[1])
    call svnTools#tools#LogLevel(1, expand('<sfile>'), "Left:     ". l:list[2])
    call svnTools#tools#LogLevelStop(1, expand('<sfile>'), "Right:    ". l:list[3])

    return l:list
endfunction


" Merge all file conflicts. 
" Open every file in conflict on a new tab and split vertical showing left,
" working and right conflic files.
" Arg1: path.
" Arg2: [optional] window layout configuration.
" Commands: Svnm, Svnmf, Svnmd.
function! svnTools#conflict#Merge(path, layout)
    let l:mergeLayout = g:svnTools_mergeLayout
    if a:layout != ""
        if g:svnTools_mergeLayouts =~ a:layout
            let l:mergeLayout = a:layout
        else
            call svnTools#tools#Error("Selected layout ". a:layout ." not found on layout list: ". g:svnTools_mergeLayouts)
            return
        endif
    endif

    echo "Search files with conflicts. In progress..."
    let list = svnTools#status#GetStatusFilesList(a:path, "^[C!]")
    let list += svnTools#status#GetStatusFilesList(a:path, " C ")

    let len = len(l:list)
    if len(l:list) == 0
        call svnTools#tools#Warn("No conflicts found")
        return
    endif

    redraw
    echo "Files in conflict:"
    for file in l:list 
        echo "    ".l:file
    endfor
    call input("Open all with merge tool?")

    redraw
    for file in l:list 
        if !filereadable(l:file)
            call svnTools#tools#Warn("File not found: ".l:file)
        else
            echo "Open ".l:file." on merge tool. Files: "
            let list1 = svnTools#status#GetStatusFilesList(l:file."*", "^[C!?]")
            let list1 += svnTools#status#GetStatusFilesList(l:file."*", " C ")
            let l:listArranged = s:MergeFilesArrange(l:list1)

            if len(l:listArranged) <= 0
                call svnTools#tools#Warn("File not found: ".l:file)
            endif

            for file2 in l:listArranged | echo "    ".l:file2 | endfor | echo ""

            exec "call MergeLayout". l:mergeLayout ."(l:listArranged)"
        endif
    endfor
endfunction


" Ask user how to resolve the conflict.
" Return: user selected option.
function! s:UserDialogResolve()
    while 1
        let l:opt = confirm("Resolve, accept: ", "&base\n&working\n&mine\n&theirs\n&help\n&cancel", 10)
        if l:opt == 1
            return "--accept base"
        elseif l:opt == 2
            return = "--accept working"
        elseif l:opt == 3
            return "--accept theirs-full"
        elseif l:opt == 4
            return "--accept theirs-full"
        elseif l:opt == 5
            echo ""
            echo "base:"
            echo "   Choose the file that was the BASE revision before you updated your working copy. That is, the file that you checked out before you made your latest edits."
            echo "working:"
            echo "    Assuming that you've manually handled the conflict resolution, choose the version of the file as it currently stands in your working copy."
            echo "mine-full:"
            echo "   Resolve all conflicted files with copies of the files as they stood immediately before you ran svn update."
            echo "theirs-full:"
            echo "   Resolve all conflicted files with copies of the files that were fetched from the server when you ran svn update."
            echo ""
        else
            return ""
        endif
    endwhile
endfunction


" Resolve the conflicts
" Commands: Svnres, Svnresf, Svnresd
" Arg1: path.
" Arg2: [optional] use 'all' to resolve all conflicts. File path to resolve
" single file in conflict.
function! svnTools#conflict#Resolve(path, option)
    "let l:file = ""

    if a:option != "all" && a:option != ""
        call svnTools#tools#Error("Unknown option ". a:option)
    endif

    " Perform svn st and extract all files in conflict
    echo "Search files with conflicts. In progress..."
    let list = svnTools#status#GetStatusFilesList(a:path, "^[C!]")
    "let list = svnTools#status#GetStatusFilesList(a:path, "^C\|^!")
    let list += svnTools#status#GetStatusFilesList(a:path, " C ")

    if len(l:list) == 0
        call svnTools#tools#Warn("No conflicts found ". a:path)
        return
    endif

    redraw
    echo "Files in conflict:"
    "echo l:text
    for file in l:list 
        echo "C  ". l:file
    endfor
    call confirm("Open resolve tool?")

    redraw

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    if a:option == "all"
        if confirm("ATTENTION! This will resolve all conflicts?", "&yes\n&no", 2) == 2
            return
        endif
        redraw

        echo "Resolve all conflicts"
        let l:cmd = s:UserDialogResolve()
        if l:cmd == "" | return | endif

        "echo "base"
        "echo "   Choose the file that was the BASE revision before you updated your working copy. That is, the file that you checked out before you made your latest edits."
        "echo "working
        "echo "    Assuming that you've manually handled the conflict resolution, choose the version of the file as it currently stands in your working copy."
        "echo "mine-full"
        "echo "   Resolve all conflicted files with copies of the files as they stood immediately before you ran svn update."
        "echo "theirs-full"
        "echo "   Resolve all conflicted files with copies of the files that were fetched from the server when you ran svn update."

        "let l:opt = confirm("Resolve ", "&base\n&working\n&mine\n&theirs\n&cancel", 10)
        "if l:opt == 1
            "let l:cmd = "--accept base"
        "elseif l:opt == 2
            "let l:cmd = "--accept working"
        "elseif l:opt == 3
            "let l:cmd = "--accept theirs-full"
        "elseif l:opt == 4
            "let l:cmd = "--accept theirs-full"
        "else
            "return
        "endif
        call system(l:svnCmd." resolve -R ". l:cmd)
        "call system("svn resolve -R ". l:cmd)
    else
        " Iterate on all files found with conflict.
        for file in l:list 
            echo "File: ". l:file
            let l:cmd = s:UserDialogResolve()
            if l:cmd == "" | continue | endif
            "let l:opt = confirm("Resolve ", "&mine\n&theirs\n&cancel", 3)
            "if l:opt == 1
                "let l:cmd = "--accept mine-full"
            "elseif l:opt == 2
                "let l:cmd = "--accept theirs-full"
            "else
                "continue
            "endif
            call system(l:svnCmd." resolve ". l:cmd ." ". l:file)
            call system("svn resolve ". l:cmd ." ". l:file)
            echo ""
        endfor
    endif
endfunction


