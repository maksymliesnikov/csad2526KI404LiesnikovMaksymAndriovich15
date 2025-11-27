library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Приймач
-- Приймає 8 біт з лінії MISO на фронтах SCK. Активний, коли SS = '0'.

entity spi_receiver is
    Port (
        SCK      : in  STD_LOGIC;                       -- Тактовий сигнал від передавача
        SS       : in  STD_LOGIC;                       -- Receiver Select (0 = active)
        MISO     : in  STD_LOGIC;                       -- Вхідні дані від передавача
        data_out : out STD_LOGIC_VECTOR(7 downto 0);    -- Отриманий байт
        rx_ready : out STD_LOGIC                        -- Імпульс готовності
    );
end spi_receiver;

architecture Behavioral of spi_receiver is

    -- shift_reg - зсувний регістр для прийому
    -- bit_cnt - рахує біти (7...0)

    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal bit_cnt : integer range 0 to 7 := 7;

begin

    process(SCK, SS)
    begin
        if SS = '1' then
            -- Приймач вимкнений
            bit_cnt <= 7;
            rx_ready <= '0';

        elsif rising_edge(SCK) then
            -- Читаємо MISO на фронті SCK
            shift_reg(bit_cnt) <= MISO;

            if bit_cnt = 0 then
                rx_ready <= '1';     -- Прийнято весь байт
            else
                bit_cnt <= bit_cnt - 1;
                rx_ready <= '0';
            end if;
        end if;
    end process;

    data_out <= shift_reg;

end Behavioral;
