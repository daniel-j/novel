
.PHONO := default archive archive-tds testsuite borderland
SHELL := /bin/bash -O extglob

default: archive archive-tds

archive:
	@# Build simple archive
	rm -rf novel
	mkdir -p novel
	cp -r {tex/.,doc,fonts,README.md,LICENSE} novel/
	mkdir -p novel/doc/extras/novel-scripts/input
	cp -r scripts/!(output|input|temp) novel/doc/extras/novel-scripts/
	rm -f novel.zip
	zip -9 -r novel.zip novel -x *.DS_Store* -x *.gitkeep*
	rm -rf novel

archive-tds:
	@# Build archive with TeX Directory Structure
	rm -rf novel.tds
	mkdir -p novel.tds/{doc/lualatex,fonts/opentype,tex/lualatex}/novel
	cp -r doc/. novel.tds/doc/lualatex/novel/
	mkdir -p novel.tds/doc/lualatex/novel/extras/novel-scripts/input
	cp -r scripts/!(output|input|temp) novel.tds/doc/lualatex/novel/extras/novel-scripts/
	cp -r fonts/. novel.tds/fonts/opentype/novel/
	cp -r tex/. novel.tds/tex/lualatex/novel/
	cp README.md LICENSE novel.tds/tex/lualatex/novel/
	rm -f novel.tds.zip
	cd novel.tds && zip -9 -r ../novel.tds.zip . -x *.DS_Store* -x *.gitkeep*
	rm -rf novel.tds

clean:
	rm -f novel.zip novel.tds.zip
	rm -rf build novel.tds novel

testsuite:
	mkdir -p build
	cd doc/extras/ && \
	OPENTYPEFONTS=../../fonts/:$(shell kpsewhich -var-value OPENTYPEFONTS) \
	TEXINPUTS=../../tex/:$(shell kpsewhich -var-value TEXINPUTS) \
	lualatex --output-directory=../../build ./novel-testsuite.tex

borderland:
	mkdir -p build
	@# The loop makes sure that page numbers gets correct values in toc
	@# It has to compile twice
	for n in {1..2}; do \
		cd other/house-on-the-borderland/ && \
		OPENTYPEFONTS=../../fonts/:$(shell kpsewhich -var-value OPENTYPEFONTS) \
		TEXINPUTS=../../tex/:$(shell kpsewhich -var-value TEXINPUTS) \
		lualatex --output-directory=../../build ./borderland.tex; \
	done
