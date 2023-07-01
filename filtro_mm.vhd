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


entity filtro_mv is
    generic (tap : integer range 1 to 32:=32;
             n : integer range 1 to 32:=12);
             
    Port ( x : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC;
           --readyadd  : out STD_LOGIC;
           y : out STD_LOGIC_VECTOR (n-1 downto 0));
end filtro_mv;

architecture Behavioral of filtro_mv is

--array de registradores
type reg_data is array (0 to tap-1) of std_logic_vector(n-1 downto 0);
type reg_add is array (0 to tap/2 -1) of std_logic_vector(n-1 downto 0);
type reg_add1 is array (0 to tap/4 -1) of std_logic_vector(n-1 downto 0);
type reg_add2 is array (0 to tap/8 -1) of std_logic_vector(n-1 downto 0);

--sinais dos registradores
signal sreg_data : reg_data;
signal sreg_sum : reg_add;
signal sreg_sum1 : reg_add1;
signal sreg_sum2 : reg_add2;
signal start_shift:  STD_LOGIC := '0';
signal sclk:  STD_LOGIC := '0';
signal sreset:  STD_LOGIC := '0';
signal sready:  STD_LOGIC_VECTOR(tap - 1 downto 0) := (others => '0');
signal sreadyadd:  STD_LOGIC_VECTOR(tap/2 - 1 downto 0) := (others => '0');
signal sreadyadd1:  STD_LOGIC_VECTOR(tap/4 - 1 downto 0) := (others => '0');
signal sreadyadd2:  STD_LOGIC_VECTOR(tap/8 - 1 downto 0) := (others => '0');
signal sreg_div:  STD_LOGIC_VECTOR(n -1  downto 0) := (others => '0');
signal sreadydiv:  STD_LOGIC := '0';




--controle shift

component controle_mv is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end component;

--bloco somador


component somador_mv is
    generic (n : integer range 1 to 32:=12);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_add : in STD_LOGIC;
           readyadd  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (n-1 downto 0));
end component;



begin


sclk <= clk;
sreset <= reset;

uut: controle_mv port map(
           reset => sreset,
	       clk	 => sclk,
	       start => start,
	       ready => start_shift
	       );

--shift

process(sclk,sreset,start_shift)

begin

if sreset = '1' then
    sreg_data<= (OTHERS => (OTHERS => '0'));
    sready  <= (others => '0');
elsif rising_edge(sclk) then
for i in 0 to tap-1 loop
    if start_shift = '1' then
    sready(i) <= '1';
   if i = 0 then
     sreg_data(i) <= x;
   else 
    sreg_data(i) <= sreg_data(i-1);       
    end if;   

    else
        sready(i) <= '0';
end if;
end loop;
end if;

end process;

add : for i in 0 to (tap/2 - 1) generate

add0: somador_mv generic map (n => 12) port map(
           a => sreg_data(2*i),
           b => sreg_data(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sready(2*i),
	       readyadd => sreadyadd(i),
	       result => sreg_sum(i)
	       );
end generate add;

add1 : for i in 0 to (tap/4 - 1) generate

add: somador_mv generic map (n => 12) port map(
           a => sreg_sum(2*i),
           b => sreg_sum(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sreadyadd(2*i),
	       readyadd => sreadyadd1(i),
	       result => sreg_sum1(i)
	       );
end generate add1;

add2 : for i in 0 to (tap/8 - 1) generate

add: somador_mv generic map (n => 12) port map(
           a => sreg_sum1(2*i),
           b => sreg_sum1(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sreadyadd1(2*i),
	       readyadd => sreadyadd2(i),
	       result => sreg_sum2(i)
	       );
end generate add2;

process(sclk,sreset,sreadyadd2(tap/8 -1))

begin

if sreset = '1' then
    sreg_div<= (OTHERS => '0');
    sreadydiv <= '0';
elsif rising_edge(sclk) then
    if sreadyadd2(tap/8 -1) = '1' then
    sreadydiv <= '1';
     sreg_div <= "000" & sreg_sum2(tap/8 -1)((n-1) downto 3);
    else
        sreadydiv <= '0';
end if;
end if;

end process;


ready <= sreadydiv;
y <= sreg_div;

end Behavioral;
