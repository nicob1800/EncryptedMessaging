with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;
with String_Conversion;

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

   Put ("Sending data...");
   String'Output (Channel, message);
   Put_Line ("Sent.");

   Put ("Receiving data...");

   declare
      Received_Data : String := String'Input (Channel);
   begin
      Put_Line ("Received.");
      Put_Line (Received_Data);
   end;

   Close_Socket (Client_Socket);

end client;
