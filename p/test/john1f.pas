program john1f(input,output);

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

var my_vec : array[1..ask] of String(42);
    i: integer;

begin
  for i := 1 to 42 do
    if my_vec[i].Capacity <> 42 then writeln ('Failed ', i);
  if High (my_vec) = 42 then writeln('OK') else writeln('Failed')
end.
