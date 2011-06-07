unit fjf1064h;

interface

import
  GPC;
  Implementation in 'fjf1064i.pas';

{ We've just redeclared `Implementation', so we cannot (syntactically)
  write an implementation part of this unit. But UCSD and Mac Pascal
  allow units without implementation, so we do this. }

const
  Bar = Foo;

end.
