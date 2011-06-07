program foo3;

{$W-}

type
  e1 = (enum0, enum1);
  t1 = array [e1] of boolean;

var
  v1: t1;


procedure proc1;
var
  r1 : record
      foo : integer;
      case boolean of
     false: (f1: integer);
     true: (f2: array [boolean] of integer);
     end;
begin
end;

procedure proc2;
type
  p2t1 = array [0 .. 100] of integer;
var
  p2v1: integer;
  p2v2: p2t1;

begin
p2v1 := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
p2v2[p2v1] := 42;
end;

begin
if v1[enum0] or not v1[enum0] then
  writeln('OK');
end.
