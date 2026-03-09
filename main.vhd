library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scoreboard_Main is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp : out STD_LOGIC);
end Scoreboard_Main;

architecture Behavioral of Scoreboard_Main is

type states is(start,idle,countUpT1,countDwT1,countUpT2,countDwT2, updateDisplay,
                wait5sec, clearScore);

signal current_state,next_state: states;
signal score : STD_LOGIC_VECTOR (15 downto 0);
signal w5sec : std_logic;

component driver7seg is
    Port ( clk : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp_in : in STD_LOGIC_VECTOR (3 downto 0);
           dp_out : out STD_LOGIC;
           rst : in STD_LOGIC);
end component driver7seg;

component DeBouncer is
    port(   Clock : in std_logic;
            Reset : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
end component;

signal btn_db: std_logic_vector(3 downto 0);

begin

db3: DeBouncer port map(Clock=>clk,
                        Reset=>rst,
                        button_in=>btn(3),
                        pulse_out=>btn_db(3));
                        
db2: DeBouncer port map(Clock=>clk,
                         Reset=>rst,
                         button_in=>btn(2),
                         pulse_out=>btn_db(2));
db1: DeBouncer port map(Clock=>clk,
                        Reset=>rst,
                        button_in=>btn(1),
                        pulse_out=>btn_db(1));
db0: DeBouncer port map(Clock=>clk,
                         Reset=>rst,
                         button_in=>btn(0),
                         pulse_out=>btn_db(0));
                       
disp: driver7seg port map (clk => clk,
                           Din => score,
                           an => an,
                           seg => seg,
                           dp_in => "0000",
                           dp_out => dp,
                           rst => rst);

-- clear screen
process(clk, w5sec)
begin
  if w5sec = '1' then
    current_state <= idle;
  elsif rising_edge(clk) then
    current_state <= next_state;
  end if;    
end process;

-- reset de 3 sec cu wait
process (clk, rst)
    variable i : integer := 0;
begin
    if rising_edge(clk) then
        if rst = '1' then
            if i = 300000000 then
                i := 0;
                w5sec <= '1';
            else 
                i := i + 1;
                w5sec <= '0';
            end if;
        end if;
    end if;
end process;

-- button listener
process (current_state, btn_db)
begin
    case current_state is
        when start => next_state <= idle;
        when idle =>
            if btn_db(0) = '1' then
                next_state <= countUpT1;
            elsif btn_db(1) = '1' then
                next_state <= countDwT1;
            elsif btn_db(2) = '1' then
                next_state <= countUpT2;
            elsif btn_db(3) = '1' then
                next_state <= countDwT2;
            else 
                next_state <= idle;
            end if;
        when countUpT1 =>  next_state <= updateDisplay;
        when countDwT1 =>  next_state <= updateDisplay;
        when countUpT2 =>  next_state <= updateDisplay;
        when countDwT2 =>  next_state <= updateDisplay;
        when updateDisplay => next_state <= idle;
        when clearScore => next_state <= idle;
        when others => next_state <= start;
    end case;
end process;

-- display score
generate_scor: process (clk, w5sec)
    variable zeciT1, unitatiT1, zeciT2, unitatiT2: integer range 0 to 9 := 0;
begin
    if w5sec = '1' then
        zeciT1 := 0;
        unitatiT1 := 0;
        zeciT2 := 0;
        unitatiT2 := 0;
    elsif rising_edge(clk) then
        if current_state = countUpT1 then
            if unitatiT1 = 9 then
                unitatiT1 := 0;
                if zeciT1 = 9 then
                    zeciT1 := 0;
                else 
                    zeciT1 := zeciT1 + 1;
                end if;
            else
                unitatiT1 := unitatiT1 + 1;
            end if;
        elsif current_state = countUpT2 then
            if unitatiT2 = 9 then
                unitatiT2 := 0;
                if zeciT2 = 9 then
                    zeciT2 := 0;
                else 
                    zeciT2 := zeciT2 + 1;
                end if;
            else
                unitatiT2 := unitatiT2 + 1;
            end if;
        elsif current_state = countDwT1 then
            if unitatiT1 = 0 then
                unitatiT1 := 9;
                if zeciT1 = 0 then
                    zeciT1 := 9;
                else 
                    zeciT1 := zeciT1 - 1;
                end if;
            else
                unitatiT1 := unitatiT1 - 1;
            end if;
        elsif current_state = countDwT2 then
            if unitatiT2 = 0 then
                unitatiT2 := 9;
                if zeciT2 = 0 then
                    zeciT2 := 9;
                else 
                    zeciT2 := zeciT2 - 1;
                end if;
            else
                unitatiT2 := unitatiT2 - 1;
            end if;
        end if;

        score <= std_logic_vector(to_unsigned(zeciT1, 4)) &
                 std_logic_vector(to_unsigned(unitatiT1, 4)) &
                 std_logic_vector(to_unsigned(zeciT2, 4)) &
                 std_logic_vector(to_unsigned(unitatiT2, 4));
    end if;
end process;

end Behavioral;
