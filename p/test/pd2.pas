program pd2 (output);

const c : array [ 0..2 ] of Char = 'KxO';

type t = (red,green,blue);

procedure p (a : array[lb..ub:t] of Char);
begin
  writeln ( c [ ord ( ub ) ], c [ ord ( lb ) ] );
end;

var
     a    : array[t] of Char;

begin
     p (a);
end.
