program fjf637r;

type
  a = abstract object
    procedure foo; abstract;
  end;

var
  v: ^a;
  p: PObjectType;

begin
  WriteLn ('OK');
  Halt;
  p := TypeOf (v^)  { ok since v might be polymorphic }
end.
