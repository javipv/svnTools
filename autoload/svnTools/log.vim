" Script Name: svnTools/log.vim
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


" Get the svn log history for the selected path.
" Arg1: path.
" Arg2: [optional] options ex: -v, --verbose.
" Commands: Svnlf
function! svnTools#log#GetHistory(...)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:options = ""
    let l:optionsName = ""

    if len(a:000) == 0
        let l:filepath = expand("%")
    endif

    if len(a:000) >= 1
        let l:filepath = substitute(a:1, getcwd(), "", "g")
    endif

    if len(a:000) >= 2
        let l:options = a:2 ." "
        let l:optionsName .= substitute(a:2, '-', "", "g")
    endif

    let file = substitute(l:filepath, "\/", "_", "g")

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let name     = "_svnLog_".l:optionsName.l:file.".log"
    let command  = l:svnCmd." log ". l:options . l:filepath
    "let command  = "svn log ". l:options . l:filepath
    "let command  = "svn log ". l:filepath
    let callback = ["svnTools#log#SvnLogFileEnd", l:name]

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#SystemCmd0(l:command, l:callback, 1)
endfunction

function! svnTools#log#SvnLogFileEnd(name, resfile)
    if exists('a:resfile') && !empty(glob(a:resfile)) 
        call svnTools#tools#WindowSplit()
        " Rename buffer
        silent! exec("0file")
        silent! exec("bd! ".a:name)
        silent! exec("file! ".a:name)
        put =  readfile(a:resfile)
        silent exec("normal gg")
        call   delete(a:resfile)
        normal gg
        call svnTools#tools#WindowSplitEnd()
    else
        call svnTools#tools#Warn("Svn log file search empty")
    endif
endfunction


" When placed on a svn log file, get each commit number.
" Return: list containing all commit numbers.
function! svnTools#log#SvnLogFileGetCommitNumberList()
    let list = []

    let @z=""
    silent g/^r.*\|.*(.*).*lines/y Z
    silent new
    silent put=@Z
    silent! g/^$/d
    silent! %s/ |.*$//g
    "silent bd!

    if line('$') == 1 && getline(".") == ""
        " Empty file
    else
        let @z=""
        silent normal ggVG"zy
        let revNum = @z
        let list = split(l:revNum, "\n")
    endif

    quit
    return l:list
endfunction


" Get svn log and svn diff from the given revision number.
" Arg1: rev. Revision number: r34567 or 34567.
" Arg2: mode. Use new_tab to open each revison on new tab.
function! s:SvnLogFileGetRevisionDiff(rev, mode)
    let l:rev = substitute(a:rev, '[^0-9]*', '', 'g')
    let prev = l:rev - 1
    let name = "_r".l:rev.".diff"

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let command  = l:svnCmd." log -vr ".l:rev." --diff" 
    "let command  = "svn log -vr ".l:rev." --diff" 
    let text = system(l:command)

    if l:text == "" 
        echo "Failed"
        return 1
    endif

    if a:mode == "new_tab"
        silent tabnew
        normal ggO
        silent put=l:text
        normal ggdd

        " Rename buffer
        silent! exec("0file")
        silent! exec("bd! ".l:name)
        silent! exec("file! ".l:name)

        silent exec("set syntax=diff")
        silent exec("normal gg")
    else
        normal GO
        silent put=l:text
    endif
endfunction


" When placed on the svn log file open all revisions.
" Commands: Svnlr.
function! svnTools#log#GetRevDiff(num)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    if expand("%") !~ "_svnLog_.*\.log"
        echo "First launch one of following commands: Svnl, Svnls, Svnlf, Svnld or Svnlp, to get the revision log."
        call svnTools#tools#Error("Current file is not an svn log file!")
        return
    endif

    let l:filename = expand("%")

    " Get all revision numbers
    let l:list = svnTools#log#SvnLogFileGetCommitNumberList()
    if len(l:list) == 0
        call svnTools#tools#Error("No revision number found on current buffer!")
        return
    endif

    redraw
    echo "Number of commits: ".len(l:list)
    echo "Commits found: ".join(l:list)
    if a:num != ""
        call confirm("Open the first ".a:num." revisions. Continue?")
        let max = str2nr(a:num)
    else
        call confirm("Open each revision diff. Continue?")
        let max = len(l:list)
    endif

    if confirm("Open each revision on new tab?", "&yes\n&no", 1) == 2
        let l:mode = "same_tab"
        silent tabnew
        " Rename buffer
        let l:newname = substitute(l:filename, 'svnLog', 'svnLogRevDiff_'.l:max.'Rev_', "g")
        if l:newname != ""
            silent! exec("0file")
            silent! exec("bd! ".l:newname)
            silent! exec("file! ".l:newname)
        endif
    else
        let l:mode = "new_tab"
    endif

    redraw
    " Perform svn log and svn diff for each revision.
    let n=1
    for rev in l:list
        echo l:n."/".l:max.") Getting ".l:rev." log and diff..."
        call s:SvnLogFileGetRevisionDiff(l:rev, l:mode)
        let n+=1
        if a:num != "" && l:n > l:max | break | endif
    endfor
endfunction


