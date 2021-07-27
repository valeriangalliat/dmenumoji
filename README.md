# dmenumoji

> [dmenu] with built-in [libxft-bgra] for emoji support.

[dmenu]: https://tools.suckless.org/dmenu/
[libxft-bgra]: https://aur.archlinux.org/packages/libxft-bgra/

## Overview

dmeu uses [libXft] to render fonts, which crashes on BGRA glyphs (color
emoji). To prevent the crashes, dmenu [prevents color fonts to be loaded](https://git.suckless.org/dmenu/file/drw.c.html#l136).

[libXft]: https://gitlab.freedesktop.org/xorg/lib/libxft

There is an [active PR on libXft](https://gitlab.freedesktop.org/xorg/lib/libxft/-/merge_requests/1)
to add support for BGRA glyphs, meaning that by linking dmenu against
it, removing the color fonts workaround in `drw.c`, and making sure that
it is configured with an emoji font, we can have emoji inside dmenu!

Currently, the main way to do that is, on Arch, to install [libxft-bgra]
from the AUR, get the source of dmenu, manually removing the workaround,
and configuring an emoji font as described in [this issue](https://bbs.archlinux.org/viewtopic.php?id=255799)
or [this video](https://youtu.be/0QkByBugq_4).

This package is all about making that easier. It also provides a cool
emoji picker script, because that's probably what you're trying to do if
you're trying to render emoji in dmenu.

## Installation

```sh
git clone https://github.com/valeriangalliat/dmenumoji.git
cd dmenumoji
make

# Add the patched dmenu to your `PATH`
export PATH=$PWD/dmenu:$PATH

# If you also want the `dmenumoji` picker
export PATH=$PWD:$PATH

# Or alternatively, link the commands in your `~/bin`
ln -s $PWD/dmenu/{dmenu,stest,dmenu_path,dmenu_run} $PWD/dmenumoji ~/bin
```

If you want to customize dmenu settings like fonts and colors, you can
do this instead:

```sh
make dmenu
$EDITOR dmenu/config.def.h
make
```

## Usage

dmenu is just stock dmenu, but it'll happily show emoji.

To use the `dmenumoji` command:

```sh
# Type the emoji in the active window
dmenumoji

# Copy the emoji to clipboard
dmenumoji copy
```

## How it works

Instead of globally installing the patched version of libXft like
[libxft-bgra] from the AUR does, we just statically link dmenu against
our patched version of libXft, leaving the system version alone.

This is done by with the following patch in `config.mk`:

```diff
-FREETYPELIBS = -lfontconfig -lXft
-FREETYPEINC = /usr/include/freetype2
+FREETYPELIBS = -lfontconfig -lfreetype -lXrender -lX11 -L../libxft/src/.libs -l:libXft.a
+FREETYPEINC = /usr/include/freetype2 -I$(PWD)/../libxft/include
```

FWIW, you could also use dynamic linking by adding the patched libXft
directory to the runtime search library path instead, but note that it
would break if you were to move the directory you installed it in.

```diff
-FREETYPELIBS = -lfontconfig -lXft
-FREETYPEINC = /usr/include/freetype2
+FREETYPELIBS = -lfontconfig -lXft -Wl,-rpath $(PWD)/../libxft/src/.libs
+FREETYPEINC = /usr/include/freetype2 -I$(PWD)/../libxft/include
```
