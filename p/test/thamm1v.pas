Unit XFrames;

Interface

USES PktDefs in 'thamm1u.pas';

TYPE
  tFrames = Object
    FileName : String(100);

    CONSTRUCTOR init(datafilename : String);
    DESTRUCTOR done;
    FUNCTION GetNextDataPkt(VAR pkt : PacketPtr) : BOOLEAN;
  END;

Implementation

CONSTRUCTOR tFrames.init(datafilename : String);
BEGIN
  FileName := datafilename;
END;

DESTRUCTOR tFrames.done;
BEGIN
END;

FUNCTION tFrames.GetNextDataPkt(VAR pkt : PacketPtr) : BOOLEAN;
BEGIN
  GetNextDataPkt := TRUE;
END;

END.
