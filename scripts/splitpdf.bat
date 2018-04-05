@echo off
setlocal EnableDelayedExpansion

REM splitpdf.bat
REM This is a Windows batch command script.
REM Tested with Windows 10. Should work with Windows 7 or later.
REM FREE SOFTWARE, WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.
REM Copyright 2018 Robert Allgeyer.
REM This file may be distributed and/or modified under the
REM conditions of the LaTeX Project Public License, either version 1.3c
REM of this license or [at your option] any later version.
REM The latest version of this license is in
REM    http://www.latex-project.org/lppl.txt
REM and version 1.3c or later is part of all distributions of LaTeX
REM version 2005/12/01 or later.
REM
REM This file is distributed with the "novel" LuaLaTeX document class.
REM https://ctan.org/pkg/novel  [get the one zip archive]
REM But you do not need a TeX installation to use this script.

set VERMSG=splitpdf.bat version 1.1.
set USAGEMSG=Usage: splitpdf filename.pdf
set HELPMSG=Help:  splitpdf -h

REM Test whether script was launched by double-click or from command prompt.
REM If via double-click:
if %0 == "%~0" (
  echo.
  echo %VERMSG%
  echo Splits a multi-page pdf into one or more individual pages.
  echo %USAGEMSG%
  echo %HELPMSG%
  echo.
  cmd /k
  exit /B 0
)

REM Provides version, using -v or --v or equivalent:
set GETV=no
if /I "%1"=="" ( set GETV=yes)
if /I "%1"=="-v" ( set GETV=yes)
if /I "%1"=="--v" ( set GETV=yes)
if /I "%1"=="-version" ( set GETV=yes)
if /I "%1"=="--version" ( set GETV=yes)
if "%GETV%"=="yes" (
  echo %VERMSG%
  echo.
  exit /B 0
)

REM Provides help, using -h or --h or equivalent:
set GETH=no
if /I "%1"=="-h" ( set GETH=yes)
if /I "%1"=="--h" ( set GETH=yes)
if /I "%1"=="-help" ( set GETH=yes)
if /I "%1"=="--help" ( set GETH=yes)
if /I "%1"=="/?" ( set GETH=yes)
if "%GETH%"=="yes" (
  echo.
  echo %VERMSG%
  echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.
  echo Splits a multi-page pdf into one or more individual pages.
  echo.
  echo %USAGEMSG%
  echo   The extension pdf is case-insensitive.
  echo   Input file must be located in the input folder.
  echo.
  echo The script first locates Ghostscript, then counts the pdf pages.
  echo First page is 1, no matter how they are numbered within the pdf.
  echo.
  echo You will be asked for the first and last page numbers to split.
  echo   The split includes the given numbers.
  echo   If the numbers are identical, then only that one page is split.
  echo Split pages appear in the input folder.
  echo.
  echo See novel-scripts-README.html for more information.
  echo.
  exit /B 0
)

REM Welcome message:
echo Splits a multi-page pdf into one or more individual pages.
echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.

if not exist "temp\" ( mkdir temp)
if not exist "output\" ( mkdir output)

REM Check input filename:
if "%1"=="" (
  echo.
  echo You did not provide an input filename.
  echo %USAGEMSG%
  echo %HELPMSG%
  echo.
  exit /B 1
) else (
  if exist "input\%1" (
    set FN=%1
  ) else (
    echo.
    echo Could not find %1 in input folder.
    echo %USAGEMSG%
    echo %HELPMSG%
    echo.
    exit /B 1
  )
)


REM Check input filename extension:
for %%i in (input\%FN%) do (
  set CN=%%~ni
  set CE=%%~xi
)
if /I "%CE%"==".pdf" (
  echo.
) else (
  echo ERROR.
  echo Input file does not have allowable file extension pdf or PDF.
  echo %HELPMSG%
  echo.
  exit /B 1
)


