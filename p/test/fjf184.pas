program fjf184;

type t=string(42);

Function  o1: t;
Begin
  o1:='OK'
End;

procedure  o2 ( s : string ) ;
Begin
  writeln(s)
End;

Begin
  o2 ( o1 )
End.
