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
  signal k      : integer := 25; --para sim
  signal Pres_K : std_logic;

  -------------------------------------------
  signal count_2 : integer;
  --signal N: integer:=5e6;
  signal N      : integer := 25; --para sim
  signal sclk_s : std_logic;
  --------------------------------------------
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
        Pres_K  <= '1';
      end if;
    end if;
  end process;
  ----------------------------------------------------------------
  --                       Prescaler 2                          --
  ----------------------------------------------------------------
  process (clk, rst)
  begin
    if rst = '1' then
      count_2 <= 0;
      sclk_s  <= '0';
    elsif rising_edge(clk) then
      if count_2 = N - 1 then
        count_2 <= 0;
        sclk_s  <= '0';
      elsif (N/2)-1 then
        sclk_s  <= '1';
        count_2 <= count_2 + 1;
      else
        count_2 <= count_2 + 1;
      end if;
    end if;
  end process;

----------------------------------------------------------------
--                          FSM                               --
----------------------------------------------------------------
process (clk, rst)
begin
if rst = '0' then
current_state <= WAIT_TX;
  elsif rising_edge(clk) then
  current_state <= next_state;
  end if;
end process;

process (all)--maquina FSM SIN TERMINAR
begin
next_state <= current_state;
DATA_OK    <= '0';
CS         <= '1';
ce_fsm<='0';

case current_state is
  when WAIT_TX =>
  if Pres_K='1'then
    next_state<=RD_DATA;
    CS<='0';
  end if;
    when RD_DATA =>
    cs<='0';
    if to_integer(counter)=14 then
      next_state<=LD_data;
    end if;
  when LD_DATA =>
    DATA_OK<='1';
    ce_fsm<='1';
    end case;
end process;