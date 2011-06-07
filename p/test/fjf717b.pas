program fjf717b;

type
  a = abstract object
    procedure foo; abstract; abstract;  { WARN }
  end;

begin
  WriteLn ('failed')
end.
