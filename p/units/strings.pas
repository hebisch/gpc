{ BP compatible Strings unit

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

module Strings;

export Strings = all (CStringLength => StrLen, CStringEnd => StrEnd,
                      CStringMove => StrMove, CStringCopy => StrCopy,
                      CStringCopyEnd => StrECopy, CStringLCopy => StrLCopy,
                      CStringCopyString => StrPCopy, CStringCat => StrCat,
                      CStringLCat => StrLCat, CStringComp => StrComp,
                      CStringCaseComp => StrIComp, CStringLComp => StrLComp,
                      CStringLCaseComp => StrLIComp, CStringChPos => StrScan,
                      CStringLastChPos => StrRScan, CStringPos => StrPos,
                      CStringLastPos => StrRPos, CStringUpCase => StrUpper,
                      CStringLoCase => StrLower, CStringIsEmpty => StrEmpty,
                      CStringNew => StrNew);

import GPC;

function StrPas (aString: CString): TString;
procedure StrDispose (s: CString); external name '_p_Dispose';

end;

function StrPas (aString: CString): TString;
begin
  StrPas := CString2String (aString)
end;

end.
