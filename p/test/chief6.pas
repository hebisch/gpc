{  Unit implementing a base (generic) TObject type }
Unit MyObj;

Interface

Type
  LongInt = Integer;

ObjectStr= String[255];
pObject  = ^TObject;
TObject  = Object

   Parent      : pObject;
   Child       : pObject;
   Name        : ObjectStr;
   Handle      : LongInt;
   SelfID      : LongInt;

   { BP }
   Constructor Init;
   Destructor  Done;virtual;

   { Delphi }
   Procedure   Free;virtual;     { disposes of @Self and calls Destroy }
   Destructor  Destroy;virtual;
   Constructor Create(aOwner : pObject);

   private
   SelfPtr     : pObject;  { pointer to Self }
End; { TObject }


Function InstanceFromHandle(Const aHandle:LongInt;Var aReturn:LongInt):pObject;
{ return a pointer to an object instance, via its handle }

Implementation

Var
ObjectCount:LongInt;   { a local counter to allocate unique handles }

{ record for object list }
Type
pListUnit = ^TListUnit;
TListUnit  = Record
    Next      : pListUnit;
    TheObject : pObject;
End; { TListUnit }

{ local object for manipulating list}
Type
pObjectList = ^ObjectList;
ObjectList  = Object (TObject)
    Head : pListUnit;
    Constructor Create(aOwner : pObject);
    Procedure   Free;virtual;
    Procedure   Insert(NewObject:pObject); virtual;
    Procedure   UserFree(TheObject:pObject); virtual;
    Procedure   UserLocate(Var Found:Boolean; Const aHandle:LongInt;TheObject:pObject);
virtual;
    Procedure   UserLocate2(Var Found:Boolean; Const aHandle:LongInt;TheObject:pObject);
virtual;
    Procedure   Remove(TheObject:pObject); virtual;
    Function    Count:LongInt; virtual;
    Procedure   AdjustTotCount; virtual;
    Function    FindFromHandle(Const H:LongInt):pObject;
    Function    FindFromSelfID(Const H:LongInt):pObject;
End; { ObjectList }

