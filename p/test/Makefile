# Makefile for the GNU Pascal Test Suite
#
# Copyright (C) 1996-2006 Free Software Foundation, Inc.
#
# Authors: J.J. van der Heijden <j.j.vanderheijden@student.utwente.nl>
#          Peter Gerwinski <peter@gerwinski.de>
#          Frank Heckenbach <frank@pascal.gnu.de>
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

srcdir=.
SHELL=/bin/sh
MASK="*.pas"
PC=gpc
TEST_PATHS=
BASIC_PFLAGS=-g -O3 -W -Wall -Wno-unused
PFLAGS1=--autobuild  # can be removed when using GP
PFLAGS_NO_PATHS=$(BASIC_PFLAGS) $(EXTRA_PFLAGS) $(EXTRA_TEST_PFLAGS)
PFLAGS=$(TEST_PATHS) $(PFLAGS1) $(PFLAGS_NO_PATHS)
TEST_RUN_FLAGS=
GP=

all: pascal.check

.PHONY: all pascal.check pascal.check-short pascal.check-long pascal.check-long-nolog \
        mostlyclean clean distclean extraclean maintainer-clean

VARS=GP=$(GP) PC="$(PC)" PFLAGS="$(PFLAGS)" PFLAGS_NO_PATHS="$(PFLAGS_NO_PATHS)" SRCDIR="$(srcdir)" TEST_MAKE_FLAG=test-make-flag

pascal.check: pascal.check-dejagnu

pascal.check-dejagnu: clean
	$(VARS) "$(srcdir)/test_run" $(TEST_RUN_FLAGS) $(MASK) | tee test_log | "$(srcdir)/test_sum" -d

pascal.check-short: clean
	$(VARS) "$(srcdir)/test_run" $(TEST_RUN_FLAGS) $(MASK) | tee test_log | "$(srcdir)/test_sum" | tee test_summary

pascal.check-long: clean
	$(VARS) "$(srcdir)/test_run" $(TEST_RUN_FLAGS) $(MASK) | tee test_log

pascal.check-long-nolog: clean
	$(VARS) "$(srcdir)/test_run" $(TEST_RUN_FLAGS) $(MASK)

mostlyclean:
	-rm -f *.dat *.o *.s *.i *.gpi *.gpd *.gpc core a.out stderr.out *.exe testmake.tmp dummy.c dummy.pas dummy.out diff_cr*.tmp fixcr fixcr.exe
	-rm -f todo/a.out todo/*.exe todo/*.o todo/*.s todo/*.i todo/*.gpi todo/*.gpd todo/core

clean: mostlyclean

distclean: clean

extraclean: distclean
	-rm -f *.BAK *.bak *.orig gpc.out make.out b.out dtlist.* test_log test_summary gpc.log gpc.sum

maintainer-clean: extraclean
