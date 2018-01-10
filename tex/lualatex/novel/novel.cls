%%
%% This is file `novel.cls', part of class `novel'.
%% Copyright 2017 Robert Allgeyer.  Contact:  anytthree [at] gmail.com
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
\ProvidesClass{novel}[2018/01/08 v1.46.5y LaTeX document class]
%%
%% Version 1.46: Possibly final version.
%% Version 1.43: General cleanup of docs and code, for improved readbaility.
%% Version 1.42: Greatly improved HTML documentation.
%% Version 1.41: Improved HTML documentation.
%% Versions 1.40.x: Incremental minor changes, leading to 1.42.
%% Version 1.40: removed `debug' option (was not useful). Major docs rewrite.
%%   This version was successfully used for a P.O.D. novel, with cover.
%% Version 1.38: corrected offset in cover artwork; some docs modified.
%% Version 1.36: minor documentation correction.
%% Version 1.34: Added debug class option and related code. [Later removed.]
%% Version 1.32 includes a minor documentation fix, and a major bug fix
%%   concerning looose text tracking. The bug occasionally appeared when
%%   page headings were compiled, but gave a cryptic error message
%%   about MT@res@a. The fix is expected to be permanent.
%% Version 1.2: Added capability for cover artwork.
%% Versions 1.1.x: First general release, occasional documentation changes.


%% DESCRIPTION:
%% ----------------------------------------------------------------------------
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
%% ----------------------------------------------------------------------------
%% These are not user settings.
%
\RequirePackage{ifluatex} % LuaTeX is required. Not XeTeX, dvips, or pdfTeX.
\RequirePackage{ifxetex} % For occasional hacks (hiss, boo).
\RequirePackage{luatex85} % Needed for compatibility with LuaTeX 0.95 etc.
\RequirePackage{pdftexcmds} % compatibility
\ifluatex
  % New with TeXlive 2016. Removes unnecessary File Data:
  \pdfvariable suppressoptionalinfo 511 % writes only ID to PDF Catalog
\else
  \ClassError{novel}{Must compile with LuaLaTeX 0.95+}%
   {Sorry, LuaLaTeX only. No pdfTeX, dvips, or XeTeX.}
\fi
%
\RequirePackage{etoolbox} % general good stuff
\RequirePackage{xifthen} % improved ifthenelse handling
\RequirePackage{xstring} % parses strings
\RequirePackage{fp} % used everywhere for math calculations
\RequirePackage{xfp} % more math calculations
\RequirePackage{keyval} % used by drop cap
\FPmessagesfalse % eliminates numerous friendly messages from the log
%
\pdfminorversion=3 % might be reset later, depending on settings
\gdef\thepdfminorversion{\pdfminorversion} % compatibility
%
\RequirePackage{silence} % Used here:
% hyperref draft mode is always on, even when novel is not in draft mode:
\WarningFilter{hyperref}{Draft mode on} % So, get rid of the hyperref warning.
% Prevent complaints about no protrusion list for cmr, cmm, etc. in decimal pt:
\WarningFilter{microtype}{I cannot find a protrusion list} % It's not there!
%
\WarningsOff[Fancyhdr,fancyhdr] % complains about headheight when no header
\RequirePackage[relative]{textpos} % for inserting images
\RequirePackage{noindentafter} % for unindented chapter and scene starts
\RequirePackage{calc} % allows length expression calculations
\RequirePackage{changepage} % provides block indents, etc. Do not use strict!
\RequirePackage{atbegshi} % for one-page header changes. Also used by hyperref.
\RequirePackage{letltxmacro} % for re-defining some macros
\RequirePackage{magaz} % special treatment of first lines
\RequirePackage{xparse} % for writing cool-looking commands
%
% In addition, the following packages are required, but not loaded yet.
% They must wait for something else to happen first. Then they will be loaded
%   with suitable arguments, when the time comes:
% fontspec -- in novel-LayoutSettings.sty
% unicode-math -- in novel-LayoutSettings.sty
% polyglossia -- in novel-LayoutSettings.sty
% microtype -- in novel-Fonts.sty
% hyperref -- in novel-pdfx.sty
% fancyhdr -- in novel.HeadFootStyles.sty
% xcolor -- lower in this page
% adjustbox -- lower on this page
% eso-pic -- lower on this page
% lipsum -- lower on this page
%%


\newlength\@tempLength % scratch length for local calculations
\newif \if@tempTF % scratch boolean for local tests


%% Global lengths are often passed around in `novel'.
%% But \setlength is not always global in effect.
%% This code defines a global command.
%% Via Heiko Oberdiek at tex.stackexchange.com:
\gdef\gsetlength#1#2{% #1 is the length command, #2 is the length value
  \begingroup%
    \setlength\skip@{#2}% Local assignment to a TeX scratch register.
    \global#1=\skip@% Global assignment to #1
  \endgroup% \skip@ is restored by end of group.
}% end \gsetlength
%%

