all: dmenu/dmenu emoji.txt

dmenu/dmenu: dmenu libxft/src/.libs/libXft.a
	make -C $<

dmenu:
	git clone --branch 5.0 https://git.suckless.org/dmenu
	patch -d $@ < dmenu.patch
	@# Add existing files to the Git index to make it easier to
	@# build a user customization patch of the config.
	git -C $@ add -u

libxft/src/.libs/libXft.a: libxft
	cd $< && ./autogen.sh && make SUBDIRS=src

libxft: libxft-bgra.patch
	git clone https://gitlab.freedesktop.org/xorg/lib/libxft.git
	@# Remove check for xorg-util-macros that's only used to add `.1` at the
	@# end of a man page we're not gonna use.
	patch -d $@ < libxft.patch
	patch -d $@ -p1 < $<

libxft-bgra.patch:
	curl -o $@ https://gitlab.freedesktop.org/xorg/lib/libxft/-/merge_requests/1.patch

emoji.txt:
	curl 'https://unicode.org/emoji/charts/full-emoji-list.html' \
		| sed -En "s/.*class='(chars|name)'>([^<]*)<.*/\2/p" \
		| sed 'N;s/\n/ /' > $@
