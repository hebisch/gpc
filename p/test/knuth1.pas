program manorboy (input, output);
{ Test program from "Herbert G.Mayor: Programming Languages". Program was
  written in Algol-60 by Donald Knuth and translated into Pascal "to separate
  the 'boy compilers' from the 'man compilers'". }
const
  correct: array[0..10] of integer = (1, 0, -2, 0, 1, 0, 1, -1, -10, -30, -67);

var i : integer;
  function x1 : real; begin x1 :=  1; end;
  function x2 : real; begin x2 := -1; end;
  function x3 : real; begin x3 := -1; end;
  function x4 : real; begin x4 :=  1; end;
  function x5 : real; begin x5 :=  0; end;
  function a(
     k : integer;
     function x1 : real;
     function x2 : real;
     function x3 : real;
     function x4 : real;
     function x5 : real ) : real;

    function b : real;
      begin { b }
       k := k - 1;
       b := a(k, b, x1, x2, x3, x4 );
      end; { b }

    begin { a }
     if k <= 0 then
      a := x4 + x5
     else
      a := b;
    end; { a }

begin { manorboy }
  for i := 0 to 10 do
    if round( a( i, x1, x2, x3, x4, x5 ) ) <> correct [i] then
      begin
        writeln('Failed');
        halt
      end;
  writeln('OK')
end.
