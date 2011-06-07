module ModT5 interface;

export
  ModT5A = (i, DoTest);
  ModT5B = (j);

var
  i,j: integer;


procedure DoTest;


end.


module ModT5 implementation;


procedure DoTest;
begin
  i := -9;
end;



end.