" Search the svn log for commit number
" Svn log -v -g  
" Arg1: number of commits to search
" Commands: SvnLog, Svnl.
function! svnTools#log#GetRevision(commitNumb)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let lastCommits = ""
    let numbCommits = "All"

    if  a:commitNumb != ""
        let lastCommits = " -l ".a:commitNumb
        let numbCommits = a:commitNumb
    endif

    echo "Get log changes (include trunk, branches and tags). Commit numb:".l:numbCommits.")"

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    " Get URL, remove trunk word
    let l:url = system(l:svnCmd." info \| grep URL \| awk 'NR==1 {print $2}' \| sed 's/trunk//'")
    "let l:url = system("svn info \| grep URL \| awk 'NR==1 {print $2}' \| sed 's/trunk//'")

    " Get svn log from last x commits
    echo "svn log -v -g ".l:lastCommits." ".l:url
    echo "This may take a while ..."

    let l:name = "_svnSearch".l:numbCommits.".log"

    let command  = l:svnCmd." log -v -g ".l:lastCommits." ".l:url
    "let command  = "svn log -v -g ".l:lastCommits." ".l:url
    let callback = ["svnTools#log#GetRevisionEnd", l:name]

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#SystemCmd0(l:command,l:callback,1)
endfunction

function! svnTools#log#GetRevisionEnd(name,resfile)
    if exists('a:resfile') && !empty(glob(a:resfile)) 
        call svnTools#tools#WindowSplit()
        " Rename buffer
        silent! exec("0file")
        silent! exec("bd! ".a:name)
        silent! exec("file! ".a:name)
        put =  readfile(a:resfile)
        silent exec("normal gg")
        call   delete(a:resfile)
        normal gg
        call svnTools#tools#WindowSplitEnd()
    else
        call svnTools#tools#Warn("Svn log search empty")
    endif
endfunction


" Search the svn log for pattern
" Svn log -v --search
" Arg1: pattern to search.
" Arg2: number of commits to search.
" Commands: SvnLogSearch, Svnls.
function! svnTools#log#SearchPattern(...)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let lastCommits = g:svnTools_lastCommits

    if a:0 >= 2
        let lastCommits = a:2
    endif

    if a:0 < 1
        let pattern = substitute(expand("<cword>"), 'r', '', '')
        if l:pattern == ""
            let l:pattern = expand('%:t')
        endif
    else
        let pattern = a:1
    endif

    if l:pattern == ""
        call svnTools#tools#Warn("Argument 1: search pattern not found.")
        return
    endif

    echo "Search pattern: ".l:pattern." on last ".lastCommits." commits..."
    echo "svn log -v --search ".l:pattern." -l ".l:lastCommits

    let l:name = "_svnSearch".l:lastCommits."_".l:pattern.".log"

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let command  = l:svnCmd." log -v --search ".l:pattern." -l ".l:lastCommits
    "let command  = "svn log -v --search ".l:pattern." -l ".l:lastCommits
    let callback = ["svnTools#log#SvnLogSearchPatternEnd", l:name]

    call svnTools#tools#WindowSplitMenu(4)

    echo "This may take a while ..."
    call svnTools#tools#SystemCmd0(l:command,l:callback,1)
endfunction

function! svnTools#log#SvnLogSearchPatternEnd(name,resfile)
    if exists('a:resfile') && !empty(glob(a:resfile)) 
        call svnTools#tools#WindowSplit()
        " Rename buffer
        silent! exec("0file")
        silent! exec("bd! ".a:name)
        silent! exec("file! ".a:name)
        put =  readfile(a:resfile)
        silent exec("set syntax=diff")
        silent exec("normal gg")
        call   delete(a:resfile)
        normal gg
        call svnTools#tools#WindowSplitEnd()
    else
        call svnTools#tools#Warn("Svn log search pattern empty")
    endif
endfunction



" Get log and diff from the selected revision.
" Arg1: revision number to search.
" Command: Svnr
function! svnTools#log#GetLogAndDiff(rev)
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    if a:rev == ""
        let l:rev = expand("<cword>")
    else
        let l:rev = a:rev
    endif

    let rev = substitute(l:rev, '[^0-9]*', '', 'g')
    if l:rev == ""
        call svnTools#tools#Error("Revision number not found.")
        return
    endif
    let prev = l:rev - 1
    let name = "_r".l:rev.".diff"

    echo "Getting ".l:rev." log and diff"

    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    "On Subversion versions after 1.7:
    let command  = l:svnCmd." log -vr ".l:rev." --diff" 
    "let command  = "svn log -vr ".l:rev." --diff" 
    let callback = ["svnTools#log#GetLogAndDiffEnd", l:name]

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#SystemCmd0(l:command,l:callback,1)
endfunction

function! svnTools#log#GetLogAndDiffEnd(name,resfile)
    if !exists('a:resfile') || empty(glob(a:resfile)) 
        call svnTools#tools#Warn("Svn log and diff empty")
        return
    endif
    call   svnTools#tools#WindowSplit()
    call   svnTools#tools#LogLevel(1, expand('<sfile>'), "name=".a:name)
    " Rename buffer
    silent! exec("0file")
    silent! exec("bd! ".a:name)
    silent! exec("file! ".a:name)
    put =  readfile(a:resfile)
    silent exec("set syntax=diff")
    silent exec("normal gg")
    call   delete(a:resfile)
    call   svnTools#tools#WindowSplitEnd()
endfunction




