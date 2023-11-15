# svnTools
Perform subversion commands from within vim. 

## Description
Allows to launch several svn commands from within vim.

Use :Svnh to show a command help with the latest set of commands.

Info commands:

    Svni                 : get current revision info.
  
    Svnif                : get current file revision info.

Blame commands:

    Svnbl                : get blame of current file.
  
    Svnblv               : get verbose blame of current file.
  

Status commands:

    Svnst                : show file's status (conceal symbols: X and ?).
  
    Svnsta               : show status files (show all symbols).
    
    Svnstf               : show current file status.
    
    Svnstd               : show current directory status.
    
    Svnsth               : show the svn status symbols' help.

Log commands:

    Svnl [NUM]           : get subversion log (num. commits, defaults to 3000).
    
    Svnls PATTERN [NUM]  : log search pattern (num. commits, defaults to 3000).
    
    Svnlf FILEPATH       : show file log.

Diff commands:

    Svndf                 : get diff of changes on current file.
    
    Svndd                : get diff of changes on current directory.
    
    Svnda                : get diff of changes on current workind directory.

Diff files with vimdiff commands:

    Svnvda               : show (vimdiff) all files with changes (alows to skip binaries).
    
    SvnvdA               : show (vimdiff) selected files with changes (alows to skip binaries).
    
    Svnvdf                : show (vimdiff) current file changes.
    
    Svnvdd               : show (vimdiff) current directory changes.
    
    Svnvdr REV           : show revision log and open the selected revision changes with vimdiff. 
    
    Svnr REV             : get diff of selected revision number.
    
    Svncr REV            : cat revision number

Conflicts commands:

    Svnm [LAYOUT]        : merge all conflicts with vimdiff. Layouts: 0 1 2 (default layout: 2).
    
    Svnmf [LAYOUT]       : merge current file conflict with vimdiff. Layouts: 0 1 2 (default layout: 2).
    
    Svnmp FILE [LAYOUT]  : merge file conflict with vimdiff. Layouts: 0 1 2 (default layout: 2).
    
    Svnres [all]         : perform svn resolve. Use 'all' to resolve all conflicts.
    
    Svnmh                : show merge layout help.

Password settings:

  Optional, if you don't want to use keyring or similar programs.
  
  The svn password will only be stored for the current vim session.
  
    let g:svnTools_userAndPsswd = 1
    
    let g:svnTools_svnUser = "MY_SVN_USER"
    
    let g:svnTools_storeSvnPsswd = 1
 
## Install details

Minimum version: Vim 7.0+

Recomended version: Vim 8.0+

## Install vimball:

download svnTools_2.0.1.vmb

vim svnTools_2.0.1.vmb

:so %

:q
