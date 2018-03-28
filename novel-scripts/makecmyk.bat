@echo off
setlocal EnableDelayedExpansion

REM DEFRES is default resolution, when input does not have its own.
REM If input is PDF, then DEFRES is always applied.
REM MINRES and MAXRES set warning messages for images under/over usual limits.
REM If you did not export values for these, the following are used:
if "%DEFRES%"=="" ( set DEFRES=300)
if "%MINRES%"=="" ( set MINRES=150)
if "%MAXRES%"=="" ( set MAXRES=600)

REM makecmyk.bat
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

set VERMSG=makecmyk.bat version 0.9.8.
set USAGEMSG=Usage: makecmyk [-a] filename.ext
set HELPMSG=Help:  makecmyk -h
set DEMOMSG=Demo:  makecmyk [-a] demo

REM Test whether script was launched by double-click or from command prompt.
REM If via double-click:
if %0 == "%~0" (
  echo.
  echo %VERMSG%
  echo Converts color image to CMYK PDF at 240 percent ink limit.
  echo %USAGEMSG%
  echo %HELPMSG%
  echo %DEMOMSG%
  echo.
  cmd /k
  exit /B 0
)

REM Provides version, using -v or --v or equivalent:
set GETV=
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
set GETH=
if /I "%1"=="-h" ( set GETH=yes)
if /I "%1"=="--h" ( set GETH=yes)
if /I "%1"=="-help" ( set GETH=yes)
if /I "%1"=="--help" ( set GETH=yes)
if /I "%1"=="/?" ( set GETH=yes)
if /I "%1"=="-?" ( set GETH=yes)
if /I "%1"=="--?" ( set GETH=yes)
if "%GETH%"=="yes" (
  echo.
  echo %VERMSG%
  echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.
  echo Converts image to CMYK PDF at 240 percent ink limit.
  echo.
  echo %USAGEMSG%
  echo   Where .ext may be .png, .jpg, .jpeg, .tif, .tiff, .pdf [also capitalized].
  echo %DEMOMSG%
  echo.
  echo Option -a is only used when input image is known to be in AdobeRGB1998
  echo   or compatible color space, but the color profile was not embedded.
  echo   You will almost never use this option.
  echo.
  echo Requires ImageMagick and Ghostscript.
  echo.
  echo Place input image in input folder.
  echo   Input image may be RGB or CMYK. No spaces in filename.
  echo   May or may not have its own color profile embedded.
  echo   Must be exact size [including bleed] and resolution [typ 300 pixels/inch].
  echo   If input is PDF it will be forced to 300 pixels/inch.
  echo.
  echo Output will appear in output folder, named filename-NOTpdfx.pdf.
  echo   Output PDF has CMYK image at 240pct ink limit.
  echo   Color profile not embedded. Image metadata stripped.
  echo   Resolution will be reported, but not resized, resampled, or cropped.
  echo   Do not panic if output PDF appears to have incorrect color.
  echo   You can get a better idea by viewing the output softproof tif image.
  echo.
  echo To obtain PDF/X, you must post-process the output PDF using lualatex.
  echo   A template will be placed in the output folder. Edit it, then compile.
  echo.
  echo See novel-scripts-README.html for more information.
  echo.
  exit /B 0
)

REM Welcome message:
echo This script converts an image to CMYK PDF at ink limit 240pct.
echo WITHOUT WARRANTY EXPRESS OR IMPLIED. USE AT OWN RISK.
echo.
set USAGEMSG=Usage: makecmyk [-a] filename.ext
set HELPMSG=Help:  makecmyk -h