%% Helps to avoid underfull vbox warnings when using certain environments:
\LetLtxMacro\@MyClearpage\clearpage\relax
\gdef\clearpage{\vfill\@MyClearpage} % \vfill beats \vfil
%%


%% Process document class options.
%% ----------------------------------------------------------------------------
% Allowed option list:
%   draft xml shademargins graytext greytext cropmarks cropview closecrop
%   coverart unblock mtoff polyoff test
% Yes, I realize that this could have been done another way, but I want
%   to issue error messages from `novel' rather than (say) `keyval':
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
\StrDel{\@mycol}{unblock}[\@mycol]
\StrDel{\@mycol}{mtoff}[\@mycol]
\StrDel{\@mycol}{polyoff}[\@mycol]
\StrDel{\@mycol}{test}[\@mycol]
%
\ifthenelse{\equal{\@mycol}{}}{}{
  \ClassWarning{novel}{^^JUnrecognized class option: \@mycol. ^^J%
   The unrecognized option was ignored! ^^J%
   If `debug' it is obsolete from v.1.40. ^^J%
   Note that font size, document size, and language ^^J%
   are not `novel' class options. See documentation. ^^J}%
}
% If used, option `draft' shows overflow rule.
% Prior to v. 1.46.1, the following was \if@useDraftMode.
% Changed for possible compatibility with packages that detect draft mode.
\newif \ifdraftdoc
\setlength\overfullrule{0pt}
\DeclareOption{draft}{
  \setlength\overfullrule{6pt}
  \draftdoctrue
  \ClassWarning{novel}{^^JCompiled with draft mode. Not for final release! ^^J}
}
\newif \ifmsdoc % manuscript, always false. Compatibility with other packages.
% If used, option `xml' creates a file `\jobname-XMPasXML.xml` that contains
% the XMP metadata with an xml declaration and comments at top.
% Only works when \SetPDFX is not `off'. Note that you do not need to use
% this option to get PDF/X. It is only for your own usage.
\newif \if@wantXMPasXML
\DeclareOption{xml}{\@wantXMPasXMLtrue}
\DeclareOption{xmp}{ % in case you mis-type.
  \ClassError{novel}{No class option `xmp'. Use `xml'}%
   {There is no class option named `xmp'. It is `xml'.}
}
% Option `shademargins' does just that. Ignored unless in draft mode.
% Does not matter if `graytext' option in use.
\newif \if@shademargins
\DeclareOption{shademargins}{\@shademarginstrue}
% Option `graytext' allows text in grayscale. Images unaffected.
% If this option is not used, all text will be K black.
\newif \if@graytext
\DeclareOption{graytext}{\@graytexttrue}
% For the Brits:
\DeclareOption{greytext}{\@graytexttrue}
% Usually you do NOT want crop (trim) marks!
% Configurable by \SetCropMarks[]{}.
\newif \if@cropmarks
\DeclareOption{cropmarks}{\@cropmarkstrue}
% PDF viewers display CropBox, which normally is identical to MediaBox.
% Option `cropview', sets CropBox to TrimBox instead, so that's all you see.
% Only makes a difference when MediaBox is larger than TrimBox.
% Ignored unless in draft mode.
\newif \if@cropview
\DeclareOption{cropview}{\@cropviewtrue}
% With `closecrop', the TrimSize and margins are re-sized, to preserve the
% live area, but with reduced margins on all sides (same for verso/recto).
% This option is available only in draft mode, and disables shademargins.
% The purpose is to create a PDF that is more easily read on a handheld device,
% so you can think about edits while traveling. It is NOT an e-book, since
% it has no hyperlinks and is missing some features that an e-book should have.
\newif \if@closecrop
\DeclareOption{closecrop}{\@cropviewtrue\@closecroptrue}
% New in version 1.2: `coverart' option. See documentation.
% This is used to create a 1-page file with no text, just an image.
% Intended purpose is PDF/X for novel cover.
\newif \if@coverart
\DeclareOption{coverart}{\@coverarttrue}
% New in version 1.34: unblock option, for developer use only.
% Normally, a number of packages known to be incompatible with `novel'
% are blocked from loading. If the user tries to get them via \usepackage
% or \RequirePackage, or if they are called within some other loaded package,
% then compile halts with an error. The `unblock' option turns off blocking,
% and allows incompatible packages to load. Use only at own risk!
\newif \if@novelunblock % For developer use.
\DeclareOption{unblock}{\@novelunblocktrue}
% New in version 1.44: mtoff option, primarily for developer use.
% With mtoff, the microtype package is not loaded.
\newif \if@mtoff
\DeclareOption{mtoff}{\@mtofftrue}
% New in version 1.44: polyoff option, primarily for developer use.
% With polyoff, the polyglossia package is not loaded.
% You may need to load babel, or not, via \RequirePackage[options]{babel}.
\newif \if@polyoff
\DeclareOption{polyoff}{\@polyofftrue}
% New in version 1.46: test option, primarily for developer use.
\newif \if@testsuite
\DeclareOption{test}{\@testsuitetrue}
%
% New in version 1.48: Designer Mode.
% Allows some things that would otherwise be banned in a full novel.
% Limits page output to three (fixed cover, user verso, user recto).
% Allows design of things such as tables, then PDF can be rasterized
%   in a graphics program, and images placed in the novel.
\newif \if@DesignerMode
\DeclareOption{designer}{\@DesignerModetrue}
%
%% Note that document size and normal font size are not class options.
%% They are set by commands in the Preamble, and have default values.
%
\ProcessOptions\relax
% Disable some options, depending on compatibilities:
\ifdraftdoc\else
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
  \global\draftdocfalse
  \global\@shademarginsfalse
  \global\@cropviewfalse
  \global\@closecropfalse
  \global\@graytextfalse
