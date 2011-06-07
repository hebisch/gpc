program fjf647b;

function f: Integer;
begin
  f := Ord ('O')
end;

function g: Integer;
begin
  g := Ord ('K')
end;

begin
  WriteLn (Chr (f), Char (g))
end.
