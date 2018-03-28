@echo off
setlocal EnableDelayedExpansion

REM makebw.bat
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

set VERMSG=makebw.bat version 0.9.7.
set USAGEMSG=Usage: makebw [-threshold] filename.ext
set HELPMSG=Help:  makebw -h
set DEMOMSG=Demo:  makebw [-threshold] demo

REM Test whether script was launched by double-click or from command prompt.
REM If via double-click:
if %0 == "%~0" (
  echo.
  echo %VERMSG%
  echo Converts RGB color or grayscale image to monochrome 1-bit black-white png.
  echo %USAGEMSG%
  echo %HELPMSG%
  echo %DEMOMSG%
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
  echo Converts Color or Grayscale to 1-bit black/white png.
  echo.
  echo %USAGEMSG%
  echo   Where .ext may be .png, .jpg, .jpeg, .tif, .tiff, pdf [also capitalized].
  echo %DEMOMSG%
  echo.
  echo Option is an integer 1 to 99, preceded by hyphen.
  echo   Set threshold. Default 50 sets threshold at mid-gray.
  echo   Low number makes more white. High number makes more black.
  echo   Useful for tweaking widths of lines in line art.
  echo.
  echo You need ImageMagick. On Windows, it may be portable.
  echo.
  echo Place input image in input folder.
  echo   Input image may be RGB or Grayscale. No spaces in filename.
  echo   Must be exact size and resolution [typ 600 pixels/inch for line art].
  echo   If input is PDF it will be forced to 600 pixels/inch.
  echo.
  echo Output will appear in output folder, named filename-t-BW.png.
  echo   t=threshold. If option not used, =50.
  echo   It will be single-channel 1-bit black/white. Image metadata stripped.
  echo   Resolution will be reported, but not resized, resampled, or cropped.
  echo.
  echo See novel-scripts-README.html for more information.
  echo.
  exit /B 0
)

REM Welcome message:
echo This script converts Color or Gray image to 1-bit monochrome black/white.
echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.

REM Checks for input arguments:
<nul set /p=Parsing arguments... 
set THRESH=50
if not "%2"=="" (
  set GOODNUM=no
  echo %1|findstr /R "^-[1-9]$" >nul
  if "!errorlevel!"=="0" ( set GOODNUM=yes)
  echo %1|findstr /R "^-[1-9][0-9]$" >nul
  if "!errorlevel!"=="0" ( set GOODNUM=yes)
  if "!GOODNUM!"=="yes" (
    set THRESH=%1
    set /a THRESH=-THRESH
  ) else (
    echo ERROR.
    echo Bad optional argument. May use -1 to -99. Do not omit hyphen.
    echo %USAGEMSG%
    echo %HELPMSG%
    echo.
    exit /B 1
  )
)
set NEEDSGS=
set DEMOMODE=
set FN=
set MAGICKPATH=
set MYGSPATH=
set MYGSVER=
set TARGRES=600
set MINRES=300
set MAXRES=1200
if exist "resource\internal\commonscript.bat" (
  set BADCOMMON=
  call resource\internal\commonscript.bat %1 %2
  if "!BADCOMMON!"=="yes" ( exit /B 1)
) else (
  echo ERROR.
  echo File resource\internal\commonscript.bat is missing. Needed to proceed.
  echo.
  exit /B 1
)


REM Now do conversion:
echo.
echo Converting...
set CS=%% -colorspace Gray
magick convert %FN% -density %IR% -units PixelsPerInch -threshold !THRESH!%CS% output\%CN%-!THRESH!-BW.png

REM Verify and show info on Terminal:
echo Verifying...
echo.
echo The monochrome black-white image is output\%CN%-!THRESH!-BW.png.
echo Metadata has been stripped.
magick identify -verbose output\%CN%-!THRESH!-BW.png >temp\temp-identify.txt
echo. >>temp\temp-identify.txt
echo Threshold !THRESH! percent.
findstr /C:"Channel depth" temp\temp-identify.txt 2>nul
findstr /C:"Gray: 1-bit" temp\temp-identify.txt 2>nul
findstr /I /C:"Print size" temp\temp-identify.txt 2>nul
findstr /I "PixelsPerInch" temp\temp-identify.txt 1>nul 2>nul
if "!errorlevel!"=="0" (
  echo     - measured in Inches.
) else (
  echo     - measured in Centimeters. [png format reports metric]
  echo     - Divide by 2.54 to get Inches.
)
findstr /I "Resolution" temp-identify.txt 2>nul
findstr /I "PixelsPerInch" temp-identify.txt 1>nul 2>nul
if "!errorlevel!"=="0" (
  echo     - measured in Pixels Per Inch.
) else (
  echo     - measured in Pixels per Centimeter. [png format reports metric]
  echo     - Multiply by 2.54 to get Pixels Per Inch.
)
echo.
echo %WM1%
if not "%WM2%"=="" (
  echo %WM2%
)
if not "%WM3%"=="" (
  echo %WM3%
)
if exist "temp\temp-identify.txt" ( del temp\temp-identify.txt)
echo.
echo Done.
echo You may now close this window.
echo.
exit /B 0
REM end of file
