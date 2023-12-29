library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_AD7476A is
  port
  (
    CLK     : in std_logic;
    RST     : in std_logic;
    SDATA   : in std_logic;
    CS      : out std_logic;
    SCLK    : out std_logic;
    DATA    : out std_logic_vector(11 downto 0);
    DATA_OK : out std_logic);
end cnt_AD7476A;

architecture RTL of cnt_AD7476A is

  signal count_1 : integer;
  --signal N: integer:=5e6;
  signal k      : integer := 800; --para sim
  signal Pres_K : std_logic;

  -------------------------------------------
  signal count_pre2 : integer;
  --signal N: integer:=5e6;
  signal N      : integer := 25; --para sim
  signal sclk_s : std_logic;
  signal fc     : std_logic;
  --------------------------------------------
  signal ce : std_logic;
  --------------------------------------------
  signal counter : unsigned(3 downto 0);
  --------------------------------------------
  signal sdata_reg : unsigned(11 downto 0);
  --------------------------------------------
  signal ce_fsm : std_logic;
  type state is (WAIT_TX, RD_DATA, LD_DATA);
  signal current_state, next_state : state;
begin

  ----------------------------------------------------------------
  --                       Prescaler 1                          --
  ----------------------------------------------------------------

  process (clk, rst)
  begin
    if rst = '1' then
      count_1 <= 0;
      Pres_K  <= '0';

    elsif rising_edge(clk) then
      if count_1 = K - 1 then
        count_1 <= 0;
        Pres_K  <= '1';
      else
        count_1 <= count_1 + 1;
        Pres_K  <= '0';
      end if;
    end if;
  end process;
  ----------------------------------------------------------------
  --                       Prescaler 2 CSEC                        --
  ----------------------------------------------------------------
  process (clk, rst)
  begin
    if rst = '1' then
      count_pre2 <= 0;
      fc      <= '0';
    elsif rising_edge(clk) then
      if count_pre2 = N - 1 then
        count_pre2 <= 0;
        --sclk_s  <= '1';
        fc <= '1';
      elsif count_pre2 = (N/2) - 1 then
        --sclk_s  <= '0';
        count_pre2 <= count_pre2 + 1;
        fc      <= '1';
      else
        count_pre2 <= count_pre2 + 1;
        fc      <= '0';
      end if;
    end if;
  end process;
  
   SCLK<=sclk_s;
  process (clk, rst)
  begin
    if rst = '1' then
     sclk_s <= '1';
    elsif rising_edge(clk) then
      if fc = '1' then
        sclk_s <= not sclk_s;
      end if;
    end if;

  end process;
  ----------------------------------------------------------------
  --                          CCOMB                              --
  ----------------------------------------------------------------
  
  process (all)
  begin
    if sclk_s = '0' and fc = '1' then
      ce <= '1';
    else
      ce <= '0';
    end if;
  end process;
  ----------------------------------------------------------------
  --                            CounterFSM                         --
  ----------------------------------------------------------------
  process (clk, rst)
  begin
    if rst = '1' then
      counter <= (others=>'1');
    elsif rising_edge(clk) then
      if ce = '1' and cs='0' then
        counter <= counter - 1;
       elsif cs='1' then
        counter <= (others=>'1');
        
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  --             Registro desplazamiento                         --
  ----------------------------------------------------------------
  process (clk, rst)
  begin
    if rst = '1' then
      sdata_reg <= ((others => '0'));
    elsif rising_edge(clk) then
      if ce = '1' then
        if to_integer(counter) < 13 and to_integer(counter) > 0 then
                    sdata_reg(to_integer(counter) - 1) <= sdata;
        end if;

      end if;
    end if;
  end process;
  ----------------------------------------------------------------
  --             Registro data                                  --
  ----------------------------------------------------------------

  process (clk, rst)
  begin
    if rst = '1'then
       DATA <= (others => '0');
    elsif rising_edge(clk) then
      if ce_fsm = '1' then
        DATA <= std_logic_vector(to_unsigned(to_integer(sdata_reg)*3300/4095,sdata_reg'length));
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  --                          FSM                               --
  ----------------------------------------------------------------
  process (clk, rst)
  begin
    if rst = '1' then
      current_state <= WAIT_TX;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  process (current_state,Pres_K,counter)
  begin
    next_state <= current_state;
    DATA_OK    <= '0';
    CS         <= '1';
    ce_fsm     <= '0';

    case current_state is
      when WAIT_TX =>
        if Pres_K = '1' then
          next_state <= RD_DATA;
        end if;
      when RD_DATA =>
        cs <= '0';
        if to_integer(counter) = 0   then
          next_state <= LD_data;
        end if;
      when LD_DATA =>
        next_state<=WAIT_TX;
        DATA_OK <= '1';
        ce_fsm  <= '1';
    end case;
  end process;
end RTL;