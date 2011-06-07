@echo off

rem Script to run the GPC Test Suite under DJGPP on a system that
rem suffers from losing DPMI handles (such as MS-Windows).
rem
rem Copyright (C) 2000-2006 Free Software Foundation, Inc.
rem
rem Authors: Maurice Lombardi [Maurice.Lombardi@ujf-grenoble.fr]
rem          Frank Heckenbach [frank@pascal.gnu.de]
rem
rem This file is part of GNU Pascal.
rem
rem GNU Pascal is free software; you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation; either version 2, or (at your option)
rem any later version.
rem
rem GNU Pascal is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with GNU Pascal; see the file COPYING. If not, write to the
rem Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
rem 02111-1307, USA.

if exist make.out del make.out
if exist dtlist.* del dtlist.*
make msg
ls -1 *.pas | split -l 128 - dtlist.
for %%f in (dtlist.*) do make MASK="`cat %%f`" pascal.check-long >> make.out
sh test_sum < make.out
