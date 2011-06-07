{ COMPILE-CMD: environo.cmp }

Program Environ;

uses GPC;

{$ifdef HAVE_SETENV}  { Not all libc versions support setenv() }
{ This test is not really up-to-date since GPC has `GetEnv' and
  `SetEnv' in the RTS, but it doesn't hurt, either ... }
Function LibCSetEnv ( VarName, Value: CString; Overwrite: Integer ): Integer; external name 'setenv';
Function LibCGetEnv ( VarName: CString ): CString; external name 'getenv';
{$endif}

Var
  s: TString;
  c: CString;

begin
  {$ifdef HAVE_SETENV}  { Not all libc versions support setenv() }
  Discard (LibCSetEnv ( 'TEST_ENV', 'OK', 1 ));
  c:= LibCGetEnv ( 'TEST_ENV' );
  if CString2String (c) <> 'OK' then WriteLn ('failed 1');
  {$endif}
  { Test RTS version in any case. }
  SetEnv ( 'TEST_ENV', 'OK' );
  s:= GetEnv ( 'TEST_ENV' );
  WriteLn ( s );
end.
