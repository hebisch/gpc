Unit BO5_10u;

Interface

Type
  BarPtr = ^Bar;

  Bar = object
    Constructor Init;
    Procedure WriteString ( Const S: String ); virtual;
  end { Bar };

Implementation

Constructor Bar.Init;

begin { Bar.Init }
  { empty }
end { Bar.Init };

Procedure Bar.WriteString ( Const S: String );

begin { Bar.WriteString }
  writeln ( S );
end { Bar.WriteString };

end.
