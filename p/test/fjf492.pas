program fjf492;

var
  f: Text;
  i: Integer;

begin
  Rewrite (f);
  Write (f, '4');
  Reset (f);
  Read (f, i);
  if i <> 4 then begin WriteLn ('failed 1'); Halt end;
  if not EOF (f) then begin WriteLn ('failed 2'); Halt end;
  WriteLn ('OK')
end.
