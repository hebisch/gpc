unit chief45y;

interface

type
pcollection = ^tcollection;
tcollection = object
   constructor init;
   procedure foo; virtual;
end;

tstrcollection = object (tcollection)
   procedure foo; virtual;
end;
{if *both* "foo" methods are not virtual, then the problem goes away!}

implementation

uses chief45x;

constructor tcollection.init;
begin
end;

procedure tcollection.foo;
begin
end;

procedure tstrcollection.foo;
begin
end;

end.
