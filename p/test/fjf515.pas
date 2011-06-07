program fjf515;

var
  s: String (10);

begin
  s := 'foo';
  if s = '' then
    WriteLn ('failed 1')
  else
    begin
      s := '';
      if s = '' then
        WriteLn ('OK')
      else
        WriteLn ('failed 2')
    end
end.
