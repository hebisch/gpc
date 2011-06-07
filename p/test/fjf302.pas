{$implicit-result}

program fjf302;

uses fjf302u;

function f (a : integer) : TString;
begin
  f := 'OK..'#13'Failed'#0;
  {$X+} SetLength (Result, 4) {$X-}
end;

procedure bar (x : cstring);
begin
  if length (cstring2string (x)) = 4
    then writeln (copy (cstring2string (x), 1, 2))
    else begin writeln ('failed: '); writeln (cstring2string (x)) end
end;

begin
  bar (f (0))
end.
