UNIT PktDefs;

INTERFACE

{USES BPCompat;}

TYPE
  EthernetAddress = ARRAY[1..6] OF BYTE;
  PacketPtr = ^Packet;
  Packet = PACKED RECORD
             Dst    : EthernetAddress;
             Src    : EthernetAddress;
             Typ    : WORD;
             MsgId  : LongInt;
             SeqNo  : LongInt;
             PktLen : LongInt;
             Data   : ARRAY[1..256] OF LongInt;
           END;

IMPLEMENTATION

END.
