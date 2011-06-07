Program BO5_7;

uses
  BO5_7u in 'bo5-7u.pas';

Var
  Test: BasePtrArray ( 2 );
  i: Integer;

begin
  Test [ 0 ]:= New ( BasePtr, Init );
  Test [ 1 ]:= New ( SubPtr, Init );
  for i:= 0 to Test.Capacity - 1 do
    Test [ i ]^.Foo;
  writeln;
end.
