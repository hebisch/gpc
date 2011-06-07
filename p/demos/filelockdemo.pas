{ GPC demo program for the FileLock and FileUnlock routines.

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

program FileLockDemo;

uses GPC;

var
  f: File;
  Res: Boolean;
  TempFileName: TString;

{ The program calls itself recursively, so the instances can try
  file locks against each other }
procedure DoExecute (const Msg, Parameter: String);
begin
  Write (Msg);
  Flush (Output);
  Discard (Execute (ParamStr (0) + ' --recursive ' + Parameter + ' ' + TempFileName))
end;

procedure TimerHandler (Signal: CInteger);
begin
  WriteLn ('Received signal `', StrSignal (Signal), '''.')
end;

begin
  { Recursive call }
  if ParamStr (1) = '--recursive' then
    begin
      Reset (f, ParamStr (3), 1);
      if ParamStr (2) = '--read' then
        WriteLn (FileLock (f, False, False))
      else if ParamStr (2) = '--write' then
        WriteLn (FileLock (f, True, False))
      else if ParamStr (2) = '--block' then
        begin
          WriteLn ('Subprocess write lock, should fail:                  ', FileLock (f, True, False));
          WriteLn ('Setting an alarm to 5 seconds, should succeed:       ', Alarm (5) >= 0);
          WriteLn ('Install timer handler, should succeed:               ', InstallSignalHandler (SigAlrm, TimerHandler, False, False, Null, Null));
          WriteLn ('A write lock with blocking, should block the program.');
          WriteLn ('However, in 5 seconds, the program should get an `Alarm clock'' signal ...');
          Res := FileLock (f, True, True);
          WriteLn ('The write lock should have failed,');
          WriteLn ('because it was interrupted:                          ', Res)
        end
      else
        WriteLn (ParamStr (0), ': invalid recursive call.');
      Close (f);
      Halt
    end;

  { Non-recursive call. Execution normally starts here. }

  TempFileName := GetTempFileName;
  Rewrite (f, TempFileName, 1);

  WriteLn   ('`True'' means success, `False'' means failure.');

  DoExecute ('Subprocess read lock, should succeed:                ', '--read');
  DoExecute ('Subprocess write lock, should succeed:               ', '--write');

  WriteLn   ('Read lock, should succeed:                           ', FileLock (f, False, False));
  DoExecute ('Subprocess read lock, should succeed:                ', '--read');
  DoExecute ('Subprocess write lock, should fail:                  ', '--write');
  WriteLn   ('Remove lock, should succeed:                         ', FileUnlock (f));

  WriteLn   ('Write lock, should succeed:                          ', FileLock (f, True, False));
  DoExecute ('Subprocess read lock, should fail:                   ', '--read');
  DoExecute ('Subprocess write lock, should fail:                  ', '--write');
  DoExecute ('Subprocess write lock with blocking ...' + NewLine    , '--block');
  WriteLn   ('Remove lock, should succeed:                         ', FileUnlock (f));

  DoExecute ('Subprocess read lock, should succeed:                ', '--read');
  DoExecute ('Subprocess write lock, should succeed:               ', '--write');

  Close (f);
  Erase (f)
end.
