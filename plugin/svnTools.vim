" Script Name: svnTools.vim
 "Description: 
"
" Copyright:   (C) 2017-2022 Javier Puigdevall
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  Javier Puigdevall <javierpuigdevall@gmail.com>
" Contributors:
"
" Dependencies: jobs.vim, jpLib.vim(optional)
"
" NOTES:
"
" Version:      2.0.1
" Changes:
"   - New: on commands Svnda or Svndf, add date to the buffer's result name.
"   - New: Gitvdf, do not open new tab when asking for vimdiff of current file and no other window opened.
"   - Fix: extra line on top of vmdiff left window on :Svnvd commands.
"   - New: command Svnlfd to show log history with every change diff.
"   - Fix: choosing the layout failed on commands Svnm, Svnmf, Svnmd.
"   - New: on Svnv... and SvnV... commands
"   - New: resize blame split and vertical split, sychronize cursor and
"       scroll. Unsynchronize blame when buffer is closed.
"   - New: check if the svn repository is available before launching any action.
"   - Fix: Svnbl and Svnblv, on vertical split move blame window to the left and bind both
"       windows' scroll and movement.
" 2.0.1 	Fri, Feb 25.     JPuigdevall
"   - New: command Vdd, compare with vimdiff all files found on different directories.
"       allows to filter files (flags: +fileX, -fileY), 
"       skip/keep-only binaries (flags: SB, BO) and/or 
"       skip/keep-only equal files (flags: SE, EO).
"   - New: command Vdf, compare current file with same file on a different directory.
"       When the structure paths are the same in both sides, passing as argument the other working directory is enough.
"         ex: 'Vdf ~/Projects/dir2/' 
"       When comparing directories on the same path, only need to change the directory name.
"         ex: compare same file on sandbox1 with dir2: 'Vdf sandbox1 dir2'
"       When comparing directories on the same path, only need to change the directory part to be replaced.
"         ex: compare same file on dir1 with dir2: 'Vdf 1 2'
"   - New: commands SvnD, SvnDD and SvnDA. Advanced diff on path, allows to filter files (flags: +fileX, -fileY),
"       and skip/keep-only binaries (flags: SB, BO).
"   - New: commands SvnVD, SvnVDD and SvnVDA. Advanced vimdiff on path, allows to filter files (flags: +fileX -fileY), 
"       and skip/keep-only binaries (flags: SB, BO).
"   - New: Svndc and Svnvdc admit flags SE and SB to skip equal files and binary files.
"       use falgs C1 or C2 to check only changes on path1 or path2.
"   - Del: remove commands SvndA, SvnvdA, SvndC, SvnvdC, already covered on
"       Svndc and Svnvdc modifying the flags argument.
"   - Fix: Svnst color highlighting on ^C tagged files.
"   - Fix: Svnres command. Missing files in conflict not correctly fetched from snv st output.
"   - Fix: Svnm command. Missing files in conflict not correctly fetched from snv st output.
"      reverse previous changes on svnTools#status#GetStatusFilesList launch filter field.
"   - Fix: Svnm command. Missing list variable definition.
"   - Fix: Svnvdr. error on OpenVimDiffOnEachFileAndRevision.
" 2.0.0 	Fri, 21 Jan 22.     JPuigdevall
"   - new: menu to alow SvnvdC to skip or keep only the files matching the required patterns.
"   - Fix: Svnc VimDiffFilePaths not found.
"   - Fix: Svnvdf command, not showing any result.
"   - New: Svnedit command, not showing the plugint/svnTools.vim file.
"   - Fix: Svnvdf command, not showing any result.
"   - Fix: svnTools#status#GetStatusFilesList calls, use "^M \|^D \|^A " instead of  "^[M|D|A] ".
"   - Fix: svnTools#status#GetStatusFilesList list returns empty when only one file modified found.
"   - Fix: Svnvdr command.
"   - REFACTORING of the plugin to divide in different files. 
"     New autoload/svnTools/ folder to save the plugin files.
"   - New: save and restore changes' functions: Svncsv, Svncvd, Svncvdd, Svncr.
"     Allowing to save, compare and restore changes.
"     Every time we save changes a new  directory is created: _svnTools_changes_YYMMDD_HHMMSS/
"     Every modified file is saved as: dir1___dir2___dir3__filename.ext
"   - New: Svnpwd command, enter user and password.
"   - New: on Svndvda, Svnvdd commands: allow user to select the files to perform the vimdiff.
"   - New: on Svndvda, Svnvdd commands: allow user to filter files adding splace separated filter patterns.
" 1.0.6 	Fri, 28 May 21.     JPuigdevall
"   - New: Svndvdr command, when placed on an svn log and diff file (obtained from Svnr, Svnda, Svndd or Svndf), for each file
"     open the vimdiff of the current log's file revision.
"   - New configuration option g:svnTools_userAndPsswd to use non interactive snv and send user and password in the
"     same command: let g:svnTools_userAndPsswd = 1
"   - New options to manage svn user and password: g:svnTools_svnUser, g:svnTool_storeSvnPsswd.
" 1.0.5 	Fri, 26 Feb 21.     JPuigdevall
"   - New: Svnlr command, when placed on an svn log file, for each revision
"     number get its log and diff changes.
"   - Fix Svnm command, treat status ' C ' as file in conflict.
"   - Fix Svnm command, treat status !.*C as file in conflict.
"   - Fix Svnm command, do not try opening merge tool when file in confict is not found.
"   - Fix GetStatusFilesList function, file path is last column not second one.
"   - New Svnvmb command, development command to create a vimball release of the plugin.
" 1.0.4 	Wed, 16 Dec 20.     JPuigdevall
"   - Fix bug on Svnvda, Svnvdd, Svnvdf,  SvnvdA.
"   - New on Svnda, Svndd, Svndf: do not allow to modify or save the revision file on vimdiff.
"   - New Svndc command, show diff between files with changes on two different directories.
"   - New Svndc command, show diff between files with changes on two different directories, skip binary files.
"   - New Svnmh command: show merge layout help.
" 1.0.3 	Thu, 10 Dec 20.     JPuigdevall
"   - New SvnvdA command. For every modifed file, allows user to get vimdiff, skip (this/all/none) file, 
"     skip (this/all/none) binaries.
"   - New on Svnvdf/Svnvdd/Svnvda check if file is binary, ask user to skip binary files.
"   - New on Svnvdc will now show only files with differecnes, omitt any files that do not differ.
"   - New Svnvdca command to show all changes between directories.
"   - Fix GetStatusFilesString issue affecting svnTools#VimDiffCompareDirChanges.
" 1.0.2 	Fry, 10 Jul 20.     JPuigdevall
"   - Add Svnm command to merge commit upon conflict.
"   - Add Svnrv command to resolve commit conflicts.
"   - Add Svnst commands to show svn status.
"   - Adapt to jobs.vim 0.1.0
"   - Add Svnvdr command to show vimdiff on files modified on selected revision.
" 1.0.1 	Fry, 22 Jun 20.     JPuigdevall
" 1.0.0 	Wed, 13 Feb 19.     JPuigdevall
" 0.0.1 	Sun, 10 Feb 18.     JPuigdevall
"   - Initial realease.


