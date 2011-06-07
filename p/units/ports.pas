{ Access functions for I/O ports for GPC on an IA32 platform. This
  unit is *not* portable. It works only on IA32 platforms (tested
  under Linux and DJGPP). It is provided here only to serve as a
  replacement for BP's Port and PortW pseudo arrays.

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
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}
{$ifndef __i386__}
{$error The Ports unit is only for the IA32 platform}
{$endif}

unit Ports;

interface

{ Port access functions }
function  InPortB  (PortNumber: ShortWord): Byte;
function  InPortW  (PortNumber: ShortWord): ShortWord;
procedure OutPortB (PortNumber: ShortWord; aValue: Byte);
procedure OutPortW (PortNumber, aValue: ShortWord);

{ libc functions for getting access to the ports -- only for root
  processes, of course -- and to give up root privileges after
  getting access to the ports for setuid root programs. Dummies
  under DJGPP. }
{$ifdef MSDOS}
function  IOPerm (From, Num: MedCard; On: Integer): Integer; attribute (name = 'ioperm');
function  IOPL (Level: Integer): Integer;                    attribute (name = 'iopl');
function  SetEUID (EUID: Integer): Integer;                  attribute (name = 'seteuid');
{$else}
function  IOPerm (From, Num: MedCard; On: Integer): Integer; external name 'ioperm';
function  IOPL (Level: Integer): Integer;                    external name 'iopl';
function  SetEUID (EUID: Integer): Integer;                  external name 'seteuid';
{$endif}

implementation

function InPortB (PortNumber: ShortWord): Byte;
var aValue: Byte;
begin
  asm volatile ('inb %%dx, %%al' : '=a' (aValue) : 'd' (PortNumber));
  InPortB := aValue
end;

function InPortW (PortNumber: ShortWord): ShortWord;
var aValue: ShortWord;
begin
  asm volatile ('inw %%dx, %%ax' : '=a' (aValue) : 'd' (PortNumber));
  InPortW := aValue
end;

procedure OutPortB (PortNumber: ShortWord; aValue: Byte);
begin
  asm volatile ('outb %%al, %%dx' : : 'd' (PortNumber), 'a' (aValue))
end;

procedure OutPortW (PortNumber, aValue: ShortWord);
begin
  asm volatile ('outw %%ax, %%dx' : : 'd' (PortNumber), 'a' (aValue))
end;

{$ifdef MSDOS}

function IOPerm (From, Num: MedCard; On: Integer): Integer;
begin
  Discard (From);
  Discard (Num);
  Discard (On);
  IOPerm := 0
end;

function IOPL (Level: Integer): Integer;
begin
  Discard (Level);
  IOPL := 0
end;

function SetEUID (EUID: Integer): Integer;
begin
  Discard (EUID);
  SetEUID := 0
end;

{$endif}

end.
