{ This test tests, among other things, a BP extension (`^A'), and BP
  fails (`^A..^Z'). GPC handles BP's features a little better than
  BP itself ... ;-) }

{$W no-typed-const}

Program Chars;

Type
  X = ^Y;
  Y = packed array [ ^A..^B ] of Char;
  Z = ^A..^Z;

Const
  O: Char = 'O';
  OK: Y = 'ab';

Var
  K: Char value 'Y';
  KO: array [ 1..2 ] of Char value ( 'K', 'O' );


Procedure Foo ( bar: Char );

begin { Foo }
  writeln ( OK );
  {$W-} OK [ #1 ]:= '';
  OK [ ^B ]:= 'schade'; {$W+}
end { Foo };


begin
  K:= KO [ 1 ];
  case KO [ 2 ] of
    succ ( ^O, 64 ): OK [ chr ( 1 ) ]:= O;
    #3: OK [ pred ( ^O, ord ( ^M ) ) ]:= #27;
  end { case };
  if OK [ ^A ] in [ ^A..^C, 'A'..'Z' ] then
    OK [ ^B ]:= K;
  {$W-}  Foo ( '' );  {$W+}
  { Extended Pascal allows Char := <empty string>.  GPC warns about that. }
end.
