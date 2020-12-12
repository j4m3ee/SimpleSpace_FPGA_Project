----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:07:50 11/12/2020 
-- Design Name: 
-- Module Name:    Captain - Behavioral 
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Captain is
port(
		--Input
		clk: in std_logic;
		top_switch: in std_logic_vector(7 downto 0);
		switch: in std_logic_vector(7 downto 0);
		button: in std_logic_vector(4 downto 0);
		
		
		--Output
		top_led: out std_logic_vector(7 downto 0);
		led: out std_logic_vector(7 downto 0);
		buzzer: out std_logic;
		
		--System
		o2_output: inout std_logic_vector(7 downto 0);
		engine_output: inout std_logic_vector(7 downto 0);
		energy_output: inout std_logic_vector(7 downto 0);
		
		--7SEG
		a,b,c,d,e,f,g: out std_logic;
		common: out std_logic_vector(3 downto 0)
		
		);
		
end Captain;

architecture Behavioral of Captain is
--Components
component BCD_7SEG is
port(
		B0,B1,B2,B3 : in STD_LOGIC;
		LED_out: out STD_LOGIC_vector(6 downto 0)
	);
end component;


--Clock
signal clk_count: integer := 0;
signal clk_count2: integer := 0;
signal clk_count3: integer := 0;
signal new_clk: std_logic;
signal new_clk2: std_logic;
signal seg_clk: std_logic;

--State
signal state: std_logic_vector(3 downto 0) := "0000";
constant initial: std_logic_vector(3 downto 0) := "0000";
constant ship_off: std_logic_vector(3 downto 0) := "0001";
constant ready: std_logic_vector(3 downto 0) := "0010";
constant game: std_logic_vector(3 downto 0) := "0011";

--Input

--Output
signal inst_top_led: std_logic_vector(7 downto 0);
signal inst_led: std_logic_vector(7 downto 0);
signal inst_buzzer: std_logic;
signal inst_o2_output: std_logic_vector(7 downto 0);

--Distance
signal common_index: integer := 0;
signal distance: std_logic_vector(3 downto 0);
signal distance0: std_logic_vector(3 downto 0);
signal distance1: std_logic_vector(3 downto 0);
signal distance2: std_logic_vector(3 downto 0);
signal distance3: std_logic_vector(3 downto 0);

--etc.
signal led_index: integer := 0;
signal segment_light_loop: integer := 0;
signal segment_light: std_logic_vector(3 downto 0) := "1010";
signal display_select: std_logic;

--Velocity_clk
signal speed_clk: std_logic := '0';
signal speed: std_logic;
signal speed_count: integer := 0;
signal speed_max: integer := 0;


--Time 
signal time0 :std_logic_vector(3 downto 0) := "0000";
signal time1 :std_logic_vector(3 downto 0) := "0000";
signal time2 :std_logic_vector(3 downto 0) := "0111";


begin
--Initialize sysytem output

--Inform that game has started
	--Oxygen
	o2_output(0) <= switch(0);
	
	--Engine
	engine_output(0) <= switch(0);
	
	--Energy
	energy_output(0) <= switch(0);
	




--Clock Divider
Clock_divider: process(clk,clk_count,new_clk)
begin
	--1 sec
	if (rising_edge(clk)) then
		clk_count <= clk_count + 1;
		if (clk_count = 10000000-1) then
			new_clk <= not new_clk;
			clk_count <= 0;
		end if;
	end if;
	-- 1/4 sec
	if (rising_edge(clk)) then
		clk_count2 <= clk_count2 + 1;
		if (clk_count2 = 1000000 - 1) then
			new_clk2 <= not new_clk2;
			clk_count2 <= 0;
		end if;
	end if;
	
	-- 1/32 sec
	if (rising_edge(clk)) then
		clk_count3 <= clk_count3 + 1;
		if (clk_count3 = 31250 - 1) then
			seg_clk <= not seg_clk;
			clk_count3 <= 0;
		end if;
	end if;
	
	--SPEED
	if (rising_edge(clk)) then
		speed_count <= speed_count + 1;
		if speed_count >= speed_max then
			speed_clk <= not speed_clk;
			speed_count <= 0;
		end if;
	end if;
		
			
