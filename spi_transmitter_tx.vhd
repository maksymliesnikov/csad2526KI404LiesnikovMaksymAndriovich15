library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Генерує SCK, MOSI, SS. Передає 8-бітне слово у режимі MSB first.

entity spi_transmitter is
    Port (
        clk      : in  STD_LOGIC;                       -- системний такт (наприклад 100 МГц)
        reset    : in  STD_LOGIC;                       -- асинхронний скидання
        start    : in  STD_LOGIC;                       -- імпульс "почати передачу"
        data_in  : in  STD_LOGIC_VECTOR(7 downto 0);    -- байт для передачі

        MOSI     : out STD_LOGIC;                       -- дані до приймача
        SCK      : out STD_LOGIC;                       -- тактовий сигнал SPI
        SS       : out STD_LOGIC;                       -- вибір приймача (активний 0)
        tx_done  : out STD_LOGIC                        -- "передача завершена"
    );
end spi_transmitter;

architecture Behavioral of spi_transmitter is

    constant CLK_DIV : integer := 4;

    type state_type is (IDLE, SHIFT, DONE);
    signal state      : state_type := IDLE;

    -- Внутрішні сигнали:
    -- shift_reg - буфер даних для MOSI
    -- bit_count - позиція бітів (7...0)
    -- phase_cnt - внутрішній регістр генерації такту

    signal shift_reg  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal bit_count  : integer range 0 to 7 := 7;
    signal phase_cnt  : integer range 0 to CLK_DIV-1 := 0;  -- 0..3

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state     <= IDLE;
            SS        <= '1';
            SCK       <= '0';
            MOSI      <= '0';
            tx_done   <= '0';
            bit_count <= 7;
            phase_cnt <= 0;

        elsif rising_edge(clk) then
            case state is

                -- Стан IDLE: нічого не відбувається, чекаємо start = 1

                when IDLE =>
                    SS      <= '1';
                    SCK     <= '0';
                    MOSI    <= '0';
                    tx_done <= '0';
                    phase_cnt <= 0;

                    if start = '1' then
                        shift_reg <= data_in;    -- зберігаємо байт
                        bit_count <= 7;
                        SS        <= '0';        -- активуємо приймач
                        MOSI      <= data_in(7); -- одразу виставляємо перший біт
                        state     <= SHIFT;
                    end if;

                when SHIFT =>
                    case phase_cnt is

                        when 0 =>
                            -- Такт "підготовка": SCK низький, MOSI стабільний
                            SCK <= '0';
                            phase_cnt <= 1;

                        when 1 =>
                            -- Висхідний фронт: приймач зчитує MOSI
                            SCK <= '1';
                            phase_cnt <= 2;

                        when 2 =>
                            -- Утримуємо високий рівень SCK
                            SCK <= '1';
                            phase_cnt <= 3;

                        when others =>  -- 3
                            -- Повертаємо SCK у 0, готуємо наступний біт
                            SCK <= '0';
                            phase_cnt <= 0;

                            if bit_count = 0 then
                                -- Усі 8 біт передані
                                state <= DONE;
                            else
                                bit_count <= bit_count - 1;
                                -- Виставляємо наступний біт, поки SCK=0
                                MOSI <= shift_reg(bit_count - 1);
                            end if;

                    end case;

                -- Стан DONE: короткий імпульс завершення

                when DONE =>
                    SS      <= '1';
                    SCK     <= '0';
                    tx_done <= '1';
                    -- Повертаємось у IDLE, коли start відпущений
                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
