----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:07:40 11/13/2020 
-- Design Name: 
-- Module Name:    BCD_7SEG - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BCD_7SEG is
Port ( B0,B1,B2,B3 : in STD_LOGIC;
		 LED_out: out STD_LOGIC_vector(6 downto 0)
);

end BCD_7SEG;

architecture Behavioral of BCD_7SEG is
signal LED_BCD: std_logic_vector(3 downto 0);

begin

BCD_LED: process(LED_BCD)
begin
LED_BCD(0) <= B0;
LED_BCD(1) <= B1;
LED_BCD(2) <= B2;
LED_BCD(3) <= B3;


case LED_BCD is
    when "0000" => LED_out <= not "0000001"; -- "0"     
    when "0001" => LED_out <= not "1001111"; -- "1" 
    when "0010" => LED_out <= not "0010010"; -- "2" 
    when "0011" => LED_out <= not "0000110"; -- "3" 
    when "0100" => LED_out <= not "1001100"; -- "4" 
    when "0101" => LED_out <= not "0100100"; -- "5" 
    when "0110" => LED_out <= not "0100000"; -- "6" 
    when "0111" => LED_out <= not "0001111"; -- "7" 
    when "1000" => LED_out <= not "0000000"; -- "8"     
    when "1001" => LED_out <= not "0000100"; -- "9" 
    when "1010" => LED_out <= not "1101101"; -- a
    when "1011" => LED_out <= not "1011011"; -- b
    when "1100" => LED_out <= not "0110111"; -- C
    when "1101" => LED_out <= not "1000010"; -- d
    when "1110" => LED_out <= not "0110000"; -- E
    when "1111" => LED_out <= not "1111111"; -- F
	 when others => null;
	 
end case;
end process;


end Behavioral;

