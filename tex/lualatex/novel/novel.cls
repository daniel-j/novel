%%
%% This is file `novel.cls', part of class `novel'.
%% Copyright 2017 Robert Allgeyer.  Contact:  anytthree [at] gmail.com
%% 
%% Wanted: Replacement maintainer. The original creator wants to move on.
%% AFAIK this code is tested and suitable for general use.
%% Contact CTAN (and me) if interested in taking over the maintenance.
%% 
%% This file may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either version 1.3c
%% of this license or (at your option) any later version.
%% The latest version of this license is in
%%    http://www.latex-project.org/lppl.txt
%% and version 1.3c or later is part of all distributions of LaTeX
%% version 2005/12/01 or later.
%% 
%% 
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
% Actually needs LuaLaTeX, at least version 0.95 from TeXLive 2016.
\ProvidesClass{novel}[2017/09/21 v1.40.2 LaTeX document class]
%%

%% Version 1.40: removed `debug' option (was not useful). Major docs rewrite.

%% Version 1.38: corrected offset in cover artwork; some docs modified.

%% Version 1.36: minor documentation correction.

%% Version 1.34: Added debug class option and related code. [Later removed.]

%% Version 1.32 includes a minor documentation fix, and a major bug fix
%% concerning looose text tracking. The bug occasionally appeared when
%% page headings were compiled, but gave a cryptic error message
%% about MT@res@a. The fix is expected to be permanent.

%% Version 1.2: Added capability for cover artwork.

%% Versions 1.1.x: First general release, occasional documantation changes.


%% DESCRIPTION:
%% Class `novel' is designed for print fiction: novels or short stories.
%% It cannot be used for e-books or for journal publication.
%% It is not suitable for most non-fiction, because routine academic features
%% such as bibiography and automatic sectioning are defeated.
%%
%% There are pre-configured layouts for the most commonly used choices of
%% trim size (finished book width and height), and internal layout consistent
%% with fiction. The user can over-ride the pre-configured settings.
%%
%% The class will automatically create PDF/X compliant files upon request,
%% using a self-contained command structure. Results have been tested.
%%
%% LuaLaTeX is required, and input files must be encoded utf-8.
%%
%% Fonts are loaded by luaotfload and fontspec, and massaged by microtype.
%% For best results, use modern Open Type fonts, or TrueType fonts.
%%
%% The Libertinus font family, a fork of [Linux] Libertine/Biolinum,
%% is the default. Actually, I recommend it! In addition, an included
%% custom font, NovelDeco.otf, is used for special purposes.
%%


%% REQUIRE LUATEX and do some preliminary setup.
%% -----------------------------------------------------------------------------
%% These are not user settings.
%
\RequirePackage{ifluatex} % LuaTeX is required. Not XeTeX, dvips, or pdfTeX.
\RequirePackage{luatex85} % Needed for compatibility when using LuaTeX 0.95 etc.
\RequirePackage{pdftexcmds} % compatibility
\ifluatex
  % New with TeXlive 2016. Removes unnecessary File Data:
  \pdfvariable suppressoptionalinfo 511 % writes only ID to PDF Catalog
\else
  \ClassError{novel}{Must compile with LuaLaTeX 0.95+}{Sorry, LuaLaTeX only.%
    No pdfTeX, dvips, or XeTeX.}
