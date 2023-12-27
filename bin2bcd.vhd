library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity bin2bcd is

  port
  (
    CLK    : in std_logic;
    RST    : in std_logic;
    VM_OK  : in std_logic;
    V_MED  : in std_logic_vector(11 downto 0);
    BCD_OK : out std_logic;
    BCD    : out std_logic_vector(15 downto 0));
end bin2bcd;
architecture rtl of bin2bcd is

  signal tc             : std_logic;
  signal tc_1           : std_logic;
  signal tc_rising_edge : std_logic;
  ------------------------------------------------------
  signal bit_counter : unsigned(11 downto 0);
  ------------------------------------------------------
  signal tmp_count : unsigned(15 downto 0);
  signal count     : std_logic_vector(15 downto 0);
begin
  ----------------------------------------------------------------
  --                    Detecci�n de flacos                     --
  ----------------------------------------------------------------

  process (clk)
  begin
    if rising_edge(clk) then
      tc_1           <= tc;
      tc_rising_edge <= '0';
      if tc = '1' and tc_1 = '0' then
        tc_rising_edge <= '1';
      end if;
    end if;
  end process;
  ----------------------------------------------------------------
  --                    Contador Binario                        --
  ----------------------------------------------------------------
  process (clk,rst)
  begin
    if rst = '1' then

      bit_counter <= (others => '0');
    elsif rising_edge(clk) then
      if VM_OK = '1' then
        bit_counter <= unsigned(V_MED);
        tc          <= '0';
      elsif unsigned(bit_counter) > 0 then
        bit_counter <= bit_counter - 1;
        if bit_counter = 1 then
          tc <= '1';
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  --                    Contador BCD                            --
  ----------------------------------------------------------------

  process (clk, rst)
  begin
      if rst = '1' then
      tmp_count <= (others => '0');
      
    elsif rising_edge(clk) then
      if VM_OK = '1' then                                 --Reinicia la cuenta
      tmp_count <= (others => '0');
      elsif tc = '1' then                                 --Almacenas el valor cuando no cuenta
        tmp_count<= tmp_count;
      elsif tmp_count(3 downto 0) = "1001" then
        tmp_count(3 downto 0) <= "0000";
        if tmp_count(7 downto 4) = "1001" then
          tmp_count(7 downto 4) <= "0000";
          if tmp_count(11 downto 8) = "1001" then
            tmp_count(11 downto 8) <= "0000";
            if tmp_count(15 downto 12) = "1001" then
              tmp_count(15 downto 12) <= "0000";
            else
              tmp_count(15 downto 12) <= tmp_count(15 downto 12) + 1;
            end if;
          else
            tmp_count(11 downto 8) <= tmp_count(11 downto 8) + 1;
          end if;
        else
          tmp_count(7 downto 4) <= tmp_count(7 downto 4) + 1;
        end if;
      else
        tmp_count(3 downto 0) <= tmp_count(3 downto 0) + 1;
      end if;
    end if;
  end process;

  count <= std_logic_vector(tmp_count);

  ----------------------------------------------------------------
  --                    Registros                               --
  ----------------------------------------------------------------
  process (clk, rst)
  begin
    if rst = '1' then
        BCD<=(others => '0');
        BCD_OK<='0';
    elsif rising_edge(clk) then
      if tc = '1' then
        BCD <= count;
        if tc_rising_edge = '1' then
          BCD_OK <= '1';
        else
          BCD_OK <= '0';
        end if;
      end if;
    end if;
  end process;
end rtl;