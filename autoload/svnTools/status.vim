" Script Name: svnTools/status.vim
 "Description: save/restore/compare the file changes.
"
" Copyright:   (C) 2017-2021 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: 
"
" NOTES:
"

" Show on a new window the svn status lines matching the selected filter
" pattern.
" Arg1: filter keep pattern.
"   Keep only files in conflict: "^C ".
"   Keep only modified files: "^M ".
"   Keep only modified, added or deleted files: "^M \|^A \|^D ".
" Arg2: filter remove pattern.
"   Remove only files not added to the repository: "^? ".
"   Remove only files with modified permissions: "^X ".
"   Remove both files not added and permission changes: "^? \|^X ".
" Commands: Svnst, Svnsta, Svnstf, Svnstd.
function! svnTools#status#GetStatus(path, filter, remove)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let command  = l:svnCmd." st ".a:path 
    "let command  = "svn st ".a:path 
    let callback = ["svnTools#status#GetStatusEnd", a:path, a:filter, a:remove]
    call svnTools#tools#WindowSplitMenu(1)
    call svnTools#tools#SystemCmd0(l:command, l:callback, 1)
endfunction

function! svnTools#status#GetStatusEnd(path, filter, remove, resfile)
    if !exists('a:resfile') || empty(glob(a:resfile)) 
        call svnTools#tools#Warn("Svn st ". a:path .". No modifications found.")
        return
    endif

    call svnTools#tools#WindowSplit()
    put = readfile(a:resfile)

    " Filter window content.
    if a:filter != ""
        silent exec "g!/". a:filter ."/d"
        let l:filter0 = a:filter
    else
        let l:filter = ""
        let l:filter0 = "none"
    endif

    " Filter window content.
    if a:remove != ""
        silent exec "g/". a:remove ."/d"
    endif

    let noResults = 0
    if line('$') == 1 && getline(".") == ""
        let noResults = 1
    endif
    if line('$') == 2 && getline(1) == "" && getline(2) == ""
        let noResults = 1
    endif

    " Close window if empty
    if l:noResults == 1
        if a:filter == "" && a:remove == ""
            call svnTools#tools#Warn("Svn st ". a:path .". No modifications found.")
        else
            call svnTools#tools#Warn("Svn st ". a:path .". No modifications found. (Keep: ". a:filter .". Remove: ". a:remove.")" )
        endif
        quit
        return
    endif

    let l:lines0 = line('$')

    call delete(a:resfile)

    " Rename window
    silent exec("0file")
    silent! exec("file _svnSt.txt")

    " Add header on top
    normal ggO
    if a:filter == "" && a:remove == ""
        let text = "[svnTools.vim] svn st '".a:path."' (".l:lines0." results)"
    else
        let text = "[svnTools.vim] svn st '".a:path."' Filter: keep:'".l:filter0."', remove:'".a:remove."' (".l:lines0." results)"
    endif
    put=l:text
    normal ggdd

    " Resize window to fit content.
    call svnTools#tools#WindowSplitEnd()

    " Highlight lines in different colors. If hi.vim plugin available.
    if exists('g:HiLoaded')
        let g:HiCheckPatternAvailable = 0
        silent! call hi#config#PatternColorize(" C ", "m*")          " Conflicted
        silent! call hi#config#PatternColorize("?.*left",    "m2*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("?.*right",   "m3*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("?.*working", "m1*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("?.*mine",    "m1*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("?.*original","m1*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("?.*second",  "m3*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("?.*first",   "m2*")  " Conflicted. Merge file.
        silent! call hi#config#PatternColorize("! ",         "r4@")  " Missing
        silent! call hi#config#PatternColorize("\\~ ",       "v2@")  " Obstructed by some item of different kind
        silent! call hi#config#PatternColorize("A ",         "g*")   " Added
        silent! call hi#config#PatternColorize("C ",         "m*")   " Conflicted
        silent! call hi#config#PatternColorize("D ",         "o*")   " Deleted
        silent! call hi#config#PatternColorize("I ",         "n*")   " Ignored
        silent! call hi#config#PatternColorize("M ",         "b*")   " Modified
        silent! call hi#config#PatternColorize("R ",         "y*")   " Replaced
        silent! call hi#config#PatternColorize("X ",         "w7*-") " Unversioned directory
        silent! call hi#config#PatternColorize("? ",         "w7*-") " Unversioned file
        let g:HiCheckPatternAvailable = 1
    endif
endfunction


" Get files from svn status that match the selected filter pattern.
" Arg1: pattern to keep from the result: 
"   Keep only files in conflict: "^C ".
"   Keep only modified files: "^M ".
"   Keep only modified, added or deleted files: "^M \|^A \|^D ".
" Return: list with all files.
function! svnTools#status#GetStatusFilesList(path, filter)
    let l:list = []
    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()
    let text = system(l:svnCmd." st ". a:path)
    "echom "Svn status: ".l:text

    if l:text == "" 
        return l:list
    endif

    silent new
    normal ggO
    silent put=l:text
    normal ggdd

    if a:filter != ""
        "silent exec "g!/". a:filter ."/d"
        silent exec "v/". a:filter ."/d"
    endif

    silent exec "g/^$/d"

    if line('$') == 1 && getline(".") == ""
        " Empty file
    else
        " Get last column. File paths.
        silent normal gg0f/G$"zy
        let files = @z
        "echo "Files: ".l:i
        let list = split(l:files, "\n")

        if len(l:list) == 0
            " Only one file.
            let list = [ l:files ]
        endif
        "echom "Svn status list: "l:list
    endif

    silent quit!
    return l:list
endfunction



" Get files from svn status that match the selected filter pattern.
" Arg1: filter pattern.
"   Keep only files in conflict: "^C ".
"   Keep only modified files: "^M ".
"   Keep only modified, added or deleted files: "^M \|^A \|^D ".
" Return: string with all files.
function! svnTools#status#GetStatusFilesString(path, filter)
    let l:list = []
    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()
    "echom "GetStatusFilesString: ".l:svnCmd." st ".a:path
    let text = system(l:svnCmd." st ". a:path)

    if l:text == "" 
        return ""
    "elseif l:text =~ "Can't open file" 
        "call svnTools#tools#Error("Check svn password and try again.")
        "return ""
    endif

    silent new
    normal ggO
    silent put=l:text
    normal ggdd

    if a:filter != ""
        silent exec "g!/". a:filter ."/d"
    endif

    silent exec "g/^$/d"

    if line('$') == 1 && getline(".") == ""
        " Empty file
        let l:res = ""
    else
        "normal VGww"z
        silent normal gg0WG$"zy
        let files = @z
        let l:res = substitute(l:files, "\n", " ", "g")

        if l:res =~ "not a working copy"
            call svnTools#tools#Error("Not a svn working copy")
            return ""
        endif
    endif

    silent exec("bd!")
    return l:res
endfunction
