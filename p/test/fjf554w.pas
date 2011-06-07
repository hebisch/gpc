program fjf554w;

type
  x = set of Byte;

const
  y: x = [];

begin
  y := [1];  { WARN }
  WriteLn ('failed')
end.
