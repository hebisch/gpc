program fjf715a;

type
  a = Integer attribute (Size = Chr (4));  { WRONG }

begin
  WriteLn ('failed')
end.
