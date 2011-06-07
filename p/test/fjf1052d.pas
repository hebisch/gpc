{$pointer-checking,pointer-checking-user-defined}

program fjf1052d (Output);

uses GPC;

var
  o: Char = 'O';

procedure c1 (p: Pointer);
begin
  if p <> @o then WriteLn ('failed 1')
end;

procedure c2 (p: Pointer);
begin
  if p = nil then WriteLn ('K');
  Halt
end;

type
  p = ^Integer;

const
  a = p (nil);

begin
  ValidatePointerPtr := @c1;
  Write ((@o)^);
  ValidatePointerPtr := @c2;
  WriteLn (a^)
end.
