----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2020 00:27:02
-- Design Name: 
-- Module Name: filtro_fir - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity multiplicador is
    generic (n : integer range 1 to 32:=12);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_mult : in STD_LOGIC;
           readymult  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (2*n downto 0));
end multiplicador;

architecture Behavioral of multiplicador is

--sinais dos registradores

signal sready:  STD_LOGIC := '0';
signal sstart_mult:  STD_LOGIC := '0';
signal sregmult:  STD_LOGIC_VECTOR(2*n - 1 downto 0) := (others => '0');
signal sregmulta:  STD_LOGIC_VECTOR(n-1 downto 0) := (others => '0');
signal sregmultb:  STD_LOGIC_VECTOR(n-1 downto 0) := (others => '0');



type state is (idle,saida); --possiveis estados
signal proximo_estado, estado_atual : state := idle;

begin

sstart_mult <= start_mult;

process (clk, reset,sstart_mult)

begin
       if reset = '1' then
        estado_atual <= idle;
       elsif rising_edge (clk) then
        estado_atual <= proximo_estado;
       end if;
end process;

--´processo de transição de estados
process (estado_atual, sstart_mult)
begin
    case estado_atual is
        when idle =>
            if sstart_mult = '1' then
                proximo_estado <= saida;
            else
                proximo_estado <= idle;
            end if;
           sready      <= '0'; 
        when saida =>  
          proximo_estado <= idle;
          sready       <= '1'; 
        when others =>
          sready       <= '0'; 
          proximo_estado <= idle;
    end case;
end process;


sregmulta <= a;
sregmultb <= b;

--registrador

process(clk,reset,sstart_mult)

begin

if reset = '1' then
    sregmult<= (OTHERS => '0');
elsif rising_edge(clk) then
    if sstart_mult = '1' then
    sregmult <= std_logic_vector(signed(sregmulta) * signed(sregmultb)) ;          
end if;
end if;

end process;

readymult <= sready;
result <= '0' &  sregmult;
end Behavioral;
