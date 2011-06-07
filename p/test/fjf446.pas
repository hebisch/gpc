program fjf446 (Output);

uses GPC;

var
  str:String(20);
  i,j:Integer;

procedure foo;
begin
  if ErrorAddr = nil then
    WriteLn ('failed: ', str)
  else
    begin
      WriteLn ('OK');
      Halt
    end
end;

begin
  AtExit(foo);
  str:='1234failed';
  i:=5; j:=13;
  {$extended-pascal}
  str:=str[i..j];
end.
