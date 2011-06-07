unit chief45u;

interface

type tcollection = object
   constructor init;
   procedure foo; virtual;
end;

tstrcollection = object (tcollection)
   procedure foo; virtual;
end;
{if *both* "foo" methods are not virtual, then the problem goes away!}

implementation

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
