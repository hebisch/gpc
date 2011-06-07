program Maur10a;

uses GPC;

var
  s: TString;

begin
  ReadStr (ParamStr (1), s);
  if Copy (s, LastCharPos (DirSeparators, s) + 1) = 'maur10a.pas' then
    WriteLn ('OK')
  else
    WriteLn ('failed ', s)
end.
