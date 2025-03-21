MAKEFILE_DIR=$(shell pwd)

PAS_FILES=\
"./archive/bigfile/bigfileunpacker" \
"./archive/hugo5dos/unpackhugo5dat" \
"./archive/hugo4dos/unpackhugo4dat" \
"./archive/hugo_magick_oak/resdatunpack" \
"./archive/iteres/iteresunpack" \
"./archive/hugo3dos/unpack4hugo" \
"./archive/skaermtrolden_hugo_dat/pack" \
"./archive/skaermtrolden_hugo_dat/unpack2" \
"./archive/hugoxl/unpackmiscdat" \
"./archive/hugoxl/unpack_sbk" \
"./config/hugoxl/unpack_cfb" \
"./sync/oos/txt2oos" \
"./sync/oos/oos2txt" \
"./graphics/cbr/cbr2bmp" \
"./graphics/brs/brs2bmp" \
"./graphics/skaermtrolden_speach_cloud/decodespeach2" \
"./graphics/skaermtrolden_speach_cloud/encodespeach" \
"./graphics/lzp/lzp2bmp" \
"./graphics/cgf/cgf2bmp" \
"./graphics/til/til2bmp" \
"./graphics/pbr/pbr2bmp"

build:
	mkdir -p $(MAKEFILE_DIR)/bin
	for file in $(PAS_FILES); do \
		cd "$(dirname "$$file")" && \
		fpc -o$$file $$file.pas  && \
		mv $$file $(MAKEFILE_DIR)/bin/; \
	done

clean:
	rm -rf $(MAKEFILE_DIR)/bin
	find . -name "*.o" -exec rm -f {} \;