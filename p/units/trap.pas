{ Trapping runtime errors

  The Trap unit allows you to trap runtime errors, so a runtime
  error will not abort the program, but pass the control back to a
  point within the program.

  The usage is simple. The TrapExec procedure can be called with a
  function (p) as an argument. p must take a Boolean argument. p
  will immediately be called with False given as its argument. When
  a runtime error would otherwise be caused while p is active, p
  will instead be called again with True as its argument. After p
  returns, runtime error trapping ends.

  When the program terminates (e.g. by reaching its end or by a Halt
  statement) and a runtime error was trapped during the run, Trap
  will set the ExitCode and ErrorAddr variables to indicate the
  trapped error.

  Notes:

  - After trapping a runtime error, your program might not be in a
    stable state. If the runtime error was a "minor" one (such as a
    range checking or arithmetic error), it should not be a problem.
    But if you, e.g., write a larger application and use Trap to
    prevent a sudden abort caused by an unexpected runtime error,
    you should make the program terminate regularly as soon as
    possible after a trapped error (perhaps by telling the user to
    save the data, then terminate the program and report the bug to
    you).

  - Since the trapping mechanism *jumps* back, it has all the
    negative effects that a (non-local!) `goto' can have! You should
    be aware of the consequences of all active procedures being
    terminated at an arbitrary point!

  - Nested traps are supported, i.e. you can call TrapExec again
    within a routine called by another TrapExec instance. Runtime
    errors trapped within the inner TrapExec invocation will be
    trapped by the inner TrapExec, while runtime errors trapped
    after its termination will be trapped by the outer TrapExec
    again.

  Copyright (C) 1996-2006 Free Software Foundation, Inc.

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

unit Trap;

interface

uses GPC;

var
  TrappedExitCode: Integer = 0;
  TrappedErrorAddr: Pointer = nil;
  TrappedErrorMessageString: TString = '';

{ Trap runtime errors. See the comment at the top. }
procedure TrapExec (procedure p (Trapped: Boolean));

{ Forget about saved errors from the innermost TrapExec instance. }
procedure TrapReset;

implementation

{ @@ Implementation in pure Pascal without need of trapc.c. Fails under
     Solaris with gcc-2.95.x (backend bug); 2.8.1 and 3.x seem to be OK.
     The old code can probably removed after the transition to 3.x.
     Nonlocal `goto's still fail with gcc-3.x on Linux/S390 and
     Mac OS X. :-( `--longjmp-all-nonlocal-labels' helps. }
{.$define NEW_TRAP}

{$ifdef NEW_TRAP}
var
  TrapJump: ^procedure = nil;
{$else}
{$L trapc.c}
procedure DoSetJmp (procedure p (Trapped: Boolean)); external name 'dosetjmp';
procedure DoLongJmp; external name 'dolongjmp';
{$endif}

var
  TrapCount: Integer = 0;

procedure TrapExit;
begin
  if ErrorAddr <> nil then
    begin
      if TrapCount <> 0 then
        begin
          TrappedExitCode := ExitCode;
          TrappedErrorAddr := ErrorAddr;
          TrappedErrorMessageString := ErrorMessageString;
          ErrorAddr := nil;
          ExitCode := 0;
          ErrorMessageString := '';
{$ifdef NEW_TRAP}
          TrapJump^
{$else}
          DoLongJmp
{$endif}
        end
    end
  else
    if TrappedErrorAddr <> nil then
      begin
        ExitCode := TrappedExitCode;
        ErrorAddr := TrappedErrorAddr;
        ErrorMessageString := TrappedErrorMessageString;
        TrappedErrorAddr := nil
      end
end;

{$ifndef NEW_TRAP}
var
  TrapP: ^procedure (Trapped: Boolean) = nil;

procedure DoCall (Trapped: Boolean);
begin
  AtExit (TrapExit);
  TrapP^ (Trapped)
  end;
{$endif}


procedure TrapExec (procedure p (Trapped: Boolean));
var
  SavedTrappedExitCode: Integer { @@ } = 0;
  SavedTrappedErrorAddr: Pointer { @@ } = nil;
  SavedTrappedErrorMessageString: TString;
{$ifdef NEW_TRAP}
  SavedTrapJump: ^procedure { @@ } = nil;
  Trapped: Boolean;

label TrapLabel;

  procedure DoTrapJump;
  begin
    Trapped := True;
    goto TrapLabel
  end;
{$else}
  SavedTrapP: ^procedure (Trapped: Boolean) = nil;

{$endif}

begin
  SavedTrappedExitCode := TrappedExitCode;
  SavedTrappedErrorAddr := TrappedErrorAddr;
  SavedTrappedErrorMessageString := TrappedErrorMessageString;
  Inc (TrapCount);
{$ifdef NEW_TRAP}
  SavedTrapJump := TrapJump;
  TrapJump := @DoTrapJump;
  Trapped := False;
TrapLabel:
  AtExit (TrapExit);
  p (Trapped);
  TrapJump := SavedTrapJump;
{$else}
  SavedTrapP := TrapP;
  TrapP := @p;
  DoSetJmp (DoCall);
  TrapP := SavedTrapP;
{$endif}
  Dec (TrapCount);
  if TrappedErrorAddr = nil then
    begin
      TrappedExitCode := SavedTrappedExitCode;
      TrappedErrorAddr := SavedTrappedErrorAddr;
      TrappedErrorMessageString := SavedTrappedErrorMessageString
    end;
  AtExit (TrapExit)
end;

procedure TrapReset;
begin
  TrappedExitCode := 0;
  TrappedErrorAddr := nil;
  TrappedErrorMessageString := ''
end;

end.
