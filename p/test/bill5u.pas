Unit Timer;

interface

procedure TimerInt; {$ifdef HAVE_SECTION_LTEXT} attribute( section(".ltext") ); {$endif}

implementation

procedure TimerInt;

begin
end;

end.
