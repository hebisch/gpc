{$borland-pascal}

program fjf972a;

type
  t = set of 1 .. 100;

begin
  WriteLn (1 in t[42])  { WRONG }
end.
