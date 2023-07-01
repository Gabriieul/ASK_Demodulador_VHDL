----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.10.2022 21:18:12
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
  Port ( 
            clk : in std_logic

);
end top;

architecture Behavioral of top is

component top_module is
    Port ( clk : in STD_LOGIC;
            resultado : out std_logic_vector (11 downto 0);
            x   : in std_logic_vector (11 downto 0);
            reset   : in std_logic;
            start   : in std_logic
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

COMPONENT ila_0

PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(11 DOWNTO 0)
);
END COMPONENT  ;

COMPONENT vio_0
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;


signal addr : std_logic_vector(9 downto 0) := (others => '0');
signal sx : std_logic_vector(11 downto 0) := (others => '0');
signal resultado : std_logic_vector(11 downto 0) := (others => '0');
signal sstart : std_logic := '0';
signal sready : std_logic := '0';
signal reset, start : std_logic := '0';

--signal proc_sig, ff1,ff2 : std_logic := '0';
--signal lock_proc : std_logic := '0';


begin

uut1: top_module port map (
         clk => clk,
         resultado => resultado,
         x => sx,
         reset => reset,
         start => start   
);

ut:  ROM
  PORT MAP (
    clka => clk,
    ena => '1',
    addra => addr,
    douta => sx
  );


uut2: ila_0
PORT MAP (
	clk => clk,
	probe0 => resultado
);


uut3 : vio_0 PORT MAP (
    clk => clk,
    probe_out0(0) => reset,
    probe_out1(0) => start
  );
  
  
    -- processo para alterar o endereco da rom
    addr_romx: process(reset, clk)
     variable cnt : integer range 0 to 1000;
    begin
        if reset = '1' then
            addr <= (others=>'0');
            sstart <= '0';
        elsif rising_edge(clk) then
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
