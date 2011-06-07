{ prior parameter ... }

program fjf501a;

uses GPC, fjf501u;

procedure p (s : String);
begin
  WriteLn (s)
end;

var
  v : PString;

begin
  v := @'OK';
  p (v^)
end.
