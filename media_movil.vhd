library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


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

architecture rtl of media_movil is
type shift_reg is array(0 to 15) of unsigned(11 downto 0);
signal reg : shift_reg := (others => (others => '0'));
signal ac1: unsigned(11 downto 0);
signal ac2: unsigned(12 downto 0); -- 13 por overflow
signal ac3: unsigned(12 downto 0);

begin
  ----------------------------------------------------------------
  --               Registros de desplazamiento                  --
  ----------------------------------------------------------------
  process (clk,rst)
  begin
    if rst = '1' then
      reg <= (others => (others => '0'));
      ac3<=(others=>'0');
      V_MED<=(others=>'0');

    elsif rising_edge(clk) then
      if DATA_OK = '1' then
        reg(0) <= unsigned(data);
        for i in 0 to 14 loop
          reg(i + 1) <= reg(i);
        end loop;
      ac3<=ac2;    
      V_MED<=std_logic_vector(resize(ac3(12 downto 4),V_MED'length));
      end if;
     end if;
    end process;
    
    ac1<=unsigned(data)-reg(15);
    ac2<=ac1+ac3;
   
  
    process(clk,rst)
    begin
      if rst ='1'then 
        VM_OK<='0';
      elsif rising_edge(clk) then 
        VM_OK<=DATA_OK;
        end if;
    end process;
  end rtl;