unit miguel2v;

interface

uses
  miguel2u;

function p(v1,v2: enum): boolean;

implementation

function p(v1,v2: enum): boolean;
begin
  p :=(v1=v2);
end;

end.
