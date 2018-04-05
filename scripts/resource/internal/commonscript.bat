REM commonscript.bat
REM Supports scripts version 1.2.
REM This file has common functions for novel-script Windows scripts.
REM It is read by another script, using the call command. Do not use directly.
REM %HELPMSG% and %USAGEMSG% are messages set by calling script.
REM %DEFRES% is the default resolution. Set by calling script, or set/export.
REM Over or under %DEFRES% generates an Alert or a Warning, depending on how much.
REM %MINRES is low-resolution warning point, 300 for b/w, 150 for other.
REM %MAXRES% is the excess-resolution warning point, 1200 for b/w, 600 for other.
REM %1 and %2 are arguments passed from calling script.


REM Get input filename:
if /I "%1"=="demo" ( set DEMOMODE=yes)
if /I "%2"=="demo" ( set DEMOMODE=yes)
if "%DEMOMODE%"=="yes" (
  if exist "resource\internal\novelscriptsdemo.jpg" (
    copy "resource\internal\novelscriptsdemo.jpg" "input\novelscriptsdemo.jpg" 1>nul
    set FN=novelscriptsdemo.jpg
  ) else (
    echo ERROR.
    echo File resource\internal\novelscriptsdemo.jpg not found. Needed for demo.
    echo.
    set BADCOMMON=yes
    exit /B 1
  )
) else (
  if "%2"=="" (
    if exist "input\%1" (
      set FN=%1
    ) else (
      echo ERROR.
      echo Did not find file %1 in input folder.
      echo %USAGEMSG%
      echo %HELPMSG%
      echo.
      set BADCOMMON=yes
      exit /B 1
    )
  ) else (
    if exist "input\%2" (
      set FN=%2
    ) else (
      echo ERROR.
      echo Did not find file %2 in input folder.
      echo %USAGEMSG%
      echo %HELPMSG%
      echo.
      set BADCOMMON=yes
      exit /B 1
    )
  )
)

REM Check input filename extension:
for %%i in (input\%FN%) do (
  set CN=%%~ni
  set CE=%%~xi
)
set EXTOK=
if /I "%CE%"==".png" ( set EXTOK=yes)
if /I "%CE%"==".jpg" ( set EXTOK=yes)
if /I "%CE%"==".jpeg" ( set EXTOK=yes)
if /I "%CE%"==".tif" ( set EXTOK=yes)
if /I "%CE%"==".tiff" ( set EXTOK=yes)
if /I "%CE%"==".pdf" (
  set EXTOK=yes
  set NEEDSGS=yes
)
if "%EXTOK%"=="" (
  echo ERROR.
  echo Input file does not have allowable file extension.
  echo May be png, jpg, jpeg, tif, tiff, pdf, or capitalized version.
  echo %HELPMSG%
  echo.
  set BADCOMMON=yes
  exit /B 1
)
echo OK.


REM Check for ImageMagick:
<nul set /p=Checking for ImageMagick... 
if exist "resource\portable\bin\magick.exe" (
  set MAGICKPATH=resource\portable\bin\
  if not exist "resource\portable\bin\delegates.xml" (
    copy /Y "resource\internal\blank.xml" "resource\portable\bin\delegates.xml" 1>nul
  )
  if not exist "resource\portable\bin\magic.xml" (
    copy /Y "resource\internal\blank.xml" "resource\portable\bin\magic.xml" 1>nul
  )
  if not exist "resource\portable\bin\colors.xml" (
    copy /Y "resource\internal\blank.xml" "resource\portable\bin\colors.xml" 1>nul
  )
)
%MAGICKPATH%magick.exe --version 1>nul 2>nul
if "!errorlevel!"=="0" (
  echo OK.
) else (
  echo ERROR.
  echo ImageMagick required but not found, either system or portable.
  echo %HELPMSG%
  echo.
  set BADCOMMON=yes
  exit /B 1
)

