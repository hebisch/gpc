{$W-}

program fjf211r;

procedure foo (a: array of (foo,bar,baz));  { WRONG }
begin
end;

begin
  WriteLn ('failed')
end.
