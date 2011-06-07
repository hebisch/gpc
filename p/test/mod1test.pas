module ModT1 interface;

export
  ModT1Int = (i, DoTest);

var
  i: integer;


procedure DoTest;


end.


module ModT1 implementation;


{ Fixed: Implementation Module did not know about Interfaces. }

procedure DoTest;
begin
  i := -9;
end;



end.
