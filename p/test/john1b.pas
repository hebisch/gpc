program john1b(input,output);

type vector(n:integer) = array [1..n] of integer;

var c: boolean value false;

function ask : integer;
  begin
    ask := 42;
    if c then
      begin
        writeln ('Failed');
        halt(1)
      end;
    c := true
  end;

var my_vec : vector(ask);

begin
  if my_vec.n = 42 then writeln('OK') else writeln('Failed')
end.
