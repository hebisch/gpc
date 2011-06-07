{ Yet another very useful BP feature ... :-( }

program fjf549b;

type
  foo = (bar, baz, qux);

var
  a: array [1 .. 4] of Char;

begin
  a := 'abcd';
  if a <> 'abcd' then begin WriteLn ('failed 1'); Halt end;
  FillChar (a, 3, bar);
  if a <> #0#0#0'd' then begin WriteLn ('failed 2'); Halt end;
  FillChar (a, 2, baz);
  if a <> #1#1#0'd' then begin WriteLn ('failed 3'); Halt end;
  FillChar (a, 1, qux);
  if a <> #2#1#0'd' then begin WriteLn ('failed 4'); Halt end;
  WriteLn ('OK')
end.