if exists('g:loaded_svntools')
    finish
endif

let g:loaded_svntools = 1
let s:save_cpo = &cpo
set cpo&vim

let g:svnTools_version = "2.0.1"

"- configuration --------------------------------------------------------------

let g:svnTools_svnCmd          = get(g:, 'svnTools_svnCmd', "svn")
let g:svnTools_userAndPsswd    = get(g:, 'svnTools_userAndPsswd', 0)
let g:svnTools_svnUser         = get(g:, 'svnTools_svnUser', "")
let g:svnTools_storeSvnPsswd   = get(g:, 'svnTools_storeSvnPsswd', 1)
let g:svnTools_runInBackground = get(g:, 'svnTools_runInBackground', 1)
let g:svnTools_gotoWindowOnEnd = get(g:, 'svnTools_gotoWindowOnEnd', 1)
let g:svnTools_lastCommits     = get(g:, 'svnTools_lastCommits', 3000)
let g:svnTools_mode            = get(g:, 'svnTools_mode', 3)

" Merge Layout:
" Layout 2:
"   ------------------
"   |       |        |
"   | LOCAL | REMOTE |
"   |       |        |
"   ------------------
"
" Layout 3:
"   ----------------------------
"   |       |         |        |
"   | LOCAL | MERGED  | REMOTE |
"   |       |         |        |
"   ----------------------------
"
" Layout 4:
"    -------------------------
"    |      |       |        |
"    | BASE | LOCAL | REMOTE |
"    |      |       |        |
"    -------------------------
"    |        MERGED         |
"    -------------------------
"
let g:svnTools_mergeLayout     = get(g:, 'svnTools_mergeLayout', "4")
let g:svnTools_mergeLayouts    = get(g:, 'svnTools_mergeLayouts', "2 3 4")


