----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:58:02 12/09/2020 
-- Design Name: 
-- Module Name:    Engine - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Engine is
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
end Engine;

architecture Behavioral of Engine is
--Components
component BCD_7SEG is
port(
		B0,B1,B2,B3 : in STD_LOGIC;
		LED_out: out STD_LOGIC_vector(6 downto 0)
	);
end component;
--7SEGMENT
signal common_index: integer := 0;
--etc.
signal led_index: integer := 0;
signal segment_light_loop: integer := 0;
signal segment_light: std_logic_vector(3 downto 0) := "0000";
signal segment_clk: std_logic;

--Clock
signal clk_count1: integer := 0;
signal new_clk1: std_logic;
signal seg_clk_count: integer := 0;
signal seg_clk: std_logic;
signal speed_count: integer := 0;
signal speed_clk: std_logic;
signal speed_max: integer := 0;
signal clk_count2: integer := 0;
signal new_clk2: std_logic;


--State
signal state: std_logic_vector(3 downto 0) := "0000";
constant initial: std_logic_vector(3 downto 0) := "0000";
constant ready: std_logic_vector(3 downto 0) := "0010";
constant game: std_logic_vector(3 downto 0) := "0011";
constant engine_off: std_logic_vector(3 downto 0) := "0100";


--Output
signal inst_top_led: std_logic_vector(7 downto 0);
signal inst_led: std_logic_vector(7 downto 0);

--Speed
signal speed: std_logic_vector(3 downto 0) := "0000";
signal speed1: std_logic_vector(3 downto 0) := "0000";
signal speed2: std_logic_vector(3 downto 0) := "0000";
signal speed3: std_logic_vector(3 downto 0) := "0000";
signal speed_max2:std_logic_vector(3 downto 0) := "0000";
signal speed_max3:std_logic_vector(3 downto 0) := "0000";

begin

--Clock Divider
Clock_divider: process(clk)
begin
	--1 sec
	if (rising_edge(clk)) then
		--1 SEC
		clk_count1 <= clk_count1 + 1;
		if (clk_count1 = 10000000-1) then
			new_clk1 <= not new_clk1;
			clk_count1 <= 0;
		end if;
		
	--SEGMENT CLOCK
		seg_clk_count <= seg_clk_count + 1;
		if (seg_clk_count = 31250 - 1) then
			seg_clk <= not seg_clk;
			seg_clk_count <= 0;
		end if;
	
	--SPEED
		speed_count <= speed_count + 1;
		if speed_count >= speed_max then
			speed_clk <= not speed_clk;
			speed_count <= 0;
		end if;
		
	--1/4 SEC
		clk_count2 <= clk_count2 + 1;
		if (clk_count2 = 1000000-1) then
			new_clk2 <= not new_clk2;
			clk_count2 <= 0;
		end if;

		
	end if;
end process;

--7SEG
DISTANCE_DISPLAY: BCD_7SEG 
port map(
			B3 => speed(3),
			B2 => speed(2),
			B1 => speed(1),
			B0 => speed(0),
			LED_out(6) => a,
			LED_out(5) => b,
			LED_out(4) => c,
			LED_out(3) => d,
			LED_out(2) => e,
			LED_out(1) => f,
			LED_out(0) => g
			);

