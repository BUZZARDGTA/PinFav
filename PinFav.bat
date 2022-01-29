::------------------------------------------------------------------------------
:: NAME
::     PinFav.bat
::
:: DESCRIPTION
::     Pin your favorite window.
::
:: KNOWN BUGS
::      Programs minimized in the notification area are ignored.
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::
:: CREDITS
::     @Rosalyn - Original project idea, testing and ideas.
::     @Sintrode - Some code optimisation.
::
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
@echo off
title PinFav  ^|  Pin your favorite window.
setlocal DisableDelayedExpansion
set "@CMDWIZ=!cmdwiz.exe! showwindow ? /n:"!executable!""
setlocal EnableDelayedExpansion

set cmdwiz.exe=lib\cmdwiz.exe

if not exist "!cmdwiz.exe!" (
    echo ERROR: PinFav can't start because "!cmdwiz.exe!" is missing.
    echo Please reinstall PinFav and try again.
    echo:
    pause
    exit /b 0
)

set index=0

:MAIN_MENU
cls
set /a write_header=1, cn_memory=0, cn_loop=0
if defined write_newline (
    set write_newline=
)
>nul 2>&1 set memory_executable_ && (
    for /l %%A in (1,1,!index!) do (
        if defined memory_executable_[%%A] (
            call :TASKLIST memory_executable_[%%A] && (
                set /a cn_memory+=1
            ) || (
                set memory_executable_[%%A]=
            )
        )
    )
)
>nul 2>&1 set memory_executable_ && (
    for /l %%A in (1,1,!index!) do (
        if defined memory_executable_[%%A] (
            set /a cn_loop+=1
            if !cn_loop! lss !cn_memory! (
                set "@delimiter=, "
            ) else (
                set @delimiter=
            )
            if defined write_header (
                set write_header=
                echo:
                <nul set /p="Pinned windows: "
            )
            <nul set /p=""!memory_executable_[%%A]!"!@delimiter!"
            if not defined write_newline (
                set write_newline=1
            )
        )
    )
    if defined write_newline (
        echo:
    )
) || (
    set index=0
)
echo:
echo [Warnings]:
echo - Programs minimized in the notification area are ignored.
echo - Some rare other programs are sometimes also ignored.
echo:
<nul set /p="> Do you want to [P]in or [R]estore your window? [P, R]: "
choice /n /c PR
if !errorlevel!==1 (
    set display_action=Pin
    set action=PIN
) else if !errorlevel!==2 (
    set display_action=Restore
    set action=RESTORE
) else (
    exit /b
)

:CHOOSE_EXECUTABLE
if defined executable (
    set executable=
)
set /p "executable=>> Enter the executable you want to !display_action!: "
if not defined executable (
    call :ERROR_WINDOW
    goto :CHOOSE_EXECUTABLE
) else (
    if not "!executable:~-4!"==".exe" (
        set "executable=!executable!.exe"
    )
)
call :TASKLIST executable || (
    call :ERROR_WINDOW
    goto :CHOOSE_EXECUTABLE
)
call :EXECUTABLE_!action!
if not !errorlevel!==0 (
    echo ERROR: Something wrong happened.
    goto :CHOOSE_EXECUTABLE
)
if !action!==PIN (
    for /l %%A in (1,1,!index!) do (
        if defined memory_executable_[%%A] (
            if "!memory_executable_[%%A]!"=="!executable!" (
                goto :MAIN_MENU
            )
        )
    )
    set /a index+=1
    set "memory_executable_[!index!]=!executable!"
) else if !action!==RESTORE (
    for /l %%A in (1,1,!index!) do (
        if defined memory_executable_[%%A] (
            if "!memory_executable_[%%A]!"=="!executable!" (
                set memory_executable_[%%A]=
            )
        )
    )
)
goto :MAIN_MENU

:TASKLIST
tasklist /v /fo csv /fi "imagename eq !%1!" | >nul find /i "!%1!" || (
    exit /b 1
)
exit /b 0

:ERROR_WINDOW
echo Error: Invalid window name or window is not currently running.
exit /b

:EXECUTABLE_PIN
%@CMDWIZ:?=minimize%
%@CMDWIZ:?=restore%
%@CMDWIZ:?=topmost%
exit /b

:EXECUTABLE_RESTORE
%@CMDWIZ:?=minimize%
%@CMDWIZ:?=restore%
%@CMDWIZ:?=top%
exit /b