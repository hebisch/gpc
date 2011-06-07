program fjf320b;

type
  PPStrings = ^TPStrings;
  TPStrings (Count: Cardinal) = array [1 .. Count] of ^String;
  q = ^procedure (protected var x : TPStrings);

procedure foo (protected var x : TPStrings);
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
