----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.09.2022 19:44:33
-- Design Name: 
-- Module Name: dem_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ASK_TB is
--  Port ( );
end ASK_TB;

architecture Behavioral of ASK_TB is

component top_module is
  Port ( 
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
--        resultado       : out  std_logic_vector( 19 downto 0);
        x       : in  std_logic_vector( 11 downto 0)
);
end component;

COMPONENT ROM
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;


signal sclk : std_logic := '0';
signal sstart : std_logic := '0';
signal sreset : std_logic := '0';
signal addr : std_logic_vector(9 downto 0) := (others => '0');
signal sx : std_logic_vector(11 downto 0) := (others => '0');
signal ssaida : std_logic_vector(11 downto 0) := (others => '0');
signal sready : std_logic := '0';
signal reset, start : std_logic := '0';

--signal proc_sig, ff1,ff2 : std_logic := '0';
--signal lock_proc : std_logic := '0';

begin

utb: top_module Port map(
        clk => sclk,
        reset => sreset,
        start => sstart,
        x => sx
        );

uut : ROM PORT MAP (
    clka => sclk,
    ena => '1',
    addra => addr,
    douta => sx
  );

sclk <= not sclk after 5 ns;
start <= '1' after 10 ns;

  -- processo para alterar o endereco da rom
    addr_romx: process(sreset, sclk)
     variable cnt : integer range 0 to 1000;
    begin
        if sreset = '1' then
            addr <= (others=>'0');
            sstart <= '0';
        elsif rising_edge(sclk) then
            if start='1' or sready='1' then
                if cnt = 100 then
                cnt := 0;
                addr <= "0000000000";
                sstart <= '0';
                else
                addr <= std_logic_vector(unsigned(addr) + 1);
                cnt := cnt + 1;
                sstart <= '1';
            end if;                  
            end if;
        end if;        
    end process; 


end Behavioral;