with Ada.Text_IO;       use Ada.Text_IO;
with GNAT.Sockets;      use GNAT.Sockets;
with String_Conversion; use String_Conversion;
with Interfaces;        use Interfaces;

procedure client is
   Message       : String := "message";
   Server_IP     : constant String :=
     "127.0.0.1"; -- hard coded server ip address
   Client_Socket : Socket_Type;
   Address       : Sock_Addr_Type;
   Channel       : Stream_Access;

begin
   Put ("Connecting to " & Server_IP & "...");
   Create_Socket (Client_Socket);
   Address.Addr := Inet_Addr (Server_IP);
   Address.Port := 12345;
   Connect_Socket (Client_Socket, Address);
   Put_Line ("Connected.");

   Channel := Stream (Client_Socket);
   declare
      bitwise_message : String_Conversion.byte_array :=
        String_To_Bytes (message);
   begin
      Put ("Sending data...");
      byte_array'Output (Channel, bitwise_message);
      Put_Line ("Sent.");

      Put ("Receiving data...");
   end;

   declare
      Received_Data   : byte_array := byte_array'Input (Channel);
      Received_String : String (1 .. Received_Data'Length);
   begin
      for I in Received_Data'Range loop
         Received_String (I) := Character'Val (Integer (Received_Data (I)));
      end loop;

      Put_Line ("Received.");
      Put_Line (Received_String);
   end;

   Close_Socket (Client_Socket);

end client;