\fi
%
\RequirePackage{etoolbox} % general good stuff
\RequirePackage{xifthen} % improved ifthenelse handling
\RequirePackage{xstring} % parses strings
\RequirePackage{fp} % used everywhere for math calculations
\FPmessagesfalse % eliminates numerous friendly messages from the log
%
\pdfminorversion=3 % might be reset later, depending on settings
\gdef\thepdfminorversion{\pdfminorversion}
%
\RequirePackage{silence} % Used here:
% hyperref draft mode is always on, even when novel is not in draft mode:
\WarningFilter{hyperref}{Draft mode on} % So, get rid of the hyperref warning.
% Prevent complaints about no protrusion list for cmr, cmm, etc. in decimal pts:
\WarningFilter{microtype}{I cannot find a protrusion list} % It's not there!
%
\WarningsOff[Fancyhdr,fancyhdr] % complains about headheight when no header
\RequirePackage[relative]{textpos} % for inserting images
\RequirePackage{noindentafter} % for unindented chapter and scene starts
\RequirePackage{calc} % allows length expression calculations
\RequirePackage{changepage} % block indents, etc.
\RequirePackage{atbegshi} % for one-page header changes. Also used by hyperref.
\RequirePackage{letltxmacro} % for re-defining some macros
\RequirePackage{magaz} % special treatment of first lines
\RequirePackage{changepage} % for adjusted text widths. Do not use strict!
\RequirePackage{xparse} % for writing cool-looking commands
%
% In addition, the following packages are required, but they are not loaded now.
% They must wait for something else to happen first. They will be loaded
% with suitable arguments, when the time comes:
% fontspec -- in novel-LayoutSettings.sty
% unicode-math -- in novel-LayoutSettings.sty
% eso-pic -- in novel-CalculateLayout.sty
% polyglossia -- in novel-FontDefaults.sty
% microtype -- in novel-FontDefaults.sty
% hyperref -- in novel-pdfx.sty
% fancyhdr -- in novel.HeadFootStyles.sty
% xcolor -- lower in this page
% adjustbox -- lower on this page
% eso-pic -- lower on this page
% lipsum -- later on this page
%%


