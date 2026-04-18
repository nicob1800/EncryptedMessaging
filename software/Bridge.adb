with Ada.Calendar; use Ada.Calendar;
with Ada.Characters.Handling;
with Ada.Directories;
with Ada.Text_IO;  use Ada.Text_IO;
with Interfaces;   use Interfaces;

package body Bridge is

   function To_Hex_Char (Value : Natural) return Character is
   begin
      if Value < 10 then
         return Character'Val (Character'Pos ('0') + Value);
      else
         return Character'Val (Character'Pos ('A') + (Value - 10));
      end if;
   end To_Hex_Char;

   function Hex_Value (Ch : Character) return Natural is
   begin
      case Ada.Characters.Handling.To_Upper (Ch) is
         when '0'    =>
            return 0;

         when '1'    =>
            return 1;

         when '2'    =>
            return 2;

         when '3'    =>
            return 3;

         when '4'    =>
            return 4;

         when '5'    =>
            return 5;

         when '6'    =>
            return 6;

         when '7'    =>
            return 7;

         when '8'    =>
            return 8;

         when '9'    =>
            return 9;

         when 'A'    =>
            return 10;

         when 'B'    =>
            return 11;

         when 'C'    =>
            return 12;

         when 'D'    =>
            return 13;

         when 'E'    =>
            return 14;

         when 'F'    =>
            return 15;

         when others =>
            raise Constraint_Error;
      end case;
   end Hex_Value;

   procedure Transfer_Payload
     (In_Payload       : in byte_array;
      Out_Payload      : out byte_array;
      Status           : out Bridge_Status;
      Counter          : in Unsigned_16 := 0;
      Timeout_Seconds  : in Duration := 2.0;
      Input_File_Name  : in String := "payload_to_enc.bin";
      Output_File_Name : in String := "enc_to_payload.bin")
   is
      Input_File   : File_Type;
      Output_File  : File_Type;
      Counter_Line : String (1 .. 4);
      Length_Line  : String (1 .. 4);
      Line         : String (1 .. 2);
      Start_Time   : Time;
      Out_Line     : String (1 .. 2);
      Last         : Natural;
   begin
      if In_Payload'Length /= Out_Payload'Length then
         Status := Length_Mismatch;
         return;
      end if;

      if Ada.Directories.Exists (Output_File_Name) then
         Ada.Directories.Delete_File (Output_File_Name);
      end if;

      Create (Input_File, Out_File, Input_File_Name);
      Counter_Line (1) := To_Hex_Char (Natural (Counter / 4096));
      Counter_Line (2) := To_Hex_Char (Natural ((Counter / 256) mod 16));
      Counter_Line (3) := To_Hex_Char (Natural ((Counter / 16) mod 16));
      Counter_Line (4) := To_Hex_Char (Natural (Counter mod 16));
      Put_Line (Input_File, Counter_Line);

      declare
         Payload_Length : constant Natural := In_Payload'Length;
      begin
         Length_Line (1) := To_Hex_Char (Payload_Length / 4096);
         Length_Line (2) := To_Hex_Char ((Payload_Length / 256) mod 16);
         Length_Line (3) := To_Hex_Char ((Payload_Length / 16) mod 16);
         Length_Line (4) := To_Hex_Char (Payload_Length mod 16);
         Put_Line (Input_File, Length_Line);
      end;

      for B of In_Payload loop
         Line (1) := To_Hex_Char (Natural (B / 16));
         Line (2) := To_Hex_Char (Natural (B mod 16));
         Put_Line (Input_File, Line);
      end loop;
      Close (Input_File);

      Start_Time := Clock;
      loop
         exit when Ada.Directories.Exists (Output_File_Name);

         if Clock - Start_Time > Timeout_Seconds then
            Status := Timeout;
            return;
         end if;

         delay 0.01;
      end loop;

      if not Ada.Directories.Exists (Output_File_Name) then
         Status := Output_Missing;
         return;
      end if;

      Open (Output_File, In_File, Output_File_Name);
      Get_Line (Output_File, Counter_Line, Last);
      if Last < 4 then
         Close (Output_File);
         Status := Length_Mismatch;
         return;
      end if;

      Get_Line (Output_File, Length_Line, Last);
      if Last < 4 then
         Close (Output_File);
         Status := Length_Mismatch;
         return;
      end if;

      declare
         Counter_Out : constant Unsigned_16 :=
           Unsigned_16
             (Hex_Value (Counter_Line (1)) * 4096
              + Hex_Value (Counter_Line (2)) * 256
              + Hex_Value (Counter_Line (3)) * 16
              + Hex_Value (Counter_Line (4)));
         Length_Out_Value : constant Natural :=
           Hex_Value (Length_Line (1)) * 4096
           + Hex_Value (Length_Line (2)) * 256
           + Hex_Value (Length_Line (3)) * 16
           + Hex_Value (Length_Line (4));
      begin
         if Counter_Out /= Counter then
            Close (Output_File);
            Status := Io_Error;
            return;
         end if;

         if Length_Out_Value /= Out_Payload'Length then
            Close (Output_File);
            Status := Length_Mismatch;
            return;
         end if;
      end;

      for I in Out_Payload'Range loop
         Get_Line (Output_File, Out_Line, Last);
         if Last < 2 then
            Close (Output_File);
            Status := Length_Mismatch;
            return;
         end if;

         Out_Payload (I) :=
           Unsigned_8
             (Hex_Value (Out_Line (1)) * 16 + Hex_Value (Out_Line (2)));
      end loop;
      Close (Output_File);

      Status := Ok;

   exception
      when others =>
         if Is_Open (Input_File) then
            Close (Input_File);
         end if;
         if Is_Open (Output_File) then
            Close (Output_File);
         end if;
         Status := Io_Error;
   end Transfer_Payload;

end Bridge;
