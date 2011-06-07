{$extended-pascal}

program fjf492b (Output);

var
  f: Text;
  i: Integer;

begin
  Rewrite (f);
  Write (f, '4');
  Reset (f);
  Read (f, i);
  if i <> 4 then begin WriteLn ('failed 1'); Halt end;
  if not EOLn (f) then begin WriteLn ('failed 2'); Halt end;
  if f^ <> ' ' then begin WriteLn ('failed 3'); Halt end; { Is this really guaranteed? }
  WriteLn ('OK')
end.
