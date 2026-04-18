with Ada.Directories;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with String_Conversion;     use String_Conversion;
with Interfaces;            use Interfaces;

procedure Bridge (In_Payload : byte_array) is
   payload       : byte_array (In_Payload'Range) := In_Payload;
   F             : Ada.Streams.Stream_IO.File_Type;
   S             : Stream_Access;
   Q             : Stream_Access;
   File_Name_In  : constant String := "payload_to_enc.bin";
   File_Name_Out : constant String := "enc_to_payload.bin";

begin
   Put_Line ("HELLO");
end Bridge;

with Ada.Directories;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with String_Conversion;     use String_Conversion;
with Interfaces;            use Interfaces;

procedure Ada_VDHL (In_Payload : byte_array) is
begin

   Create (F, Out_File, "Ada_To_VHDL");
   S := Stream (F);
   byte_array'Write (S, payload);
   Close (F);

end Ada_VHDL;

procedure VHDL_Ada (In_Payload : byte_array) is
begin

   if Ada.Directories.Exists (File_Name_Out) then
      Open (F, In_File, File_Name_Out);
      Q := Stream (F);
      byte_array'Read (Q, payload);
      Close (F);
   else
      Put_Line ("FILE DOES NOT EXIST");
   end if;
end VHDL_Ada;
