
   library IEEE;
   use     IEEE.std_logic_1164.all;
   use     IEEE.numeric_std.all;

----------------
entity CIPHER is
----------------
  port ( RESET : in  std_logic;                       -- Active high master reset
         CLOCK : in  std_logic;                       -- Master clock
         LOAD  : in  std_logic;                       -- Key load control
         KEY   : in  std_logic_vector (39 downto 0);  -- Key data
         READY : in  std_logic;                       -- Plaintext data ready
         DIN   : in  std_logic_vector  (7 downto 0);  -- Plaintext data input
         VALID : out std_logic;                       -- Ciphertext data valid
         DOUT  : out std_logic_vector  (7 downto 0)); -- Ciphertext data output
end CIPHER;

-----------------------------
architecture RTL of CIPHER is 
-----------------------------
  signal LFSR17 : std_logic_vector (17 downto 1);
  signal LFSR23 : std_logic_vector (23 downto 1);
begin 
  -------------------------
  process (RESET, CLOCK) is
  -------------------------
    variable TEMP17 : std_logic_vector (17 downto 1);
    variable TEMP23 : std_logic_vector (23 downto 1);
  begin
    if (RESET = '1') then
      LFSR17 <= (others => '0');
      LFSR23 <= (others => '0');
      VALID  <= '0';
      DOUT   <= (others => '0');
    elsif (CLOCK'event and CLOCK = '1') then
      if (LOAD = '1') then
        VALID  <= '0';                                      -- Set VALID to false
        LFSR17 <= KEY (39 downto 23);
        LFSR23 <= KEY (22 downto  0);
      elsif (READY = '1') then
        VALID  <= '1';                                      -- Set VALID to true
        DOUT <= DIN xor LFSR23 (8 downto 1) xor LFSR17 (8 downto 1);
        TEMP17 := LFSR17;                                   -- Save the current LFSR value
        TEMP23 := LFSR23;
        for I in 1 to 8 loop                                -- Shift the LFSR value 8 times
          TEMP17 := TEMP17 (16 downto 1) & (TEMP17 (17) xor TEMP17 (14));
          TEMP23 := TEMP23 (22 downto 1) & (TEMP23 (23) xor TEMP23 (18));
        end loop;
        LFSR17 <= TEMP17;                                   -- Transfer the new LFSR value back to LFSR17
        LFSR23 <= TEMP23;
      else
        VALID  <= '0';
      end if;
    end if;
    --···
  end process;
  
end architecture RTL;