REM Locate Ghostscript:
set MYGSVER=
<nul set /p=Checking for Ghostscript... 
resource\portable\bin\gswin64c.exe -v 1>nul 2>nul
if "!errorlevel!"=="0" (
  set MYGSPATH=resource\portable\bin\
  set MYGSVER=64
) else (
  resource\portable\bin\gswin32c.exe -v 1>nul 2>nul
  if "!errorlevel!"=="0" (
    set MYGSPATH=resource\portable\bin\
    set MYGSVER=32
  ) else (
    gswin64c.exe -v 1>nul 2>nul
    if "!errorlevel!"=="0" (
      set MYGSVER=64
    ) else (
      gswin32c.exe -v 1>nul 2>nul
      if "!errorlevel!"=="0" (
        set MYGSVER=32
      )
    )
  )
)
if "!MYGSVER!"=="" (
  echo ERROR.
  echo.
  echo This script requires Ghostscript, but did not find it.
  echo See novel-scripts-README.html for more information.
  echo.
  exit /B 1
)
echo OK
cd input
if "!MYGSVER!"=="64" (
  !MYGSPATH!gswin64c -q -dNODISPLAY -c "(%FN%) (r) file runpdfbegin pdfpagecount = quit" >..\temp\temp-identify.txt
) else (
  !MYGSPATH!gswin32c -q -dNODISPLAY -c "(%FN%) (r) file runpdfbegin pdfpagecount = quit" >..\temp\temp-identify.txt
)
echo. >>..\temp\temp-identify.txt
set /p PDFCOUNT=<..\temp\temp-identify.txt
cd ..\
if exist "temp\temp-identify.txt" ( del temp\temp-identify.txt)
set /a PDFCOUNT=PDFCOUNT*1
echo.
if !PDFCOUNT! GTR 1 (
  echo This pdf has !PDFCOUNT! pages. The first page is always 1.
  set /p BEGPAGE=First page to split, answer 1 to !PDFCOUNT! : 
  set /a BEGPAGE=BEGPAGE*1
  if !BEGPAGE! LSS 1 (
    echo Cannot be less than page 1. Start over.
    echo.
    exit /B 1
  )
  if !BEGPAGE! GTR !PDFCOUNT! (
    echo Cannot be greater than page !PDFCOUNT!. Start over.
    echo.
    exit /B 1
  )
  set /p ENDPAGE=Last page to split, answer !BEGPAGE! to !PDFCOUNT! : 
  set /a ENDPAGE=ENDPAGE*1
  if !ENDPAGE! LSS !BEGPAGE! (
    echo Cannot be less than page !BEGPAGE!. Start over.
    echo.
    exit /B 1
  )
  if !ENDPAGE! GTR !PDFCOUNT! (
    echo Cannot be greater than page !PDFCOUNT!. Start over.
    echo.
    exit /B 1
  )
  set /a SUMPAGE=BEGPAGE-1
  cd input
  if "!MYGSVER!"=="64" (
    !MYGSPATH!gswin64c -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=!BEGPAGE! -dLastPage=!ENDPAGE! -sOutputFile=temp-split-range.pdf !FN! 1>nul
    !MYGSPATH!gswin64c -sDEVICE=pdfwrite -dSAFER -o !CN!-!SUMPAGE!plus%%d.pdf temp-split-range.pdf 1>nul
  ) else (
    !MYGSPATH!gswin32c -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=!BEGPAGE! -dLastPage=!ENDPAGE! -sOutputFile=temp-split-range.pdf !FN! 1>nul
    !MYGSPATH!gswin32c -sDEVICE=pdfwrite -dSAFER -o !CN!-!SUMPAGE!plus%%d.pdf temp-split-range.pdf 1>nul
  )
  if exist "temp-split-range.pdf" ( del temp-split-range.pdf)
  cd ..\
  echo.
  echo Done! The split pages are in the input folder.
  echo.
) else (
  echo That pdf file only has one page. No need to split it. No output generated.
  echo.
)

exit /B 0
REM end of file
