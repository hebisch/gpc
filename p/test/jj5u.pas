Unit JJ5u;

Interface

Procedure O ( foo: Integer ); {$ifdef HAVE_STDCALL} attribute (stdcall);  { Not on all platforms } {$endif}

Implementation

Procedure O ( foo: Integer );

begin { O }
  write ( 'O' );
end { O };

end.
