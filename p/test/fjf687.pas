program fjf687;

uses GPC;

var
  s: TString;

begin
  s := RemoveDirSeparator ('foo' + DirSeparator + DirSeparator);
  if s = 'foo' then
    WriteLn ('OK')
  else
    WriteLn ('failed `', s, '''')
end.
