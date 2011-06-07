program size_bug;

type
 Time = object
  h,m,s:byte;
  constructor init;
  destructor  done; virtual;
 end;

var OT:Time;  { Kollision with EP-Prozedur }

constructor Time.init;
begin
end;

destructor Time.done;
begin
end;

begin
 OT.init;
 if SizeOf(OT) >= SizeOf ( Pointer ) + 3 * SizeOf ( byte ) then
  writeln ( 'OK' )
 else
  writeln ( 'failed' );
end.
