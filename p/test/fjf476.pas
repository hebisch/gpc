program fjf476;

function foo (var s : String) : Boolean;
begin
  s := 'OK';
  foo := True
end;

function bar (s : String) : Boolean;
begin
  Write (s);
  bar := True
end;

var
  s : String (10);

begin
  s := 'failed';
  { Problem: The copy for passing by value is made at the beginning
    of the *statement*, but it must be made after the call to foo. }
  if foo (s) and_then bar (s) then WriteLn
end.
