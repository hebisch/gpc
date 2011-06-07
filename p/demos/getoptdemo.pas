{ GPC demo program for the GetOpt functions.
  Comfortable command line option parsing.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

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

program GetOptDemo;

uses GPC;

var
  ch, LongOptFlag: Char;
  i, LongIndex: Integer;

const
  LongOptions: array [1 .. 4] of OptionType =
    (('x',      NoArgument,       nil,          'x'),
     ('noarg',  NoArgument,       @LongOptFlag, #2),
     ('reqarg', RequiredArgument, @LongOptFlag, #3),
     ('optarg', OptionalArgument, @LongOptFlag, #4));

begin
  if ParamCount = 0 then
    begin
      WriteLn (StdErr, 'GetOpt demo');
      WriteLn (StdErr, 'Usage: ', ParamStr (0), ' [-n] [-r foo] [-o[bar]] [--noarg] [--reqarg foo] ');
      WriteLn (StdErr, '       [--optarg[=bar]] [--x] [baz...]');
      Halt (1)
    end;
  LongIndex := -1;
  repeat
    ch := GetOptLong ('nr:o::', LongOptions, LongIndex, True);
    case ch of
      EndOfOptions : Break;
      NoOption     : Write ('no-option argument');
      UnknownOption: if UnknownOptionCharacter = UnknownLongOption then
                       Write ('(incorrect long option)')
                     else
                       Write ('unknown option `', UnknownOptionCharacter, '''');
      LongOption   : with LongOptions[LongIndex] do
                       begin
                         Write ('long option `', CString2String (OptionName), '''');
                         if Ord (LongOptFlag) <> LongIndex then
                           Write (' <internal error> ')
                       end;
      else           Write ('option `', ch, '''')
    end;
    if HasOptionArgument then
      WriteLn (' with argument `', OptionArgument, '''')
    else
      WriteLn
  until False;
  if (FirstNonOption < 1) or (FirstNonOption > ParamCount + 1) then
    begin
      WriteLn (StdErr, 'Internal error with FirstNonOption.');
      Halt (2)
    end;
  if FirstNonOption <= ParamCount then WriteLn ('Remaining arguments:');
  for i := FirstNonOption to ParamCount do WriteLn (ParamStr (i))
end.
