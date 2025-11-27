library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_spi is
end tb_spi;

architecture sim of tb_spi is

    signal clk       : STD_LOGIC := '0';                      -- системний такт для передавача
    signal reset     : STD_LOGIC := '0';                      -- сигнал скидання для обох модулів
    signal start     : STD_LOGIC := '0';                      -- імпульс запуску передачі
    signal data_in   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- байт, що передається

    -- Лінії SPI між передавачем та приймачем
    signal MOSI      : STD_LOGIC;                             -- дані від передавача до приймача
    signal SCK       : STD_LOGIC;                             -- тактовий сигнал SPI
    signal SS        : STD_LOGIC;                             -- вибір приймача (активний 0)

    -- Сигнали стану передавача та приймача
    signal tx_done   : STD_LOGIC;                             -- прапорець завершення передачі
    signal data_out  : STD_LOGIC_VECTOR(7 downto 0);          -- байт, прийнятий приймачем
    signal rx_ready  : STD_LOGIC;                             -- імпульс "дані прийнято"

begin

    -- Генератор системного такту clk

    clk_process : process
    begin
        clk <= '0'; 
        wait for 5 ns;
        clk <= '1'; 
        wait for 5 ns;
    end process;

    -- Інстанціювання передавача

    uut_tx : entity work.spi_transmitter
        port map (
            clk      => clk,
            reset    => reset,
            start    => start,
            data_in  => data_in,
            MOSI     => MOSI,
            SCK      => SCK,
            SS       => SS,
            tx_done  => tx_done
        );

    -- Інстанціювання приймача

    uut_rx : entity work.spi_receiver
        port map (
            SCK      => SCK,
            SS       => SS,
            MISO     => MOSI,
            data_out => data_out,
            rx_ready => rx_ready
        );

    stim_proc : process
    begin
        -- Початковий скидання системи

        reset <= '1';
        start <= '0';
        data_in <= (others => '0');
        wait for 30 ns;

        reset <= '0';
        wait for 50 ns;

        -- Перша передача: байт 10101010

        data_in <= "10101010";          -- встановлюємо дані
        start   <= '1';                 -- імпульс запуску
        wait for 10 ns;                 -- один період clk
        start   <= '0';
        wait for 500 ns;                -- час на завершення передачі

        -- Друга передача: байт 11001100

        data_in <= "11001100";
        start   <= '1';
        wait for 10 ns;
        start   <= '0';
        wait for 500 ns;

        wait;
    end process;

end sim;
