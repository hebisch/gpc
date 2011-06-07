program fjf320a;

type
  PPStrings = ^TPStrings;
  TPStrings (Count: Cardinal) = array [1 .. Count] of ^String;
  q = ^procedure (const x : TPStrings);

procedure foo (const x : TPStrings);
begin
  if x.Count = 1 then writeln (x [1]^) else writeln ('failed')
end;

var
  a: TPStrings (1) = (@'OK');
  w: q;

begin
  w := @foo; { doesn't work }
  w^ (a)     { doesn't work either }
end.
