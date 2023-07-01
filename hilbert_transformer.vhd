library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hilbert_transformer is
    Port ( clk      : in  STD_LOGIC;
           real_in  : in  STD_LOGIC_VECTOR (9 downto 0);
           real_out : out  STD_LOGIC_VECTOR (10 downto 0) := (others => '0');
           imag_out : out  STD_LOGIC_VECTOR (10 downto 0) := (others => '0'));
end hilbert_transformer;

architecture Behavioral of hilbert_transformer is
   -- Constants are 2/(n * pi) * 512, for n of -7,-5,-3,-1,1,3,5,7
   constant kernel0  : signed(real_in'length-1 downto 0) := to_signed( -47, real_in'length);
   constant kernel2  : signed(real_in'length-1 downto 0) := to_signed( -66, real_in'length);
   constant kernel4  : signed(real_in'length-1 downto 0) := to_signed(-109, real_in'length);
   constant kernel6  : signed(real_in'length-1 downto 0) := to_signed(-326, real_in'length);
   constant kernel8  : signed(real_in'length-1 downto 0) := to_signed( 326, real_in'length);
   constant kernel10 : signed(real_in'length-1 downto 0) := to_signed( 109, real_in'length);
   constant kernel12 : signed(real_in'length-1 downto 0) := to_signed(  66, real_in'length);
   constant kernel14 : signed(real_in'length-1 downto 0) := to_signed(  47, real_in'length);

   type a_delay is array (0 to 14) of signed(real_in'high downto 0);

   signal delay : a_delay := (others => (others => '0'));
   signal tap0  : signed(real_in'length+kernel0'length-1  downto 0) := (others => '0');
   signal tap2  : signed(real_in'length+kernel2'length-1  downto 0) := (others => '0');
   signal tap4  : signed(real_in'length+kernel4'length-1  downto 0) := (others => '0');
   signal tap6  : signed(real_in'length+kernel6'length-1  downto 0) := (others => '0');
   signal tap8  : signed(real_in'length+kernel8'length-1  downto 0) := (others => '0');
   signal tap10 : signed(real_in'length+kernel10'length-1 downto 0) := (others => '0');
   signal tap12 : signed(real_in'length+kernel12'length-1 downto 0) := (others => '0');
   signal tap14 : signed(real_in'length+kernel14'length-1 downto 0) := (others => '0');
   
begin

process(clk) 
   variable imag_tmp : signed(real_in'length*2-1 downto 0);
   begin
      if   rising_edge(clk) then 
         
         real_out <= std_logic_vector(resize(delay(8),real_out'length));  -- deliberatly advanced by one due to latency
         
         imag_tmp := tap0 + tap2  + tap4  + tap6 
                   + tap8 + tap10 + tap12 + tap14;
         imag_out <= std_logic_vector(imag_tmp(imag_tmp'high downto imag_tmp'high-imag_out'high));
         
         tap0  <= delay(0)  * kernel0;
         tap2  <= delay(2)  * kernel2;
         tap4  <= delay(4)  * kernel4;
         tap6  <= delay(6)  * kernel6;
         tap8  <= delay(8)  * kernel8;
         tap10 <= delay(10) * kernel10;
         tap12 <= delay(12) * kernel12;
         tap14 <= delay(14) * kernel14;
         
         -- Update the delay line 
         delay(1 to 14) <= delay(0 to 13) ;
         delay(0)       <= signed(real_in);
      end if;
   end process;
end Behavioral;