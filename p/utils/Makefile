# Makefile for the GNU Pascal utilities
#
# Copyright (C) 2002-2006 Free Software Foundation, Inc.
#
# Author: Frank Heckenbach <frank@pascal.gnu.de>
#
# This file is part of GNU Pascal.
#
# GNU Pascal is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Pascal is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Pascal; see the file COPYING. If not, write to the
# Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# Variables to override
PC=gpc
CFLAGS=-O2 -g
PFLAGS=
UTILS_WARN=-W -Wall -Wmissing-prototypes -Wmissing-declarations
GCC_DIR=ERROR--GCC_DIR-MUST-BE-SET
exeext=
prefix=/usr/local
bindir=$(prefix)/bin
man1dir=$(prefix)/man/man1
INSTALL_PROGRAM=install -m 755
INSTALL_DATA=install -m 644
BUILD=unknown
HOST=unknown

srcdir=$(GCC_DIR)/p/utils
VPATH=$(srcdir)

# Internal variables
PFLAGS1=--executable-path=. --unit-path=$(GCC_DIR)/p/rts --unit-path=$(GCC_DIR)/p/units
EXE=binobj$(exeext) gpidump$(exeext)
EXE2=binobj gpidump
DOC=binobj.1 gpidump.1
PC_WITH_FLAGS=$(PC) --automake --executable-file-name $(UTILS_WARN) $(CFLAGS) $(PFLAGS) $(PFLAGS1)

all: $(EXE) $(DOC)

binobj$(exeext): binobj.pas
	$(PC_WITH_FLAGS) "$<"

gpidump$(exeext): gpidump.pas tree.inc
	$(PC_WITH_FLAGS) -I. -I "$(GCC_DIR)/p" "$<"

binobj.1: binobj
	[ -r no-man ] || if [ x"$(BUILD)" != x"$(HOST)" ]; then \
	  echo "*** cross-compiling; man pages for the GPC utilities will not be built" >&2; \
	  echo cross-compile > no-man; \
	elif help2man --version > /dev/null 2>&1; then \
	  help2man -N ./"$<" > "$@" || { rm -f "$@"; false; } \
	else \
	  echo "*** help2man not found; man pages for the GPC utilities will not be built" >&2; \
	  echo no-help2man > no-man; \
	fi

gpidump.1: gpidump
	[ -r no-man ] || if [ x"$(BUILD)" != x"$(HOST)" ]; then \
	  echo "*** cross-compiling; man pages for the GPC utilities will not be built" >&2; \
	  echo cross-compile > no-man; \
	elif help2man --version > /dev/null 2>&1; then \
	  help2man -N ./"$<" > "$@" || { rm -f "$@"; false; } \
	else \
	  echo "*** help2man not found; man pages for the GPC utilities will not be built" >&2; \
	  echo no-help2man > no-man; \
	fi

tree.inc: $(GCC_DIR)/version.c $(GCC_DIR)/tree.def $(GCC_DIR)/p/p-tree.def $(GCC_DIR)/p/module.c
	"$(srcdir)/mk-t-inc" "$(GCC_DIR)" "$@"

install: $(EXE) $(DOC)
	for f in $(EXE); do \
	  rm -f $(bindir)/"$$f"; \
	  $(INSTALL_PROGRAM) "$$f" "$(bindir)/$$f"; \
	  chmod a+x $(bindir)/"$$f"; \
	done
	for f in $(DOC); do \
	  if [ -r "$$f" ]; then \
	    rm -f $(man1dir)/"$$f"; \
	    $(INSTALL_DATA) "$$f" "$(man1dir)/$$f"; \
	    chmod a-x $(man1dir)/"$$f"; \
	  fi; \
	done

clean:
	rm -f *.o *.i *.s *.gpi *.gpd $(EXE) $(EXE2) $(DOC) tree.inc
