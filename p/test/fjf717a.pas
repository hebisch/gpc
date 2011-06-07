program fjf717a;

type
  a = abstract object
    procedure foo; abstract; virtual;  { WARN }
  end;

begin
  WriteLn ('failed')
end.
