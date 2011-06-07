program fjf583;

var
  b: array [1 .. 3] of Integer;

procedure foo (a: array of Integer);
begin
  if a[0] <> 3  then begin WriteLn ('failed 1'); Halt end;
  if b[1] <> 3  then begin WriteLn ('failed 2'); Halt end;
  a[0] := 42;
  if a[0] <> 42 then begin WriteLn ('failed 3'); Halt end;
  if b[1] <> 3  then begin WriteLn ('failed 4'); Halt end;
end;

begin
  b[1] :=3;
  if b[1] <> 3  then begin WriteLn ('failed 0'); Halt end;
  foo (b);
  if b[1] <> 3  then begin WriteLn ('failed 5'); Halt end;
  WriteLn ('OK')
end.
