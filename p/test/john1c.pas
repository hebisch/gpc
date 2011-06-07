program john1c(input,output);

type vector(n:integer) = array [1..n] of String (42);

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
    i: integer;

begin
  for i := 1 to 42 do
    if my_vec[i].Capacity <> 42 then writeln ('Failed ', i);
  if my_vec.n = 42 then writeln('OK') else writeln('Failed')
end.
