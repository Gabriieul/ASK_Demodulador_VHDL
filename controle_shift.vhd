----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2020 01:11:43
-- Design Name: 
-- Module Name: registrador - Behavioral
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



entity controle_shift is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end controle_shift ;

architecture Behavioral of controle_shift is

type state is (idle,shift,saida); --possiveis estados
signal proximo_estado, estado_atual : state := idle;


begin

process (clk, reset,start)

begin
       if reset = '1' then
        estado_atual <= idle;
       elsif rising_edge (clk) then
        estado_atual <= proximo_estado;
       end if;
end process;

--´processo de transição de estados
process (estado_atual, start)
begin
    case estado_atual is
        when idle =>
            if start = '1' then
                proximo_estado <= saida;
            else
                proximo_estado <= idle;
            end if;
           ready       <= '0'; 
--        when shift => 
--                proximo_estado <= saida;
--          ready       <= '0'; 
        when saida =>  
          proximo_estado <= idle;
          ready       <= '1'; 
        when others =>
          ready       <= '0'; 
          proximo_estado <= idle;
    end case;
end process;


end Behavioral;
