----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:22:01 11/14/2020 
-- Design Name: 
-- Module Name:    Oxygen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Oxygen is
port(
		--Input
		clk: in std_logic;
		top_switch: in std_logic_vector(7 downto 0);
		switch: in std_logic_vector(7 downto 0);
		button: in std_logic_vector(4 downto 0);
		
		--System
		hq_input: inout std_logic_vector(7 downto 0);
		
		
		--Output
		top_led: out std_logic_vector(7 downto 0);
		led: out std_logic_vector(7 downto 0);
		buzzer: out std_logic;
		
		--7SEG
		a,b,c,d,e,f,g,p: out std_logic;
		common: out std_logic_vector(3 downto 0)
		
		);
end Oxygen;

architecture Behavioral of Oxygen is
--Components
component BCD_7SEG is
port(
		B0,B1,B2,B3 : in STD_LOGIC;
		LED_out: out STD_LOGIC_vector(6 downto 0)
	);
end component;

--Clock
signal clk_count1: integer := 0;
signal new_clk1: std_logic;
signal clk_count2: integer := 0;
signal new_clk2: std_logic;
signal seg_clk_count: integer := 0;
signal seg_clk: std_logic;
signal suf_clk_count: integer := 0;
signal suf_clk: std_logic;
signal clk_count3: integer := 0;
signal new_clk3: std_logic;
signal clk_count4: integer := 0;
signal new_clk4: std_logic;
signal clk_count5: integer := 0;
signal new_clk5: std_logic;

--State
signal state: std_logic_vector(3 downto 0) := "0000";
constant initial: std_logic_vector(3 downto 0) := "0000";
constant generator_off: std_logic_vector(3 downto 0) := "0001";
constant ready: std_logic_vector(3 downto 0) := "0110";
constant game: std_logic_vector(3 downto 0) := "0011";
constant shutdown: std_logic_vector(3 downto 0) := "0100";
constant sufficient: std_logic_vector(3 downto 0) := "0101";


--Output
signal inst_top_led: std_logic_vector(7 downto 0);
signal inst_led: std_logic_vector(7 downto 0);

--etc.
signal led_index: integer := 0;
signal segment_light_loop: integer := 0;
signal segment_light: std_logic_vector(3 downto 0) := "0000";

--7SEGMENT
signal common_index: integer := 0;
signal segment_clk: std_logic;


--Oxygen
signal oxygen: std_logic_vector(3 downto 0);
signal oxygen0: std_logic_vector(3 downto 0) := "0000";
signal oxygen1: std_logic_vector(3 downto 0) := "0000";
signal oxygen2: std_logic_vector(3 downto 0) := "0000";
signal oxygen3: std_logic_vector(3 downto 0) := "0001";

--Sufficient time
signal time0: std_logic_vector(3 downto 0) := "0000";
signal time1: std_logic_vector(3 downto 0) := "0000";
signal time2: std_logic_vector(3 downto 0) := "0000";
signal time3: std_logic_vector(3 downto 0) := "0011";


begin

--Clock Divider
Clock_divider: process(clk)

begin
	--1 sec
	if (rising_edge(clk)) then
		clk_count1 <= clk_count1 + 1;
		clk_count2 <= clk_count2 + 1;
		clk_count3 <= clk_count3 + 1;
		clk_count4 <= clk_count4 + 1;
		clk_count5 <= clk_count5 + 1;
		seg_clk_count <= seg_clk_count + 1;
		suf_clk_count <= suf_clk_count + 1;
		
		if (clk_count1 = 10000000-1) then
			new_clk1 <= not new_clk1;
			clk_count1 <= 0;
		end if;
		if (clk_count2 = 1000000-1) then
			new_clk2 <= not new_clk2;
			clk_count2 <= 0;
		end if;
		if (seg_clk_count = 31250 - 1) then
			seg_clk <= not seg_clk;
			seg_clk_count <= 0;
		end if;
		if (clk_count3 = 2500000-1) then
			new_clk3 <= not new_clk3;
			clk_count3 <= 0;
		end if;
		if (clk_count4 = 500000-1) then
			new_clk4 <= not new_clk4;
			clk_count4 <= 0;
		end if;
		if (clk_count5 = 800000-1) then
			new_clk5 <= not new_clk5;
			clk_count5 <= 0;
		end if;
		
		--millisec
		if (suf_clk_count = 100000 - 1) then
			suf_clk <= not suf_clk;
			suf_clk_count <= 0;
		end if;
		
	end if;