" On vimdiff window (commands: Svnvd, Svnvdp, Svnvda, Svnvdd, Svnvdf...) resize the right most window 
" multiplying current width with this value.
let g:svnTools_vimdiffWinWidthMultiplyValue   = get(g:, 'svnTools_vimdiffWinWidthMultiplyValue', 1.3)



"- commands -------------------------------------------------------------------

" SVN INFO: 
command! -nargs=0  Svni                               call svnTools#svnTools#Info(getcwd())
command! -nargs=0  Svnif                              call svnTools#svnTools#Info(getcwd())

" SVN STATUS: 
command! -nargs=0  Svnst                              call svnTools#status#GetStatus(getcwd(), "^[A-Z!] ", "^[?X] ")
command! -nargs=0  Svnsta                             call svnTools#status#GetStatus(getcwd(), "", "")
command! -nargs=0  Svnstf                             call svnTools#status#GetStatus(expand('%'), "", "")
command! -nargs=0  Svnstd                             call svnTools#status#GetStatus(expand('%:h'), "", "")
command! -nargs=0  Svnsth                             call svnTools#help#StatusHelp()

" SVN DIFF: 
" Simple diff
command! -nargs=1  -complete=dir   Svnd               call svnTools#diff#Diff(<q-args>)
command! -nargs=0  Svndf                              call svnTools#diff#Diff(expand('%'))
command! -nargs=0  Svndd                              call svnTools#diff#Diff(expand('%:h'))
command! -nargs=0  Svnda                              call svnTools#diff#Diff(getcwd())

" Flags:
"  ALL:show all files modified.
"  BO: show binaries only.
"  SB: skip binaries (default). 
"  +KeepPattern  : pattern used to keep files with names matching.
"  -SkipPattern  : pattern used to skip files with names not matching.
command! -nargs=*  -complete=dir   SvnD               call svnTools#diff#DiffAdv(<f-args>)
command! -nargs=*  SvnDD                              call svnTools#diff#DiffAdv(expand('%:h'), <f-args>)
command! -nargs=*  SvnDA                              call svnTools#diff#DiffAdv(getcwd(), <f-args>)

" SVN DIFF WITH VIMDIF:
command! -nargs=0  Svnvdf                             call svnTools#vimdiff#File(expand('%'))

command! -nargs=1  -complete=dir   Svnvd              call svnTools#vimdiff#Path(<q-args>)
command! -nargs=0  Svnvdd                             call svnTools#vimdiff#Path(expand('%:h'))
command! -nargs=0  Svnvda                             call svnTools#vimdiff#Path(getcwd())

" Flags:
"  ALL:show all files modified.
"  BO:  show binaries only.
"  SB: skip binaries (default). 
"  +KeepPattern  : pattern used to keep files with names matching.
"  -SkipPattern  : pattern used to skip files with names not matching.
command! -nargs=*  -complete=dir   SvnVD              call svnTools#vimdiff#PathAdv(<f-args>)
command! -nargs=*  SvnVDD                             call svnTools#vimdiff#PathAdv(expand('%:h'), <f-args>)
command! -nargs=*  SvnVDA                             call svnTools#vimdiff#PathAdv(getcwd(), <f-args>)

