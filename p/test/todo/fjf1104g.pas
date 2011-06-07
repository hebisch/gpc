program fjf1104e (Output);

procedure p;

type
  TString = packed array [1 .. 100] of Char;

function f: TString;
begin
  f := 'OK this is not'
end;

var
  s: packed array [1 ..2] of Char = f;

begin
  WriteLn (s)
end;

begin
  p
end.
