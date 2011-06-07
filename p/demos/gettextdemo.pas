{ GPC demo program for the GetText feature of the
  internationalization unit.

  Copyright (C) 2001-2006 Free Software Foundation, Inc.

  Authors: Eike Lange <eike.lange@uni-essen.de>
           Maurice Lombardi <Maurice.Lombardi@ujf-grenoble.fr>
           Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. }

program GetTextDemo;

uses GPC, Intl;

var
  LocaleDir: TString;

begin
  LocaleDir := {$ifdef __GO32__} GetEnv ('DJDIR') + '/share/locale' {$else} '/usr/share/locale' {$endif};
  WriteLn (
'This demo translates the string ` done.\n'' to the representation of
your locale.

It assumes that you have the program `gettext'' installed. If you
don''t, please change the source of the demo program to refer to
another program with `.mo'' files installed. The path to the `.mo''
file (' + LocaleDir + ') is hard coded, except
under DJGPP. Please change it if it''s different on your system.

Without a locale set, the output should be as follows:
C
 done.

For a German locale, the output should be as follows:
de_DE
 fertig.

For a French locale, the output should be as follows:
fr_FR
 ', {$ifdef __GO32__} 'termin‚.' {$else} 'terminé.' {$endif}, '

etc.

Starting:');
  WriteLn (SetLocale (LC_MESSAGES, ''));
  Discard (BindTextDomain ('gettext', LocaleDir));
  Discard (TextDomain ('gettext'));
  WriteLn (GetText (" done.\n"))
end.
