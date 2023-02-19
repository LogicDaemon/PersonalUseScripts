:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                           ::
:: Builded by Archimede                                                      ::
::                                                                           ::
:: Determines if a path is a File path, Directory Path, Link path and, in    ::
:: this case, the type of the link.                                          ::
::                                                                           ::
:: This program is based on ln.exe builded by Hermann Schinagl               ::
::                                                                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

IF @%1@==@/?@ GOTO :HELP
IF @%1@==@@ GOTO :HELP


(ln -j %1 | find "->" && GOTO :JUNCTION) || (ln -s %1 | find "->" && GOTO :SYMBOLIC) || (ln -l %1 | find "\" && GOTO :HARDLINK) || GOTO :ERROR

:JUNCTION
ECHO Junction - Directory && GOTO :EOF

:SYMBOLIC
((DIR /AD %1 | Find "<DIR>")>NUL && echo Symbolic link - Directory && GOTO :EOF)2>NUL
((DIR /A-D /B %1)>NUL && echo Symbolic link - File && GOTO :EOF)2>NUL

:HARDLINK
((DIR /AD %1 | Find "<DIR>")>NUL && echo Directory && GOTO :EOF)2>NUL
((DIR /A-D /B %1)>NUL && echo Hardlink - File && GOTO :EOF)2>NUL

:ERROR
ECHO Not found
GOTO :EOF

:HELP
ECHO.
ECHO Detect the type of the path passed as argument.
ECHO This command determines if the type of a Path is:
ECHO - Hardlink to 1 or much files (the common filename is an hardlink to one
ECHO   file)
ECHO - Directory name
ECHO - Symbolic link to file
ECHO - Symbolic link to directory
ECHO - Junction (only to directory)
ECHO.
ECHO Syntax:
ECHO [Path]QueryPath ["]PathTest["]
ECHO.
ECHO PathTest: the path to know the type.
GOTO :EOF