\fi
\if@DesignerMode
  \@novelunblocktrue
\fi
%% end class options


%% Activate xcolor, adjustbox, and eso-pic:
%% ----------------------------------------------------------------------------
% The final book must be monochrome (black and white only) for all text,
%   unless option `graytext' is used. Then, grayscale text is permitted.
% Interior images must be raster monochrome or grayscale, whether or not
%   the `graytext' option is used. See documentation.
%   Vector graphics are strongly discouraged, in any case.
% In draft mode only, the `shademargins' option requires `grayscale',
%   which will be temporarily enabled, even if not specifically requested.
\newif \if@grayenabled
\ifdraftdoc
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
%% end activate xcolor and adjustbox


%% Temporary normal font size, baselineskip, and fontspec
%% ----------------------------------------------------------------------------
%% This normalsize is temporary, so that packages can load without complaint.
%% It will be modified later, during layout calculations.
%% Actual default font size will be 11pt-12pt, with 11.4pt average.
%% The small temporary size is to ensure that overly-large struts and skips
%%   are not created prior to page layout calculation.
\gdef\@TentativeEmN{10}
\gdef\@TentativeBLSkipN{13}
\renewcommand\normalsize{%
  \@setfontsize\normalsize{\@TentativeEmN}{\@TentativeBLSkipN}%
}
\normalsize
\RequirePackage[no-math]{fontspec} % For LuaLaTeX. NOT package `fontenc'.
% The `novel' class is not intended for math. But TeX assumes you do math,
%   so it needs a math font, whether you like it or not.
\RequirePackage{unicode-math}
%% end temporary normal point size, baselineskip, and fontspec.


