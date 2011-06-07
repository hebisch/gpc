{ BUG: size of packed arrays (matter of definition?) }

program daj14b(input,output);
var
  a : array [1..6] of array [1..6] of Boolean;
  b : packed array [1..6] of array [1..6] of Boolean;
  c : array [1..6] of packed array [1..6] of Boolean;
  d : packed array [1..6] of packed array [1..6] of Boolean;

begin
  if sizeof(a) <> 36 * sizeof (Byte) then begin writeln ('failed 1'); halt end;
  if sizeof(b) <> 36 * sizeof (Byte) then begin writeln ('failed 2'); halt end;
  if sizeof(c) <> 6 then begin writeln ('failed 3 ', sizeof(c)); halt end;
  if sizeof(d) <> 5 { 36 bits } then begin writeln ('failed 4 ', sizeof(d)); halt end;
  writeln ('OK')
end.
