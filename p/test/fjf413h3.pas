program fjf413h3;

type
  a = String (2);

const
  foo = (^a);

begin
  if foo = Chr (1) then WriteLn ('OK') else WriteLn ('failed')
end.
