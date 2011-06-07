{$no-truncate-strings}

program fjf390e;

var
  a: array [1 .. 2] of Char = 'abc';  { WRONG }

begin
  WriteLn ('failed ', a)
end.