" DIFF FILES BETWEEN DIRECTORIES:
" Allowed options:
"  ALL:show all files modified.
"  BO: show binaries only.
"  SB: skip binaries (default). 
"  EO: show equal files only .
"  SE: skip equal files (default). 
"  C1: use only svn changes on path1. 
"  C2: use only svn changes on path2. 
command! -nargs=*  -complete=dir   Svndc              call svnTools#directory#CompareChanges("diff", <f-args>)
command! -nargs=*  -complete=dir   Svnvdc             call svnTools#directory#CompareChanges("vimdiff", <f-args>)

" Open with vimdiff all files modified on a revsion or between two different revisions
" Svnvdr REV1
" Svnvdr REV1 REV2
" When no revision number provided as argument, try get word under cursor as the revision number.
command! -nargs=*  Svnvdr                             call svnTools#vimdiff#RevisionsCompare(<f-args>)

" DIFF FILE TOOLS:
" When placed on buffer with a diff file opened.
command! -nargs=0  Svndvdr                            call svnTools#diffFile#OpenVimDiffOnEachFileAndRevision()
" Show vimdiff of each modified file
command! -nargs=*  SvnDiffVdr                         call svnTools#diffFile#OpenVimDiffOnAllFiles(<f-args>)
" When placed on a line starting with 'Index' or '---' or " '+++'
" Show vimdiff of current modified file
command! -nargs=*  SvnDiffVdrf                        call svnTools#diffFile#OpenVimDiffGetFileAndRevisionFromCurrentLine(<f-args>)

" SVN LOG: 
command! -nargs=?  Svnl                               call svnTools#log#GetRevision(<q-args>)

command! -nargs=*  Svnls                              call svnTools#log#SearchPattern(<f-args>)

command! -nargs=*  Svnlf                              call svnTools#log#GetHistory(expand("%"), <q-args>)
command! -nargs=0  Svnlfd                             call svnTools#log#GetHistory(expand("%"), "--diff")
command! -nargs=*  Svnld                              call svnTools#log#GetHistory(getcwd(), <q-args>)
command! -nargs=*  Svnlp                              call svnTools#log#GetHistory(<q-args>)

command! -nargs=?  Svnlr                              call svnTools#log#GetRevDiff("<args>")

" Get log and diff from selected revision.
command! -nargs=?  Svnr                               call svnTools#log#GetLogAndDiff(<q-args>)

" SVN CAT:
command! -nargs=1  Svncr                              call svnTools#cat#GetRevision(<f-args>)

" SVN BLAME:
command! -nargs=0  Svnbl                              call svnTools#blame#Blame("")
command! -nargs=0  Svnblv                             call svnTools#blame#Blame("-v")

" SVN CONFLICTS:
command! -nargs=*  Svnm                               call svnTools#conflict#Merge(getcwd(), <q-args>)
command! -nargs=*  Svnmf                              call svnTools#conflict#Merge(expand('%'), <q-args>)
command! -nargs=*  Svnmp                              call svnTools#conflict#Merge(<args>)
command! -nargs=*  Svnmh                              call svnTools#help#MergeLayoutHelp()

command! -nargs=*  Svnres                             call svnTools#conflict#Resolve(getcwd(), <q-args>)
command! -nargs=*  Svnresp                            call svnTools#conflict#Resolve(<q-args>)

" Other:
command! -nargs=0  Svnh                               call svnTools#help#Help()

" Toogle background/foreground execution of the svn commands.
command! -nargs=?  Svnbg                              call svnTools#svnTools#BackgroundMode("<args>")

command! -nargs=?  Svnv                               call svnTools#tools#Verbose("<args>")

" Release functions:
command! -nargs=0  Svnvba                             call svnTools#svnTools#NewVimballRelease()

