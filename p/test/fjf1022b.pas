{$implicit-result}

Program Test;

  var
    x: integer;

Function foo: integer;

  Procedure bar;
  begin (* bar *)
    result:= 7;
  end (* bar *);

begin (* foo *)
  bar;
end (* foo *);

begin
  x:= foo;
  if x = 7 then WriteLn ('OK') else WriteLn ('failed')
end.
