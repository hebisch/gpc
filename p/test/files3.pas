Program Files3 ( Output );

Type
  Byte = packed 0..255;

Var
  F: bindable File of Byte;
  B: BindingType;

Procedure Foo ( Var Bar: Byte );

begin { Foo }
  if Bar = ord ( 'P' ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', Bar )
end { Foo };

begin
  unbind ( F );
  B:= Binding ( F );
  B.Name:= ParamStr (1);
  Bind ( F, B );
  reset ( F );
  Foo ( F^ );
  close ( F )
end.