REM Check structure of folders and required files:
<nul set /p=Checking for presence of required folders and files... 
if not exist "temp\" ( mkdir temp)
if not exist "output\" ( mkdir output)
set GOTFILES=
if not exist "resource\icc\argb.icc" ( set GOTFILES=no)
if not exist "resource\icc\srgb.icc" ( set GOTFILES=no)
if not exist "resource\icc\inklimit.icc" ( set GOTFILES=no)
if not exist "resource\icc\press.icc" ( set GOTFILES=no)
if "%GOTFILES%"=="no" (
  echo ERROR.
  echo.
  echo Error. Did not find all color profiles in resource\icc folder.
  echo Needs these: argb.icc, srgb.icc, inklimit.icc, press.icc.
  echo.
  exit /B 1
)
set GOTFILES=
if not exist "resource\internal\blank.xml" ( set GOTFILES=no)
if not exist "resource\internal\dg32.xml" ( set GOTFILES=no)
if not exist "resource\internal\dg64.xml" ( set GOTFILES=no)
if not exist "resource\internal\template.tex" ( set GOTFILES=no)
if not exist "resource\internal\pdfmarks" ( set GOTFILES=no)
if not exist "resource\internal\novelscriptsdemo.jpg" ( set GOTFILES=no)
if "%GOTFILES%"=="no" (
  echo ERROR.
  echo.
  echo Error. Did not find all files in resource\internal folder.
  echo Needs: novelscriptsdemo.jpg, template.tex,
  echo   blank.xml, dg32.xml, dg64.xml, pdfmarks.
  echo.
  exit /B 1
)
echo OK.


REM Checks for input arguments:
<nul set /p=Parsing arguments... 
set INCOLOR=resource\icc\srgb.icc
set ICN=s
if not "%2"=="" (
  if /I "%1"=="-a" (
    set INCOLOR=resource\icc\argb.icc
    set ICN=a
  ) else (
    echo ERROR.
    echo Bad optional argument. May use -a. Do not omit hyphen.
    echo %USAGEMSG%
    echo %HELPMSG%
    echo.
    exit /B 1
  )
)
set NEEDSGS=yes
set DEMOMODE=
set FN=
set MAGICKPATH=
set MYGSPATH=
set MYGSVER=
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


REM Check input colorspace and possible embedded profile::
<nul set /p=Inspecting the input image... 
set ISCMYK=
%MAGICKPATH%magick identify -verbose !FN! >temp\temp-identify.txt
echo. >>temp\temp-identify.txt
findstr /C:"Colorspace: CMYK" temp\temp-identify.txt 1>nul 2>nul
if "!errorlevel!"=="0" (
  set ISCMYK=yes
  echo CMYK.
  %MAGICKPATH%magick convert %FN% temp\temp-embedded.icc 1>nul 2>nul
  if "!errorlevel!"=="0" (
    set INCOLOR=temp\temp-embedded.icc
    set ICN=e
    echo    ...Has embedded color profile.
  ) else (
    set INCOLOR=resource\icc\press.icc
    set ICN=p
    echo    ...Without embedded color profile. Will use resource\icc\press.icc.
  )
) else (
  echo RGB.
  %MAGICKPATH%magick convert %FN% temp\temp-embedded.icc 1>nul 2>nul
  if "!errorlevel!"=="0" (
    set INCOLOR=temp\temp-embedded.icc
    set ICN=e
    echo    ...Has embedded color profile.
  ) else (
    if "!ICN!"=="a" (
      echo    ...Using input color profile Compatible with AdobeRGB1998, per option.
    ) else (
      echo    ...Using default input color profile Compatible with sRGB.
    )
  )
)
echo    ...Resolution %IR% pixels per inch.
set OUTCOLOR=resource\icc\inklimit.icc
set OCN=inklimit

REM Information:
echo Converting image. This takes time...

REM Strip and flatten image:
%MAGICKPATH%magick convert -units PixelsPerInch -density %IR% %FN% -strip -flatten temp\temp-%CN%-stripped.tif
echo    ...Completed step 1 of 6.

REM Convert to CMYK:
if "!ISCMYK!"=="yes" (
  %MAGICKPATH%magick convert temp\temp-%CN%-stripped.tif -units PixelsPerInch -density %IR% -intent relative -depth 8 -profile !INCOLOR! -profile !OUTCOLOR! temp\temp-%CN%-cmyk.tif
) else (
  REM Convert from RGB to CMYK image:
  %MAGICKPATH%magick convert temp\temp-%CN%-stripped.tif -units PixelsPerInch -density %IR% -intent relative -depth 8 -black-point-compensation -profile !INCOLOR! -profile !OUTCOLOR! temp\temp-%CN%-cmyk.tif
)
echo    ...Completed step 2 of 6.

REM Create softproof RGB image:
%MAGICKPATH%magick convert temp\temp-%CN%-cmyk.tif -units PixelsPerInch -density %IR% -intent relative -depth 8 -black-point-compensation -profile resource\icc\press.icc -profile !INCOLOR! -compress zip output\%CN%-softproof.tif
echo    ...Completed step 3 of 6.