{//////////////////////////////////////////}
{//////////////////////////////////////////}
{//////////////////////////////////////////}
{$ifndef Ver70}
Function Assigned (p : pointer) : Boolean;
Begin
  Assigned := (p <> Nil);
End;
{$endif Ver70}
{//////////////////////////////////////////}
{/////////// OBJECTLIST ///////////////////}
{//////////////////////////////////////////}
Constructor ObjectList.Create;
Begin
  Inherited Create (aOwner);
  Head := Nil;
End;  { ObjectList.Create }
{//////////////////////////////////////////}
Procedure ObjectList.UserLocate;
Begin
  Found := TheObject^.SelfID = aHandle;
End;  { ObjectList.UserLocate }
{//////////////////////////////////////////}
Procedure ObjectList.UserLocate2;
Begin
  Found := TheObject^.SelfID = aHandle;
End;  { ObjectList.UserLocate2 }
{//////////////////////////////////////////}
Procedure ObjectList.UserFree;
Begin
   {TheObject:=Nil;}
End;  { ObjectList.UserFree }
{//////////////////////////////////////////}
Function ObjectList.FindFromHandle;
Var
  Found : Boolean;
  N     : pListUnit;
Begin
  Found := False;
  N     := Head;
  FindFromHandle := Nil;
  While (Found = False) and (N <> Nil) Do Begin
    UserLocate (Found, H, N^.TheObject);
    If Found then FindFromHandle := N^.TheObject;
    N := N^.Next;
  End;
End;  { ObjectList.FindFromHandle }
{//////////////////////////////////////////}
Function ObjectList.FindFromSelfID;
Var
  Found : Boolean;
  N     : pListUnit;
Begin
  Found := False;
  N     := Head;
  FindFromSelfID := Nil;
  While (Found = False) and (N <> Nil) Do Begin
    UserLocate2 (Found, H, N^.TheObject);
    If Found then FindFromSelfID := N^.TheObject;
    N := N^.Next;
  End;
End;   { ObjectList.FindFromSelfID }
{//////////////////////////////////////////}
Procedure ObjectList.Free;
Var
  N : pListUnit;
Begin
  While Head <> Nil Do Begin
    N := Head;
    Head := N^.Next;
    UserFree (N^.TheObject);
    Dispose (N);
  End;
  Inherited Free;
End;  { ObjectList.Free }
{//////////////////////////////////////////}
Procedure ObjectList.Insert;
Var
  N : pListUnit;
Begin
  New (N);
  N^.Next := Head;
  N^.TheObject := NewObject;
  Head := N;
End;  { ObjectList.Insert }
{//////////////////////////////////////////}
Function ObjectList.Count;
Var
  N : pListUnit;
  i : LongInt;
Begin
  N := Head;
  Count := 0;
  i := 0;
  While N <> Nil
  Do Begin
    Inc (i);
    N := N^.Next;
  End;
  Count := i;
End;  { ObjectList.Count }
{//////////////////////////////////////////}
Procedure ObjectList.AdjustTotCount;
Var
  N : pListUnit;
  i : LongInt;
Begin
  N := Head;
  i := 0;
  While N <> Nil
  Do Begin
    Inc (i);
    N^.TheObject^.SelfID := i;
    N := N^.Next;
  End;
  ObjectCount := i;
End;  { ObjectList.AdjustTotCount }
{//////////////////////////////////////////}
Procedure ObjectList.Remove;
Var
  N,F : pListUnit;
  i   : LongInt;
Begin
  N := Head;
  F := N;
  i := 0;
  If Not (Assigned (TheObject) ) then Exit;
  While (N <> Nil)
  Do Begin
    Inc (i);
    If  (N^.TheObject = TheObject)
    then Begin {remove it}
      UserFree (N^.TheObject);
      If N = Head then Head := N^.Next
      else F^.Next := N^.Next;

      If (N^.TheObject^.SelfID = ObjectCount)
      then Dec (ObjectCount);

      Dispose (N);
      N := Nil;
    End{remove it}
    else Begin
      F := N;
      N := N^.Next;
    End;
  End;
End;  { ObjectList.Remove }
{//////////////////////////////////////}
{//////////////////////////////////////}
{object instance to hold the list of active
objects}
Var
aList : ObjectList;
{//////////////////////////////////////}
{//////////////////////////////////////}
{//////////////////////////////////////}
{find an object instance from its SelfID}
Function InstanceFromHandle;
Begin
    aReturn := 0;
    InstanceFromHandle := aList.FindFromHandle (aHandle);
End;
{===========================================}
{===========================================}
{============ TOBJECT ======================}
{===========================================}
{===========================================}
Constructor TObject.Init;
Begin
   SelfPtr := @Self;
   Parent  := Nil;
   Child   := Nil;
   Handle  := 0;
   Name    := '';
   Inc (ObjectCount);
   SelfID := ObjectCount;
   aList.Insert(@Self);
End;  { TObject.Init }
{////////////}
Constructor TObject.Create;
Begin
   SelfPtr := @Self;
   Child   := Nil;
   Child   := Nil;
   Handle  := 0;
   Parent  := aOwner;
   Name    := '';
   Inc (ObjectCount);
   SelfID := ObjectCount;
   aList.Insert(@Self);
End;  { TObject.Create }
{////////////}
Destructor TObject.Done;
Begin
   Handle  := 0;
   Name    := '';
   Parent  := Nil;
   SelfPtr := Nil;  { Mark that we are already freed }
   aList.Remove(@Self);
End;  { TObject.Done }
{////////////}
Destructor TObject.Destroy;
Begin  { this can be different from --> Done() }
   Handle  := 0;
   Name    := '';
   Parent  := Nil;
   SelfPtr := Nil;  { Mark that we are already freed }
   aList.Remove(@Self);
End;  { TObject.Destroy }
{////////////}
Procedure TObject.Free;
Begin
   If   (SelfPtr <> Nil)   { check that we are not already freed }
   then Dispose (pObject (@Self), Destroy);
End;   { TObject.Free }
{////////////}

Begin { Unit Initialisation }
  ObjectCount:=-1;      { start with -1: aList.SelfID = 0}
  {aList.Create (Nil);} { <<<-- any call to ancestor causes GPF in GPC !! }
  aList.Init;
End.  { Unit }
