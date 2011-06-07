program anu1;
type mytype =  (a,b,c,d);
  myrec =record
    st:string (42);
  end;
var arr : array[mytype] of myrec;
begin
  arr[d].st :='OK';
  writeln(arr[d].st);
end.
