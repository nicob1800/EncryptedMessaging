with Ada.Text_IO;       use Ada.Text_IO;
with GNAT.Sockets;      use GNAT.Sockets;
with String_Conversion; use String_Conversion;
with Interfaces;        use Interfaces;

procedure client is
   Server_IP     : constant String := "127.0.0.1";
   Client_Socket : Socket_Type;
   Address       : Sock_Addr_Type;
   Channel       : Stream_Access;
   Input_Buffer  : String (1 .. 200);
   Last          : Natural;
begin
   Put ("Connecting to " & Server_IP & "...");
   Create_Socket (Client_Socket);
   Address.Addr := Inet_Addr (Server_IP);
   Address.Port := 12345;
   Connect_Socket (Client_Socket, Address);
   Put_Line ("Connected.");

   Channel := Stream (Client_Socket);
   loop
      Put ("Enter message (quit to stop): ");
      Get_Line (Input_Buffer, Last);

      if Last = 0 or else Input_Buffer (1 .. Last) = "quit" then
         exit;
      end if;

      declare
         Message_To_Send : constant String := Input_Buffer (1 .. Last);
         Bitwise_Message : byte_array := String_To_Bytes (Message_To_Send);
         Send_Length     : constant Natural := Bitwise_Message'Length;
         Received_Length : Natural;
      begin
         Put ("Sending data...");
         Natural'Write (Channel, Send_Length);
         for I in Bitwise_Message'Range loop
            Unsigned_8'Write (Channel, Bitwise_Message (I));
         end loop;
         Put_Line ("Sent.");

         Put ("Receiving data...");
         Natural'Read (Channel, Received_Length);

         declare
            Received_Data   : byte_array (1 .. Positive (Received_Length));
            Received_String : String (1 .. Integer (Received_Length));
         begin
            for I in Received_Data'Range loop
               Unsigned_8'Read (Channel, Received_Data (I));
               Received_String (I) :=
                 Character'Val (Integer (Received_Data (I)));
            end loop;

            Put_Line ("Received.");
            Put_Line (Received_String);
         end;
      end;
   end loop;

   Close_Socket (Client_Socket);
end client;
