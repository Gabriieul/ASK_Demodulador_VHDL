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


entity filtro_fir is
    generic (tap : integer range 1 to 32:=32;
             n : integer range 1 to 32:=12);
             
    Port ( x : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC;
           y : out STD_LOGIC_VECTOR (n - 1 downto 0));
end filtro_fir;

architecture Behavioral of filtro_fir is

--array de registradores
type reg_data is array (0 to tap-1) of std_logic_vector(n-1 downto 0);--12
type reg_mult is array (0 to tap-1) of std_logic_vector(2*n  downto 0);--25
type reg_add is array (0 to tap/2 -1) of std_logic_vector(2*n+1 downto 0);--26
type reg_add1 is array (0 to tap/4 -1) of std_logic_vector(2*n+2 downto 0);--27
type reg_add2 is array (0 to tap/8 -1) of std_logic_vector(2*n+3 downto 0);--28
type reg_add3 is array (0 to tap/16 -1) of std_logic_vector(2*n+4 downto 0);--29
type reg_add4 is array (0 to tap/32 -1) of std_logic_vector(2*n+4 downto 0);--29
type reg_h is array (0 to tap-1) of std_logic_vector(n-1 downto 0);--12

constant sconst_h : reg_h := ("000000000000","000000000000","000000000000","000000000000","000000000000",
"000000000000","111111111111","111111111111","000000000000","000000000010","000000000110","000000001100",
"000000010011","000000011001","000000011111","000000100010","000000100010","000000011111","000000011001",
"000000010011","000000001100","000000000110","000000000010","000000000000","111111111111","111111111111",
"000000000000","000000000000","000000000000","000000000000","000000000000","000000000000");



--sinais dos registradores
signal sreg_data : reg_data;
signal sreg_mult : reg_mult;
signal sreg_sum : reg_add;
signal sreg_sum1 : reg_add1;
signal sreg_sum2 : reg_add2;
signal sreg_sum3 : reg_add3;
signal sreg_sum4 : reg_add4;
signal start_shift:  STD_LOGIC := '0';
signal sclk:  STD_LOGIC := '0';
signal sreset:  STD_LOGIC := '0';
signal sready:  STD_LOGIC_VECTOR(tap - 1 downto 0) := (others => '0');
signal sreadymult:  STD_LOGIC_VECTOR(tap - 1 downto 0) := (others => '0');
signal sreadyadd:  STD_LOGIC_VECTOR(tap/2 - 1 downto 0) := (others => '0');
signal sreadyadd1:  STD_LOGIC_VECTOR(tap/4 - 1 downto 0) := (others => '0');
signal sreadyadd2:  STD_LOGIC_VECTOR(tap/8 - 1 downto 0) := (others => '0');
signal sreadyadd3:  STD_LOGIC_VECTOR(tap/16 - 1 downto 0) := (others => '0');
signal sreadyadd4:  STD_LOGIC_VECTOR(tap/32 - 1 downto 0) := (others => '0');
signal readyreseult:  STD_LOGIC := '0';

signal reg_aux:  STD_LOGIC_VECTOR(2*n-1 downto 0) := (others => '0');--24bits
signal start_delay:  STD_LOGIC := '0';
signal sstart:  STD_LOGIC := '0';

signal result : std_logic_vector(3*n -1 downto 0);--36bits
signal gain : std_logic_vector(n-1 downto 0);--12
signal saida : std_logic_vector(n-1 downto 0);--12


--controle shift

component controle_shift is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end component;

--bloco somador


component somador is
    generic (n : integer range 1 to 32:=25);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_add : in STD_LOGIC;
           readyadd  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (n downto 0));
end component;

component somador1 is
    generic (n : integer range 1 to 32:=26);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_add : in STD_LOGIC;
           readyadd  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (n downto 0));
end component;

component somador2 is
    generic (n : integer range 1 to 32:=27);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_add : in STD_LOGIC;
           readyadd  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (n downto 0));
end component;

component somador3 is
    generic (n : integer range 1 to 32:=28);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_add : in STD_LOGIC;
           readyadd  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (n downto 0));
end component;

component somador4 is
    generic (n : integer range 1 to 32:=29);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_add : in STD_LOGIC;
           readyadd  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (n-1 downto 0));
end component;

--bloco somador


component multiplicador is
    generic (n : integer range 1 to 32:=12);         
    Port ( a : in STD_LOGIC_VECTOR (n-1 downto 0);
           b : in STD_LOGIC_VECTOR (n-1 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_mult : in STD_LOGIC;
           readymult  : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (2*n downto 0));
end component;


begin

sclk <= clk;
sreset <= reset;

gain <="000100000000";

--gain <="000010000000";

uut: controle_shift port map(
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


mult: for i in 0 to (tap - 1) generate

mult_0 : if i = 0 generate

mult1: multiplicador generic map (n => 12) port map(
           a => sreg_data(i),
           b => sconst_h(i),
           reset => sreset,
	       clk	 => sclk,
	       start_mult => sready(1),
	       readymult => sreadymult(i),
	       result => sreg_mult(i)
	       );
end generate;

mult_1 : if i > 0 generate

multo: multiplicador generic map (n => 12) port map(
           a => sreg_data(i),
           b => sconst_h(i),
           reset => sreset,
	       clk	 => sclk,
	       start_mult => sready(1),
	       readymult => sreadymult(i),
	       result => sreg_mult(i)
	       );
end generate;

end generate mult;

add : for i in 0 to (tap/2 - 1) generate

add0: somador generic map (n => 25) port map(
           a => sreg_mult(2*i),
           b => sreg_mult(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sreadymult(2*i),
	       readyadd => sreadyadd(i),
	       result => sreg_sum(i)
	       );
end generate add;

add1 : for i in 0 to (tap/4 - 1) generate

add: somador1 generic map (n => 26) port map(
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

add: somador2 generic map (n => 27) port map(
           a => sreg_sum1(2*i),
           b => sreg_sum1(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sreadyadd1(2*i),
	       readyadd => sreadyadd2(i),
	       result => sreg_sum2(i)
	       );
end generate add2;

add3 : for i in 0 to (tap/16 - 1) generate

add: somador3 generic map (n => 28) port map(
           a => sreg_sum2(2*i),
           b => sreg_sum2(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sreadyadd2(2*i),
	       readyadd => sreadyadd3(i),
	       result => sreg_sum3(i)
	       );
end generate add3;

add4 : for i in 0 to (tap/32 - 1) generate

add: somador4 generic map (n => 29) port map(
           a => sreg_sum3(2*i),
           b => sreg_sum3(2*i+1),
           reset => sreset,
	       clk	 => sclk,
	       start_add => sreadyadd3(2*i),
	       readyadd => sreadyadd4(i),
	       result => sreg_sum4(i)
	       );
end generate add4;

reg_aux <= sreg_sum4(tap/32 -1)(2*n-1 downto 0);

ready <=  sreadyadd4(tap/32 -1);
result <= std_logic_vector(signed(gain) * signed(reg_aux));

saida <= result(27 downto 16);

y <= saida;

end Behavioral;
