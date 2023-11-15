" Script Name: svnTools/help.vim
 "Description: 
"
" Copyright:   (C) 2017-2022 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"

"- Help functions -----------------------------------------------------------

function! svnTools#help#StatusHelp()
    let text =  "[SvnTools.vim] help (v".g:svnTools_version."):\n"
    let text .= "\n"
    let text .= "Svn status' symbols help:\n"
    let text .= "\n"
    let text .= "- First column: Says if item was added, deleted, or otherwise changed\n"
    let text .= "   ' ' no modifications\n"
    let text .= "   'A' Added\n"
    let text .= "   'C' Conflicted\n"
    let text .= "   'D' Deleted\n"
    let text .= "   'I' Ignored\n"
    let text .= "   'M' Modified\n"
    let text .= "   'R' Replaced\n"
    let text .= "   'X' an unversioned directory created by an externals definition\n"
    let text .= "   '?' item is not under version control\n"
    let text .= "   '!' item is missing (removed by non-svn command) or incomplete\n"
    let text .= "   '~' versioned item obstructed by some item of a different kind\n"
    let text .= "\n"
    let text .= "- Second column: Modifications of a file's or directory's properties\n"
    let text .= "   ' ' no modifications\n"
    let text .= "   'C' Conflicted\n"
    let text .= "   'M' Modified\n"
    let text .= "\n"
    let text .= "- Third column: Whether the working copy directory is locked\n"
    let text .= "   ' ' not locked\n"
    let text .= "   'L' locked\n"
    let text .= "\n"
    let text .= "- Fourth column: Scheduled commit will contain addition-with-history\n"
    let text .= "   ' ' no history scheduled with commit\n"
    let text .= "   '+' history scheduled with commit\n"
    let text .= "\n"
    let text .= " Fifth column: Whether the item is switched or a file external\n"
    let text .= "   ' ' normal\n"
    let text .= "   'S' the item has a Switched URL relative to the parent\n"
    let text .= "   'X' a versioned file created by an eXternals definition\n"
    let text .= "\n"
    let text .= "- Sixth column: Repository lock token\n"
    let text .= "   (without -u)\n"
    let text .= "   ' ' no lock token\n"
    let text .= "   'K' lock token present\n"
    let text .= "   (with -u)\n"
    let text .= "   ' ' not locked in repository, no lock token\n"
    let text .= "   'K' locked in repository, lock toKen present\n"
    let text .= "   'O' locked in repository, lock token in some Other working copy\n"
    let text .= "   'T' locked in repository, lock token present but sTolen\n"
    let text .= "   'B' not locked in repository, lock token present but Broken\n"
    let text .= "\n"
    let text .= "- Seventh column: Whether the item is the victim of a tree conflict\n"
    let text .= "   ' ' normal\n"
    let text .= "   'C' tree-Conflicted\n"

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#WindowSplit()
    call svnTools#tools#WindowSplitEnd()
    setl nowrap
    set buflisted
    set bufhidden=delete
    set buftype=nofile
    setl noswapfile
    silent put = l:text
    silent! exec '0file | file svnTools_plugin_svn_status_help'
    normal ggdd
endfunction


function! svnTools#help#MergeLayoutHelp()
    let text =  "[SvnTools.vim] help (v".g:svnTools_version."):\n"
    let text .= "\n"
    let text .= "Svn merge's layout help:\n"
    let text .= "\n"
    let text .= "Layout 2:\n"
    let text .= "--------------------------\n"
    let text .= "|            |           |\n"
    let text .= "|  Current   |   Right   |\n"
    let text .= "|            |           |\n"
    let text .= "--------------------------\n"
    let text .= "\n"
    let text .= "Layout 3 and 3A:\n"
    let text .= "--------------------------\n"
    let text .= "|      |         |       |\n"
    let text .= "| Left | Current | Right |\n"
    let text .= "|      |         |       |\n"
    let text .= "--------------------------\n"
    let text .= "\n"
    let text .= "Layout 4:\n"
    let text .= "--------------------------\n"
    let text .= "|      |         |       |\n"
    let text .= "| Left | Working | Right |\n"
    let text .= "|      |         |       |\n"
    let text .= "--------------------------\n"
    let text .= "|        Current         |\n"
    let text .= "--------------------------\n"
    let text .= "\n"
    let text .=  "Default layout: ".g:svnTools_mergeLayout."\n"
    let text .= "\n"

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#WindowSplit()
    call svnTools#tools#WindowSplitEnd()
    setl nowrap
    set buflisted
    set bufhidden=delete
    set buftype=nofile
    setl noswapfile
    silent put = l:text
    silent! exec '0file | file svnTools_plugin_svn_merge_layout_help'
    normal ggdd
