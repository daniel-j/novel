@echo off
setlocal EnableDelayedExpansion

REM makegray.bat
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

set VERMSG=makegray.bat version 0.9.7.
set USAGEMSG=Usage: makegray [-digit] filename.ext
set HELPMSG=Help:  makegray -h
set DEMOMSG=Demo:  makegray [-digit] demo

REM Test whether script was launched by double-click or from command prompt.
REM If via double-click:
if %0 == "%~0" (
  echo.
  echo %VERMSG%
  echo Converts color or grayscale image to single-channel grayscale jpg.
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
if /I "%1"=="-?" ( set GETH=yes)
if /I "%1"=="--?" ( set GETH=yes)
if "%GETH%"=="yes" (
  echo.
  echo makegray.bat version 0.9.6.
  echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.
  echo Converts Color or Grayscale to single-channel Grayscale jpg.
  echo.
  echo %USAGEMSG%
  echo   Where .ext may be .png, .jpg, .jpeg, .tif, .tiff, .pdf [also capitalized].
  echo %DEMOMSG%
  echo.
  echo Option is an integer 1 to 9, preceded by hyphen.
  echo   Performs sigmoidal contrast adjustment. No adjustment if no option.
  echo   Low number increases contrast in darker areas, at expense of lighter.
  echo   High number increases contrast in lighter areas, at expense of darker.
  echo   Middle number increases midrange contrast, at expense of both extremes.
  echo.
  echo You need ImageMagick. On Windows, it may be portable.
  echo.
  echo Place input image in input folder.
  echo   Input image may be Color or Grayscale. No spaces in filename.
  echo   Must be exact size and resolution [typ 300 pixels/inch].
  echo   If input is PDF it will be forced to 300 pixels/inch.
  echo.
  echo Output will appear in output folder, named filename-P-GRAY.jpg.
  echo   P=0: contrast unchanged.
  echo   P=1 through 9: number provided as optional argument.
  echo   It will be single-channel 8-bit Grayscale. Image metadata stripped.
  echo   Color inputs are weighted, typical of photos.
  echo   Resolution will be reported, but not resized, resampled, or cropped.
  echo.
  echo See novel-scripts-README.html for more information.
  echo.
  exit /B 0
)

REM Welcome message:
echo This script converts RGB color/grayscale image to single-channel grayscale.
echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.

REM Checks for input arguments:
<nul set /p=Parsing arguments... 
set IL=0
if not "%2"=="" (
  echo %1|findstr /R "^-[1-9]$" >nul
  if "!errorlevel!"=="0" (
    set IL=%1
    set /a IL=-IL
  ) else (
    echo ERROR.
    echo Bad optional argument. May use -1 to -9. Do not omit hyphen.
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
set TARGRES=300
set MINRES=150
set MAXRES=600
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
echo Converting, this takes awhile...
set HG=-fx "luminance"
set PU=-units PixelsPerInch
set DR=-density %IR%
set QN=-quality 95
set CG=-colorspace Gray
set HC=-sigmoidal-contrast 4,!IL!0%% -colorspace Gray
%MAGICKPATH%magick.exe convert %FN% -strip -flatten %DR% %PU% temp\temp-%CN%.tif
%MAGICKPATH%magick.exe convert temp\temp-%CN%.tif -colorspace Gray %HG% %DR% %PU% temp\temp-%CN%-GRAY.tif
if "!IL!"=="0" (
  %MAGICKPATH%magick.exe convert temp\temp-%CN%-GRAY.tif %CG% %DR% %PU% %QN% output\%CN%-0-GRAY.jpg
) else (
  %MAGICKPATH%magick.exe convert temp\temp-%CN%-GRAY.tif %HC% %DR% %PU% %QN% output\%CN%-!IL!-GRAY.jpg
)
if exist "temp\temp-%CN%.tif" ( del temp\temp-%CN%.tif)
if exist "temp\temp-%CN%-GRAY.tif" ( del temp\temp-%CN%-GRAY.tif)

REM Done:
echo Verifying...
echo.
echo The Grayscale image is output\%CN%-!IL!-GRAY.jpg.
echo Metadata has been stripped.
if "!IL!"=="0" (
  echo No contrast adjustment applied.
) else (
  echo Contrast adjustment value !IL! applied.
)
%MAGICKPATH%magick.exe identify -verbose output\%CN%-!IL!-GRAY.jpg >temp\temp-identify.txt
findstr "Colorspace" temp\temp-identify.txt 2>nul
findstr /C:"Print size" temp\temp-identify.txt 2>nul
findstr "PixelsPerInch" temp\temp-identify.txt 1>nul 2>nul
if "!errorlevel!"=="0" (
  echo     - Measured in Inches.
) else (
  echo     - Measured in Centimeters.
  echo     - Divide by 2.54 to get Inches.
)
findstr "Resolution" temp\temp-identify.txt 2>nul
findstr "PixelsPerInch" temp\temp-identify.txt 1>nul 2>nul
if "!errorlevel!"=="0" (
  echo     - Measured in Pixels Per Inch.
) else (
  echo     - Measured in Pixels Per Centimeter.
  echo     - Multiply by 2.54 to get Pixels Per Inch.
)
echo %WM1%
if not "%WM2%"=="" ( echo %WM2%)
if not "%WM3%"=="" ( echo %WM3%)
if exist "temp\temp-identify.txt" ( del temp\temp-identify.txt)
echo.
echo Done.
echo You may now close this window.
echo.
exit /B 0
REM end of file
