
.PHONO := zip testsuite borderland

zip:
	rm -f novel.zip
	zip -9 novel.zip LICENSE README.md
	cd novel && zip -9 -r ../novel.zip *

testsuite:
	OPENTYPEFONTS=./novel/fonts/:$(shell kpsewhich -var-value OPENTYPEFONTS) TEXINPUTS=./novel/doc/extras/:./novel/:$(shell kpsewhich -var-value TEXINPUTS) lualatex --output-directory=./build ./novel/doc/extras/novel-testsuite.tex

borderland:
	@# The loop makes sure that page numbers gets correct values in toc
	@# It has to compile twice
	for n in {1..2}; do	OPENTYPEFONTS=./novel/fonts/:$(shell kpsewhich -var-value OPENTYPEFONTS) TEXINPUTS=./other/house-on-the-borderland/:./novel/:$(shell kpsewhich -var-value TEXINPUTS) lualatex --output-directory=./build ./other/house-on-the-borderland/borderland.tex; done
