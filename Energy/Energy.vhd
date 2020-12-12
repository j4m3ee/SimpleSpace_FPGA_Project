----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:51:25 12/10/2020 
-- Design Name: 
-- Module Name:    Energy - Behavioral 
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

entity Energy is
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
end Energy;

architecture Behavioral of Energy is
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
signal new_clk3: std_logic;
signal clk_count3: integer := 0;
signal suf_clk_count: integer := 0;
signal suf_clk: std_logic;
signal clk_count4: integer := 0;
signal new_clk4: std_logic;


--State
signal state: std_logic_vector(3 downto 0) := "0000";
constant initial: std_logic_vector(3 downto 0) := "0000";
constant ready: std_logic_vector(3 downto 0) := "0010";
constant game: std_logic_vector(3 downto 0) := "0011";
constant generator_off: std_logic_vector(3 downto 0) := "0100";
constant shutdown: std_logic_vector(3 downto 0) := "0101";


--Output
signal inst_top_led: std_logic_vector(7 downto 0);
signal inst_led: std_logic_vector(7 downto 0);

--Energy
signal energy: std_logic_vector(3 downto 0) := "0000";
signal energy0: std_logic_vector(3 downto 0) := "0000";
signal energy1: std_logic_vector(3 downto 0) := "0000";
signal energy2: std_logic_vector(3 downto 0) := "0000";
signal energy3: std_logic_vector(3 downto 0) := "0001";

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
	
		
	--1/4 SEC
		clk_count2 <= clk_count2 + 1;
		if (clk_count2 = 1000000-1) then
			new_clk2 <= not new_clk2;
			clk_count2 <= 0;
		end if;
		
	--1/2 sec
		clk_count3 <= clk_count3 + 1;
		if (clk_count3 = 2000000-1) then
			new_clk3 <= not new_clk3;
			clk_count3 <= 0;
		end if;
		
	--millisec
	suf_clk_count <= suf_clk_count + 1;
		if (suf_clk_count = 100000 - 1) then
			suf_clk <= not suf_clk;
			suf_clk_count <= 0;
		end if;

	clk_count4 <= clk_count4 + 1;
	if (clk_count4 = 250000 - 1) then
		new_clk4 <= not new_clk4;
		clk_count4 <= 0;
	end if;
		
	end if;
end process;