end process;

--7SEG
DISTANCE_DISPLAY: BCD_7SEG 
port map(
			B3 => oxygen(3),
			B2 => oxygen(2),
			B1 => oxygen(1),
			B0 => oxygen(0),
			LED_out(6) => a,
			LED_out(5) => b,
			LED_out(4) => c,
			LED_out(3) => d,
			LED_out(2) => e,
			LED_out(1) => f,
			LED_out(0) => g
			);
			
			
--State
State_select: process(clk,state)
begin
	if (rising_edge(clk)) then
		case state is
		--Initial State
			when initial =>
				--CS
				
				--setup signal
					inst_led <= (others => '0');
					inst_top_led <= (others => 'Z');
					common <= (others => '1');
					led_index <= 0;
					segment_light <= "0000";
					common_index <= 0;
				
				--setup oxygen 1000
					oxygen0 <= "0000";
					oxygen1 <= "0000";
					oxygen2 <= "0000";
					oxygen3 <= "0001";
					
				--Setupu Time 
					time0 <= "0000";
					time1 <= "0000";
					time2 <= "0000";
					time3 <= "0011";
				
				
				--NS
					if (hq_input(0) = '1' and hq_input(1) = '1') then
						state <= ready;
					end if;
				
		--READY STATE 
			when ready =>
			--CS
				--Decoration 
					led_index <= 0;
					
				--7SEGMENT
					if(switch(0) = '1' and switch(7) = '1') then
						oxygen <= segment_light;
						segment_clk <= seg_clk;
						p<= '0';
					else
						segment_light <= "0000";
						oxygen <= "1111";
						segment_clk <= new_clk1;
						p <= '1';
					end if;
						
					if (rising_edge(segment_clk)) then
					--select common
						case common_index is
							when 0 =>
								common(0) <= '0';
								common(1) <= '1';
								common(2) <= '1';
								common(3) <= '1';
							when 1 =>
								common(0) <= '1';
								common(1) <= '0';
								common(2) <= '1';
								common(3) <= '1';
							when 2 =>
								common(0) <= '1';
								common(1) <= '1';
								common(2) <= '0';
								common(3) <= '1';
							when 3 =>
								common(0) <= '1';
								common(1) <= '1';
								common(2) <= '1';
								common(3) <= '0';
							when others => null;
						end case;
						common_index <= common_index + 1;
						if common_index = 3 then
							common_index <= 0;
						end if;
					end if;
				
				--Initial LED

					inst_top_led(7) <= switch(7);
					inst_top_led(0) <= switch(0);
					inst_top_led(6 downto 1) <= "ZZZZZZ";
					if (rising_edge(new_clk2)) then
						inst_led(led_index) <= '1';
						led_index <= led_index + 1;
						if (led_index = 7) then
							led_index <= 0;
						end if;
					end if;
					
				--7SEGMENT LIGHT LOOP
					if(rising_edge(new_clk2) and switch(0) = '1' and switch(7) = '1') then
						segment_light <= segment_light + 1;
						if segment_light = "1100" then
							segment_light <= "1010";
						end if;
					end if;
					
				--System Operation
					--Setup Oxygen ,1000
						oxygen0 <= "0000";
						oxygen1 <= "0000";
						oxygen2 <= "0000";
						oxygen3 <= "0001";
					
					--Setupu Time ,30.00
						time0 <= "0000";
						time1 <= "0000";
						time2 <= "0000";
						time3 <= "0011";
					
					
			--NS
				--Start Travel
					if (hq_input(2) = '1') then
						state <= game; 
					end if;
				
				--Shutdown 
					if (hq_input(1) = '0') then 
						state <= initial;
					end if;
				
		--SHUTDOWN STATE
			when shutdown =>
			--CS
				--Setup Signal
				common <= (others => '1');
				inst_led <= (others => '0');
				inst_top_led <= (others => 'Z');
				common_index <= 0;
				hq_input(3) <= '0';
				
				--LED Light Blink
				if (rising_edge(new_clk2)) then
						inst_top_led(led_index) <= '0';
						inst_led(led_index) <= '1';
						led_index <= led_index + 1;
						if (led_index = 7) then
							led_index <= 0;
						end if;
				end if;
				
				--Oxygen Consumtion
				if (rising_edge(new_clk2)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
					oxygen0 <= oxygen0 - 1;
					if (oxygen0 = "0000") then
						oxygen0 <= "1001";
						oxygen1 <= oxygen1 - '1';
					end if;
					if (oxygen1 = "0000" and oxygen0 = "0000") then
						oxygen1 <= "1001";
						oxygen2 <= oxygen2 - '1';
					end if;
					if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
						oxygen2 <= "1001";
						oxygen3 <= oxygen3 - '1';
					end if;
				end if;
				
				
				
				--NS
				if (hq_input(0) = '1' and hq_input(1) = '1') then
					state <= game;
				elsif (hq_input(0) = '0' and hq_input(1) = '0') then
					state <= initial;
				end if;
				
				
		--Generator Off State
			when generator_off =>
			--CS
				--setup signal
				common <= (others => '1');
				inst_led(7 downto 5) <= hq_input(6 downto 4);
				inst_led(4 downto 0) <= (others => '0');
				led_index <= 0;
				common_index <= 0;
				hq_input(3) <= switch(6);
				
				
				--Top LED
				inst_top_led(0) <= switch(0);
				inst_top_led(6) <= switch(6);
				inst_top_led(7) <= switch(7);
				inst_top_led(5 downto 1) <= (others => '0');
				
				
				--7segment
					if (rising_edge(seg_clk)) then
					--select common
					case common_index is
						when 0 =>
							if(switch(1) = '1') then
								oxygen <= time0;
							else 
								oxygen <= oxygen0;
							end if;
							common(0) <= '0';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '1';
						when 1 =>
							if(switch(1) = '1') then
								oxygen <= time1;
							else 
								oxygen <= oxygen1;
							end if;
							common(0) <= '1';
							common(1) <= '0';
							common(2) <= '1';
							common(3) <= '1';
						when 2 =>
							if(switch(1) = '1') then
								oxygen <= time2;
							else 
								oxygen <= oxygen2;
							end if;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '0';
							common(3) <= '1';
						when 3 =>
							if(switch(1) = '1') then
								oxygen <= time3;
							else 
								oxygen <= oxygen3;
							end if;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '0';
						when others => null;
					end case;
					common_index <= common_index + 1;
					if common_index = 3 then
						common_index <= 0;
					end if;
				end if;
				
				
			--Oxygen Consumtion
				--Engine usage
				case hq_input(6 downto 4) is
				
					when "100" =>
						if (rising_edge(new_clk2)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
						
					when "110" =>
						if (rising_edge(new_clk5)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
						
					when "111" =>
						if (rising_edge(new_clk4)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
					
					when others =>
						if (rising_edge(new_clk2) and switch(7) = '1' and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
				end case;
				
				
	
			--NS
				if ((switch(0) = '1' and hq_input(1) = '1') and hq_input(7) = '1') then
					state <= game;
				elsif (hq_input(0) = '0' and switch = "00000000") then
					state <= initial;
				elsif (hq_input(1) = '0') then
					state <= shutdown;
				elsif (switch(7) = '0') then
					state <= sufficient;
				end if;
				
				
					
			--GAME STATE
				when game =>
				--CS
					inst_top_led(7) <= switch(7);
					inst_top_led(6) <= switch(6);
					inst_top_led(5 downto 2) <= (others => 'Z');
					inst_top_led(1 downto 0) <= switch(1 downto 0);
					inst_led(7 downto 5) <= hq_input(6 downto 4);
					inst_led(4 downto 1) <= (others => '0');
					p <= '0';
					hq_input(3) <= switch(6);
					led_index <= 0;
					
					--7segment
					if (rising_edge(seg_clk)) then
					--select common
					case common_index is
						when 0 =>
							if(switch(1) = '1') then
								oxygen <= time0;
							else 
								oxygen <= oxygen0;
							end if;
							common(0) <= '0';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '1';
						when 1 =>
							if(switch(1) = '1') then
								oxygen <= time1;
							else 
								oxygen <= oxygen1;
							end if;
							common(0) <= '1';
							common(1) <= '0';
							common(2) <= '1';
							common(3) <= '1';
						when 2 =>
							if(switch(1) = '1') then
								oxygen <= time2;
							else 
								oxygen <= oxygen2;
							end if;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '0';
							common(3) <= '1';
						when 3 =>
							if(switch(1) = '1') then
								oxygen <= time3;
							else 
								oxygen <= oxygen3;
							end if;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '0';
						when others => null;
					end case;
					common_index <= common_index + 1;
					if common_index = 3 then
						common_index <= 0;
					end if;
				end if;
				
				--Time Generate
					if (rising_edge(suf_clk) and not(time0 = "0000" and time1 = "0000" and time2 = "0000" and time3 = "0011")) then
						inst_led(0) <= not inst_led(0);
						time0 <= time0 + '1';
						if (time0 = "1001") then
							time0 <= "0000";
							time1 <= time1 + '1';
						end if;
						if (time1 = "1001" and time0 = "1001") then
							time1 <= "0000";
							time2 <= time2 + '1';
						end if;
						if (time2 = "1001" and time1 = "1001" and time0 = "1001") then
							time2 <= "0000";
							time3 <= time3 + '1';
						end if;
					end if;
				
				
				case hq_input(6 downto 4) is
				
					when "100" =>
						if (rising_edge(new_clk1)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
						
					when "110" =>
						if (rising_edge(new_clk3)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
						
					when "111" =>
						if (rising_edge(new_clk2)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
					
					when others =>
						--Oxygen Generation
						if (rising_edge(new_clk1)) then
							oxygen0 <= oxygen0 + 1;
							if (oxygen0 = "1001") then
								oxygen0 <= "0000";
								oxygen1 <= oxygen1 + '1';
							end if;
							if (oxygen1 = "1001" and oxygen0 = "1001") then
								oxygen1 <= "0000";
								oxygen2 <= oxygen2 + '1';
							end if;
							if (oxygen2 = "1001" and oxygen1 = "1001" and oxygen0 = "1001") then
								oxygen2 <= "0000";
								oxygen3 <= oxygen3 + '1';
							end if;
						end if;
					
					end case;
				
				--Engine use
				hq_input(3) <= switch(6);
				
		
				--NS
				if (switch(0) = '0' or hq_input(7) = '0') then
					state <= generator_off;
				elsif (hq_input(0) = '0' and switch = "00000000") then
					state <= initial;
				elsif (hq_input(1) = '0') then
					state <= shutdown;
				elsif (switch(7) = '0') then
					state <= sufficient;
				end if;
				
				
					
			--Sufficient State
				when sufficient =>
				--CS
					hq_input(3) <= switch(6);
					inst_top_led(7 downto 6) <= switch(7 downto 6);
					inst_top_led(1 downto 0) <= switch(1 downto 0);
					inst_top_led(5 downto 2) <= (others => 'Z');
					inst_led(7 downto 5) <= hq_input(6 downto 4);
					inst_led(4 downto 0) <= (others => '0');
					--7segment
					if (rising_edge(seg_clk)) then
					--select common
					case common_index is
						when 0 =>
							if(switch(1) = '0') then
								oxygen <= time0;
							else 
								oxygen <= oxygen0;
							end if;
							common(0) <= '0';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '1';
						when 1 =>
							if(switch(1) = '0') then
								oxygen <= time1;
							else 
								oxygen <= oxygen1;
							end if;
							common(0) <= '1';
							common(1) <= '0';
							common(2) <= '1';
							common(3) <= '1';
						when 2 =>
							if(switch(1) = '0') then
								oxygen <= time2;
							else 
								oxygen <= oxygen2;
							end if;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '0';
							common(3) <= '1';
						when 3 =>
							if(switch(1) = '0') then
								oxygen <= time3;
							else 
								oxygen <= oxygen3;
							end if;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '0';
						when others => null;
					end case;
					common_index <= common_index + 1;
					if common_index = 3 then
						common_index <= 0;
					end if;
				end if;
				
				--Time LEFT
					if (rising_edge(suf_clk) and not(time0 = "0000" and time1 = "0000" and time2 = "0000" and time3 = "0000")) then
						time0 <= time0 - '1';
						if (time0 = "0000") then
							time0 <= "1001";
							time1 <= time1 - '1';
						end if;
						if (time1 = "0000" and time0 = "0000") then
							time1 <= "1001";
							time2 <= time2 - '1';
						end if;
						if (time2 = "0000" and time1 = "0000" and time0 = "0000") then
							time2 <= "1001";
							time3 <= time3 - '1';
						end if;
					end if;
				
				
				
				--Engine usage
				case hq_input(6 downto 4) is
				
					when "100" =>
						if (rising_edge(new_clk1)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
						
					when "110" =>
						if (rising_edge(new_clk3)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
						
					when "111" =>
						if (rising_edge(new_clk2)and not(oxygen0 = "0000" and oxygen1 = "0000" and oxygen2 = "0000" and oxygen3 = "0000")) then
							oxygen0 <= oxygen0 - 1;
							if (oxygen0 = "0000") then
								oxygen0 <= "1001";
								oxygen1 <= oxygen1 - '1';
							end if;
							if (oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen1 <= "1001";
								oxygen2 <= oxygen2 - '1';
							end if;
							if (oxygen2 = "0000" and oxygen1 = "0000" and oxygen0 = "0000") then
								oxygen2 <= "1001";
								oxygen3 <= oxygen3 - '1';
							end if;
						end if;
					when others => 
						--Oxygen Generation
							if (rising_edge(new_clk2) and switch(0) = '1') then
								oxygen0 <= oxygen0 + 1;
								if (oxygen0 = "1001") then
									oxygen0 <= "0000";
									oxygen1 <= oxygen1 + '1';
								end if;
								if (oxygen1 = "1001" and oxygen0 = "1001") then
									oxygen1 <= "0000";
									oxygen2 <= oxygen2 + '1';
								end if;
								if (oxygen2 = "1001" and oxygen1 = "1001" and oxygen0 = "1001") then
									oxygen2 <= "0000";
									oxygen3 <= oxygen3 + '1';
								end if;
							end if;
					
					end case;
				
					
					
			--NS
					if (switch(7) = '1') then
						state <= game;
					elsif (hq_input(0) = '0' and switch = "00000000") then
						state <= initial;
					elsif (hq_input(1) = '0') then
						state <= shutdown;
					end if;
					
					
				when others => null;
				
				
				
		end case;
	end if;
end process;	

top_led <= inst_top_led;
led <= inst_led;
	
end Behavioral;

