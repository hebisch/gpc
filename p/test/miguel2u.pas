unit miguel2u;

interface

type
  enum = (e1,e2,e3,e4);

function q(v: enum): boolean;

implementation

uses
  miguel2v;

function q(v: enum): boolean;
begin
  q :=p(v,e1);
end;

end.
