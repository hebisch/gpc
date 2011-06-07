program fjf148;

type
  t(x:Integer)=record
    Name:string(80);
    Data:array[1..x] of Integer
  end;

var p:^t;

begin
  New(p,1);
  p^.Name:='OK';
  WriteLn(p^.Name);
end.
