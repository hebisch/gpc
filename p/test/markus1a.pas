Unit Markus1A;


Interface

  type
    StammPtr = ^StammObj;
      NachfahrPtr = ^NachfahrObj;
        Nachfahr2Ptr = ^Nachfahr2Obj;

    StammObj = object
      Constructor init;
      Procedure machwas1; virtual;
      Procedure machwas2;
      Procedure machwas3; virtual;
      Destructor fini; virtual;
    end { StammObj };

    NachfahrObj = object ( StammObj )
      Constructor init;
      Procedure machwas1; virtual;
      Destructor fini; virtual;
    end { NachfahrObj };

    Nachfahr2Obj = object ( NachfahrObj )
      Constructor init;
      Procedure machwas1; virtual;
      Destructor fini; virtual;
    end { Nachfahr2Obj };


Implementation


Constructor StammObj.init;

begin { StammObj.init }
end { StammObj.init };


Procedure StammObj.machwas1;

begin { StammObj.machwas }
end { StammObj.machwas };


Procedure StammObj.machwas2;

begin { StammObj.machwas2 }
end { StammObj.machwas2 };


Procedure StammObj.machwas3;

begin { StammObj.machwas3 }
end { StammObj.machwas3 };


Destructor StammObj.fini;

begin { StammObj.fini }
end { StammObj.fini };


Constructor NachfahrObj.init;

begin { NachfahrObj.init }
  write ( 'O' );
end { NachfahrObj.init };


Procedure NachfahrObj.machwas1;

begin { NachfahrObj.machwas1 }
end { NachfahrObj.machwas1 };


Destructor NachfahrObj.fini;

begin { NachfahrObj.fini }
  writeln ( 'K' );
end { NachfahrObj.fini };


Constructor Nachfahr2Obj.init;

begin { Nachfahr2Obj.init }
end { Nachfahr2Obj.init };


Procedure Nachfahr2Obj.machwas1;

begin { Nachfahr2Obj.machwas1 }
end { Nachfahr2Obj.machwas1 };


Destructor Nachfahr2Obj.fini;

begin { Nachfahr2Obj.fini }
end { Nachfahr2Obj.fini };


end.
