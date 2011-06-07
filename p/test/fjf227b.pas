{ FLAG -O3 --omit-frame-pointer -g0 }

program fjf227b;

uses fjf227u;

procedure foo (const v : Extended);
var s : TString;
begin
  repeat
    WriteStr (s, '', v : 0);
    ReadStr (s, s);
  until (s = '') or (s <> '');
  if s = ' 4.2e+01' then writeln ('OK') else writeln ('failed ', s)
end;

begin
  foo (42)
end.
