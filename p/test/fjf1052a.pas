{$pointer-checking}

program fjf1052a (Output);

type
  p = ^Integer;

const
  a = p (nil);

begin
  WriteLn (a^)  { WRONG }
end.
