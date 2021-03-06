-------------------------------------------------------------------------------
--
--  THIS FILE AND ANY ASSOCIATED DOCUMENTATION IS FURNISHED "AS IS"
--  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
--  BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY
--  AND/OR FITNESS FOR A PARTICULAR PURPOSE.  The user assumes the
--  entire risk as to the accuracy and the use of this file.
--
--  Copyright (C) Intermetrics, Inc. 1995
--  Royalty-free, unlimited, worldwide, non-exclusive use, modification,
--  reproduction and further distribution of this file is permitted.
--
--  This file is now maintained and made available by AdaCore under
--  the same terms.
--
--  Copyright (C) 2000-2010, AdaCore
--
-------------------------------------------------------------------------------

package Win32.crt.Assert is

   DEBUG : constant Boolean := Standard.True;

   procedure Assert
     (Condition   : Boolean;
      Message     : String  := "(no message)";
      Source_File : String  := "(no source file)";
      Line_Number : Natural := 0);

   pragma Inline (Assert);

end Win32.crt.Assert;
