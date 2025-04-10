
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_buffer IS
   GENERIC(RSTDEF:  std_logic := '1');
   PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
        clk:    IN  std_logic;  -- clock, rising edge
        en:     IN  std_logic;  -- enable, high active
        swrst:  IN  std_logic;  -- software reset, RSTDEF active
        din:    IN  std_logic;  -- data bit, input
        dout:   OUT std_logic;  -- data bit, output
        redge:  OUT std_logic;  -- rising  edge on din detected
        fedge:  OUT std_logic); -- falling edge on din detected
END sync_buffer;

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_buffer implementiert werden.
--

ARCHITECTURE struktur OF sync_buffer IS
    -- TYPE TState IS (S0, S1);

    SIGNAL dff1: std_logic;
    SIGNAL dff2: std_logic;

    SIGNAL state: std_logic;
    SIGNAL tdout: std_logic;
    CONSTANT N: natural := 15;
    SIGNAL cnt: integer RANGE 0 TO N;
BEGIN

dout <= tdout;
redge <= tdout AND (NOT state);
fedge <= (NOT tdout) AND state;

p1: process(clk, rst)
begin
    if rst = RSTDEF then
        dff1 <= '0';
        dff2 <= '0';
        tdout <= '0';
        state <= '0';
        cnt <= 0;
    elsif rising_edge(clk) then
        -- Sync
        dff1 <= din;
        dff2 <= dff1;

        -- Hysterese
        CASE state IS
            WHEN '0' =>
                IF dff2 = '0' THEN
                    IF cnt = 0 THEN
                        state <= '0';
                        -- cnt
                        tdout <= '0';
                    ELSE
                        state <= '0';
                        cnt <= cnt - 1;
                        tdout <= '0';
                    END IF;
                ELSE
                    IF cnt = N THEN
                        state <= '1';
                        -- cnt
                        tdout <= '0';
                    ELSE
                        state <= '0';
                        cnt <= cnt + 1;
                        tdout <= '0';
                    END IF;
                END IF;
                
            WHEN '1' =>
                IF dff2 = '1' THEN
                    IF cnt = N THEN
                        state <= '1';
                        
                        tdout <= '1';
                    ELSE
                        state <= '1';
                        cnt <= cnt + 1;
                        tdout <= '1';
                    END IF;
                ELSE
                    IF cnt = 0 THEN
                        state <= '0';
                        -- cnt
                        tdout <= '1';
                    ELSE
                        state <= '1';
                        cnt <= cnt - 1;
                        tdout <= '1';
                    END IF;
                END IF;
        END CASE;

        IF swrst = RSTDEF THEN
            dff1 <= '0';
            dff2 <= '0';
            tdout <= '0';
            state <= '0';
            cnt <= 0;
        END IF;

    end if;
end process p1;

END struktur;
