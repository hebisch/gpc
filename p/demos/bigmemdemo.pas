{ GPC demo program for the BigMem routines.
  Uniform access to big memory blocks for GPC and BP.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

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

program BigMemDemo;

uses GPC {$ifdef __GPC__}, GPCUtil {$endif};

type
  TStr = String {$ifdef __GPC__} ($fff7) {$endif};

const
  BlockNumber = 1000;
  BlockSize = SizeOf (TStr);

var
  BigMem: PBigMem;
  s: TStr;
  p: ^TStr;
  i: Integer;

begin
  WriteLn ('Trying to allocate ', BlockNumber, ' blocks of ', BlockSize, ' bytes each.');
  BigMem := AllocateBigMem (BlockNumber, BlockSize, True);
  if BigMem^.Number = 0 then
    begin
      WriteLn (StdErr, 'Could not allocate any blocks. Please make available some more memory.');
      Halt (1)
    end;
  WriteLn ('Allocated ', BigMem^.Number, ' blocks.');
  WriteLn;
  WriteLn ('Enter some strings up to ', GetStringCapacity (s), ' characters each to');
  WriteLn ('copy into the blocks (empty string when finished).');
  for i := 1 to BigMem^.Number do
    begin
      Write ('Block #', i, ': ');
      ReadLn (s);
      MoveToBigMem (s, BigMem, i);
      if s = '' then Break
    end;
  WriteLn;
  WriteLn ('Copying back the strings from the blocks:');
  for i := 1 to BigMem^.Number do
    begin
      MoveFromBigMem (BigMem, i, s);
      if s = '' then Break;
      WriteLn ('Block #', i, ': ', s)
    end;
  WriteLn;
  WriteLn ('Press enter.');
  ReadLn;
  WriteLn ('Now mapping the blocks and reading the strings directly:');
  for i := 1 to BigMem^.Number do
    begin
      p := MapBigMem (BigMem, i);
      if p^ = '' then Break;
      WriteLn ('Block #', i, ': ', p^)
    end;
  WriteLn;
  WriteLn ('Deallocating memory blocks.');
  DisposeBigMem (BigMem)
end.
