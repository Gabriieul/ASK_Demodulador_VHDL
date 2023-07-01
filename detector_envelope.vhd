LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
ENTITY detector_envelope IS
        Port (
            clk       : in std_logic;
            entrada   : in std_logic_vector(9 downto 0) := (others => '0');
            resultado_final : out std_logic_vector(11 downto 0)
);
END detector_envelope;
 
ARCHITECTURE behavior OF detector_envelope IS 
 
 
    COMPONENT hilbert_transformer
    PORT(
         clk : IN  std_logic;
         real_in : IN  std_logic_vector(9 downto 0);
         real_out : OUT  std_logic_vector(10 downto 0);
         imag_out : OUT  std_logic_vector(10 downto 0)
        );
    END COMPONENT;

    COMPONENT magnitude is
        Port ( 
            clk           : in std_logic;
            x_in          : in std_logic_vector;
            y_in          : in std_logic_vector;
            x_out         : out std_logic_vector := (others => '0');
            y_out         : out std_logic_vector := (others => '0');
            magnitude_out : out std_logic_vector := (others => '0') -- Accurate to 5 bits or so
        );
    end COMPONENT;
        
--   signal clk           : std_logic := '0';
--   signal real_in       : std_logic_vector(11 downto 0) := (others => '0');
   signal real_out      : std_logic_vector(10 downto 0);
   signal imag_out      : std_logic_vector(10 downto 0);
   signal x_out         : std_logic_vector(10 downto 0);
   signal y_out         : std_logic_vector(10 downto 0);
   signal magnitude_out : std_logic_vector(10 downto 0);
--   constant clk_period : time := 10 ns;
 
BEGIN
 
   uut: hilbert_transformer PORT MAP (
          clk => clk,
          real_in => entrada,
          real_out => real_out,
          imag_out => imag_out
        );

uut2: magnitude 
        Port map( 
          clk => clk,
          y_in => real_out,
          x_in => imag_out,
          x_out => x_out,
          y_out => y_out,
          magnitude_out => resultado_final
        );



END;