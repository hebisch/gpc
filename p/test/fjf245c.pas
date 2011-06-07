program fjf245c;
var
  x:integer=42; external name 'foo';  { WRONG }
begin
  WriteLn ('failed')
end.
