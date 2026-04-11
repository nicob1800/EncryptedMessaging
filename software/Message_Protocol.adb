with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;

package body Message_Protocol is

    procedure Write_Message
       (Message_Header  : Header;
        Message_Payload : byte_array;
        Channel         : Stream_Access;
        Status          : out Protocol_Status)
    is
        Header_Length : constant Integer :=
           Integer (Message_Header.Message_Length);
    begin
        if Header_Length <= 0 or else Message_Payload'Length /= Header_Length
        then
            Status := Bad_Length;
            return;
        end if;

        Unsigned_16'Write (Channel, Message_Header.Sender_ID);
        Unsigned_16'Write (Channel, Message_Header.Receiver_ID);
        Unsigned_16'Write (Channel, Message_Header.Message_Length);
        Unsigned_16'Write (Channel, Message_Header.Counter);
        for char of Message_Payload loop
            Unsigned_8'Write (Channel, char);
        end loop;

        Status := Ok;
    end Write_Message;

    procedure Read_Header
       (Message_Header : out Header;
        Channel        : Stream_Access;
        Status         : out Protocol_Status) is
    begin
        Message_Header.Sender_ID := Unsigned_16'Input (Channel);
        Message_Header.Receiver_ID := Unsigned_16'Input (Channel);
        Message_Header.Message_Length := Unsigned_16'Input (Channel);
        Message_Header.Counter := Unsigned_16'Input (Channel);

        Status := Ok;
    exception
        when others =>
            Status := Stream_Error;
    end Read_Header;

    procedure Read_Payload
       (Message_Payload : out byte_array;
        Payload_Length  : Unsigned_16;
        Channel         : Stream_Access;
        Status          : out Protocol_Status)
    is
        Length_Integer : Integer := Integer (Payload_Length);
    begin
        if Length_Integer <= 0 or else Message_Payload'Length /= Length_Integer
        then
            Status := Bad_Length;
            return;
        end if;

        for I in 1 .. Length_Integer loop
            begin
                Message_Payload (I) := Unsigned_8'Input (Channel);
            exception
                when others =>
                    Status := Stream_Error;
                    return;
            end;
        end loop;

        Status := Ok;

    end Read_Payload;

end Message_Protocol;
