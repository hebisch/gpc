{ FLAG -w } { Program NoHead; - headline may be omitted.  Yields warning. }

uses
  MyUnit;

Var
  OKcopy: OKarray;

begin
  OKcopy [ 1 ]:= 'O';
  OKcopy [ 2 ]:= 'K';
  OKvar:= OKcopy;
  OK;
end.
