with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with String_Conversion;     use String_Conversion;
with Interfaces;            use Interfaces;

procedure Bridge is
   Payload_Length : constant Positive := 1;
   payload        : byte_array (1 .. Payload_Length);
   F              : Ada.Streams.Stream_IO.File_Type;
   S              : Stream_Access;
   Q              : Stream_Access;
   File_Name_In   : constant String := "payload_to_enc.bin";
   File_Name_Out  : constant String := "enc_to_payload.bin";

begin

   Create (F, Out_File, File_Name_In);
   S := Stream (F);
   for byte of payload loop
      Unsigned_8'Write (S, byte);
   end loop;
   Close (F);

   Create (F, In_File, File_Name_Out);
   Q := Stream (F);
   for byte of payload loop
      Unsigned_8'Read (Q, byte);
   end loop;
   Close (F);

end Bridge;
