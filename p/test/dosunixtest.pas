{ Test of the DosUnix unit. Similar to DosUnixDemo. }

program DosUnixTest;

uses GPC, DosUnix;

const
  ExtraCR = {$ifdef __OS_DOS__} '' {$else} #13 {$endif};
  Command = 'foo &> bar';

var
  t : Text;
  s, n : TString;

procedure Error (const Msg : String);
begin
  WriteLn ('Error in ', Msg);
  Halt (1)
end;

begin
  {$local no-exact-compare-strings}
  if TranslateRedirections (Command) <> {$ifdef __OS_DOS__} 'redir -o bar -eo foo' {$else} Command {$endif} then
    Error ('TranslateRedirections: ' + TranslateRedirections (Command));
  {$endlocal}
  n := GetTempFileName;
  Assign (t, n);
  Rewrite (t);
  WriteLn (t, 'foo', ExtraCR);
  Assign (t, n);
  Reset (t);
  ReadLn (t, s);
  if s <> 'foo' + ExtraCR then Error ('Assign #1');
  if not EOF (t) then Error ('Assign #2');
  Close(t);
  AssignDos (t, n);
  Reset (t);
  ReadLn (t, s);
  if s <> 'foo' then Error ('Assign #1');
  if not EOF (t) then Error ('Assign #2');
  Close (t);
  Assign (t, n);
  Erase (t);
  WriteLn ('OK')
end.
