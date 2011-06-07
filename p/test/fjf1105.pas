{$object-checking}

program fjf1105 (Output);

uses GPC;

type
  px = ^tx;
  tx = abstract object
    procedure p; abstract;
  end;

  py = ^ty;
  ty = object (tx)
    constructor c;
    procedure p; virtual;
  end;

constructor ty.c;
begin
end;

procedure ty.p;
begin
  WriteLn ('ty.p')
end;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

var
  a: px;

begin
  AtExit (ExpectError);
  a := New (py);
  SetType (a^, TypeOf (a^)^.Parent);
  a^.p
end.
