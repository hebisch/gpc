Program Switches (Output);

Var
  S: String ( 5 );

{$mixed-comments}

(* Mixed comments are switched on. }

{$no-mixed-comments}

(* Mixed {comments} are switched {off}.*)


{$ifdef INVIS }

  GPC does not see this text unless you #define INVIS.  But why should you?

{$endif }


{$define CMULB chr }


begin
  write ( "\117" );
  WriteStr ( S, '\n' + chr ( 8#13 ) + CMULB ( $0C ) );
  if S = '\n'^K#12 then
    writeln ( 'K' )
  else
    writeln ( '\bfailed: ''', S, '''' );
end.
