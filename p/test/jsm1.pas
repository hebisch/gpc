program jsm1( input, output ) ;
                                                                                
  { passing string literal to const var string formal parameter  }
  { produces                                                     }
  {   error: type mismatch in argument 1 of `rejecter'           }

procedure rejecter( const var s : string ) ;
  begin
    writeln('OK') 
  end ;

begin
rejecter( 'literal' ) ;
end.
