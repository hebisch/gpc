program zap (output);

{ FLAG --extended-pascal }

var
   enumvar :  (absolute);

begin
  if enumvar = enumvar then  { avoid unused variable warning }
    writeln ( 'OK' );
end.