" Edit plugin files:
command! -nargs=0  Svnedit                            call svnTools#svnTools#Edit()

" Svn user and password functions:
command! -nargs=0  Svnpwd                             call svnTools#tools#SetUserAndPsswd()

" Save/restore changes from disk:
command! -nargs=0  Svnc                               call svnTools#changes#Show()
command! -nargs=0  Svncsv                             call svnTools#changes#Save()
command! -nargs=0  Svncvd                             call svnTools#changes#VimdiffCurrentAndSaved()
command! -nargs=0  Svncvdd                            call svnTools#changes#VimdiffSaved()
command! -nargs=0  Svncr                              call svnTools#changes#Restore()

" Diff:
" Compare with vimdiff same file on different base directory.
" Vim Diff File (vertical split)
command! -nargs=* -complete=dir Vdf                   call svnTools#utils#DiffSameFileOnPath("vnew", <f-args>)
" Compare with vimdiff (each file on) two diferent directories
" Vim Diff Directories
command! -nargs=* -complete=dir Vdd                   call svnTools#utils#VimdiffAll(<f-args>)


"- abbreviations -------------------------------------------------------------------

" DEBUG functions: reload plugin
cnoreabbrev _svnrl    <C-R>=svnTools#svnTools#Reload()<CR>


"- menus -------------------------------------------------------------------