REM Locate Ghostscript, if requested by main script:
if "%NEEDSGS%"=="yes" (
  <nul set /p=Checking for Ghostscript... 
  resource\portable\bin\gswin64c.exe -v 1>nul 2>nul
  if "!errorlevel!"=="0" (
    set MYGSPATH=resource\portable\bin\
    set MYGSVER=64
    copy /Y "resource\internal\dg64.xml" "resource\portable\bin\delegates.xml" 1>nul
  ) else (
    resource\portable\bin\gswin32c.exe -v 1>nul 2>nul
    if "!errorlevel!"=="0" (
      set MYGSPATH=resource\portable\bin\
      set MYGSVER=32
      copy /Y "resource\internal\dg32.xml" "resource\portable\bin\delegates.xml" 1>nul
    ) else (
      gswin64c.exe -v 1>nul 2>nul
      if "!errorlevel!"=="0" (
        set MYGSVER=64
        copy /Y "resource\internal\dg64.xml" "resource\portable\bin\delegates.xml" 1>nul
      ) else (
        gswin32c.exe -v 1>nul 2>nul
        if "!errorlevel!"=="0" (
          set MYGSVER=32
          copy /Y "resource\internal\dg32.xml" "resource\portable\bin\delegates.xml" 1>nul
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
    set BADCOMMON=yes
    exit /B 1
  ) else (
    echo OK.
  )
)


REM Get image resolution:
set TEMPRESX=0
set TEMPRESY=0
set TEMPRESD=0
set TI=
REM If input is pdf, always set resolution to %DEFRES%, and trim image:
if /I "%CE%"==".pdf" (
  set IR=%DEFRES%
  set TI=-trim
  set PDFZ=[0]
  goto skipres
)
REM I really dislike using goto, but the alternative involves complicated
REM parsing of delayed expansion percent and exclamation. Ugh. Better just goto.

REM If not pdf, get resolution from the image. This is skipped by goto, if pdf:
set PDFZ=
%MAGICKPATH%magick.exe identify -format "%%x" -units PixelsPerInch input\!FN! > temp\temp-res.txt
echo. >>temp\temp-res.txt
set /p TEMPRESX=<temp\temp-res.txt
set TEMPRESX=%TEMPRESX: =%.0
%MAGICKPATH%magick.exe identify -format "%%y" -units PixelsPerInch input\!FN! > temp\temp-res.txt
echo. >>temp\temp-res.txt
set /p TEMPRESY=<temp\temp-res.txt
set TEMPRESY=%TEMPRESY: =%.0
if exist "temp\temp-res.txt" (del temp\temp-res.txt)
REM Problem: Resolution may be non-integer, due to units converted from metric to PixelsPerInch.
REM   But the arithmetic only handles integers.
REM Solution: Analyze whether there is a decimal part at least as great as 0.1.
REM   If so, add 1 to the truncated integer resolution.
set RESXTEST=%TEMPRESX:*.=%
set RESXTEST=1%RESXTEST:~0,1%
set /a RESXTEST=RESXTEST*1
if %RESXTEST% GTR 11 (
  set /a TEMPRESX+=1
) else (
  set /a TEMPRESX=TEMPRESX*1
)
set RESYTEST=%TEMPRESY:*.=%
set RESYTEST=1%RESYTEST:~0,1%
set /a RESYTEST=RESYTEST*1
if %RESYTEST% GTR 11 (
  set /a TEMPRESY+=1
) else (
  set /a TEMPRESY=TEMPRESY*1
)
REM Ensure that X and Y resolutions are identical:
set /a TEMPRESD=TEMPRESX-TEMPRESY
set GOTRES=no
if %TEMPRESD% EQU 0 ( set GOTRES=yes)
if %TEMPRESX% EQU 0 ( set GOTRES=no)
if %TEMPRESY% EQU 0 ( set GOTRES=no)
set /a IR=TEMPRESX*1
set IR=%IR%

REM Resume from skipped resolution calculation.
:skipres

REM Prepare messages:
set WM1=Image resolution %DEFRES% pixels per inch.
set WM2=
set WM3=
if "%GOTRES%"=="no" (
  set WM1=WARNING: Image resolution was not included in file, or was unreadable.
  set WM2=Processed with resolution set to target %DEFRES% pixels per inch.
  set WM3=Be sure to check image dimensions.
  set IR=%DEFRES%
)
if %IR% LSS %MINRES% (
  set WM1=WARNING: Image resolution %IR% is less than %MINRES% pixels per inch.
  set WM2=This is likely to be rejected by the print service.
  set WM3=Some print services allow as low as %MINRES%, but your target is %DEFRES%.
) else (
  if %IR% LSS %DEFRES% (
    set WM1=ALERT: Image resolution %IR% is less than target %DEFRES% pixels per inch.
    set WM2=Some print services allow as low as %MINRES%, but your target is %DEFRES%.
    set WM3=
  )
  if %IR% GTR %DEFRES% (
    if %IR% LEQ %MAXRES% (
      set WM1=ALERT: Image resolution %IR% is over target %DEFRES% pixels per inch.
      set WM2=Some print services allow as high as %MAXRES%, but your target is %DEFRES%.
      set WM3=
    ) else (
      set WM1=WARNING: Image resolution %IR% is over %MAXRES% pixels per inch.
      set WM2=This is likely to be rejected by the print service.
      set WM3=Some print services allow as high as %MAXRES%, but your target is %DEFRES%.
    )
  )
)

set BADCOMMON=no


REM end of file
