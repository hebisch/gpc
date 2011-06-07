{ GPC demo program for port access from GPC on IA32 platforms
  (tested under Linux/IA32 and DJGPP).

  Must be run as root or suid root under Unix systems!

  DISCLAIMER: This program might interfere with your hardware, or
  even do damage to it! The author disclaims any liability for the
  consequences of running the program or not being able to run it.
  Use it at your own risk!

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

program PortDemo;

uses GPC, Ports;

const
  BasePort = $278;

begin
  { Allow acces to ports BasePort .. BasePort + 2 }
  if IOPerm (BasePort, 3, 1) <> 0 then
    begin
      WriteLn (StdErr, 'Could not set I/O permissions. Please run as root.');
      Halt (1)
    end;

  { Give up root privileges as soon as possible }
  if SetEUID (UserID (False)) <> 0 then
    begin
      WriteLn (StdErr, 'Could not reset effective user ID. Should not happen ...');
      Halt (1)
    end;

  { Play around with the ports ... }
  WriteLn ('Value at port ', BasePort, ' is ', InPortB (BasePort));
  WriteLn ('Value at ports ', BasePort, '/', BasePort + 1, ' is ', InPortW (BasePort));
  WriteLn ('Setting port ',BasePort, ' to 42 ...');
  OutPortB (BasePort, 42);
  WriteLn ('Value at ports ', BasePort, '/', BasePort + 1, ' is now ', InPortW (BasePort));
  WriteLn ('Setting port ',BasePort, ' to 0 through OutPortW ...');
  OutPortW (BasePort, 256 * InPortB (BasePort + 1));
  WriteLn ('Value at ports ', BasePort, '/', BasePort + 1, ' is now ', InPortW (BasePort));
end.
