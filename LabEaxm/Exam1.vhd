----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:41:57 11/26/2020 
-- Design Name: 
-- Module Name:    Exam1 - Behavioral 
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

entity Exam1 is
port(
		clk: in std_logic;
		button: in std_logic;
		buz: out std_logic;
		output: out std_logic_vector(6 downto 0);
		common: out std_logic_vector(3 downto 0)
		);
end Exam1;

architecture Behavioral of Exam1 is

component BCD_7SEG is
port(
		B0,B1,B2,B3 : in STD_LOGIC;
		LED_out: out STD_LOGIC_vector(6 downto 0)
	);
end component;

signal clk_count: integer := 0;
signal new_clk: std_logic;
signal number0: std_logic_vector(3 downto 0) := "0000";
signal number1: std_logic_vector(3 downto 0) := "0000";
signal number: std_logic_vector(3 downto 0);
signal common_index: integer := 0;
signal seg_clk: std_logic;
signal seg_count: integer:= 0;
signal random_num: integer:= 0;
signal random_num2: integer :=0;
signal select_num: integer:= 0;
signal select_num2: integer :=0;


begin
display : BCD_7SEG
port map(
			B0 => number(0),
			B1 => number(1),
			B2 => number(2),
			B3 => number(3),
			LED_OUT => output
			);
			
clk_div: process(clk) 
begin 
	if(rising_edge(clk)) then
		clk_count <= clk_count + 1;
		seg_count <= seg_count + 1;
		
		if (clk_count = 10000000) then
			new_clk <= not new_clk;
			clk_count <= 0;
		end if;
		if (seg_count = 31250) then
			seg_clk <= not seg_clk;
			seg_count <= 0;
		end if;
	end if;
end process;
			
--count: process(new_clk) 
--begin
--		if(rising_edge(new_clk)) then
--			number <= number + '1';
--			if (number = "0101") then
--				number <= "0001";
--				buz <= '0';
--			elsif (number = "0100") then
--				buz <= '1';
--			else
--				buz <= '0';
--			end if;
--		end if;
--end process;

--7seg
select_com : process(seg_clk)
begin
		if (rising_edge(seg_clk)) then
			--select common
						case common_index is
							when 0 =>
								number  <= number0;
								common(0) <= '0';
								common(1) <= '1';
								common(2) <= '1';
								common(3) <= '1';
							when 1 =>
								number <= number1;
								common(0) <= '1';
								common(1) <= '0';
								common(2) <= '1';
								common(3) <= '1';
--							when 2 =>
--								distance <= distance2;
--								common(0) <= '1';
--								common(1) <= '1';
--								common(2) <= '0';
--								common(3) <= '1';
--							when 3 =>
--								distance <= distance3;
--								common(0) <= '1';
--								common(1) <= '1';
--								common(2) <= '1';
--								common(3) <= '0';
							when others => null;
						end case;
						common_index <= common_index + 1;
						if common_index = 1 then
							common_index <= 0;
						end if;
					end if;
end process;

random1 : process(clk)
begin 
	if(rising_edge(clk)) then
		random_num <= random_num + 1;
		if(button = '1') then
			select_num <= random_num;
		end if;
		
		if(random_num = 7) then
			random_num <= 0;
		end if;
		
		if(select_num = 0) then
			buz <= '1';
			number0 <= "0000";
		elsif(select_num = 1) then
			buz <= '0';
			number0 <= "0001";
		elsif(select_num = 2) then
			buz <= '1';
			number0 <= "0010";
		elsif(select_num = 3) then
			buz <= '0';
			number0 <= "0011";
		elsif(select_num = 4) then
			buz <= '1';
			number0 <= "0100";
		elsif(select_num = 5) then
			buz <= '0';
			number0 <= "0101";
		elsif(select_num = 6) then
			buz <= '1';
			number0 <= "0110";
		elsif(select_num = 7) then
			buz <= '0';
			number0 <= "0111";
		end if;
	end if;
end process;
		
		
random2 : process(clk)
begin 
	if(rising_edge(seg_clk)) then
		random_num2 <= random_num2 + 1;
		if(button = '1') then
			select_num2 <= random_num2;
		end if;
		
		if(random_num2 = 7) then
			random_num2 <= 0;
		end if;
		
		if(select_num2 = 0) then
			number1 <= "0000";
		elsif(select_num2 = 1) then
			number1 <= "0001";
		elsif(select_num2 = 2) then
			number1 <= "0010";
		elsif(select_num2 = 3) then
			number1 <= "0011";
		elsif(select_num2 = 4) then
			number1 <= "0100";
		elsif(select_num2 = 5) then
			number1 <= "0101";
		elsif(select_num2 = 6) then
			number1 <= "0110";
		elsif(select_num2 = 7) then
			number1 <= "0111";
		end if;
	end if;
end process;
		

			



end Behavioral;

