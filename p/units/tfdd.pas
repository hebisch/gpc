{ Some text file tricks.

  Copyright (C) 2002-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030412}
{$error This unit requires GPC release 20030412 or newer.}
{$endif}

unit TFDD;

interface

uses GPC;

{ Write to multiple files. Everything written to Dest after calling
  this procedure will be written to both File1 and File2. Can be
  chained. }
procedure MultiFileWrite (var Dest, File1, File2: AnyFile);

implementation

type
  TMultiFileWritePrivateData = record
    f1, f2: ^AnyFile;
  end;

function MultiFileWriteWrite (var PrivateData; const Buffer; Size: SizeType): SizeType;
var
  Data: TMultiFileWritePrivateData absolute PrivateData;
  CharBuf: array [1 .. Size] of Char absolute Buffer;
begin
  BlockWrite (Data.f1^, CharBuf, Size);
  BlockWrite (Data.f2^, CharBuf, Size);
  MultiFileWriteWrite := Size
end;

procedure MultiFileWriteFlush (var PrivateData);
var Data: TMultiFileWritePrivateData absolute PrivateData;
begin
  Flush (Data.f1^);
  Flush (Data.f2^)
end;

procedure MultiFileWriteDone (var PrivateData);
begin
  Dispose (@PrivateData)
end;

procedure MultiFileWrite (var Dest, File1, File2: AnyFile);
var Data: ^TMultiFileWritePrivateData;
begin
  SetReturnAddress (ReturnAddress (0));
  New (Data);
  Data^.f1 := @File1;
  Data^.f2 := @File2;
  AssignTFDD (Dest, nil, nil, nil, nil, MultiFileWriteWrite, MultiFileWriteFlush, nil, MultiFileWriteDone, Data);
  Rewrite (Dest);
  RestoreReturnAddress
end;

end.
