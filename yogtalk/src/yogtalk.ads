with GNAT.Sockets; use GNAT.Sockets;
private with Ada.Finalization;

package Yogtalk 
is
	pragma SPARK_Mode (On);
	-- TODO:
	-- RFC 6120 3.2.1 states that an SRV Lookup is preferred, but not required.
	-- As such, we'll work with 3.2.2 first, and just do a direct connection with A / AAAA.

	type Connection is tagged limited private;
	function Is_Connected (Conn : Connection) return Boolean;

	-- 3.2.2
	function Connect_To_Server (Hostname : String; Port : Port_Type := 5222) return Connection;

	procedure Disconnect (Conn : in out Connection)
		with Post'Class => not Is_Connected (Conn);

	procedure Send (Conn : Connection; Data : in String) with Pre => Is_Connected (Conn);
private
	pragma SPARK_Mode (Off);
	type Connection is new Ada.Finalization.Limited_Controlled with record
		Channel : Stream_Access := null;
		Client : Socket_Type := No_Socket;
	end record;
	
	overriding procedure Initialize (Conn : in out Connection);
	overriding procedure Finalize (Conn : in out Connection);
	function Is_Connected (Conn : Connection) return Boolean is
		(Conn.Client /= No_Socket and then Conn.Channel /= null);

end Yogtalk;
