with Yogtalk; use Yogtalk;

procedure Yogtalk_Tests.Send_Msg is
	Conn : constant Connection := Connect_To_Server("localhost");
	test_str : constant String := "Hello World!";
begin
	if Yogtalk.Is_Connected (Conn) then
		Conn.Send(test_str);
	end if;
end Yogtalk_Tests.Send_Msg;
