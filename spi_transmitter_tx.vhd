library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Генерує SCK, MOSI, SS. Передає 8-бітне слово у режимі MSB first.

entity spi_transmitter is
    Port (
        clk        : in  STD_LOGIC;                      -- Основний системний тактовий сигнал
        reset      : in  STD_LOGIC;                      -- Скидання
        start      : in  STD_LOGIC;                      -- Старт передачі
        data_in    : in  STD_LOGIC_VECTOR(7 downto 0);   -- Дані для передачі

        MOSI       : out STD_LOGIC;                      -- Лінія даних передавача
        SCK        : out STD_LOGIC;                      -- Генерований тактовий сигнал SPI
        SS         : out STD_LOGIC;                      -- Вибір приймача (Receiver Select)

        tx_done    : out STD_LOGIC                       -- Сигнал завершення передачі
    );
end spi_transmitter;

architecture Behavioral of spi_transmitter is

    type state_type is (IDLE, LOAD, SHIFT, DONE);
    signal state, next_state : state_type;


    -- Внутрішні сигнали:
    -- shift_reg - буфер даних для MOSI
    -- bit_count - позиція бітів (7...0)
    -- sck_reg - внутрішній регістр генерації такту

    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal bit_count : integer range 0 to 7 := 7;
    signal sck_reg   : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            sck_reg <= not sck_reg;
        end if;
    end process;

    SCK <= sck_reg;

    -- Реєстр станів (FSM)

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, start, bit_count)
    begin
        case state is

            when IDLE =>
                if start = '1' then
                    next_state <= LOAD;
                else
                    next_state <= IDLE;
                end if;

            when LOAD =>
                next_state <= SHIFT;

            when SHIFT =>
                if bit_count = 0 then
                    next_state <= DONE;
                else
                    next_state <= SHIFT;
                end if;

            when DONE =>
                next_state <= IDLE;

        end case;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            SS      <= '1';               -- Приймач не активний
            MOSI    <= '0';
            tx_done <= '0';
            bit_count <= 7;

        elsif rising_edge(clk) then
            case state is

                when IDLE =>
                    SS <= '1';
                    tx_done <= '0';

                when LOAD =>
                    SS <= '0';                -- Активуємо приймач
                    shift_reg <= data_in;     -- Завантажуємо байт
                    bit_count <= 7;

                when SHIFT =>
                    MOSI <= shift_reg(7);     -- Передаємо найстарший біт
                    shift_reg <= shift_reg(6 downto 0) & '0';

                    if sck_reg = '1' then
                        bit_count <= bit_count - 1;
                    end if;

                when DONE =>
                    SS <= '1';                -- Передача завершена
                    tx_done <= '1';

            end case;
        end if;
    end process;

end Behavioral;
