program fjf105a;

const v = 1;

uses GPC;

uses Overlay, StringUtils;

const w = OvrNotFound;

const x = MaxLongInt;

const y = DefaultHashSize;

uses MD5;

const z = BitSizeOf (Card8);

begin
  if     (v = 1)
     and (w = OvrNotFound)
     and (x = High (LongInt))
     and (y >= 1)
     and (z = 8)
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
