program fjf923;

type PString = ^String;

function f: PString;
begin
  Write ('O');
  f := @'K'
end;

begin
  WriteLn (f^)
end.
