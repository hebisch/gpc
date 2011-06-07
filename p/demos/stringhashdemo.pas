{ GPC demo program. How to hash strings using the StringUtils unit.

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

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

program StringHashDemo;

uses GPC, StringUtils;

var
  HashTable: PStrHashTable;
  n, Entries, Slots: Integer;
  s: TString;

begin
  WriteLn ('String hash demo');
  Write ('Case sensitive? ');
  ReadLn (s);
  HashTable := NewStrHashTable (DefaultHashSize, (s <> '') and (LoCase (s[1]) = 'y'));
  WriteLn ('Enter some strings to store (empty string when finished).');
  n := 0;
  repeat
    Inc (n);
    Write ('#', n, ': ');
    ReadLn (s);
    if s <> '' then
      begin
        AddStrHashTable (HashTable, s, n, nil);
        StrHashTableUsage (HashTable, Entries, Slots);
        WriteLn ('Hash table usage so far: ', Entries, ' entries, ',
                 Slots, ' of ', HashTable^.Size, ' slots used, ',
                 Entries - Slots, ' collisions')
      end
  until s = '';
  WriteLn ('Now enter some strings to search (empty string when finished).');
  repeat
    ReadLn (s);
    if s <> '' then
      begin
        n := SearchStrHashTable (HashTable, s, Null);
        if n = 0 then
          WriteLn ('String not found.')
        else
          WriteLn ('String was entered at #', n)
      end
  until s = '';
  DisposeStrHashTable (HashTable)
end.
