# commonscript.sh
# This file has common functions for novel-script Linux scripts.
# It is read by another script, using the source command. Do not use directly.
# $HELPMSG and $USAGEMSG are messages set by calling script.
# $DEFRES is the default resolution. Set by calling script or set/export.
# Over or under DEFRES generates an Alert or a Warning, depending on how much.
# $MINRES is low-resolution warning point, 300 for b/w, 150 for other.
# $MAXRES is the excess-resolution warning point, 1200 for b/w, 600 for other.
# $1 and $2 are arguments passed from calling script.


# Get input filename:
if [ "$1" == "demo" ] || [ "$1" == "DEMO" ] || [ "$2" == "demo" ] || [ "$2" == "DEMO" ]
then
  DEMOMODE="yes"
fi
if [ "$DEMOMODE" == "yes" ]
then
  if [ -f "resource/internal/novelscriptsdemo.jpg" ]
  then
    cp "resource/internal/novelscriptsdemo.jpg" "input/novelscriptsdemo.jpg" 1>/dev/null
    FN="input/novelscriptsdemo.jpg"
  else
    echo "ERROR."
    echo "File resource/internal/novelscriptsdemo.jpg not found. Needed for demo."
    echo 
    BADCOMMON="yes"
    exit 1
  fi
else
  if [ "$2" == "" ]
  then
    if [ -f "input/$1" ]
    then
      FN="input/$1"
    else
      echo "ERROR."
      echo "Did not find file $1 in input folder."
      echo "$USAGEMSG"
      echo "$HELPMSG"
      echo 
      BADCOMMON="yes"
      exit 1
    fi
  else
    if [ -f "input/$2" ]
    then
      FN="input/$2"
    else
      echo "ERROR."
      echo "Did not find file $2 in input folder."
      echo "$USAGEMSG"
      echo "$HELPMSG"
      echo 
      BADCOMMON="yes"
      exit 1
    fi
  fi
fi

# Check filename extension:
CN=$(basename "$FN")
CE="${CN##*.}"
CN="${CN%.*}"
if [ "$CE" == "png" ] || [ "$CE" == "jpg" ] || [ "$CE" == "jpeg" ] || [ "$CE" == "tif" ] || [ "$CE" == "tiff" ] || [ "$CE" == "PNG" ] || [ "$CE" == "JPG" ] || [ "$CE" == "JPEG" ] || [ "$CE" == "TIF" ] || [ "$CE" == "TIFF" ] || [ "$CE" == "pdf" ] || [ "$CE" == "pdf" ]
then
  :
else
  echo 
  echo "Input file does not have allowable file extension."
  echo "May be png, jpg, jpeg, tif, tiff, pdf, or capitalized version."
  echo "$HELPMSG"
  echo 
  exit 1
fi


# Check for ImageMagick:
printf "Checking for ImageMagick... "
convert --version 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
  echo "OK."
else
  echo "ERROR."
  echo "ImageMagick required but not found."
  echo "$HELPMSG"
  echo 
  BADCOMMON="yes"
  exit 1
fi


# Locate Ghostscript, if requested by main script:
if [ "$NEEDSGS" == "yes" ]
then
  printf "Checking for Ghostscript... "
  gs -v 1>/dev/null 2>/dev/null
  if [ $? -ne 0 ]
  then
    echo "ERROR."
    echo 
    echo "This script requires Ghostscript, but did not find it."
    echo "See novel-scripts-README.html for more information."
    echo 
    BADCOMMON="yes"
    exit 1
  else
    echo "OK."
  fi
fi


# Get image resolution:
TEMPRESX="0"
TEMPRESY="0"
TEMPRESD="0"
identify -format "%x" -units PixelsPerInch $FN > temp/temp-res.txt
TEMPRESX=$(cat temp/temp-res.txt)
identify -format "%y" -units PixelsPerInch $FN > temp/temp-res.txt
TEMPRESY=$(cat temp/temp-res.txt)
if [ -f "temp/temp-res.txt" ]; then rm temp/temp-res.txt; fi
printf -v TEMPRESX %.0f $TEMPRESX
printf -v TEMPRESY %.0f $TEMPRESY
# Ensure that X and Y resolutions are identical:
GOTRES="no"
if [ $TEMPRESX -eq $TEMPRESX ]
then
  if [ $TEMPRESY -eq $TEMPRESY ]
  then
    let "TEMPRESD = $TEMPRESX - $TEMPRESY"
    if [ $TEMPRESD -eq 0 ]
    then
      GOTRES="yes"
    fi
  fi
fi
IR=$TEMPRESX
# If input is pdf, always set resolution to $DEFRES:
if [ "$CE" == "pdf" ] || [ "$CE" == "PDF" ]; then IR=$DEFRES; fi

# Prepare messages:
WM1="Output image resolution $DEFRES pixels per inch."
WM2=""
WM3=""
if [ "$GOTRES" == "no" ]
then
  WM1="WARNING: Image resolution was not included in file, or was unreadable."
  WM2="Processed with resolution set to $DEFRES pixels per inch."
  WM3="Be sure to check image dimensions."
  IR=$DEFRES
fi
if [ $IR -lt $MINRES ]
then
  WM1="WARNING: Image resolution $IR is less than $MINRES pixels per inch."
  WM2="This is likely to be rejected by the print service."
  WM3="Some print services allow as low as $MINRES, but most require $DEFRES."
else
  if [ $IR -lt $DEFRES ]
  then
    WM1="ALERT: Image resolution $IR is less than $DEFRES pixels per inch."
    WM2="Some print services allow as low as $MINRES, but most require $DEFRES."
    WM3=""
  fi
  if [ $IR -gt $DEFRES ]
  then
    if [ $IR -le $MAXRES ]
    then
      WM1="ALERT: Image resolution $IR is over $DEFRES pixels per inch."
      WM2="Some print services allow as high as $MAXRES, but most require $DEFRES."
      WM3=""
    else
      WM1="WARNING: Image resolution $IR is over $MAXRES pixels per inch."
      WM2="This is likely to be rejected by the print service."
      WM3="Some print services allow as high as $MAXRES, but most require $DEFRES."
    fi
  fi
fi

BADCOMMON="no"

# end of file



