all: dmenu/dmenu

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
	[ -d emojilib ] && git -C emojilib pull || git clone https://github.com/muan/emojilib
	@# Not using the default file because it contains manually edited keywords
	@# and I just want the official CLDR keywords, which the `i18n` command
	@# allows to fetch unaltered.
	@#
	@# This script is only available when cloning the repo which is why I don't
	@# install it from npm.
	npm --prefix emojilib run i18n en en
	npm install
	node fetch-emoji > $@