%% Define commands used for File Data, including PDF/X Settings.
%% ----------------------------------------------------------------------------
%% As used here, `File Data' refers to PDF metadata as found in PDF/Info
%% and in XMP. This class does not write it to the PDF Catalog.
\RequirePackage{novel-FileData}
%%


%% Physical Layout Commands and Settings.
%% ----------------------------------------------------------------------------
%% Define user commands that over-ride class option pre-configured settings.
%% Also sets a variety of miscellaneous lengths:s \parsep, \parindent, etc.
\RequirePackage{novel-LayoutSettings}


%% polyglossia
% Language-specific settings:
\if@polyoff % polyoff is new in v 1.44.
  \ClassWarning{novel}{^^JYou chose the `polyoff' class option. ^^J%
    So, the polyglossia package was not loaded. But like it or not, ^^J%
    the babel package was loaded, with generic hyphenation. ^^J%
    This behavior, or choice of language, cannot be changed. ^^J%
    If you want a specific language, you will have to use polyglossia. ^^J}%
\else
  \RequirePackage{polyglossia} % loading order changed in v. 1.40.3.
  \setdefaultlanguage[variant=american]{english} % may be changed by user
\fi
%% end polyglossia


%%


%% Additional Macros, Loaded in Preamble.
%% ----------------------------------------------------------------------------
\RequirePackage{novel-Fonts} % font settings and defaults
\RequirePackage{lipsum} % generates dummy text for examples
%% New in version 1.48:
\RequirePackage{novel-DropCap}
% Macros for use in document body:
\RequirePackage{novel-TextMacros}
% Standard header footer styles, based on `fancyhdr':
\RequirePackage{novel-HeadFootStyles}
% Chapter and Scene styles:
\RequirePackage{novel-ChapterScene}
% Image placement:
\RequirePackage{novel-Images}
% Footnotes and endnotes:
\RequirePackage{novel-Footnotes}
%%


%% Special features of test suite (for developers and error reporting)
%% ----------------------------------------------------------------------------
% Files `novel-testsuite.tex' and `novel-testimage.png' are within the novel
%   documentation extras folder. To run the test suite, copy these files to
%   a writeable location (such as your home directory) and compile there.
\newcommand\testsuiteoops[1]{%
  \ClassError{novel}{#1 missing}{Install the necessary file(s).}%
}
\if@testsuite
  \IfFontExistsTF{libertinusserif-regular.otf}{}{%
    \testsuiteoops{`libertinus' fonts}%
  }
  \IfFileExists{lmodern.sty}{}{\testsuiteoops{`lmodern' package}}
  \IfFileExists{novel-testimage.png}{}{\testsuiteoops{`novel-testimage.png'}}
  \NewFontFamily\mustbelibertinus{Libertinus Serif}
  \NewFontFamily\mustbelmodern{Latin Modern Roman}
\fi
%% end special features of test suite.


%% Designer mode.
% Thanks to user `Compholio' at stackoverflow.com
\newcounter{@DesignerPage}
\if@DesignerMode
  \newcommand{\@DesignerPages}[1]{%
    \setcounter{@DesignerPage}{0}%
    \gdef\maxpages{#1}%
    \ifx\latex@outputpage\@undefined\relax%
        \global\let\latex@outputpage\@outputpage%
    \fi%
    \gdef\@outputpage{%
        \stepcounter{@DesignerPage}%
        \ifnum\value{@DesignerPage}>\maxpages\relax%
            % Do not output the page
        \else%
            \latex@outputpage%
        \fi%
    }%
  }
  \@DesignerPages{3} % cover, verso, recto
  \AfterEndPreamble{%
    \null\null
    \charscale[1.6]{DESIGNER MODE}\par
    \null
    Portion of artwork for this book:\par
    Title: \theTitle\par
    Author: \theAuthor\par
    \null
    Info:\par
    \@DesignerLabel\par
    \null
    Timestamp: \pdfcreationdate\par
    \clearpage%
  }%
\fi
%% end designer mode.


%% \AtEndPreamble sets defaults, calculates layout, and writes PDF/X
%% ----------------------------------------------------------------------------
% This is prior to \AtBeginDocument, and ensures that the results are available
%   prior to any \AtBeginDocument routines from user macros or loaded packages. 
\AtEndPreamble{
  \@ActivateFlexResolution % in `novel-Images.sty'
  \@ActivateFonts % in `novel-Fonts.sty'
  \RequirePackage{novel-CalculateLayout} % may load novel-ChangeLayout.sty
  \RequirePackage{novel-PostLayout} % calculates shademargins, cropmarks, etc.
  \RequirePackage{novel-pdfx}% also provides an \AtBeginDocument macro
}%
%% end AtEndPreamble


%% \AtBeginDocument finishes the setup
%% ----------------------------------------------------------------------------
\AtBeginDocument{ %
  % Mostly involve settings defaults:
  \@ActivateTextLengths % in `novel-TextMacros.sty'
  \@ActivateDropCaps % in `novel-DropCaps.sty'
  \@ActivateChapterScene % in `novel-ChapterScene.sty'
  \@ActivateHeadFootStyles % in file `novel-HeadFootStyles.sty'
  \@ActivatePDFInfo % in file `novel-pdfx.sty'
  \@ActivateTextMacros % in `novel-TextMacros.sty'
  \@ActivateFootnotes % in `novel-Footnotes.sty'
  % Commands that cannot be used after Preamble:
  \if@DesignerMode
    \@ActivateFontSizes % in file `novel-Layout-Settings.sty'
  \else
    \@DisableFontSizes % in file `novel-LayoutSettings.sty'
    \@DisableIncludeGraphics % in file `novel-Images.sty'
  \fi
  \@DisableLayoutSettings % in file `novel-LayoutSettings.sty'
  \@DisableFileDataSettings % in file `novel-FileData.sty'
  \@DisableChapterSceneSettings % in file `novel-ChapterScene.sty'
  \@DisableHeadFootSettings % in file `novel-HeadFootStyles.sty'
  % Dealing with known incompatible packages:
  \if@novelunblock
    \gdef\sorry@no#1#2#3{} % let them be used, if unblock or DesignerMode
  \else % block them (default)
    \gdef\sorry@no#1#2#3{
      \@ifpackageloaded{#1}{%
       \ClassError{novel}{Sorry, package `#1' cannot be used in `novel' class}%
        {Reason: `novel' has #2 ^^J%
         See `novel' HTML documentation, section #3. ^^J%
         Note: The offending package may have been loaded by another package.}%
      }{}%
    }
  \fi
  \gdef\really@no#1#2#3{ % cannot be used, even with unblock or DesignerMode
    \@ifpackageloaded{#1}{%
     \ClassError{novel}{Sorry, package `#1' cannot be used in `novel' class}%
      {Reason: `novel' has #2 ^^J%
       See `novel' HTML documentation, section #3. ^^J%
       Note: The offending package may have been loaded by another package.}%
    }{}%
  }
  \if@DesignerMode
    \gdef\warn@nodisp#1{}
  \else
    \gdef\warn@nodisp#1{%
      \ClassWarning{novel}{You loaded package `#1'. Some of its commands ^^J%
       may produce unexpected layout in the main document body. ^^J%
       Better if you confine usage to display pages. ^^J}%
    }
  \fi
  % List of blocked packages (not exhaustive, since TeX has so many):
  \really@no{geometry}{its own layout commands.}{4}
  \really@no{pdfx}{built-in PDF/X capability.}{3.4}
  \really@no{xmpincl}{built-in PDF/X capability.}{3.4}
  \really@no{hyperxmp}{built-in PDF/X capability.}{3.4}
  \really@no{pdfxmult}{built-in PDF/X capability.}{3.4}
  \really@no{inputenc}{utf-8 encoding always.}{1.2.1}
  \really@no{fontenc}{`fontspec' and utf-8 encoding always.}{1.2.1, 1.2.3}
  \sorry@no{wrapfig}{its own \string\WrapImage\space command.}{7.3.7}
  \sorry@no{floatflt}{its own \string\WrapImage\space command.}{7.3.7}
  \sorry@no{floatfig}{its own \string\WrapImage\space command.}{7.3.7}
  \sorry@no{float}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{subfig}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{lpic}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{pinabel}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{overpic}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{morefloats}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{placeins}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{flafter}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{endfloat}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{footmisc}{limited built-in footnote methods.}{6.5}
  \sorry@no{footnote}{limited built-in footnote methods.}{6.5}
  \sorry@no{manyfoot}{limited built-in footnote methods.}{6.5}
  \sorry@no{caption}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{sidecap}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{subcaption}{its own \string\FloatImage\space command.}{7.3.6}
  \sorry@no{multirow}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \sorry@no{tabu}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \sorry@no{tabularx}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \sorry@no{tabulary}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \sorry@no{longtable}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \sorry@no{paracol}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \sorry@no{array}{limited, built-in TOC capability.}{1.2.5, 8.3.2.7}
  \really@no{biblatex}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \really@no{showkeys}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \sorry@no{easylist}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \sorry@no{scrextend}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \sorry@no{listings}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \sorry@no{numitem}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \sorry@no{tasks}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \sorry@no{exsheets}{an aversion to academic-style layouts. ^^J
    This has to do with maintining text line grid.}{1.2.5}
  \really@no{booktabs}{no capability for this, due to printer specs.}{3.4}
  \sorry@no{eqparbox}{conflicting layout requirements.}{6.3.1}
  \really@no{pdfpages}{specific requirements that exclude PDF import. ^^J%
    This has to do with file requirements for commercial printers. ^^J%
    You may rasterize a page via graphics program, and place its image.}{3.4}
  \really@no{bookmark}{focus on paper books, not e-books.}{(top of file)}
  %\sorry@no{nth}{}{} %  probably OK, redefinition of \textsuperscript
  %\sorry@no{engord}{}{} %  probably OK, redefinition of \textsuperscript
  \really@no{endnotes}{limited, built-in endnote methods.}{6.5}
  \really@no{acronym}{its own acronym style.}{6.2.4}
  \warn@nodisp{ulem}
  \warn@nodisp{soul}
  % end list of incompatible packages
  \@ifpackageloaded{pagegrid}{
    \ifdraftdoc
      \if@shademargins
        \ClassWarning{novel}{^^JGrid from `pagegrid' is concealed. ^^J%
         Document class option `shademargins' over-writes page grid. ^^J%
         To see the grid, use `draft' but not `shademargins'. ^^J}
      \else\fi
    \else
      \ClassError{novel}{Package `pagegrid' needs `draft' mode}%
       {Package `pagegrid' only with document class option `draft'.}%
    \fi
  }{} % end pagegrid
}% end AtBeginDocument
%%


%% New in version 1.2, coverart option. See documentation.
\AfterEndPreamble{% occurs after \AtBeginDocument
  \if@coverart%
    \AddToShipoutPictureBG{%
      \AtPageUpperLeft{%
        \InlineImage{\novelcoverimage}%
      }%
    }%
    \null% without this, page has no "content"
  \fi%
}%
%%



%%
%% End of file `novel.cls'

