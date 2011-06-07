program fjf226i;
uses GPC;
{$B-}

function r : LongestReal;
begin
  r := 0;
  writeln ('failed');
  halt
end;

begin
  RandRealPtr := @r;
  if false and (random >= 0) then writeln ('failed') else writeln ('OK')
end.
