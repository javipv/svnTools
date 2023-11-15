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

" Get the plugin reload command
function! svnTools#svnTools#Reload()
    let l:pluginPath = substitute(s:plugin_path, "autoload/svnTools", "plugin", "")
    let s:initialized = 0
    let l:cmd  = ""
    let l:cmd .= "unlet g:loaded_svntools "
    let l:cmd .= " | so ".s:plugin_path."/blame.vim"
    let l:cmd .= " | so ".s:plugin_path."/cat.vim"
    let l:cmd .= " | so ".s:plugin_path."/changes.vim"
    let l:cmd .= " | so ".s:plugin_path."/conflict.vim"
    let l:cmd .= " | so ".s:plugin_path."/diff.vim"
    let l:cmd .= " | so ".s:plugin_path."/diffFile.vim"
    let l:cmd .= " | so ".s:plugin_path."/diffTools.vim"
    let l:cmd .= " | so ".s:plugin_path."/directory.vim"
    let l:cmd .= " | so ".s:plugin_path."/help.vim"
    let l:cmd .= " | so ".s:plugin_path."/info.vim"
    let l:cmd .= " | so ".s:plugin_path."/log.vim"
    let l:cmd .= " | so ".s:plugin_path."/misc.vim"
    let l:cmd .= " | so ".s:plugin_path."/status.vim"
    let l:cmd .= " | so ".s:plugin_path."/svnTools.vim"
    let l:cmd .= " | so ".s:plugin_path."/tools.vim"
    let l:cmd .= " | so ".s:plugin_path."/utils.vim"
    let l:cmd .= " | so ".s:plugin_path."/vimdiff.vim"
    let l:cmd .= " | so ".l:pluginPath."/svnTools.vim"
    let l:cmd .= " | let g:loaded_svntools = 1"
    return l:cmd
endfunction


" Edit plugin files
" Cmd: Svnedit
function! svnTools#svnTools#Edit()
    let l:plugin = substitute(s:plugin_path, "autoload/svnTools", "plugin", "")
    silent exec("tabnew ".s:plugin)
    silent exec("vnew   ".l:plugin."/".s:plugin_name)
endfunction


function! s:Initialize()
    "call svnTools#tools#SetLogLevel(0)
    let s:jobsRunningDict = {}
endfunction


" Svn info 
" Command: SvnInfo, Svni
function! svnTools#svnTools#Info(path)
    let l:svnCmd  = g:svnTools_svnCmd
    let l:svnCmd .= svnTools#tools#CheckSvnUserAndPsswd()

    let info = system(l:svnCmd." info ".a:path." \| egrep -i 'rev:|date' \| awk '{$1=$2=\"\";print}'")
    "let info = system("svn info ".a:path." \| egrep -i 'rev:|date' \| awk '{$1=$2=\"\";print}'")
    let list = split(l:info,"\n")
    "echo "".l:fileFullPath
    for file in l:list 
        echo "".l:file
    endfor
    call input("")
endfunction


" Change background/foreground execution of the svn commands.
" Arg1: [options]. 
"   - Change current mode when aragument is b/f (f:foreground, b:background).
"   - Show current mode when aragument is '?'.
"   - Toogle the background/foregraund execution mode when no argument provided.
" Commands: Svnbg
function! svnTools#svnTools#BackgroundMode(options)
    if a:options =~ "b" || a:options =~ "f"
        if a:options =~ "f"
            let g:svnTools_runInBackground = 0
        else
            let g:svnTools_runInBackground = 1
        endif
    elseif a:options == ""
        if g:svnTools_runInBackground == 1
            let g:svnTools_runInBackground = 0
        else
            let g:svnTools_runInBackground = 1
        endif
    endif

    if g:svnTools_runInBackground == 1
        let l:mode = "background"
    else
        let l:mode = "foreground"
    endif

    echo "[".s:plugin_name."] run commands in ".l:mode."."
endfunction


"- GUI menu  ------------------------------------------------------------
"
" Create menu items for the specified modes.
function! svnTools#svnTools#CreateMenus(modes, submenu, target, desc, cmd)
    " Build up a map command like
    let plug = a:target
    let plug_start = 'noremap <silent> ' . ' :call SvnTools("'
    let plug_end = '", "' . a:target . '")<cr>'

    " Build up a menu command like
    let menuRoot = get(['', 'SvnTools', '&SvnTools', "&Plugin.&SvnTools".a:submenu], 3, '')
    let menu_command = 'menu ' . l:menuRoot . '.' . escape(a:desc, ' ')

    if strlen(a:cmd)
        let menu_command .= '<Tab>' . a:cmd
    endif

    let menu_command .= ' ' . (strlen(a:cmd) ? plug : a:target)

    call svnTools#tools#LogLevel(1, expand('<sfile>'), l:menu_command)

    " Execute the commands built above for each requested mode.
    for mode in (a:modes == '') ? [''] : split(a:modes, '\zs')
        if strlen(a:cmd)
            execute mode . plug_start . mode . plug_end
            call svnTools#tools#LogLevel(1, expand('<sfile>'), "execute ". mode . plug_start . mode . plug_end)
        endif
        " Check if the user wants the menu to be displayed.
        if g:svnTools_mode != 0
            call svnTools#tools#LogLevel(1, expand('<sfile>'), "execute " . mode . menu_command)
            execute mode . menu_command
        endif
    endfor
endfunction


"- Release tools ------------------------------------------------------------
"

" Create a vimball release with the plugin files.
" Commands: Svnvba
function! svnTools#svnTools#NewVimballRelease()
    let text  = ""
    let l:text .= "plugin/svnTools.vim\n"
    let l:text .= "autoload/svnTools/blame.vim\n"
    let l:text .= "autoload/svnTools/cat.vim\n"
    let l:text .= "autoload/svnTools/changes.vim\n"
    let l:text .= "autoload/svnTools/conflict.vim\n"
    let l:text .= "autoload/svnTools/diff.vim\n"
    let l:text .= "autoload/svnTools/diffFile.vim\n"
    let l:text .= "autoload/svnTools/diffTools.vim\n"
    let l:text .= "autoload/svnTools/directory.vim\n"
    let l:text .= "autoload/svnTools/help.vim\n"
    let l:text .= "autoload/svnTools/info.vim\n"
    let l:text .= "autoload/svnTools/log.vim\n"
    let l:text .= "autoload/svnTools/misc.vim\n"
    let l:text .= "autoload/svnTools/status.vim\n"
    let l:text .= "autoload/svnTools/svnTools.vim\n"
    let l:text .= "autoload/svnTools/tools.vim\n"
    let l:text .= "autoload/svnTools/utils.vim\n"
    let l:text .= "autoload/svnTools/vimdiff.vim\n"
    let l:text .= "plugin/jobs.vim\n"
    let l:text .= "autoload/jobs.vim\n"

    silent tabedit
    silent put = l:text
    silent! exec '0file | file vimball_files'
    silent normal ggdd

    let l:plugin_name = substitute(s:plugin_name, ".vim", "", "g")
    let l:releaseName = l:plugin_name."_".g:svnTools_version.".vmb"

    let l:workingDir = getcwd()
    silent cd ~/.vim
    silent exec "1,$MkVimball! ".l:releaseName." ./"
    silent exec "vertical new ".l:releaseName
    silent exec "cd ".l:workingDir
    "call svnTools#tools#WindowSplitEnd()
endfunction


"- initializations ------------------------------------------------------------
"
let  s:plugin = expand('<sfile>')
let  s:plugin_path = expand('<sfile>:p:h')
let  s:plugin_name = expand('<sfile>:t')

call s:Initialize()

