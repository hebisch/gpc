program TestConformantArrays;

procedure Test1(a: array[j..k: integer] of Char);

var
  i: integer;

begin
  for i := j to k do
    a[i] := chr (i);
end;

var
  a1: array[0..ord ( 'O' )] of Char;
  a2: array[0..ord ( 'K' )] of Char;

begin
  a1 [ 5 ]:= 'O';
  a2 [ 13 ]:= 'K';
  Test1(a1);
  Test1(a2);
  writeln ( a1 [ 5 ], a2 [ 13 ] );
end.
