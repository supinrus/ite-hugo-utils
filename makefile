ARCH := $(shell uname -m)
OS   := $(shell uname -s)

build:
	mkdir -p bin
	fpc archive/bigfile/bigfileunpacker.pas -obin/bigfileunpacker
	fpc archive/hugo5dos/unpackhugo5dat.pas -obin/unpackhugo5dat
	fpc archive/hugo4dos/unpackhugo4dat.pas -obin/unpackhugo4dat
	fpc archive/hugo_magick_oak/resdatunpack.pas -obin/resdatunpack
	fpc archive/iteres/iteresunpack.pas -obin/iteresunpack
	fpc archive/hugo3dos/unpack4hugo.pas -obin/unpack4hugo
	fpc archive/skaermtrolden_hugo_dat/pack.pas -obin/pack
	fpc archive/skaermtrolden_hugo_dat/unpack2.pas -obin/unpack2
	fpc archive/hugoxl/unpackmiscdat.pas -obin/unpackmiscdat
	fpc archive/hugoxl/unpack_sbk.pas -obin/unpack_sbk
	fpc config/hugoxl/unpack_cfb.pas -obin/unpack_cfb
	fpc sync/oos/txt2oos.pas -obin/txt2oos
	fpc sync/oos/oos2txt.pas -obin/oos2txt
	fpc graphics/cbr/cbr2bmp.pas -obin/cbr2bmp
	fpc graphics/brs/brs2bmp.pas -obin/brs2bmp
	fpc graphics/skaermtrolden_speach_cloud/decodespeach2.pas -obin/decodespeach2
	fpc graphics/skaermtrolden_speach_cloud/encodespeach.pas -obin/encodespeach
	fpc graphics/lzp/lzp2bmp.pas -obin/lzp2bmp
	fpc graphics/cgf/cgf2bmp.pas -obin/cgf2bmp
	fpc graphics/til/til2bmp.pas -obin/til2bmp
	fpc graphics/pbr/pbr2bmp.pas -obin/pbr2bmp
	rm bin/*.o

targz:
	tar -czf ite-hugo-utils-${OS}-${ARCH}.tar.gz -C bin .
	
clean:
	rm -rf bin
	find . -name "*.o" -exec rm -f {} \;