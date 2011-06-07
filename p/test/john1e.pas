program john1e(input,output);

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

var my_vec : array[1..ask] of integer;

begin
  if High (my_vec) = 42 then writeln('OK') else writeln('Failed')
end.