end process;

--7SEG
DISTANCE_DISPLAY: BCD_7SEG 
port map(
			B3 => distance(3),
			B2 => distance(2),
			B1 => distance(1),
			B0 => distance(0),
			LED_out(6) => a,
			LED_out(5) => b,
			LED_out(4) => c,
			LED_out(3) => d,
			LED_out(2) => e,
			LED_out(1) => f,
			LED_out(0) => g
			);



--State
State_select: process(clk,new_clk,state)
begin
	if (rising_edge(clk)) then
		case state is
		
		
		--Initial State
			when initial =>
			
			--7SEGMENT Setup
				common <= (others => '1');
				
				
			--CS
				--Setup Signal
				led_index <= 0;
				inst_led <= (others => '0');
				inst_top_led(7 downto 1) <= "ZZZZZZZ";
				
				--Operation
				if (rising_edge(new_clk)) then
					inst_top_led(0) <= not inst_top_led(0);
				end if;
				
				
			--NS
				--Start Game
				if (switch(0) = '1' and switch(7 downto 1) = "0000000") then
					state <= ship_off;
					
				--
				elsif (switch = "00000000") then
					state <= initial;
				end if;
				
				
				
		--Ship Off State
			when ship_off =>
			--CS
				--Setup Signal
				led_index <= 0;
				common_index <= 0;
				common <= (others => '1');
				inst_led <= (others => '0');
				inst_top_led(7 downto 1) <= "0000000";
				inst_top_led(0) <= '1';
				o2_output(2) <= '0';
				engine_output(2) <= '0';
				energy_output(2) <= '0';
				
				--Distance Setting
				distance0 <= "1000";
				distance1 <= "0010";
				distance2 <= "0101";
				distance3 <= "0111";
				
				--Time Setting
				time0 <= "0000";
				time1 <= "0011";
				time2 <= "0000";
				
			--NS
				--Stop Game
				if (switch = "00000000") then
					state <= initial;
					
				--Start Ship
				elsif (switch(1) = '1' ) then	
					state <= ready;
				end if;
				
				
				
		--Ready State
			when ready =>
			--CS
				--Decoration
					inst_led <= (others => '0');
					if (rising_edge(new_clk2)) then
						inst_top_led(led_index) <= '1';
						inst_led(led_index) <= '1';
						led_index <= led_index + 1;
						if (led_index = 7) then
							led_index <= 0;
						end if;
					end if;
					inst_top_led(7 downto 5) <= switch(7 downto 5);
					
					--7segment light loop
						distance <= segment_light;
						common(3 downto 1) <=  not switch(7 downto 5);
						common(0) <= '0';
						if(rising_edge(new_clk2)) then
							segment_light <= segment_light + 1;
							if segment_light = "1100" then
								segment_light <= "1010";
							end if;
						end if;
					
					
				
				--Setup System
					--Initialize System 
						--Oxygen
							o2_output(1) <= switch(7);
							
						--Engine
							engine_output(1) <= switch(5);
							
						--Energy
							energy_output(1) <= switch(6);
							
						--Start Travel
						if (switch(7 downto 5) = "111") then
								o2_output(2) <= button(0);
								engine_output(2) <= button(0);
								energy_output(2) <= button(0);
							end if;
							
							
					
					
					
				
							
				
			--NS
				--Stop Game
				if (switch = "00000000") then
					state <= initial;
					
				--Start Travel
				elsif (inst_top_led = "11111111" and button(0) = '1' and switch(7 downto 5) = "111") then
					state <= game;
					
				--Stop Ship
				elsif (switch(1) = '0') then
					state <= ship_off;
				end if;
			
			
			
		--Game State
			when game =>
				--CS				
				--7segment
					if (rising_edge(seg_clk)) then
					--select common
						case common_index is
							when 0 =>
								if(display_select = '0') then
									distance <= distance0;
								elsif(display_select = '1') then
									distance <= time0;
								end if;
								
								common(0) <= '0';
								common(1) <= '1';
								common(2) <= '1';
								common(3) <= '1';
							when 1 =>
								if(display_select = '0') then
									distance <= distance1;
								elsif(display_select = '1') then
									distance <= time1;
								end if;
								
								common(0) <= '1';
								common(1) <= '0';
								common(2) <= '1';
								common(3) <= '1';
							when 2 =>
								if(display_select = '0') then
									distance <= distance2;
								elsif(display_select = '1') then
									distance <= time2;
								end if;
								
								common(0) <= '1';
								common(1) <= '1';
								common(2) <= '0';
								common(3) <= '1';
							when 3 =>
								if(display_select = '0') then
									distance <= distance3;
								elsif(display_select = '1') then
									distance <= "0000";
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
					
				--Top LED Setup
				inst_top_led(7 downto 5) <= switch(7 downto 5);
				inst_led <= (others => '0');
				inst_top_led(1 downto 0) <= switch(1 downto 0);
				inst_top_led(4 downto 2) <= (others => 'Z');
					
				
				--Distance Subtraction
				if (rising_edge(speed_clk)) then
					distance0 <= distance0 - '1';
					if (distance0 = "0000") then
						distance0 <= "1001";
						distance1 <= distance1 - '1';
					end if;
					if (distance1 = "0000" and distance0 = "0000") then
						distance1 <= "1001";
						distance2 <= distance2 - '1';
					end if;
					if (distance2 = "0000" and distance1 = "0000" and distance0 = "0000") then
						distance2 <= "1001";
						distance3 <= distance3 - '1';
					end if;
					
					if distance0 = "1111" then
						distance0 <= "1001";
					end if;
					if distance1 = "1111" then
						distance1 <= "1001";
					end if;
					if distance2 = "1111" then
						distance2 <= "1001";
					end if;
					if distance3 = "1111" then
						distance3 <= "1001";
					end if;
				end if;
				
				
				---Acceralation
				case engine_output(7 downto 4) is 
					when "1000" =>
						speed_max <= 1000000;
					when "1100" =>
						speed_max <= 500000;
					when "1110" =>
						speed_max <= 333333;
					when "1111" =>
						speed_max <= 250000;
					when others => speed_max <= 10000000;
				end case;
				
				
				--- Time Left
				if(rising_edge(new_clk) and not(time0 = "0000" and time1 = "0000" and time2 = "0000")) then
					time0 <= time0 - '1';
					if(time0 = "0000") then
						time0 <= "1001";
						time1 <= time1 - '1';
					end if;
					if(time1 = "0000") then
						if not(time2 = "0000" ) then
							time1 <= "0101";
							time2 <= time2 - '1';
						end if;
					end if;
				end if;
						
				---Display Select
					display_select <= switch(2);		
				
				
			--System Control
				o2_output(1) <= switch(7);
				engine_output(1) <= switch(5);
				energy_output(1) <= switch(6);
				
				--Engine Part
					--engine_output(3) <= switch(4);
				
				--Test
					
			--NS
				--Stop Game
				if switch(0) = '0' and switch(1) = '0' then
					state <= initial;
				end if;
				
				--Emergency shutdown
				if (switch(1) = '0') then
					if (rising_edge(new_clk)) then
						inst_led <= not inst_led;
					end if;
					o2_output(1) <= '0';
					engine_output(1) <= '0';
					energy_output(1) <= '0';
				end if;

				
						
			when others => null;
			
		end case;
	end if;
end process;




					
top_led <= inst_top_led;
led <= inst_led;
buzzer <= inst_buzzer;

end Behavioral;

