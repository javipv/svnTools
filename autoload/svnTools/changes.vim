" Script Name: changes.vim
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
"- Changes Save/restore functions ---------------------------------------------------


" Show saved changes.
" Commands: Svnc
function! svnTools#changes#Show()
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:savedDatesList = s:GetSavedChangesDatesList()

    if len(l:savedDatesList) == 0
        call svnTools#tools#Warn("No saved changes found")
        return
    endif

    echo "Saved changes:"
    let n = 1
    for date in l:savedDatesList 
        if l:date == "" | continue | endif
        echo "  ".l:n.") ".l:date
        let l:n += 1
    endfor
endfunction


" Save current changes.
" Commands: Svncsv
function! svnTools#changes#Save()
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    echo "Getting changed files at ".getcwd()."..."
    "let l:list = svnTools#status#GetStatusFilesList(getcwd(), '^[MAD] ')
    let l:list = svnTools#status#GetStatusFilesList(getcwd(), '^M \|^A \|^D ')

    if len(l:list) == 0
        call svnTools#tools#Warn("No changes found")
        return
    endif

    redraw
    let l:dir = "_svnTools_changes_" . strftime("%y%m%d_%H%M%S")
    echo "Save changes as: ". l:dir
    if system("mkdir ".l:dir) != 0
        call svnTools#tools#Warn("Mkdir error for: ".l:dir)
    endif

    echo "Modified Files:"
    let n = 0
    for file in l:list 
        echo "- ".l:file

        let l:file = substitute(l:file, getcwd()."/", "", "")
        let l:newfile = substitute(l:file, "/", "___", "g")

        if system("cp ".l:file." ".l:dir."/".l:newfile) != 0
            call svnTools#tools#Warn("Copy error on: ".l:file." to ".l:newfile)
        endif
        "echo "cp ".l:file." ".l:dir."/".l:newfile
    endfor
    call input("(press key)")
endfunction


" View the saved changes, compare choosen date them with current changes using vimdiff.
" Commands: Svncvd
function! svnTools#changes#VimdiffCurrentAndSaved()
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:changeDate = s:ChooseSavedDate(0)
    if l:changeDate == "" | return | endif

    echo "Getting changed files at ".getcwd()."..."
    "let l:changedFilesList = svnTools#status#GetStatusFilesList(getcwd(), '^[MAD] ')
    let l:changedFilesList = svnTools#status#GetStatusFilesList(getcwd(), '^M \|^A \|^D ')
    redraw

    let l:modifiable = 1
    let l:NOmodifiable = 0

    if len(l:changedFilesList) == 0
        call svnTools#tools#Warn("No changes found")

        let l:savedFilesList = s:GetSavedChangesFilesList(changeDate)

        if len(l:savedFilesList) == 0
            call svnTools#tools#Warn("No file changes found for saved date: ".l:changeDate)
        else
            for savedFile in l:savedFilesList 
                let l:savedFile = fnamemodify(l:savedFile, ":t")
                let l:originalFile = substitute(l:savedFile, "___", "/", "g")

                echo "Vimdiff>> saved:".l:savedFile." and original:".l:originalFile
                call svnTools#diffTools#VimDiffFilePaths_setModifiable(l:savedFile, l:originalFile, l:NOmodifiable, l:modifiable)
            endfor
        endif
    else
        for changedFile in l:changedFilesList 
            let l:savedFile = substitute(l:changedFile, getcwd()."/", "", "g")
            let l:savedFile = substitute(l:savedFile, "/", "___", "g")

            let l:savedFilePath = "_svnTools_changes_".l:changeDate."/".l:savedFile

            echo "Vimdiff saved: [".l:savedFilePath."] and changed: [".l:changedFile."]"
            call svnTools#diffTools#VimDiffFilePaths_setModifiable(l:savedFilePath, l:changedFile, l:NOmodifiable, l:modifiable)
        endfor
    endif
endfunction


" View the saved changes, compare using vimdiff a pair of chosen dates.
" Commands: Svncvdd
function! svnTools#changes#VimdiffSaved()
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:datesList = []
    let l:date = s:ChooseSavedDate(1)

    while l:date != ""
        let l:datesList += [ l:date ]
        echo "(Press enter to stop selecting dates)"
        echo " "
        let l:date = s:ChooseSavedDate(1)
    endwhile

    if len(l:datesList) == 0
        call svnTools#tools#Warn("No date selected")
    endif
    if len(l:datesList) < 2
        call svnTools#tools#Warn("Two dates needed.")
    endif

    let l:filesList = s:GetSavedChangesListFilesList(l:datesList)

    if len(l:filesList) == 0
        call svnTools#tools#Warn("No file changes found")
    endif

    let l:pathsList = []
    for date in l:datesList 
        let l:pathsList += [ "_svnTools_changes_".l:date."/" ]
    endfor

    redraw
    let l:setNoModifiable = 1
    call svnTools#diffTools#VimDiffFilePathsList(l:pathsList, l:filesList, l:setNoModifiable)
