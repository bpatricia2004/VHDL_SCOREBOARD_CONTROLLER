library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DeBouncer is
    port( Clock      : in std_logic;
          Reset      : in std_logic;
          button_in  : in std_logic;
          pulse_out  : out std_logic );
end DeBouncer;

architecture Behavioral of DeBouncer is

constant COUNT_MAX : integer := 10000000;  -- debounce delay (~100 ms at 100 MHz)
constant BTN_ACTIVE : std_logic := '1';

type states is (idle, wait_time);
signal state : states := idle;

signal count      : integer := 0;
signal pulse_reg  : std_logic := '0';

begin

process(Clock, Reset)
begin
    if Reset = '1' then
        state <= idle;
        count <= 0;
        pulse_reg <= '0';

    elsif rising_edge(Clock) then
        pulse_reg <= '0';  -- default: no pulse

        case state is
            when idle =>
                count <= 0;
                if button_in = BTN_ACTIVE then
                    state <= wait_time;
                end if;

            when wait_time =>
                if count < COUNT_MAX then
                    count <= count + 1;
                else
                    if button_in = BTN_ACTIVE then
                        pulse_reg <= '1';  -- one-cycle pulse
                    end if;
                    count <= 0;
                    state <= idle;
                end if;

        end case;
    end if;
end process;

pulse_out <= pulse_reg;

end Behavioral;
