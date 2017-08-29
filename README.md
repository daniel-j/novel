# novel
LuaLaTeX document class for fiction, such as novels and short story collections.


## Version

The current stable version is 1.38. It is available via TeX package managers, or from CTAN. Note that this package is not (yet) distributed in default TeX installations. You have to request it.

The *novel* class requires TeXLive 2016 or later, or recent MiKTeX.


### What's Here

Folders *doc*, *tex*, and *fonts* contain development versions of code that may subsequently be available in an updated version of the package.

The *archive* folder contains one or more zip files of prior stable code. This may be useful if you are in the middle of a project, and a package update causes problems.

The *extras* folder contains material that is not part of the TeX package, but might be useful.


#### Shameless Plug

Since GitHub's Terms of Service (item K.2) appear to allow this, I'll shamelessly plug an actual novel that I wrote using the *novel* document class. Nearly all of its settings are defaults for this class, so the Preamble is amazingly short. The resulting book file validates as PDF/X-1a:2001. The cover artwork was prepared using Inkscape and GIMP to prepare a png image. The image was processed to CMYK at SWOP 240% ink limit using GraphicsMagick, per the instructions in *novel* class documentation. Then the image was converted to PDF/X-1a:2001, using the *novel* class.

The uploaded files were submitted for automated review and accepted on the very first attempt. *The Werewolf of Barbary Arc,* by Roberta Ligando (pseudonym), is now in print. It is humorous and romantic, not horror. Unlikely to be of interest to the kind of folks who use TeX and GitHub. Your mom might like it. The correct edition has the image of a wine glass on its cover (there was an obsolete older version).

Moral: The *novel* document class is tested and it works.

Additional moral: No doubt some authors will use it in a way that reveals a bug that I didn't encounter. Use GitHub to raise an issue.


#### Help Wanted

TeX may be long in the tooth, but so am I. Sooner or later I will move on to other things. If you are interested in taking over package maintenance, contact me (and CTAN). You'll need a basic understanding of how things work in commercial printing (especially P.O.D.), familiarity with LuaTeX and especially fontspec, familiarity with Open Type fonts, understanding of PDF/X, and familiarity with the needs of fiction writers. You don't need to know Lua code. You don't need to know any stinking math or physics.


