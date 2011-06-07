module ModT6 interface;

export
  ModT6A = (i, j, DoTest);
  ModT6B = (j);

var
  i,j: integer;


procedure DoTest;


end.


module ModT6 implementation;


procedure DoTest;
begin
  i := -9;
end;



end.
