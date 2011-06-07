Program Markus2;

  {$X+}

  type
    VarRealProc = ^Function ( var x, y: real ): integer;


Function foo ( var x, y: real ): integer;

begin { foo }
  writeln ( 'OK' );
  foo:= 0;
end { foo };


Procedure bar ( f: VarRealProc );

  var
    u, v: real = 0;

begin { bar }
  f^ ( u, v );
end { bar };


begin
  bar ( @foo );
end.
