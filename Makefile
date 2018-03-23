
.PHONO := zip testsuite borderland

zip:
	zip -r novel.zip doc fonts tex

testsuite:
	TEXINPUTS=./tex/lualatex/novel/:./doc/lualatex/novel/extras/:$(shell kpsewhich -var-value TEXINPUTS) lualatex --output-directory=./build ./doc/lualatex/novel/extras/novel-testsuite.tex

borderland:
	@# The loop makes sure that page numbers gets correct values in toc
	@# It has to compile twice
	for n in {1..2}; do	TEXINPUTS=./tex/lualatex/novel/:./other/house-on-the-borderland/:$(shell kpsewhich -var-value TEXINPUTS) lualatex --output-directory=./build ./other/house-on-the-borderland/borderland.tex; done
