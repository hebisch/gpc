{ Turbo Pascal 3.0 compatibility unit

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

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

unit Turbo3;

interface

import GPC only (AssignTFDD);
       System (MemAvail => System_MemAvail,
               MaxAvail => System_MaxAvail);
       CRT (LowVideo  => CRT_LowVideo,
            HighVideo => CRT_HighVideo);

var
  Kbd: Text;
  CBreak: Boolean absolute CheckBreak;

procedure AssignKbd (var f: AnyFile);
function  MemAvail: Integer;
function  MaxAvail: Integer;
function  LongFileSize (var f: AnyFile): Real;
function  LongFilePos  (var f: AnyFile): Real;
procedure LongSeek     (var f: AnyFile; aPosition: Real);
procedure LowVideo;
procedure HighVideo;

implementation

function Kbd_Read (var PrivateData; var Buffer; Size: SizeType) = BytesRead: SizeType;
var CharBuf: array [1 .. Size] of Char absolute Buffer;
begin
  Discard (PrivateData);
  BytesRead := 0;
  repeat
    Inc (BytesRead);
    CharBuf[BytesRead] := ReadKey;
    if CharBuf[BytesRead] = #0 then CharBuf[BytesRead] := chEsc
  until (BytesRead = Size) or not KeyPressed
end;

procedure AssignKbd (var f: AnyFile);
begin
  AssignTFDD (f, nil, nil, nil, Kbd_Read, nil, nil, nil, nil, nil)
end;

function MemAvail: Integer;
begin
  MemAvail := System_MemAvail div 16
end;

function MaxAvail: Integer;
begin
  MaxAvail := System_MaxAvail div 16
end;

function LongFileSize (var f: AnyFile): Real;
begin
  LongFileSize := FileSize (f)
end;

function LongFilePos (var f: AnyFile): Real;
begin
  LongFilePos := FilePos (f)
end;

procedure LongSeek (var f: AnyFile; aPosition: Real);
begin
  Seek (f, Round (aPosition))
end;

procedure LowVideo;
begin
  TextColor (LightGray);
  TextBackground (Black)
end;

procedure HighVideo;
begin
  TextColor (Yellow);
  TextBackground (Black)
end;

to begin do
  begin
    NormAttr := Yellow + $10 * Black;
    AssignKbd (Kbd);
    Reset (Kbd)
  end;

end.
