unit fjf1064b;

interface

var
  Bar: Integer;
  Implementation: Integer;

{ We've just redeclared `Implementation', so we cannot (syntactically)
  write an implementation part of this unit. But UCSD and Mac Pascal
  allow units without implementation, so we do this. }

end.
