module ModT11 interface;

export
  ModT11 = (i, j, k, p);

var
  i, j: integer;
  k: integer absolute i;

procedure p;

end.


module ModT11 implementation;

procedure p;

begin
  writeln ('failed');
end;

end.
