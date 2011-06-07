program john1d(input,output);

procedure foo;

var c: integer value 42;

function ask : integer;
  begin
    if c <> 42 then begin writeln('Failed 1 ', c); halt end;
    ask := c;
    c := c + 1
  end;

var my_vec : array[1..ask] of integer;

begin
  if High (my_vec) = 42 then writeln('OK') else writeln('Failed 2 ', High (my_vec))
end;

begin
  foo
end.