--STATE SELECTOR
State_select:process(clk,state)
begin
if(rising_edge(clk)) then
	case state is
	
		-- INITIAL
			when initial =>
			--CS
				
				--setup signal
					inst_led <= (others => '0');
					inst_top_led <= (others => 'Z');
					common <= (others => '1');
					led_index <= 0;
					speed_max2 <= "0000";
					segment_light <= "0000";
					common_index <= 0;
				
				--NS
					--Start Game
					if (hq_input(0) = '1' and hq_input(1) = '1') then
						state <= ready;
					end if;
			
			
		--READY STATE
			when ready =>
				--CS
				--7SEGMENT
					if(switch(0) = '1') then
						speed <= segment_light;
						segment_clk <= seg_clk;
						p<= '0';
					else
						segment_light <= "0000";
						speed <= "1111";
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
					inst_top_led(0) <= switch(0);
					inst_top_led(7 downto 1) <= (others => 'Z');

					if (rising_edge(new_clk2)) then
						inst_led(led_index) <= '1';
						led_index <= led_index + 1;
						if (led_index = 7) then
							led_index <= 0;
						end if;
					end if;
					
				--7SEGMENT LIGHT LOOP
					if(rising_edge(new_clk2) and switch(0) = '1') then
						segment_light <= segment_light + 1;
						if segment_light = "1100" then
							segment_light <= "1010";
						end if;
					end if;
					
						
					
			--NS
				--Start Travel
					if (hq_input(2) = '1') then
						state <= game; 
					end if;
				
				--Shutdown 
					if (hq_input(1) = '0') then 
						state <= initial;
					end if;
			
		--GAME STATE
			when game =>
			--CS
					p <= '0';
					--LED Setup
					inst_top_led(7) <= switch(7);
					inst_top_led(0) <= switch(0);
					inst_top_led(3 downto 1) <= (others => '0');
					if(hq_input(3) = '1') then
						inst_top_led(6 downto 4) <= (others => '1');
						inst_led(7 downto 4) <= switch(7 downto 4);
					else
						inst_top_led(6 downto 4) <= (others => '0');
						inst_led <= (others => '0');
					end if;
					
					
					--7SEGMENT
					if (rising_edge(seg_clk)) then
					--select common
					case common_index is
						when 0 =>
							speed <= speed1;
							common(0) <= '0';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '1';
						when 1 =>
							speed <= speed2;
							common(0) <= '1';
							common(1) <= '0';
							common(2) <= '1';
							common(3) <= '1';
						when 2 =>
							speed <= speed3;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '0';
							common(3) <= '1';

							
						when others => null;
					end case;
					common_index <= common_index + 1;
					if common_index = 2 then
						common_index <= 0;
					end if;
				end if;
				
			
				--System Operation
					--Send Speed
						hq_input(7) <= switch(7);
						if (hq_input(3) = '1') then
							hq_input(6 downto 4) <= switch(6 downto 4); 
						elsif (hq_input(3) = '0') then
							hq_input(6 downto 4) <= "000";
						end if;
					--Select Speed
						if(switch(7 downto 4) = "0000") then
							speed_max <= 2500000;
							speed_max2 <= "0000";
							speed_max3 <= "0000";
							
						elsif(switch(7 downto 4) = "1000" and hq_input(3) = '1') then
							speed_max <= 1000000;
							speed_max2 <= "0001";
							speed_max3 <= "0000";
							
						elsif(switch(7) = '1' and hq_input(3) = '0') then
							speed_max <= 1000000;
							speed_max2 <= "0001";
							speed_max3 <= "0000";
							
						elsif (switch(7 downto 4) = "1100" and hq_input(3) = '1') then
							speed_max <= 500000;
							speed_max2 <= "0010";
							speed_max3 <= "0000";

						elsif (switch(7 downto 4) = "1110" and hq_input(3) = '1') then
							speed_max <= 333333;
							speed_max2 <= "0011";
							speed_max3 <= "0000";

						elsif (switch(7 downto 4) = "1111" and hq_input(3) = '1') then
							speed_max <= 250000;
							speed_max2 <= "0100";
							speed_max3 <= "0000";

						else
							speed_max <= 100000;
							speed_max2 <= "0000";
							speed_max3 <= "0000";

						end if;
					
					--Accerelation 
						if (rising_edge(speed_clk)) then
							if (speed2 < speed_max2 or speed3 < speed_max3) then
								speed1 <= speed1 + '1';
								if (speed1 = "1001") then
									speed1 <= "0000";
									speed2 <= speed2 + '1';
								end if;
								if (speed2 = "1001") then
									speed2 <= "0000";
									speed3 <= speed3 + '1';
								end if;
							elsif (speed3 > speed_max3 or speed2 > speed_max2 or not(speed1 = "0000")) then
								speed1 <= speed1 - '1';
								if(speed1 = "0000" and not(speed2 = "0000")) then
									speed1 <= "1001";
									speed2 <= speed2 - '1';
								end if;
								if(speed2 = "0000" and not(speed3 = "0000")) then
									speed2 <= "1001";
									speed3 <= speed3 - '1';
								end if;
							end if;
							
							
						end if;
						
							
							
					
					
					
			--NS
				--Shutdown engine
				if (switch(0) = '0') then
					state <= engine_off;
					
				--Stop Game
				elsif (hq_input(0) = '0' and switch = "00000000") then
					state <= initial;
				
				--Emergency Shutdown
				elsif (hq_input(1) = '0') then
					state <= engine_off;
				end if;
				
		--ENGINE OFF STATE
			when engine_off =>
				--CS
					--Setup Signal
					common <= (others => '1');
					inst_led <= (others => '0');
					inst_top_led <= (others => 'Z');
					led_index <= 0;
					common_index <= 0;
					speed1 <= "0000";
					speed2 <= "0000";
					speed3 <= "0000";
					
					hq_input(7 downto 4) <= "0000";
					
					--LED Light Blink
					if (rising_edge(new_clk2)) then
							inst_top_led(led_index) <= '0';
							inst_led(led_index) <= '1';
							led_index <= led_index + 1;
							if (led_index = 7) then
								led_index <= 0;
							end if;
					end if;				
					
					
				--NS
					if (hq_input(0) = '1' and hq_input(1) = '1' and switch(0) = '1') then
						state <= game;
					elsif (hq_input(0) = '0' and hq_input(1) = '0') then
						state <= initial;
					end if;
					
		
		when others => null;
	end case;
end if;
end process;
					
					
--Initialize Output
top_led <= inst_top_led;
led <= inst_led;


end Behavioral;

