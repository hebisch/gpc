{$W no-implicit-abstract}

program fjf637x;

type
  t = object
    a: Integer;
    procedure f; abstract;
  end;

begin
  WriteLn ('OK')
end.
