
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_module IS
   GENERIC(RSTDEF: std_logic := '1');
   PORT(rst:   IN  std_logic;  -- reset, active RSTDEF
        clk:   IN  std_logic;  -- clock, risign edge
        swrst: IN  std_logic;  -- software reset, active RSTDEF
        BTN1:  IN  std_logic;  -- push button -> load
        BTN2:  IN  std_logic;  -- push button -> dec
        BTN3:  IN  std_logic;  -- push button -> inc
        load:  OUT std_logic;  -- load,      high active
        dec:   OUT std_logic;  -- decrement, high active
        inc:   OUT std_logic); -- increment, high active
END sync_module;

-- requires
-- - 3  sync buffers
-- - 1 freq splitter

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_module implementiert werden.
--
architecture struktur of sync_module is
    COMPONENT sync_buffer is
        GENERIC(RSTDEF: std_logic);
        PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
             clk:    IN  std_logic;  -- clock, rising edge
             en:     IN  std_logic;  -- enable, high active
             swrst:  IN  std_logic;  -- software reset, RSTDEF active
             din:    IN  std_logic;  -- data bit, input
             dout:   OUT std_logic;  -- data bit, output
             redge:  OUT std_logic;  -- rising  edge on din detected
             fedge:  OUT std_logic); -- falling edge on din detected
    END COMPONENT;

    SIGNAL reg: std_logic_vector(15 DOWNTO 0);
begin
    btn1_sync: sync_buffer
    GENERIC MAP (RSTDEF => RSTDEF)
    PORT MAP (
        rst    => rst,
        clk    => clk,
        en     => reg(15),
        swrst  => swrst,
        din    => BTN1,
        dout   => open,
        redge  => open,
        fedge  => inc
    );

    btn2_sync: sync_buffer
    GENERIC MAP (RSTDEF => RSTDEF)
    PORT MAP (
        rst    => rst,
        clk    => clk,
        en     => reg(15),
        swrst  => swrst,
        din    => BTN2,
        dout   => open,
        redge  => open,
        fedge  => dec
    );

    btn3_sync: sync_buffer
    GENERIC MAP (RSTDEF => RSTDEF)
    PORT MAP (
        rst    => rst,
        clk    => clk,
        en     => reg(15),
        swrst  => swrst,
        din    => BTN3,
        dout   => open,
        redge  => load,
        fedge  => open
    );

    p1: process(clk, rst)
    begin
        if rst = RSTDEF then
            reg <= (OTHERS => '0');
        elsif rising_edge(clk) then
            reg <= ('0' & reg(14 DOWNTO 0)) + 1;
            
            if swrst = RSTDEF then
                reg <= (OTHERS => '0');
            end if;
        end if;
    end process p1;

end struktur;