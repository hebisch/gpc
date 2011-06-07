Unit fjf803u;

interface

operator Plus (a, b: Integer) c: Integer;
operator Unit (a, b: Integer) c: Integer;

implementation

operator Plus (a, b: Integer) c: Integer;
begin
  c := a + b
end;

operator Unit (a, b: Integer) c: Integer;
begin
  c := a * b
end;

end.