if has("gui_running")
    call svnTools#svnTools#CreateMenus('cn' , '.&Info'         , ':Svni'    , 'Working dir info'                                       , ':Svni')
    call svnTools#svnTools#CreateMenus('cn' , '.&Info'         , ':Svnif'   , 'File info'                                              , ':Svnif')
    call svnTools#svnTools#CreateMenus('cn' , '.&Blame'        , ':Svnbl'   , 'Get file blame'                                         , ':Svnbl')
    call svnTools#svnTools#CreateMenus('cn' , '.&Blame'        , ':Svnblv'  , 'Get file blame verbose'                                 , ':Svnblv')
    call svnTools#svnTools#CreateMenus('cn' , '.&Log'          , ':Svnl'    , 'Show log (num of commits)'                              , ':Svnl [NUM]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Log'          , ':Svnls'   , 'Log search (num of commits)'                            , ':Svnls PATTERN [NUM]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Log'          , ':Svnlr'   , 'On svn log file, get each revision diff'                , ':Svnlr')
    call svnTools#svnTools#CreateMenus('cn' , '.&Log'          , ':Svnlvdr' , 'On svn log and diff file, get each file vimdiff'        , ':Svnlvdr')
    call svnTools#svnTools#CreateMenus('cn' , '.&Diff'         , ':Svnd'    , 'Get file/path diff'                                     , ':SvnD PATH')
    call svnTools#svnTools#CreateMenus('cn' , '.&Diff'         , ':Svndf'   , 'Get file diff'                                          , ':SvnDf')
    call svnTools#svnTools#CreateMenus('cn' , '.&Diff'         , ':Svndd'   , 'Get dir diff'                                           , ':SvnDd')
    call svnTools#svnTools#CreateMenus('cn' , '.&Diff'         , ':Svnda'   , 'Get working dir changes diff'                           , ':SvnDa')
    call svnTools#svnTools#CreateMenus('cn' , '.&DiffFilt'     , ':SvnD'    , 'Get (filtered) file/path diff'                          , ':SvnD PATH [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&DiffFilt'     , ':SvnDD'   , 'Get (filtered) dir changes diff'                        , ':SvnDD [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&DiffFilt'     , ':SvnDA'   , 'Get (filtered) working dir diff'                        , ':SvnDA [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Vimdiff'      , ':Svnvd'   , 'Get current file/path changes using vimdiff'            , ':Svnvd')
    call svnTools#svnTools#CreateMenus('cn' , '.&Vimdiff'      , ':Svnvdf'  , 'Get current file changes using vimdiff'                 , ':Svnvdf')
    call svnTools#svnTools#CreateMenus('cn' , '.&Vimdiff'      , ':Svnvdd'  , 'Get current dir changes using vimdiff'                  , ':Svnvdd')
    call svnTools#svnTools#CreateMenus('cn' , '.&Vimdiff'      , ':Svnvda'  , 'Get working dir with changes using vimdiff'             , ':Svnvda')
    call svnTools#svnTools#CreateMenus('cn' , '.&VimdiffFilt'  , ':SvnvD'   , 'Get current (filtered) file/path changes using vimdiff' , ':SvnvD PATH [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&VimdiffFilt'  , ':SvnvDD'  , 'Get current (filtered) dir changes using vimdiff'       , ':SvnvDD [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&VimdiffFilt'  , ':SvnvDA'  , 'Get working (filtered) dir with changes using vimdiff'  , ':SvnvDA [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&DirCompare'   , ':Svndc'   , 'Get diff between changes on both paths'                 , ':Svndc PATH1 PATH2 [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&DirCompare'   , ':Svnvdc'  , 'Get vimdiff between changes on both paths'              , ':Svnvdc PATH1 PATH2 [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&MyDirCompare' , ':Svndmc'  , 'Get diff with files changed on current path'            , ':Svndc PATH [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&MyDirCompare' , ':Svnvdmc' , 'Get vimdiff with files changed on current path'         , ':Svnvdmc PATH [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Revision'     , ':Svnr'    , 'Get revision log and diff'                              , ':Svnr REV')
    call svnTools#svnTools#CreateMenus('cn' , '.&Revision'     , ':Svncr'   , 'Get revision files'                                     , ':Svncr REV')
    call svnTools#svnTools#CreateMenus('cn' , '.&Revision'     , ':Svnvdr'  , 'Get vimdiff on revision'                                , ':Svnvdr [REV1] [REV2]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Conflicts'    , ':Svnm'    , 'Merge all files in conflict'                            , ':Svnm [LAYOUT]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Conflicts'    , ':Svnmf'   , 'Merge file in conflict'                                 , ':Svnmf FILE [LAYOUT]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Conflicts'    , ':Svnmp'   , 'Merge file in conflict'                                 , ':Svnmf FILE [LAYOUT]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Conflicts'    , ':Svnres'  , 'Resolve conflicts'                                      , ':Svnres [all/file]')
    call svnTools#svnTools#CreateMenus('cn' , '.&Conflicts'    , ':Svnmh'   , 'Show merge layout help'                                 , ':Svnmh')
    call svnTools#svnTools#CreateMenus('cn' , '.&Changes'      , ':Svnc'    , 'Show saved changes'                                     , ':Svnc')
    call svnTools#svnTools#CreateMenus('cn' , '.&Changes'      , ':Svncsv'  , 'Save current changes'                                   , ':Svncsv')
    call svnTools#svnTools#CreateMenus('cn' , '.&Changes'      , ':Svncvd'  , 'Show selected changes and vimdiff'                      , ':Svncvd')
    call svnTools#svnTools#CreateMenus('cn' , '.&Changes'      , ':Svncr'   , 'Restore selected changes'                               , ':Svncr')
    call svnTools#svnTools#CreateMenus('cn' , '.&FileCompare'  , ':Vdf'     , 'Compare [current] file with same one on different dir'  , ':Vdf [PATH1] PATH2')
    call svnTools#svnTools#CreateMenus('cn' , '.&FileCompare'  , ':Vdd'     , 'Compare all files between directories'                  , ':Vdd [PATH1] PATH2 [FLAGS]')
    call svnTools#svnTools#CreateMenus('cn' , ''               , ':Svnpwd'  , 'Set svn user and password'                              , ':Svnpwd')
    call svnTools#svnTools#CreateMenus('cn' , ''               , ':Svnbg'   , 'Run foreground/background'                              , ':Svnbg')
    call svnTools#svnTools#CreateMenus('cn' , ''               , ':Svnh '   , 'Show command help'                                      , ':Svnh')
endif


let &cpo = s:save_cpo
unlet s:save_cpo

