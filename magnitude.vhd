library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity magnitude is
    Port ( 
        clk           : in std_logic;
        x_in          : in std_logic_vector;
        y_in          : in std_logic_vector;
        x_out         : out std_logic_vector := (others => '0');
        y_out         : out std_logic_vector := (others => '0');
        magnitude_out : out std_logic_vector(11 downto 0) := (others => '0') -- Accurate to 5 bits or so
    );
end magnitude;

architecture Behavioral of magnitude is

    type a_x is array(0 to 5) of signed(x_in'high+1 downto 0);
    type a_y is array(0 to 5) of signed(y_in'high+1 downto 0);
    type a_x_delay is array(0 to 5) of std_logic_vector(x_in'high downto 0);
    type a_y_delay is array(0 to 5) of std_logic_vector(y_in'high downto 0);
    
    signal x : a_x := (others => (others => '0'));
    signal y : a_y := (others => (others => '0'));
    signal x_delay : a_x_delay := (others => (others => '0'));
    signal y_delay : a_y_delay := (others => (others => '0'));
    
begin

    magnitude_out <= std_logic_vector(y(5));
    x_out <= x_delay(x_delay'high);
    y_out <= y_delay(y_delay'high);

process(clk)
    begin
        if rising_edge(clk) then
            if x(4) >= 0 then
                -- x(5) is not needed
                y(5) <= y(4) + x(4)(x(4)'high downto 4);
            else
                -- x(5) is not needed
                y(5) <= y(4) - x(4)(x(4)'high downto 4);
            end if;
            
            if x(3) >= 0 then
                x(4) <= x(3) - y(3)(y(3)'high downto 3);
                y(4) <= y(3) + x(3)(x(3)'high downto 3);
            else
                x(4) <= x(3) + y(3)(y(3)'high downto 3);
                y(4) <= y(3) - x(3)(x(3)'high downto 3);
            end if;
            
            if x(2) >= 0 then
                x(3) <= x(2) - y(2)(y(2)'high downto 2);
                y(3) <= y(2) + x(2)(x(2)'high downto 2);
            else
                x(3) <= x(2) + y(2)(y(2)'high downto 2);
                y(3) <= y(2) - x(2)(x(2)'high downto 2);
            end if;
            
            if x(1) >= 0 then
                x(2) <= x(1) - y(1)(y(1)'high downto 1);
                y(2) <= y(1) + x(1)(x(1)'high downto 1);
            else
                x(2) <= x(1) + y(1)(y(1)'high downto 1);
                y(2) <= y(1) - x(1)(x(1)'high downto 1);
            end if;
            
            if x(0) >= 0 then
                x(1) <= x(0) - y(0)(y(0)'high downto 0);
                y(1) <= y(0) + x(0)(x(0)'high downto 0);
            else
                x(1) <= x(0) + y(0)(y(0)'high downto 0);
                y(1) <= y(0) - x(0)(x(0)'high downto 0);
            end if;
            
            if y_in(y_in'high) = '1' then
                x(0) <= signed(x_in(x_in'high) & x_in);
                y(0) <= signed(to_signed(0,y_in'length+1)-signed(y_in));
            else
                x(0) <= signed(x_in(x_in'high) & x_in);
                y(0) <= signed(y_in(y_in'high) & y_in);
            end if;
            
            -- Delay to output the inputs, so they are aligned with the magnitudes
            x_delay(1 to 5) <= x_delay(0 to 4);
            y_delay(1 to 5) <= y_delay(0 to 4);
            x_delay(0) <= x_in;
            y_delay(0) <= y_in;
        end if;
    end process;
 


end Behavioral;
