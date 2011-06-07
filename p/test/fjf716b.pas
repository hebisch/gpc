program fjf716b;

var
  x, y: packed record
    a: packed record
       end
  end;

begin
  x.a := y.a;
  WriteLn ('OK')
end.
