program fjf468;

procedure foo; external name ''; { WRONG }

begin
  WriteLn ('failed')
end.
