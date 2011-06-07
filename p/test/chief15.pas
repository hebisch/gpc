program foobar;

{$X+}

function foo ( p : pChar ) : pChar;
Begin
    foo := succ ( p, 2 );
End;

Var
  x : array [ 0..4 ] of Char value 'xyOK'#0;

Begin
    writeln ( foo ( x ) );
End.