endfunction


function! svnTools#help#Help()
    if g:svnTools_runInBackground == 1
        let l:job = "foreground"
    else
        let l:job = "background"
    endif

    let l:text =  "[svnTools.vim] help (v".g:svnTools_version."):\n"
    let l:text .= "\n"
    let l:text .= "Abridged command help:\n"
    let l:text .= "\n"
    let l:text .= "- Info:\n"
    let l:text .= "    :Svni                 : get current revision info.\n"
    let l:text .= "    :Svnif                : get current file revision info.\n"
    let l:text .= "\n"
    let l:text .= "- Blame:\n"
    let l:text .= "    :Svnbl                : get blame of current file.\n"
    let l:text .= "    :Svnblv               : get verbose blame of current file.\n"
    let l:text .= "\n"
    let l:text .= "- Status:\n"
    let l:text .= "    :Svnst                : show file's status (conceal symbols: X and ?).\n"
    let l:text .= "    :Svnsta               : show status files (show all symbols).\n"
    let l:text .= "    :Svnstf               : show current file status.\n"
    let l:text .= "    :Svnstd               : show current directory status.\n"
    let l:text .= "    :Svnsth               : show the svn status symbols' help.\n"
    let l:text .= "\n"
    let l:text .= "- Log:\n"
    let l:text .= "    :Svnl [NUM]           : get subversion log (num. commits, defaults to ".g:svnTools_lastCommits.").\n"
    let l:text .= "    :Svnls PATTERN [NUM]  : log search pattern (num. commits, defaults to ".g:svnTools_lastCommits.").\n"
    let l:text .= "    :Svnlf FILEPATH       : show file log.\n"
    let l:text .= "    :Svnlr [NUM]          : when placed on a svn log file, get the log and diff of each revison.\n"
    let l:text .= "                           NUM: given a number, only first number of changes will be get.\n"
    let l:text .= "\n"
    let l:text .= "- Diff:\n"
    let l:text .= "    Basic:\n"
    let l:text .= "      :Svnd PATH          : get diff of changes on the selected path.\n"
    let l:text .= "      :Svndf              : get diff of changes on current file.\n"
    let l:text .= "      :Svndd              : get diff of changes on current file's directory.\n"
    let l:text .= "      :Svnda              : get diff of (all) changes on current workind directory.\n"
    let l:text .= "    Advanced: allows to filter files and binaries.\n"
    let l:text .= "      :SvnD PATH [FLAGS]  : get diff of changes on selected path.\n"
    let l:text .= "      :SvnDD [FLAGS]      : get diff of changes on current file's directory.\n"
    let l:text .= "      :SvnDA [FLAGS]      : get diff of (all) changes on workind directory.\n"
    let l:text .= "    Svndvdr              : when placed on a svn log and diff file (after Svnr/Svndd/Svndf/Svnda)\n"
    let l:text .= "                           get each file changes vimdiff.\n"
    let l:text .= "\n"
    let l:text .= "- Vimdiff:\n"
    let l:text .= "    Basic:\n"
    let l:text .= "      :Svnvdf             : get vimdiff of current file changes.\n"
    let l:text .= "      :Svnvd PATH         : get vimdiff of (all) changes on working dir.\n"
    let l:text .= "      :Svnvdd             : get vimdiff of current file's directory changes.\n"
    let l:text .= "      :Svnvda             : get vimdiff of (all) files with changes on working dir.\n"
    let l:text .= "    Advanced: allows to filter files and binaries.\n"
    let l:text .= "      :SvnvD PATH [FLAGS] : get vimdiff of the files with changes on the selected path.\n"
    let l:text .= "      :SvnvDD [FLAGS]     : get vimdiff of the files with changes on current file's directory.\n"
    let l:text .= "      :SvnvDA [FLAGS]     : get vimdiff of the files with changes on working directory.\n"
    let l:text .= "    FLAGS:\n"
    let l:text .= "      B:  show binaries.\n"
    let l:text .= "      NB: skip binaries (default).\n"
    let l:text .= "      EQ: show equal (default).\n"
    let l:text .= "      NEQ: skip equal.\n"
    let l:text .= "      +pattern (keep only files with pattern).\n"
    let l:text .= "      -pattern (skip all files with pattern).\n"
    let l:text .= "    Svnvdr REV           : get revision log and open the selected revision changes with vimdiff.\n"
    let l:text .= "\n"
    let l:text .= "- Directory compare (sandbox compare):\n"
    let l:text .= "    Compare files with changes on both paths:\n"
    let l:text .= "      :Svndc [PATH1] PATH2 [FLAG]  : get diff on all changes.\n"
    let l:text .= "      :Svnvdc [PATH1] PATH2 [FLAG] : get vimdiff on all changes.\n"
    let l:text .= "    FLAG:\n"
    let l:text .= "      ALL: show all files.\n"
    let l:text .= "      EO: equal files only.\n"
    let l:text .= "      SE: skip equal files (default).\n"
    let l:text .= "      BO: binary files only. \n"
    let l:text .= "      SB: skip binary files (default).\n"
    let l:text .= "      C1: check only svn changes on path1.\n"
    let l:text .= "      C2: check only svn changes on path2.\n"
    let l:text .= "\n"
    let l:text .= "- Revision:\n"
    let l:text .= "    :Svnr REV             : get diff of selected revision number.\n"
    let l:text .= "    :Svncr REV            : cat revision number\n"
    let l:text .= "\n"
    let l:text .= "- Conflicts:\n"
    let l:text .= "    :Svnm [LAYOUT]        : merge all conflicts with vimdiff. Layouts: ".g:svnTools_mergeLayouts." (default layout: ".g:svnTools_mergeLayout.").\n"
    let l:text .= "    :Svnmf [LAYOUT]       : merge current file conflict with vimdiff. Layouts: ".g:svnTools_mergeLayouts." (default layout: ".g:svnTools_mergeLayout.").\n"
    let l:text .= "    :Svnmp PATH [LAYOUT]  : merge selected path conflicts with vimdiff. Layouts: ".g:svnTools_mergeLayouts." (default layout: ".g:svnTools_mergeLayout.").\n"
    let l:text .= "    :Svnres [all]         : perform svn resolve. Use 'all' to resolve all conflicts.\n"
    let l:text .= "    :Svnmh                : show merge layout help.\n"
    let l:text .= "\n"
    let l:text .= "- Changes on disk (save/restore/show):\n"
    let l:text .= "    :Svnc                 : show saved changes.\n"
    let l:text .= "    :Svncsv               : save current changes.\n"
    let l:text .= "    :Svncvd               : perform vimdiff between saved changes and current changes.\n"
    let l:text .= "    :Svncvdd              : perform vimdiff between saved changes.\n"
    let l:text .= "    :Svncr                : restore saved changes.\n"
    let l:text .= "\n"
    let l:text .= "- Compare same files on different base directories:\n"
    let l:text .= "    :Vdf [PATH1] PATH2  : compare (vimdiff) current file with same one on path2.\n"
    let l:text .= "    :Vdd [PATH1] PATH2 [FLAGS]  : compare (vimdiff) files between directories. Perform vertical diff.\n"
    let l:text .= "    FLAGS:\n"
    let l:text .= "      ALL: show all files.\n"
    let l:text .= "      EO: equal files only.\n"
    let l:text .= "      SE: skip equal files (default).\n"
    let l:text .= "      BO: binary files only. \n"
    let l:text .= "      SB: skip binary files (default).\n"
    let l:text .= "      C1: compare only with svn changes on path1.\n"
    let l:text .= "      C2: compare only with svn changes on path2. \n"
    let l:text .= "      +pattern (keep only files with pattern).\n"
    let l:text .= "      -pattern (skip all files with pattern).\n"
    let l:text .= "\n"
    let l:text .= "- Password:\n"
    let l:text .= "    :Svnpwd               : set svn user and password.\n"
    let l:text .= "    Custom .vimrc config:\n"
    let l:text .= "       let g:svnTools_userAndPsswd = 1\n"
    let l:text .= "       let g:svnTools_svnUser = 'MY_USER'\n"
    let l:text .= "\n"
    let l:text .= "- Tools:\n"
    let l:text .= "    :Svnbg                : toogle svn job run on ".l:job."\n"
    let l:text .= "\n"
    let l:text .= "\n"
    let l:text .= "-------------------------------------------------------------------------\n"
    let l:text .= "\n"
    let l:text .= "EXAMPLES:\n"
    let l:text .= "\n"
    let l:text .= "- Get diff off all changes on selected path (show equal and binary files):\n"
    let l:text .= "    :SvnD project1/source ALL\n"
    let l:text .= "\n"
    let l:text .= "- Get diff off all changes on selected path, only cpp files:\n"
    let l:text .= "    :SvnD project1/source +cpp\n"
    let l:text .= "\n"
    let l:text .= "- Get diff off all changes on all cpp files:\n"
    let l:text .= "    :SvnDA +cpp\n"
    let l:text .= "\n"
    let l:text .= "- Get diff off all changes on all cpp and xml files, skip config files:\n"
    let l:text .= "    :SvnDA +cpp +xml -config\n"
    let l:text .= "\n"
    let l:text .= "- Get vimdiff off each cpp file with changes on the selected path\n"
    let l:text .= "    :SvnvD project1/source +cpp\n"
    let l:text .= "\n"
    let l:text .= "- Get vimdiff off each cpp and xml, but not config file with changes:\n"
    let l:text .= "    :SvnVDA +cpp +xml -config\n"
    let l:text .= "\n"
    let l:text .= "- Compare the files changed on two directories (omitt binaries and equal files):\n"
    let l:text .= "    :Svnvdc /home/jp/sandbox1 /home/jp/sandbox2/\n"
    let l:text .= "\n"
    let l:text .= "- Compare the files changed on two directories (show equal and binary files):\n"
    let l:text .= "    :Svnvdc /home/jp/sandbox1 /home/jp/sandbox2/ ALL\n"
    let l:text .= "\n"
    let l:text .= "- Compare the files changed on current directory (flag C1) with its counterpart on another directory:\n"
    let l:text .= "  (equal files and binaries omitted by default)\n"
    let l:text .= "    :Svnvdc /home/jp/sandbox2/ C1\n"
    let l:text .= "\n"
    let l:text .= "- Compare current file open with same file on different working directory:\n"
    let l:text .= "  (split vertical)\n"
    let l:text .= "    :Vdf  /home/jp/sandbox2/\n"
    let l:text .= "\n"
    let l:text .= "- Compare current file open with same file on different working directory:\n"
    let l:text .= "  (From current file path, replace sandbox1 with sandbox2, to open the file to diff.\n"
    let l:text .= "    :Vdf 1 2\n"
    let l:text .= "\n"
    let l:text .= "- Compare files on different directories:\n"
    let l:text .= "    :Vdd /home/jp/sandbox1/config/ /home/jp/sandbox2/config/\n"
    let l:text .= "\n"
    let l:text .= "- Compare only 'conf' files on different directories, skip 'xml' files:\n"
    let l:text .= "    :Vdd /home/jp/sandbox1/config/ /home/jp/sandbox2/config/ +conf -xml\n"
    let l:text .= "\n"

    call svnTools#tools#WindowSplitMenu(4)
    call svnTools#tools#WindowSplit()
    call svnTools#tools#WindowSplitEnd()
    setl nowrap
    set buflisted
    set bufhidden=delete
    set buftype=nofile
    setl noswapfile
    silent put = l:text
    silent! exec '0file | file svnTools_plugin_help'
    normal ggdd
endfunction


