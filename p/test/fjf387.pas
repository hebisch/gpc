program fjf387;

type
  TString = String (100);

function foo (a : Integer) : TString;
begin
  foo := 'failed'
end;

procedure bar (var s : String);
begin
  WriteLn (s)
end;

var
  a : Integer;

begin
  bar (foo (a)) { WRONG }
end.
