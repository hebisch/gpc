dnl m4 script to create acconfig.h from configure.in.
dnl Relies on the usage of GPC_MSG_CHECKING in configure.in.
dnl
dnl Copyright 2000-2006 Free Software Foundation, Inc.
dnl
dnl Author: Frank Heckenbach <frank@pascal.gnu.de>
dnl
dnl This file is part of GNU Pascal.
dnl
dnl GNU Pascal is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 3 of the License, or
dnl (at your option) any later version.
dnl
dnl GNU Pascal is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with GNU Pascal; see the file COPYING. If not, write to the
dnl Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
dnl 02111-1307, USA.
dnl
dnl The following comment is inserted into the generated acconfig.h
dnl file. It does not apply to this script!
/* acconfig.h.  Generated automatically from configure.in using make-acconfig-h.m4.  */

divert(-1)
changequote([,])
define(ARTICLE,[ifelse(regexp([$1],[^[^A-Za-z]*[AEIOUaeiou]]),-1,a,an) $1])
define(GPC_MSG_CHECKING,[divert(0)[/* Define $2.  */]
divert(-1)])
define(AC_DEFINE,[divert(0)#undef $1

divert(-1)])
define(AC_DEFUN,[define($1, [$2])])
