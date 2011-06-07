unit fjf178b;

interface

type
  TCount=Integer;

  p=^t;
  t(c:Integer)=array[1..c] of record
    i,v:TCount;
  end;

implementation
end.
