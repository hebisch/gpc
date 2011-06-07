unit fjf178a;

interface

uses fjf178b;

function x r:p;

implementation

function x r:p;
begin
  new(r,1);
  r^[1].i:=Ord('O');
  r^[1].v:=Ord('K');
end;

end.
