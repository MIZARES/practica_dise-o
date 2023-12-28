library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity AD7476A is

  port (
    VIN   : in  real range 0.0 to 3.3;
    CS    : in  std_logic;
    SCLK  : in  std_logic;
    SDATA : out std_logic);
end AD7476A;
architecture rtl of AD7476A is

  signal   dato   : std_logic_vector(15 downto 0) := (others => '0');
  signal   cuenta : natural;
  constant tSCLK  : time                          := 50 ns;
  constant t1, t2 : time                          := 10 ns;
  constant t3     : time                          := 20 ns;
  constant t4     : time                          := 40 ns;
  constant t5, t6 : time                          := 0.4*tSCLK;
  constant t7     : time                          := 7 ns;
  constant t8     : time                          := 25 ns;
  constant tQUIET : time                          := 50 ns;

begin
-------------------------------------------------------------------------------
  -- verificación de tiempos
  process (SCLK)
    variable aux1, aux2 : time;
  begin
    if SCLK'event and SCLK = '0' then
      if CS = '0' then
        assert not(CS'last_event <= t2)
          report "VIOLACIÓN DEL TIEMPO DE CS to SCLK Setup Time (t2)"
          severity note;
      end if;
    end if;
    if SCLK = '1' then
      aux2 := aux1;
      aux1 := now;
      assert not(aux1-aux2       <= t5)
        report "VIOLACIÓN DEL TIEMPO A NIVEL BAJO DE SCLK (t5)"
        severity note;
    else
      aux2 := aux1;
      aux1 := now;
      assert not(aux1-aux2       <= t6)
        report "VIOLACIÓN DEL TIEMPO A NIVEL ALTO DE SCLK (t6)"
        severity note;
    end if;
  end process;


  process (CS)
    variable aux6, aux7 : time;
  begin
    aux7 := aux6;
    aux6 := now;
    if CS'event and CS = '0' then
      assert not(aux6-aux7 <= t1)
        report "VIOLACIÓN DE LA DURACIÓN DEL TIEMPO DEL NIVEL ALTO DE CS (t1)"
        severity note;
    end if;
  end process;

  process (CS, SCLK )
    variable aux3, aux4, aux5 : time := now;
  begin
    if SCLK'event and SCLK = '0'and CS = '0' then
      aux3                           := now;
    end if;

    if CS = '1' then
      aux5 := aux3;
    end if;

    if CS = '0' then
      aux4 := now;
      assert not(aux4-aux5 <= tQUIET)
        report "VIOLACIÓN DE LA DURACIÓN DEL tQUIET"
        severity note;
    end if;

  end process;

  -----------------------------------------------------------------------------
  -- Modelado de funcionamiento.
  process ( CS)
    variable aux : std_logic_vector(11 downto 0) := (others => '0');
  begin
    if CS'event and CS = '0' then
      if VIN > 3.3 then
        aux                                      := (others => '1');
      elsif VIN < 0.0 then
        aux                                      := (others => '0');
      else
        aux                                      := std_logic_vector(to_unsigned(integer((4095.0*VIN)/3.3), 12));
      end if;
    end if;
    dato <= "0000"&aux;
  end process;


  process (SCLK, CS)
  begin
    if CS = '1' then
      cuenta <= 0;
    elsif SCLK'event and SCLK = '0' then
      cuenta <= cuenta+1;
    end if;
  end process;

  process (cuenta, CS)
  begin
    if CS = '0' then
      if cuenta = 0 then
        SDATA <= '0' after t3;
      elsif cuenta < 16 then
        SDATA <= '-' after t7, dato(15-cuenta)after t4;
      else
        SDATA <= 'Z'after t8;
      end if;
    else
      SDATA   <= 'Z';
    end if;
  end process;


end rtl;