%% Process document class options.
%% -----------------------------------------------------------------------------
% Allowed option list:
%   draft xml shademargins graytext greytext cropmarks cropview closecrop
%   coverart unblock
% Yes, I realize that this could have been done another way:
\gdef\@mycol{\@classoptionslist}
\StrDel{\@mycol}{ }[\@mycol]
\StrDel{\@mycol}{,}[\@mycol]
\StrDel{\@mycol}{draft}[\@mycol]
\StrDel{\@mycol}{xml}[\@mycol]
\StrDel{\@mycol}{shademargins}[\@mycol]
\StrDel{\@mycol}{graytext}[\@mycol]
\StrDel{\@mycol}{greytext}[\@mycol]
\StrDel{\@mycol}{cropmarks}[\@mycol]
\StrDel{\@mycol}{cropview}[\@mycol]
\StrDel{\@mycol}{closecrop}[\@mycol]
\StrDel{\@mycol}{coverart}[\@mycol]
\StrDel{\@mycol}{debug}[\@mycol] % obsolete
\StrDel{\@mycol}{unblock}[\@mycol]
%
\ifthenelse{\equal{\@mycol}{}}{}{
  \ClassWarning{novel}{Unrecognized class option: \@mycol^^J%
   The unrecognized option was ignored!^^J%
   If `debug' it is obsolete from v.1.40.^^J%
   Note that font point size and document size^^J%
   are not novel class options. See documentation.}%
}
%
% If used, option `draft' shows overflow rule.
\newif \if@useDraftMode
\setlength\overfullrule{0pt}
\DeclareOption{draft}{
  \setlength\overfullrule{6pt}
  \@useDraftModetrue
  \ClassWarning{novel}{Compiled using draft mode. Not for final release!^^J}
}
% If used, option `xml' creates a file `\jobname-XMPasXML.xml` that contains
% the XMP metadata with an xml declaration and comments at top.
% Only works when \SetPDFX is not `off'.
\newif \if@wantXMPasXML
\DeclareOption{xml}{
  \@wantXMPasXMLtrue
}
\DeclareOption{xmp}{ % in case you mis-type.
  \ClassError{novel}{No class option `xmp'. Want `xml' ?^^J}%
   {There is no class option named `xmp'. It is `xml'.^^J}
}
% Option `shademargins' does just that. Ignored unless in draft mode.
% Does not matter if `graytext' option in use.
\newif \if@shademargins
\DeclareOption{shademargins}{
  \@shademarginstrue
}
% Option `graytext' allows text in grayscale. Images unaffected.
% If this option is not used, all text will be K black.
\newif \if@graytext
\DeclareOption{graytext}{
  \@graytexttrue
}
% For the Brits:
\DeclareOption{greytext}{
  \@graytexttrue
}
% Usually you do NOT want crop (trim) marks. Configurable by \SetCropMarks[]{}.
\newif \if@cropmarks
\DeclareOption{cropmarks}{
  \@cropmarkstrue
}
% The cropview sets PDF CropBox equal to TrimBox instead of MediaBox.
% Only makes a difference when MediaBox is larger than TrimBox.
% Ignored unless in draft mode.
\newif \if@cropview
\DeclareOption{cropview}{
  \@cropviewtrue
}
% With closecrop, the TrimSize and margins are re-sized, to preserve the
% live area, but with reduced margins on all sides (same for verso/recto).
% This option is available only in draft mode, and disables shademargins.
% The purpose is to create a PDF that is more easily read on a handheld device,
% so you can think about edits while traveling. It is NOT an e-book, since
% it has no hyperlinks and is missing some features that an e-book should have.
\newif \if@closecrop
\DeclareOption{closecrop}{
  \@cropviewtrue\@closecroptrue
}
% New in version 1.2: coverart option. See documentation page 10.
% This is used to create a 1-page file with no text, just an image.
% Intended purpose is PDF/X for novel cover. See docs page 10.
\newif \if@coverart
\DeclareOption{coverart}{
  \@coverarttrue
}
% New in version 1.34: unblock option, for developer use only.
% Normally, a number of packages known to be incompatible with this document class
% are blocked from loading. If the user tries to get them via \usepackage
% or \RequirePackage, or if they are called within some other loaded package,
% then compile halts with an error. The `unblock' option turns off blocking,
% and allows incompatible packages to load. Use only at own risk!
\newif \if@novelunblock % For developer use.
\DeclareOption{unblock}{
  \@novelunblocktrue
}
%% Note that document size and normal font size are not class options.
%% They are set by commands in the Preamble, and have default values.
%
\ProcessOptions\relax
% Disable some options, depending on compatibilities:
\if@useDraftMode\else
  \global\@shademarginsfalse
  \global\@cropviewfalse
  \global\@closecropfalse
\fi
%
\if@cropview
  \global\@cropmarksfalse
\fi
%
\if@closecrop
  \global\@cropviewtrue
  \global\@shademarginsfalse
  \global\@cropmarksfalse
\fi
%
\if@coverart
  \global\@useDraftModefalse
  \global\@shademarginsfalse
  \global\@cropviewfalse
  \global\@closecropfalse
  \global\@graytextfalse
\fi
%% end class options


%% Activate xcolor, adjustbox, and eso-pic:
%% -----------------------------------------------------------------------------
% The final book must be monochrome (black and white only) for all text
%   and vector graphics, unless option `graytext' is used.
% Vector graphics are discouraged, in any case. See Page 9.
% You can use grayscale (single channel, not RGB gray) raster images.
% In draft mode only, the `shademargins' option
%   requires grayscale, so it is temporarily enabled.
\newif \if@grayenabled
%
\if@useDraftMode
  \RequirePackage[gray,hyperref]{xcolor} % allows some layout checks
  \global\@grayenabledtrue
\else
  \if@graytext
    \RequirePackage[gray,hyperref]{xcolor} % black/white book block
    \global\@grayenabledtrue
  \else
    \RequirePackage[monochrome,hyperref]{xcolor} % black/white book block
  \fi
\fi
% adjustbox and eso-pic cannot precede xcolor.
\RequirePackage{adjustbox} % for scaling and moving
\RequirePackage{eso-pic} % background effects in draft mode
%
%% end activate xcolor and adjustbox


%% Temporary normal font size
%% -----------------------------------------------------------------------------
%% This normalsize is temporary, so that packages can load without complaint.
%% It will be modified later, during layout calculations.
\def\Current@FontSizeNum{10}
\def\Current@BaselineSkipNum{13}
\renewcommand\normalsize{%
  \@setfontsize\normalsize{\Current@FontSizeNum}{\Current@BaselineSkipNum}%
}
\normalsize
%
\RequirePackage{lipsum} % for examples
%
%% end temporary normal point size and baselineskip


%% Define commands used for File Data, including PDF/X Settings.
%% -----------------------------------------------------------------------------
%% As used here, `File Data' refers to PDF metadata as found in PDF/Info
%% and in XMP. This class does not write it to the Catalog.
%% Defines commands such as \title{}, not necessarily the same as other TeX.
\RequirePackage{novel-FileData}
%
%%


%% Physical Layout Commands and Settings.
%% -----------------------------------------------------------------------------
%% Define commands that over-ride the class option pre-configured settings.
%% Variety of miscellaneous layout settings such as \parsep, \parindent, etc.
\RequirePackage{novel-LayoutSettings}
%
%%


%% Additional Preamble Settings and Commands.
%% -----------------------------------------------------------------------------
%%
% Macros for use in document body:
\RequirePackage{novel-TextMacros} % part of novel class
% Standard `fancyhdr' header footer styles:
\RequirePackage{novel-HeadFootStyles} % part of novel class
% Chapter and Scene styles:
\RequirePackage{novel-ChapterScene}
% Image placement:
\RequirePackage{novel-Images} % part of novel class
% Footnotes and endnotes:
\RequirePackage{novel-Footnotes} % part of novel class
%%


%% \AtEndPreamble sets defaults and calculates layout
%% -----------------------------------------------------------------------------
%
\AtEndPreamble{
  \RequirePackage{novel-CalculateLayout}
  \RequirePackage{novel-FontDefaults}
  \renewcommand\textls[2][]{#2%
    \typeout{Class `novel' Alert: \string\textls\space ignored on pg \thepage.}%
  } % nullifies this microtype command (problems)
  \RequirePackage{novel-pdfx}%
}
%%


%% \AtBeginDocument finishes the setup
%% -----------------------------------------------------------------------------
%
\AtBeginDocument{ %
  \defaultfontfeatures{} % reset
  % Any other fonts will use these defaults:
  \defaultfontfeatures{%
    SmallCapsFeatures={Renderer=Basic},Kerning=On,%
    Ligatures=TeX,%
  }%
  %
  % Find some useful measurements:
  \gdef\@normalxheight{\heightof{x}}
  \setlength\normalxheight{\@normalxheight}
  \global\normalxheight=\normalxheight
  \gdef\@normalXheight{\heightof{X}}
  \setlength\normalXheight{\@normalXheight}
  \global\normalXheight=\normalXheight
  % Activate user choice of whether or not to indent after scenebreak commands:
  \if@indentAfterScenebreak\else
    \NoIndentAfterCmd{\scenebreak}
    \NoIndentAfterCmd{\sceneline}
    \NoIndentAfterCmd{\scenestars}
  \fi
  %
  \@activateHeadFootStyles % in file `novel-HeadFootStyles.sty'
  \@novelPDFinfo % in file `novel-pdfx.sty'.
  % Commands that cannot be used after Preamble:
  \let\indentAfterScenebreak\relax
  \let\title\relax
  \let\author\relax
  \let\subtitle\relax
  % Dealing with known incompatible packages:
  \if@novelunblock
    \gdef\sorry@no#1{} % let them be used
  \else % block them (default)
    \gdef\sorry@no#1{\@ifpackageloaded{#1}{%
      \ClassError{novel}{Sorry, package `#1' cannot be used}%
      {The `novel' class does not allow use of package `#1'.^^J%
      You must remove it from the Preamble, and also remove its commands^^J%
        from the body of your document. In rare cases, the offending package^^J%
        was loaded by some other package.^^J}%
      }{}%
    }
  \fi
  %
  \sorry@no{pdfx}
  \sorry@no{xmpincl}
  \sorry@no{hyperxmp}
  \sorry@no{pdfxmult}
  \sorry@no{inputenc}
  \sorry@no{fontenc}
  \sorry@no{showkeys}
  \sorry@no{wrapfigure}
  \sorry@no{wrapfig}
  \sorry@no{float}
  \sorry@no{morefloats}
  \sorry@no{footmisc}
  \sorry@no{footnote}
  \sorry@no{manyfoot}
  \sorry@no{caption}
  \sorry@no{subcaption}
  \sorry@no{multirow}
  \sorry@no{tabu}
  \sorry@no{tabularx}
  \sorry@no{tabulary}
  \sorry@no{array}
  \sorry@no{booktabs}
  \sorry@no{eqparbox}
  \sorry@no{pdfpages}
  \sorry@no{nth}
  \sorry@no{engord}
  \sorry@no{endnotes}
  %%

  %%
  %% Pertains to novel-LayoutSettings.sty:
  \ifcsname pagenumberstyle\endcsname\else
    \SetPageNumberStyle{\thepage}
  \fi
  %
  \def\@setchapterstartOK{false}%
  \ifthenelse{\equal{\@setchapterstart}{empty}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{plain}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{footer}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{fancyplain}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{fancy}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{forcenumber}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{dropfolio}}{% no footnote there
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{dropfoliolater}}{% footnote(s) there
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstart}{foliobeneath}}{%
    \def\@setchapterstartOK{true}%
  }{}%
  \ifthenelse{\equal{\@setchapterstartOK}{true}}{}{%
    \ClassError{novel}{\string\SetChapterStart\space bad argument}%
    {\string\SetChapterStart\space only allows certain choices.^^J}%
  }%
  %%
  %% Pertains to novel-TextMacros.sty:
  \setlength\forceparlength{\parindent}
  \global\forceparlength=\forceparlength
  \gdef\forceindent{\ifvmode\else\unskip\fi\stake\hspace{\forceparlength}}
  \gdef\backindent{\ifvmode\else\unskip\fi\hspace{-\forceparlength}}
  %%
  %% Pertains to novel-footnotes.sty:
  \gdef\SetFootnoteMarker#1{%
    \typeout{^^JClass `novel' Alert: %
    \string\SetFootnoteMarker\space ineffective after Preamble.^^J}%
  }
  % Must wait for \nbs to be calculated:
  \setlength\footnotesep{0.8\nbs}
  % Must wait for main font and its size to be active:
  \newlength\@hoaring
  \setlength\@hoaring{\heightof{Å}}
  \global\@hoaring=\@hoaring
  \newlength\@twast % tweaks asterisk
  \setlength\@twast{\heightof{*}}
  \addtolength\@twast{-\@hoaring}
  \global\@twast=\@twast
  \newlength\@twdag % tweaks dagger
  \setlength\@twdag{\heightof{†}}
  \addtolength\@twdag{-0.2\@twdag}
  \addtolength\@twdag{-\@hoaring}
  \global\@twdag=\@twdag
  \newlength\@twdbldag % tweaks double dagger
  \setlength\@twdbldag{\heightof{‡}}
  \addtolength\@twdbldag{-0.2\@twdbldag}
  \addtolength\@twdbldag{-\@hoaring}
  \global\@twdbldag=\@twdbldag
  \newlength\@twsect % tweaks section mark
  \setlength\@twsect{\heightof{§}}
  \addtolength\@twsect{-0.2\@twsect}
  \addtolength\@twsect{-\@hoaring}
  \global\@twsect=\@twsect
  \newlength\@tweight % tweaks 8, reliably the tallest digit
  \setlength\@tweight{\heightof{8}}%
  \addtolength\@tweight{-0.2\@tweight}%
  \addtolength\@tweight{-\@hoaring}%
  \global\@tweight=\@tweight%
  % Must wait to see how \SetFootnoteMarker was used:
  \ifthenelse{\equal{\@myfnsymbols}{*}}{\setcounter{@maxfnsymbol}{8}}{}
  \ifthenelse{\equal{\@myfnsymbols}{†}}{\setcounter{@maxfnsymbol}{6}}{}
  %%
}
%%


%% New in version 1.2, coverart option. See docs page 10.
\AfterEndPreamble{
    \if@coverart
      \AddToShipoutPictureBG{%
        \AtPageUpperLeft{%
          \InlineImage{\novelcoverimage}% Version 1.38 corrected erroneous starred command here.
        }%
      }
      \null% without this, page has no "content"
    \fi
}
%%


%% AtBeginShipout occurs at the completion of each page layout, in document body.
\AtBeginShipout{%
  \gdef\@fnafter{}% Pertains to some standard LaTeX footnote code.
  \stepcounter{runningpages}%
  \global\@thispagestylesetfalse%
}
%%


%%
%% End of file `novel.cls'