REM This next strip step is important! Without it, the PDF color gets re-profiled:
%MAGICKPATH%magick mogrify -strip temp\temp-%CN%-cmyk.tif
echo    ...Completed step 4 of 6.

REM The intermediate tif file will become a PDF Xobject with FlateDecode:
%MAGICKPATH%magick convert temp\temp-%CN%-cmyk.tif -units PixelsPerInch -density %IR% -compress zip temp\temp-%CN%-NOTpdfx.pdf
echo    ...Completed step 5 of 6.

REM Add an identifier in the PDF info dictionary:
copy resource\internal\pdfmarks temp\pdfmarks 1>nul
if "%MYGSVER%"=="32" (
  %MYGSPATH%gswin32c -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.3 -sOutputFile=temp\%CN%-NOTpdfx.pdf temp\temp-%CN%-NOTpdfx.pdf temp\pdfmarks
) else (
  %MYGSPATH%gswin64c -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.3 -sOutputFile=temp\%CN%-NOTpdfx.pdf temp\temp-%CN%-NOTpdfx.pdf temp\pdfmarks
)
if exist "temp\pdfmarks" ( del temp\pdfmarks)
if exist "temp\temp-%CN%-NOTpdfx.pdf" ( del temp\temp-%CN%-NOTpdfx.pdf)
move "temp\%CN%-NOTpdfx.pdf" "output\%CN%-NOTpdfx.pdf" 1>nul
echo    ...Completed step 6 of 6.

REM Verify and show info on Terminal:
echo Verifying...
echo.
%MAGICKPATH%magick identify -verbose temp\temp-%CN%-cmyk.tif >temp\temp-identify.txt
echo.  >>temp\temp-identify.txt
echo The CMYK is output\%CN%-NOTpdfx.pdf. It is not PDF/X.
echo If you need PDF/X, then you must post-process using lualatex:
if "%DEMOMODE%"=="yes" (
  echo   Use accompanying output\makecmyk-demo.tex file.
  echo %% Compile only with lualatex. >output\makecmyk-demo.tex
  echo \documentclass[coverart]{novel} >>output\makecmyk-demo.tex
  echo \title{demo of makecmyk script} >>output\makecmyk-demo.tex
  echo \SetMediaSize{3.95in}{2.95in} %% includes bleed >>output\makecmyk-demo.tex
  echo \SetTrimSize{3.7in}{2.7in} %% finished size, without bleed >>output\makecmyk-demo.tex
  echo \SetPDFX[CGATSTR001]{X-1a:2001} >>output\makecmyk-demo.tex
  echo %% NO COMMENTS AFTER THIS. >>output\makecmyk-demo.tex
  echo \begin{document} >>output\makecmyk-demo.tex
  echo \ScriptCoverImage{novelscriptsdemo-NOTpdfx.pdf} >>output\makecmyk-demo.tex
  echo \end{document} >>output\makecmyk-demo.tex
  echo.  >>output\makecmyk-demo.tex
) else (
  type resource\internal\template.tex | more /P > output\%CN%-EDIT-THEN-COMPILE.tex
  echo Use accompanying output\%CN%-EDIT-THEN-COMPILE.tex file.
)
echo.
findstr "Colorspace" temp\temp-identify.txt 2>nul
findstr /C:"Total ink" temp\temp-identify.txt 2>/nul
echo     - Anything over 240 percent, probably isolated speckles.
findstr /C:"Print size" temp\temp-identify.txt 2>/nul
echo     - WxH, inches. Includes bleed area, so is larger than trim size.
if "%DEMOMODE%"=="yes" (
  echo   Note that this demo image is much smaller than a real cover image.
)
echo.
echo Compare output\filename-softproof.tif to original, to see color changes.
echo.
echo %WM1%
if not "%WM%"=="" ( echo %WM2%)
if not "%WM3%"=="" ( echo %WM3%)

REM Cleanup:
if exist "temp\temp-%CN%-stripped.tif" ( del temp\temp-%CN%-stripped.tif)
if exist "temp\temp-%CN%-cmyk.tif" ( del temp\temp-%CN%-cmyk.tif)
if exist "temp\temp-identify.txt" ( del temp\temp-identify.txt)
if exist "temp\temp-embedded.icc" ( del temp\temp-embedded.icc)
echo.
echo Done.
echo You may now close this window.
echo.
exit /B 0
REM end of file