--7SEG
DISTANCE_DISPLAY: BCD_7SEG 
port map(
			B3 => energy(3),
			B2 => energy(2),
			B1 => energy(1),
			B0 => energy(0),
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
					energy0 <= "0000";
					energy1 <= "0000";
					energy2 <= "0101";
					energy3 <= "0000";
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
					if(switch(0) = '1' and switch(7) = '1') then
						energy <= segment_light;
						segment_clk <= seg_clk;
						p <= '0';
					else
						segment_light <= "0000";
						energy <= "1111";
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
					inst_top_led(7) <= switch(7);
					inst_top_led(6 downto 1) <= (others => 'Z');

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
					
				--System 
					hq_input(7) <= switch(7);
						
					
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
					inst_top_led(7) <= switch(7);
					inst_top_led(1 downto 0) <= switch(1 downto 0);
					inst_top_led(6 downto 2) <= (others => '0');
					inst_led(7 downto 4) <= hq_input(6 downto 3);
					inst_led(3 downto 0) <= (others => '0');
				
				--7segment
					if (rising_edge(seg_clk)) then
					--select common
					case common_index is
						when 0 =>
							energy <= energy0;
							common(0) <= '0';
							common(1) <= '1';
							common(2) <= '1';
							common(3) <= '1';
						when 1 =>						
							energy <= energy1;
							common(0) <= '1';
							common(1) <= '0';
							common(2) <= '1';
							common(3) <= '1';
						when 2 =>
							energy <= energy2;
							common(0) <= '1';
							common(1) <= '1';
							common(2) <= '0';
							common(3) <= '1';
						when 3 =>
							energy <= energy3;
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
			
				case hq_input(6 downto 3) is
				
					when "1000" =>
							null;
						
					when "1100" =>
						if (rising_edge(new_clk1)) then
								energy0 <= energy0 + 1;
								if (energy0 = "1001") then
									energy0 <= "0000";
									energy1 <= energy1 + '1';
								end if;
								if (energy1 = "1001" and energy0 = "1001") then
									energy1 <= "0000";
									energy2 <= energy2 + '1';
								end if;
								if (energy2 = "1001" and energy1 = "1001" and energy0 = "1001") then
									energy2 <= "0000";
									energy3 <= energy3 + '1';
								end if;
							end if;
						
					when "1110" =>
						if (rising_edge(new_clk3)) then
								energy0 <= energy0 + 1;
								if (energy0 = "1001") then
									energy0 <= "0000";
									energy1 <= energy1 + '1';
								end if;
								if (energy1 = "1001" and energy0 = "1001") then
									energy1 <= "0000";
									energy2 <= energy2 + '1';
								end if;
								if (energy2 = "1001" and energy1 = "1001" and energy0 = "1001") then
									energy2 <= "0000";
									energy3 <= energy3 + '1';
								end if;
							end if;
							
					when "1111" =>
						if (rising_edge(new_clk2)) then
								energy0 <= energy0 + 1;
								if (energy0 = "1001") then
									energy0 <= "0000";
									energy1 <= energy1 + '1';
								end if;
								if (energy1 = "1001" and energy0 = "1001") then
									energy1 <= "0000";
									energy2 <= energy2 + '1';
								end if;
								if (energy2 = "1001" and energy1 = "1001" and energy0 = "1001") then
									energy2 <= "0000";
									energy3 <= energy3 + '1';
								end if;
							end if;
					
					when others =>
						--Energy Comsumtion
							if(switch(7 downto 6) = "10") then
								if (rising_edge(new_clk3)and not(energy0 = "0000" and energy1 = "0000" and energy2 = "0000" and energy3 = "0000")) then
									energy0 <= energy0 - 1;
									if (energy0 = "0000") then
										energy0 <= "1001";
										energy1 <= energy1 - '1';
									end if;
									if (energy1 = "0000" and energy0 = "0000") then
										energy1 <= "1001";
										energy2 <= energy2 - '1';
									end if;
									if (energy2 = "0000" and energy1 = "0000" and energy0 = "0000") then
										energy2 <= "1001";
										energy3 <= energy3 - '1';
									end if;
								end if;
								
							elsif(switch(7 downto 6) = "01") then
								if (rising_edge(new_clk3)and not(energy0 = "0000" and energy1 = "0000" and energy2 = "0000" and energy3 = "0000")) then
									energy0 <= energy0 - 1;
									if (energy0 = "0000") then
										energy0 <= "1001";
										energy1 <= energy1 - '1';
									end if;
									if (energy1 = "0000" and energy0 = "0000") then
										energy1 <= "1001";
										energy2 <= energy2 - '1';
									end if;
									if (energy2 = "0000" and energy1 = "0000" and energy0 = "0000") then
										energy2 <= "1001";
										energy3 <= energy3 - '1';
									end if;
								end if;
								
							elsif(switch(7 downto 6) = "11") then
								if (rising_edge(new_clk2)and not(energy0 = "0000" and energy1 = "0000" and energy2 = "0000" and energy3 = "0000")) then
									energy0 <= energy0 - 1;
									if (energy0 = "0000") then
										energy0 <= "1001";
										energy1 <= energy1 - '1';
									end if;
									if (energy1 = "0000" and energy0 = "0000") then
										energy1 <= "1001";
										energy2 <= energy2 - '1';
									end if;
									if (energy2 = "0000" and energy1 = "0000" and energy0 = "0000") then
										energy2 <= "1001";
										energy3 <= energy3 - '1';
									end if;
								end if;
							
							end if;
					
					end case;
				
					
				--System
					hq_input(7) <= switch(7);
				
				--NS
				if (switch(0) = '0') then
					state <= shutdown;
				elsif (hq_input(0) = '0' and switch = "00000000") then
					state <= initial;
				elsif (hq_input(1) = '0') then
					state <= shutdown;
				end if;
					
					
					
			--SHUTDOWN STATE
			when shutdown =>
			--CS
				--Setup Signal
				common <= (others => '1');
				inst_led <= (others => '0');
				inst_top_led <= (others => 'Z');
				led_index <= 0;
				common_index <= 0;
				
				--LED Light Blink
				if (rising_edge(new_clk2)) then
						inst_top_led(led_index) <= '0';
						inst_led(led_index) <= '1';
						led_index <= led_index + 1;
						if (led_index = 7) then
							led_index <= 0;
						end if;
				end if;
				
				--Energy Consumtion
				if (rising_edge(new_clk2)and not(energy0 = "0000" and energy1 = "0000" and energy2 = "0000" and energy3 = "0000")) then
					energy0 <= energy0 - 1;
					if (energy0 = "0000") then
						energy0 <= "1001";
						energy1 <= energy1 - '1';
					end if;
					if (energy1 = "0000" and energy0 = "0000") then
						energy1 <= "1001";
						energy2 <= energy2 - '1';
					end if;
					if (energy2 = "0000" and energy1 = "0000" and energy0 = "0000") then
						energy2 <= "1001";
						energy3 <= energy3 - '1';
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

top_led <= inst_top_led;
led <= inst_led;
	

end Behavioral;

