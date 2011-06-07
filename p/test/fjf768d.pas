program fjf768d;

var
  b: array [0 .. 1] of 0 .. 1 = (0, 0);
  x: ByteInt = 1;

begin
  { We want a warning about side-effects here, since x <= 0 could cause
    a runtime error, but depending on the order of evaluation of the set
    constructor, this error may or may not appear. }
  if 0 in [b[2 mod x], 0] then  { WARN }
end.
