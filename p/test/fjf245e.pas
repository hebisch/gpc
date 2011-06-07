program fjf245e;
const
  x:integer=42; external name 'foo';  { WRONG }
begin
  WriteLn ('failed')
end.
