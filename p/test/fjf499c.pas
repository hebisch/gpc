program fjf499c;

{$read-white-space}

var
  i, e : Integer;
  f : Text;

begin
  Rewrite (f);
  WriteLn (f, '42x');
  Reset (f);
  {$local I-} Read (f, i); {$endlocal}
  if IOResult = 0 then begin WriteLn ('failed 1'); Halt end;
  {$local I-} ReadStr ('17_', i); {$endlocal}
  if IOResult = 0 then begin WriteLn ('failed 2'); Halt end;
  Val ('234:', i, e);
  if i <> 234 then begin WriteLn ('failed 3'); Halt end;
  if e <> 4 then begin WriteLn ('failed 4'); Halt end;
  WriteLn ('OK')
end.
