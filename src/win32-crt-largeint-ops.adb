--  $Source$
--  $Revision$ $Date$ $Author$
with System;

--  GNAT body.

with Ada.Unchecked_Conversion;
with Interfaces;

package body Win32.crt.Largeint.Ops is

   use type System.Bit_Order;
   High_Order_First : constant Boolean :=
     System.Default_Bit_Order = System.High_Order_First;

   --  visible

   function To_64 (Low : DWORD; High : DWORD := 0)
                  return DWORDLONG is
      Res : DWORDLONG;
   begin
      if High_Order_First then
         Res.A := UINT (High);
         Res.B := UINT (Low);
      else
         Res.B := UINT (High);
         Res.A := UINT (Low);
      end if;
      return Res;
   end To_64;

   function To_64 (Low : DWORD; High : LONG := 0)
                  return LONGLONG is
      Res : LONGLONG;
   begin
      if High_Order_First then
         Res.A := INT (High);
         Res.B := INT (To_Signed (Low));
      else
         Res.B := INT (High);
         Res.A := INT (To_Signed (Low));
      end if;
      return Res;
   end To_64;

   procedure Split (Value : DWORDLONG;
                    Low,
                      High : out DWORD) is
   begin
      if High_Order_First then
         High := DWORD (Value.A);
         Low := DWORD (Value.B);
      else
         Low := DWORD (Value.A);
         High := DWORD (Value.B);
      end if;
   end Split;


   subtype int32 is Interfaces.Integer_32;
   subtype uns32 is Interfaces.Unsigned_32;
   subtype int64 is Interfaces.Integer_64;
   subtype uns64 is Interfaces.Unsigned_64;
   function ToInt is new Ada.Unchecked_Conversion (LONGLONG, int64);
   function ToUns is new Ada.Unchecked_Conversion (DWORDLONG, uns64);
   function ToPriv is new Ada.Unchecked_Conversion (int64, LONGLONG);
   function ToPriv is new Ada.Unchecked_Conversion (uns64, DWORDLONG);

   --  Arithmetic
   function "+" (Left, Right : LONGLONG)  return LONGLONG is
      use Interfaces;
   begin
      return ToPriv (ToInt (Left) + ToInt (Right));
   end "+";

   function "+" (Left, Right : DWORDLONG) return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (ToUns (Left) + ToUns (Right));
   end "+";

   function "-" (Left, Right : LONGLONG)  return LONGLONG is
      use Interfaces;
   begin
      return ToPriv (ToInt (Left) - ToInt (Right));
   end "-";

   function "-" (Left, Right : DWORDLONG) return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (ToUns (Left) - ToUns (Right));
   end "-";

   function "*" (Left, Right : LONG)  return LONGLONG is
      use Interfaces;
   begin
      return ToPriv (int64 (Left) * int64 (Right));
   end "*";

   function "*" (Left, Right : DWORD) return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (uns64 (Left) * uns64 (Right));
   end "*";

   function "*" (Left : LONGLONG;
                 Right : LONG) return LONGLONG is
      use Interfaces;
   begin
      return ToPriv (ToInt (Left) * int64 (Right));
   end "*";

   function "-" (Left : LONGLONG) return LONGLONG is
      use Interfaces;
   begin
      return ToPriv (-ToInt (Left));
   end "-";

   function ExtendedMagicDivide
     (Dividend : LONGLONG;
      MagicDivisor : LONGLONG;
      ShiftCount : Natural) return LONGLONG is
      function X
        (Dividend : LONGLONG;
         MagicDivisor : LONGLONG;
         ShiftCount : Natural) return LONGLONG;
      pragma Import (Stdcall, X, "ExtendedMagicDivide");
   begin
      return X (Dividend, MagicDivisor, ShiftCount);
   end ExtendedMagicDivide;

   --  Large Integer divide - 64-bits / 32-bits -> 64-bits

   function ExtendedLargeIntegerDivide
     (Dividend : LONGLONG;
      Divisor : DWORD;
      Remainder : access DWORD) return LONGLONG is
      function X
        (Dividend : LONGLONG;
         Divisor : DWORD;
         Remainder : access DWORD) return LONGLONG;
      pragma Import (Stdcall, X, "ExtendedLargeIntegerDivide");
   begin
      return X (Dividend, Divisor, Remainder);
   end ExtendedLargeIntegerDivide;

   --  Large Integer divide - 64-bits / 32-bits -> 64-bits

   function LargeIntegerDivide
     (Dividend : LONGLONG;
      Divisor : LONGLONG;
      Remainder : access LONGLONG)
     return LONGLONG is
      function X
        (Dividend : LONGLONG;
         Divisor : LONGLONG;
         Remainder : access LONGLONG) return LONGLONG;
      pragma Import (Stdcall, X, "LargeIntegerDivide");
   begin
      return X (Dividend, Divisor, Remainder);
   end LargeIntegerDivide;

   --  Bitwise operations
   function "and" (Left, Right : DWORDLONG) return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (ToUns (Left) and ToUns (Right));
   end "and";

   function Shift_Left  (Value : DWORDLONG; Amount : Natural)
                        return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (Shift_Left (ToUns (Value), Amount));
   end Shift_Left;

   function Shift_Right (Value : DWORDLONG; Amount : Natural)
                        return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (Shift_Right (ToUns (Value), Amount));
   end Shift_Right;

   function Shift_Right_Arithmetic (Value : DWORDLONG; Amount : Natural)
                                   return DWORDLONG is
      use Interfaces;
   begin
      return ToPriv (Shift_Right_Arithmetic (ToUns (Value), Amount));
   end Shift_Right_Arithmetic;

   --  Printable images, hex or decimal

   function Image (Value : LONGLONG;  Hex : Boolean := Standard.False)
                  return String is
      use Interfaces;
   begin
      return int64'Image (ToInt (Value));
   end Image;

   function Image (Value : DWORDLONG;  Hex : Boolean := Standard.True)
                  return String is
      use Interfaces;
   begin
      return uns64'Image (ToUns (Value));
   end Image;

   --  winnt.h
   function Int32x32To64 (A, B : LONG) return LONGLONG is
   begin
      return Win32.crt.Largeint.Ops."*"
        (Win32.crt.Largeint.Ops.LONG (A),
        Win32.crt.Largeint.Ops.LONG (B));
   end Int32x32To64;

   function UInt32x32To64 (A, B : DWORD) return DWORDLONG is
   begin
      return Win32.crt.Largeint.Ops."*"
        (Win32.crt.Largeint.Ops.DWORD (A),
        Win32.crt.Largeint.Ops.DWORD (B));
   end UInt32x32To64;

   function Int64ShllMod32 (Val : DWORDLONG; By : Shift_Count)
                           return DWORDLONG is
   begin
      return DWORDLONG (Win32.crt.Largeint.Ops.Shift_Left
        (Win32.crt.Largeint.Ops.DWORDLONG (Val), Natural (By)));
   end Int64ShllMod32;

   function Int64ShraMod32 (Val : LONGLONG;
                            By : Shift_Count) return LONGLONG is
   begin
      return Win32.crt.Largeint.Ops.To_Signed
        (Win32.crt.Largeint.Ops.Shift_Right_Arithmetic
        (Win32.crt.Largeint.Ops.To_Unsigned (Val), Natural (By)));
   end Int64ShraMod32;

   function Int64ShrlMod32 (Val : DWORDLONG;
                            By : Shift_Count) return DWORDLONG is
   begin
      return DWORDLONG (Win32.crt.Largeint.Ops.Shift_Right
        (Win32.crt.Largeint.Ops.DWORDLONG (Val), Natural (By)));
   end Int64ShrlMod32;

end Win32.crt.Largeint.Ops;


