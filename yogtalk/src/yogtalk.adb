package body Yogtalk 
is

	overriding procedure Initialize (Conn : in out Connection) with SPARK_Mode => Off is
	begin
		Conn.Channel := null;
		Conn.Client := No_Socket;
	end Initialize;

	overriding procedure Finalize (Conn : in out Connection) is
	begin
		Disconnect(Conn);
	exception
		-- ignore disconnect fails, just leak the socket.
		when others => null;
	end Finalize;

	function Connect_To_Server (Hostname : String; Port : Port_Type := 5222) return Connection with SPARK_Mode => Off
	is
	begin
		return Conn : Connection do
		declare
			Address : Sock_Addr_Type;
		begin
			-- Resolve Hostname to Inet_Addr
			Address := Network_Socket_Address
			(Addr => Addresses (Get_Host_By_Name(Hostname), 1),
			Port => Port);

			Create_Socket(Conn.Client, Family => Address.Family);
			Connect_Socket(Conn.Client, Address);
			Conn.Channel := Stream (Conn.Client);

			--  Send:    Data_Type'Write (Conn.Channel, Data);
			--  NOTE: You will need to read input as raw bytes.
		exception
			when others =>
				Disconnect (Conn);
			end;
		end return;
	end Connect_To_Server;

	procedure Disconnect ( Conn : in out Connection) is
	begin
		if Conn.Channel /= null then
			Free (Conn.Channel);
		end if;
		if Conn.Client /= No_Socket then
			begin
				Close_Socket(Conn.Client);
			exception
				when Socket_Error =>
					null;
			end;
			Conn.Client := No_Socket;
		end if;
	end Disconnect;

	procedure Send (Conn : Connection; Data : String) with SPARK_Mode => On is
	begin
		-- NOTE: Ada is Latin-1. Encode Unicode as UTF_Encoding.Wide_Wide_Strings.Encode()
		String'Write(Conn.Channel, Data);
	end Send;
end Yogtalk;
