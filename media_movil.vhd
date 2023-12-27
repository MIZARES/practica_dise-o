library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity media_movil is
  port
  (
    clk     : in std_logic;
    rst     : in std_logic;
    DATA_OK : in std_logic;
    DATA    : in std_logic_vector(11 downto 0);
    VM_OK   : out std_logic;
    V_MED   : out std_logic_vector(11 downto 0));
end media_movil;
type shift_reg is array(0 to 15) of unsigned(11 downto 0);
signal reg : shift_reg := (others => (others => '0'));
signal ac1 unsigned(11 downto 0);
signal ac2,ac3 unsigned(12 downto 0); -- 13 por overflow

architecture rtl of media_movil is
begin
  ----------------------------------------------------------------
  --               Registros de desplazamiento                  --
  ----------------------------------------------------------------
  process (clk,rst)
  begin
    if rst = '1' then
      reg <= (others => (others => '0'));
      ac1<=0; ac2<=0; ac3<=0;

    elsif rising_edge(clk)
    
      if DATA_OK = '1' then
        reg(0) <= data;
        for i in 0 to 14 loop
          reg(i + 1) <= reg(i)
        end loop;
      ac3<=ac2;    
  
      end if;

    end process;
    ac1<=ac1+data-reg(15);
    ac2<=ac1+ac3;

    process(clk,rst)
    begin
      if rst ='1'then 
        VM_OK<='0';
      elsif rising_edge(clk) then 
        VM_OK<=DATA_OK;
    end process;
  end rtl;