program fjf499a;

var
  i, e : Integer;
  f : Text;

begin
  Rewrite (f);
  WriteLn (f, '42x');
  Reset (f);
  Read (f, i);
  if i <> 42 then begin WriteLn ('failed 1'); Halt end;
  ReadStr ('17_', i);
  if i <> 17 then begin WriteLn ('failed 2'); Halt end;
  Val ('234:', i, e);
  if i <> 234 then begin WriteLn ('failed 3'); Halt end;
  if e <> 4 then begin WriteLn ('failed 4 ', e); Halt end;
  WriteLn ('OK')
end.
