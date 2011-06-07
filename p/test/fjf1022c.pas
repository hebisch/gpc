{$implicit-result}

Program Test;

  var
    x: integer;

Function foo: integer;

  Function bar: integer;
  begin (* bar *)
    result:= 7;
  end (* bar *);

begin (* foo *)
  result := 4;
  result := result + bar;
end (* foo *);

begin
  x:= foo;
  if x = 11 then WriteLn ('OK') else WriteLn ('failed')
end.
