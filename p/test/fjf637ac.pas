program fjf637ac;

type
  t = object
    procedure f; abstract;  { WARN }
  end;

begin
  WriteLn ('failed')
end.
