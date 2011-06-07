Unit DblImp2u;

Interface

uses
  DblImp2v;

Procedure failed;

Implementation

uses
  DblImp2v;  { WRONG }

Procedure failed;

begin { failed }
  writeln ( 'failed' )
end { failed };

end.