endfunction


" Restore previous changes saved with Svnsv 
" Commands: Svncr
function! svnTools#changes#Restore()
    let l:res = svnTools#tools#isSvnAvailable()
    if l:res != 1
        call svnTools#tools#Error("ERROR: ".l:res)
        return
    endif

    let l:changeDate = s:ChooseSavedDate(0)
    if l:changeDate == "" | return | endif

    let l:savedFilesList = s:GetSavedChangesFilesList(changeDate)
    if len(l:savedFilesList) == 0
        call svnTools#tools#Warn("No file changes found for saved date: ".l:changeDate)
        return
    endif

    call svnTools#tools#Warn("ATTENTION: you are about to replace current files with saved ones")
    if confirm("Restore ".l:changeDate." changes?", "&yes\n&no", 2) != 1
        return
    endif

    for savedFile in l:savedFilesList 
        if l:savedFile == "" | continue | endif
        let l:savedFile = fnamemodify(l:savedFile, ":t")
        let l:originalFile = substitute(l:savedFile, "___", "/", "g")
        let l:savedFilePath = "_svnTools_changes_".l:changeDate."/".l:savedFile

        echo "Restored [".l:savedFilePath."] to [".l:originalFile."]"

        if system("cp ".l:savedFilePath." ".l:originalFile) != 0
            call svnTools#tools#Warn("Copy error on: ".l:savedFile." to ".l:originalFile)
        endif
    endfor

    call input("(press key)")
endfunction


" Return: date where the changes where saved.
function! s:ChooseSavedDate(flagAll)
    let l:savedDatesList = s:GetSavedChangesDatesList()

    if len(l:savedDatesList) == 0
        call svnTools#tools#Warn("No saved changes found")
        return ""
    endif

    echo "Saved changes:"
    let n = 1
    for date in l:savedDatesList 
        if l:date == "" | continue | endif
        echo "  ".l:n.") ".l:date
        let l:n += 1
    endfor

    "if flagAll != ""
        "echo l:n.") all"
    "endif

    let l:selection = input(" Select date: ")
    if l:selection == ""
        return ""
    endif
    let l:selection -= 1
    echo " "
    echo " "

    let l:changeDate = l:savedDatesList[l:selection]
    return l:changeDate
endfunction


" Return: list with all changes' dates.
function! s:GetSavedChangesDatesList()
    let l:list = []
    let text = system("ls -d _svnTools_changes*")

    if l:text == "" 
        return l:list
    endif

    silent new
    normal ggO
    silent put=l:text
    normal ggdd
    silent exec "silent! %s/_svnTools_changes_//g"

    if line('$') == 1 && getline(".") == ""
        " Empty file
    else
        silent normal gg0VG$"zy
        let l:files = @z
        let l:list = split(l:files, "\n")
    endif

    quit
    return l:list
endfunction


" Return: list with all files on the selected changes directory
function! s:GetSavedChangesFilesList(changeDate)
    let l:list = []
    let text = system("ls -d _svnTools_changes_".a:changeDate."/*")

    if l:text == "" 
        return l:list
    endif

    silent new
    normal ggO
    silent put=l:text
    normal ggdd
    silent exec "silent! %s#_svnTools_changes_".a:changeDate."/##g"

    if line('$') == 1 && getline(".") == ""
        " Empty file
    else
        silent normal gg0VG$"zy
        let l:files = @z
        let l:list = split(l:files, "\n")
    endif

    quit
    return l:list
endfunction


" Return: list with all files on the selected changes dates
function! s:GetSavedChangesListFilesList(changeDateList)
    let l:list = []
    let l:cmd = "ls "
    for date in a:changeDateList
        let cmd .= "_svnTools_changes_".l:date."/* "
    endfor
    "echo "cmd: ".l:cmd
    let text = system(l:cmd)

    if l:text == "" 
        return l:list
    endif

    silent new
    normal ggO
    silent put=l:text
    normal ggdd
    for date in a:changeDateList
        silent exec "silent! %s#_svnTools_changes_".l:date."/##g"
    endfor
    silent! %sort u

    if line('$') == 1 && getline(".") == ""
        " Empty file
    else
        silent normal gg0VG$"zy
        let l:files = @z
        let l:list = split(l:files, "\n")
    endif

    quit
    return l:list
endfunction


