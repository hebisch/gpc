program john1a(input,output);

procedure foo;

type vector(n:integer) = array [1..n] of integer;

var c: integer value 42;

function ask : integer;
  begin
    if c <> 42 then begin writeln('Failed 1 ', c); halt end;
    ask := c;
    c := c + 1
  end;

var my_vec : vector(ask);

begin
  if my_vec.n = 42 then writeln('OK') else writeln('Failed 2 ', my_vec.n)
end;

begin
  foo
end.
