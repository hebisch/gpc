program fjf657a;

type
  TString = String (42);

function f (a: Integer): TString;
begin
  f := 'failed'
end;

var
  a: ^TString;

begin
  a := @f(1);  { WRONG }
  WriteLn (a^)
end.
