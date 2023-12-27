
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cnt_display is
  Port (
         CLK    : in  std_logic;
         RST    : in  std_logic;
         BCD    : in  std_logic_vector(15 downto 0);
         BCD_OK : in  std_logic;
         AND_70 : out std_logic_vector(7 downto 0);
         DP     : out std_logic;
         SEG_AG : out std_logic_vector(6 downto 0));
end cnt_display;

architecture rtl of cnt_display is
signal counter_reg: integer:=0;
--signal CLKDIV: integer:=5e6;
signal CLKDIV: integer:=25; --para sim
signal pre_out: std_logic:='0';
-------------------------------------------------
signal reg_1_out: std_logic_vector(15 downto 0);
-----------------------------------------------
signal bit_counter: unsigned(1 downto 0):="00";
-----------------------------------------------
signal mux_out:std_logic_vector(3 downto 0);
-----------------------------------------------
signal seg_ag_next:std_logic_vector(6 downto 0);
-----------------------------------------------
signal and_70_next:std_logic_vector(7 downto 0);
signal dp_next:std_logic:='0';
-----------------------------------------------

begin

 process (clk, rst)
  begin  -- process
    if rst = '1' then
      counter_reg   <= 0;
    elsif rising_edge(clk) then
      if counter_reg = CLKDIV-1 then
        counter_reg <= 0;
      else
        counter_reg <= counter_reg+1;
      end if;
    end if;
  end process;
  
  process (clk, rst)
  begin  -- process
    if rst = '1' then
      pre_out   <= '0';
    elsif clk'event and clk = '1' then
      if counter_reg = CLKDIV-1 then
        pre_out <= '1';
      else
        pre_out <= '0';
      end if;
    end if;
  end process;
  --------------------------------------
    -- REgistro 1
  ---------------------------------------  
  process(clk, rst)
  begin
   if rst = '1' then
      reg_1_out<=(others=>'0');
   elsif rising_edge(clk) then
      if BCD_OK = '1' then
        reg_1_out <= BCD;
      end if;
    end if;
  end process;
  --------------------------------------
    -- Contador
  --------------------------------------- 
  process(clk)
  begin
    if rising_edge(clk) then
        if pre_out='1' then
            bit_counter<=bit_counter+1;
        end if;
    end if;
  end process;
  
  --------------------------------------
    -- MUX4
  --------------------------------------- 
  process(all)
  begin
  
    case bit_counter is
    when "11" => mux_out<=reg_1_out(15 downto 12);
    when "10" => mux_out<=reg_1_out(11 downto 8);
    when "01" => mux_out<=reg_1_out(7 downto 4);
    when "00" => mux_out<=reg_1_out(3 downto 0);
    when others => mux_out<=(others=>'0');
    end case;
    
  end process;
  
   --------------------------------------
    -- BCD_TO_7_SEG
  --------------------------------------- 
  
  process(all)
 
  begin
 
    case mux_out is
        when x"0"=> seg_ag_next<= "1000000"; --0   
        when x"1"=> seg_ag_next<= "1111001"; --1
        when x"2"=> seg_ag_next<= "0100100"; --2
        when x"3"=> seg_ag_next<= "0110000"; --3
        when x"4"=> seg_ag_next<= "0011001"; --4
        when x"5"=> seg_ag_next<= "0010010"; --5
        when x"6"=> seg_ag_next<= "0000010"; --6
        when x"7"=> seg_ag_next<= "1111000"; --7
        when x"8"=> seg_ag_next<= "0000000"; --8
        when x"9"=> seg_ag_next<= "0011000"; --9
        when others=> seg_ag_next<= (others=>'0');
    end case;
    
  end process;
  --------------------------------------
    -- Selector de digito
  --------------------------------------- 
 process(clk)
 
 begin
 if rising_edge(clk) then 
 
  case bit_counter is
        when "00"=> and_70_next<= "00000001";
        when "01"=> and_70_next<= "00000010";
        when "10"=> and_70_next<= "00000100"; --2
        when "11"=> and_70_next<= "00001000"; --3
        when others=> and_70_next<= (others=>'0');
    end case;
    end if; 
   end process;
  --------------------------------------
  -- dp
  --------------------------------------- 
 
 
  dp_next<=bit_counter(1) nand bit_counter(0);
  

 process(clk)
 
 begin
 if rising_edge(clk) then
    seg_ag<=seg_ag_next;
    and_70<=and_70_next;
    dp<=dp_next;
 end if;
 end process;
  
end rtl;
