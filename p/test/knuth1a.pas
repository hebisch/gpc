{ Awkward version of knuth1.pas that also compiles with a 'boy compiler'
  like BP. Of course, it should also compile with a better compiler. }

{$ifndef __GPC__}
{BP specific compiler options}
{$m $8000,0,$a0000} { More stack required because of deep recursion }
{$f+} { Far calls required because of procedural variables }
{$endif}

program nomanbutboy (input, output);

const
  correct: array[0..10] of integer = (1, 0, -2, 0, 1, 0, 1, -1, -10, -30, -67);

  type
   pxf=^xf;
   xf=record
    f:function(var k:integer; x1,x2,x3,x4,x5:pxf): real;
    k:^integer;
    x1,x2,x3,x4,x5:pxf
   end;

  var i : integer;
  function y1(var k:integer; x1,x2,x3,x4,x5:pxf) : real; begin y1 :=  1; end;
  function y2(var k:integer; x1,x2,x3,x4,x5:pxf) : real; begin y2 := -1; end;
  function y3(var k:integer; x1,x2,x3,x4,x5:pxf) : real; begin y3 := -1; end;
  function y4(var k:integer; x1,x2,x3,x4,x5:pxf) : real; begin y4 :=  1; end;
  function y5(var k:integer; x1,x2,x3,x4,x5:pxf) : real; begin y5 :=  0; end;

  const y:array[1..5] of xf=((f:y1),(f:y2),(f:y3),(f:y4),(f:y5));

  function a(k : integer;x1,x2,x3,x4,x5:pxf) : real; forward;

  function b (var k:integer; x1,x2,x3,x4,x5:pxf) : real;
    var p:pxf;
    begin { b }
     k := k - 1;
     new(p);
     p^.f:=b;p^.k:=@k;p^.x1:=x1;p^.x2:=x2;p^.x3:=x3;p^.x4:=x4;p^.x5:=x5;
     b := a(k, p, x1, x2, x3, x4 );
    end; { b }

  function a(k : integer;x1,x2,x3,x4,x5:pxf) : real;

    begin { a }
     if k <= 0 then
      a := x4^.f(x4^.k^,x4^.x1,x4^.x2,x4^.x3,x4^.x4,x4^.x5) +
           x5^.f(x5^.k^,x5^.x1,x5^.x2,x5^.x3,x5^.x4,x5^.x5)
     else
      a := b(k,x1,x2,x3,x4,x5);
    end; { a }

begin { nomanbutboy }
  for i := 0 to 10 do
    if round( a( i, @y[1], @y[2], @y[3], @y[4], @y[5] ) ) <> correct [i] then
      begin
        writeln('Failed');
        halt
      end;
  writeln('OK')
end.
