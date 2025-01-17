
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY std_counter IS
   GENERIC(RSTDEF: std_logic := '1';
           CNTLEN: natural   := 4);
   PORT(rst:   IN  std_logic;  -- reset,           RSTDEF active
        clk:   IN  std_logic;  -- clock,           rising edge
        en:    IN  std_logic;  -- enable,          high active
        inc:   IN  std_logic;  -- increment,       high active
        dec:   IN  std_logic;  -- decrement,       high active
        load:  IN  std_logic;  -- load value,      high active
        swrst: IN  std_logic;  -- software reset,  RSTDEF active
        cout:  OUT std_logic;  -- carry,           high active
        din:   IN  std_logic_vector(CNTLEN-1 DOWNTO 0);
        dout:  OUT std_logic_vector(CNTLEN-1 DOWNTO 0));
END std_counter;

--
-- Funktionstabelle
-- rst clk swrst en  load dec inc | Aktion
----------------------------------+-------------------------
--  V   -    -    -    -   -   -  | cnt := 000..0, asynchrones Reset
--  N   r    V    -    -   -   -  | cnt := 000..0, synchrones  Reset
--  N   r    N    0    -   -   -  | keine Aenderung
--  N   r    N    1    1   -   -  | cnt := din, paralleles Laden
--  N   r    N    1    0   1   -  | cnt := cnt - 1, dekrementieren
--  N   r    N    1    0   0   1  | cnt := cnt + 1, inkrementieren
--  N   r    N    1    0   0   0  | keine Aenderung
--
-- Legende:
-- V = valid, = RSTDEF
-- N = not valid, = NOT RSTDEF
-- r = rising egde
-- din = Dateneingang des Zaehlers
-- cnt = Wert des Zaehlers
--

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity std_counter implementiert werden
--
architecture struktur of std_counter is
    SIGNAL cnt: std_logic_vector(CNTLEN DOWNTO 0); -- carry + dout
    SIGNAL load_number: std_logic;
    SIGNAL inc_number: std_logic;
    SIGNAL dec_number: std_logic;
begin

cout <= cnt(CNTLEN);
dout <= cnt(CNTLEN-1 DOWNTO 0);

p1: process(clk, rst)
begin
    if rst = RSTDEF then
        cnt <= (OTHERS => '0');
        load_number <= '0';
        inc_number <= '0';
        dec_number <= '0';
    elsif rising_edge(clk) then
        if en = '1' then
            load_number <= load;
            inc_number <= inc;
            dec_number <= dec;
            if load_number = '1' then
                cnt <= '0' & din;
            elsif dec_number = '1' then
                cnt <= ('0' & cnt(CNTLEN-1 DOWNTO 0)) - 1;
            elsif inc_number = '1' then
                cnt <= ('0' & cnt(CNTLEN-1 DOWNTO 0)) + 1;
            end if;
        end if;

        if swrst = RSTDEF then
            cnt <= (OTHERS => '0');
            load_number <= '0';
            inc_number <= '0';
            dec_number <= '0';
        end if;
    end if;
end process;

end architecture;