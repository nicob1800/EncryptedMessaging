with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with String_Conversion;     use String_Conversion;

procedure Bridge is
    Payload_Length : constant Positive := 1;
    payload        : byte_array (1 .. Payload_Length);
    F              : File_Type;
    S              : Stream_Access;
    File_Name_In   : constant String := "payload_to_enc.bin";
    File_Name_Out  : constant String := "enc_to_payload.bin";

begin

    Create (F, Out_File, File_Name_In);
    S := Stream (F);
    for byte of payload loop
        byte_array'Write (S, byte);
    end loop;
    Close (F);

end Bridge;
