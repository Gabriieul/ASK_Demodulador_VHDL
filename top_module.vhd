----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.12.2020 12:58:27
-- Design Name: 
-- Module Name: topmodule - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


entity top_module is
    Port ( clk : in STD_LOGIC;
            resultado : out std_logic_vector (11 downto 0);
            x   : in std_logic_vector (11 downto 0);
            reset   : in std_logic;
            start   : in std_logic;
            ready   : out std_logic
    );
           --reset : in STD_LOGIC;
           --first_start : in STD_LOGIC);
end top_module;

architecture Behavioral of top_module is



component filtro_fir is
    generic (tap : integer range 1 to 32:=32;
             n : integer range 1 to 32:=12);
             
    Port ( x : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC;
            y : out STD_LOGIC_VECTOR (n-1 downto 0));
end component;

--component detector_3 is
--    Port ( 
--        clk           : in std_logic;
--        x_in          : in std_logic_vector(11 downto 0);
--        y_in          : in std_logic_vector(11 downto 0);
--        x_out         : out std_logic_vector (11 downto 0) := (others => '0');
--        y_out         : out std_logic_vector (11 downto 0) := (others => '0');
--        magnitude_out : out std_logic_vector (11 downto 0) := (others => '0') -- Accurate to 5 bits or so
--    );
--end component;

component detector_envelope IS
        Port (
            clk       : in std_logic;
            entrada   : in std_logic_vector(9 downto 0) := (others => '0');
            resultado_final : out std_logic_vector(11 downto 0)
        
);
END component;


component filtro_mv is
    generic (tap : integer range 1 to 32:=32;
             n : integer range 1 to 32:=12);
             
    Port ( x : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC;
           --readyadd  : out STD_LOGIC;
           y : out STD_LOGIC_VECTOR (n-1 downto 0));
end component;


signal addr : std_logic_vector(6 downto 0) := (others => '0');
signal sx : std_logic_vector(11 downto 0) := (others => '0');
signal ssaida : std_logic_vector(11 downto 0) := (others => '0');
signal saida : std_logic_vector(11 downto 0) := (others => '0');
signal sstart : std_logic := '0';
signal sready : std_logic := '0';
signal ssready : std_logic := '0';
--signal reset,first_start : std_logic := '0';


begin


uut1 : filtro_fir generic map (tap => 32 , n => 12) Port map ( 
                clk  => clk, 
                reset => reset,
                start  => start,
                ready => sready,
                x => x,
                y => saida
           );
      
uut2: filtro_MV generic map (tap => 32 , n => 12) Port map ( 
                clk  => clk, 
                reset => reset,
                start  =>start,
                ready => ssready,
                x => saida,
                y => ssaida
           );   
           

--uut3: detector_3 port map(
--                clk  => clk,
--                x_in => ssaida,
--                y_in => ssaida, 
--                magnitude_out => resultado

--);

uut3: detector_envelope port map(
                clk => clk,
                entrada => ssaida(11 downto 2),
                resultado_final => resultado
);

    

end Behavioral;

