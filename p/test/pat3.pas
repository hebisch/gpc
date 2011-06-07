program Pat3;

uses
  Pat2;

var
  s : string(100);

{ This procedure defined here, will work correctly }
procedure ident1(This_String : string);
begin
  write ( This_String [ 1 ] );
{$if 0 }
  WriteLn('Capacity ',This_String.Capacity);
  WriteLn('Length   ',Length(This_String));
  WriteLn('Contains ',This_String);
{$endif }
end;

{ The procedure Identify, is defined in the unit ident, exactly as above
  (except, of course for the name).  The external procedure used to fail
}
begin
  s := 'OK';
  ident1(s);
  Identify('OK');
  WriteLn;
end.
