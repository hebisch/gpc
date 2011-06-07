unit kurzw1u;

interface

procedure foo (a : byte);
function bar : boolean;

implementation

procedure foo (a : byte);
begin
  WriteLn ('Failed');
  Halt
end;

function bar : boolean;
begin
  WriteLn ('Failed');
  Halt;
  bar := false
end;

end.
