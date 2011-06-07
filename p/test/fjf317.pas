program fjf317;

type
  p = ^t;
  t (h0, h1 : Integer) = record
    Next : p;
    k0, k1, k2, k3, k4, k5, k6 : Integer;
    n0, n1 : array [1 .. 1] of Integer;
    d : packed array [1 .. 1, 1 .. 16] of Char
  end;

var
  q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, n0, n1, n2, n3, n4, n5, n6 : Integer;
  i : p;

procedure foo;
begin
  i := i^.Next
end;

var
  q : p;

begin
  q0 := q1; q2 := q3; q4 := q5; q6 := q7; q8 := q9; n0 := n1; n2 := n3; n4 := n5; n6 := n6; q := q;
  writeln ('OK')
end.
