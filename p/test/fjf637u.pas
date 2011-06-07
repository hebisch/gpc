program fjf637u;

type
  a = abstract object
    procedure foo; abstract;
  end;

var
  v: ^a;
  s: SizeType;

begin
  WriteLn ('OK');
  Halt;
  s := SizeOf (v^)  { ok since v might be polymorphic }
end.
