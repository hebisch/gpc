unit fjf1064d;

interface

const
  Bar = 42;
  Implementation = 19;

{ We've just redeclared `Implementation', so we cannot (syntactically)
  write an implementation part of this unit. But UCSD and Mac Pascal
  allow units without implementation, so we do this. }

end.
