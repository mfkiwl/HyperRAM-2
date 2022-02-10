library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This reduces the data width of an Avalon Memory Map interface.

entity avm_decrease is
   generic (
      G_SLAVE_DATA_SIZE  : integer; -- Must be a multiple of G_MASTER_DATA_SIZE
      G_MASTER_DATA_SIZE : integer
   );
   port (
      clk_i                 : in  std_logic;
      rst_i                 : in  std_logic;

      -- Slave interface (input)
      s_avm_write_i         : in  std_logic;
      s_avm_read_i          : in  std_logic;
      s_avm_address_i       : in  std_logic_vector(31 downto 0);
      s_avm_writedata_i     : in  std_logic_vector(G_SLAVE_DATA_SIZE-1 downto 0);
      s_avm_byteenable_i    : in  std_logic_vector(G_SLAVE_DATA_SIZE/8-1 downto 0);
      s_avm_burstcount_i    : in  std_logic_vector(7 downto 0);
      s_avm_readdata_o      : out std_logic_vector(G_SLAVE_DATA_SIZE-1 downto 0);
      s_avm_readdatavalid_o : out std_logic;
      s_avm_waitrequest_o   : out std_logic;

      -- Master interface (output)
      m_avm_write_o         : out std_logic;
      m_avm_read_o          : out std_logic;
      m_avm_address_o       : out std_logic_vector(31 downto 0);
      m_avm_writedata_o     : out std_logic_vector(G_MASTER_DATA_SIZE-1 downto 0);
      m_avm_byteenable_o    : out std_logic_vector(G_MASTER_DATA_SIZE/8-1 downto 0);
      m_avm_burstcount_o    : out std_logic_vector(7 downto 0);
      m_avm_readdata_i      : in  std_logic_vector(G_MASTER_DATA_SIZE-1 downto 0);
      m_avm_readdatavalid_i : in  std_logic;
      m_avm_waitrequest_i   : in  std_logic
   );
end entity avm_decrease;

architecture synthesis of avm_decrease is

   constant C_RATIO        : integer := G_SLAVE_DATA_SIZE / G_MASTER_DATA_SIZE;
   constant C_ZERO_DATA    : std_logic_vector(G_MASTER_DATA_SIZE-1 downto 0)   := (others => '0');
   constant C_ZERO_BYTE_EN : std_logic_vector(G_MASTER_DATA_SIZE/8-1 downto 0) := (others => '0');

   signal s_avm_write      : std_logic;
   signal s_avm_read       : std_logic;
   signal s_avm_address    : std_logic_vector(31 downto 0);
   signal s_avm_writedata  : std_logic_vector(G_SLAVE_DATA_SIZE-1 downto 0);
   signal s_avm_byteenable : std_logic_vector(G_SLAVE_DATA_SIZE/8-1 downto 0);
   signal s_avm_burstcount : std_logic_vector(7 downto 0);

   type t_state is (IDLE_ST, BUSY_ST);
   signal state : t_state := IDLE_ST;

   signal s_pos : integer range 0 to C_RATIO-1;

begin

   assert C_RATIO > 1;
   assert G_SLAVE_DATA_SIZE = C_RATIO * G_MASTER_DATA_SIZE;

   p_fsm : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if m_avm_waitrequest_i = '0' then
            m_avm_write_o <= '0';
            m_avm_read_o  <= '0';
         end if;

         case state is
            when IDLE_ST =>
               if s_avm_write_i = '1' or s_avm_read_i = '1' then
                  assert s_avm_burstcount_i = X"01";   -- TBD
                  s_avm_write      <= s_avm_write_i;
                  s_avm_read       <= s_avm_read_i;
                  s_avm_address    <= s_avm_address_i;
                  s_avm_writedata  <= s_avm_writedata_i;
                  s_avm_byteenable <= s_avm_byteenable_i;
                  s_avm_burstcount <= std_logic_vector(to_unsigned(C_RATIO, 8));
                  s_pos            <= 0;
                  state            <= BUSY_ST;
               end if;

            when BUSY_ST =>
               if m_avm_waitrequest_i = '1' then
                  s_pos <= s_pos + 1;

                  if s_pos+2 = C_RATIO then
                     state <= IDLE_ST;
                  end if;
               end if;
         end case;

         if rst_i = '1' then
            m_avm_write_o <= '0';
            m_avm_read_o  <= '0';
            s_pos         <= 0;
            state         <= IDLE_ST;
         end if;

      end if;
   end process p_fsm;

   m_avm_write_o         <= s_avm_write;
   m_avm_read_o          <= s_avm_read;
   m_avm_address_o       <= s_avm_address;
   m_avm_writedata_o     <= s_avm_writedata(G_MASTER_DATA_SIZE*s_pos + G_MASTER_DATA_SIZE-1 downto G_MASTER_DATA_SIZE*s_pos);
   m_avm_byteenable_o    <= s_avm_byteenable(G_MASTER_DATA_SIZE/8*s_pos + G_MASTER_DATA_SIZE/8-1 downto G_MASTER_DATA_SIZE/8*s_pos);
   m_avm_burstcount_o    <= s_avm_burstcount;
   s_avm_readdata_o      <= m_avm_readdata_i;
   s_avm_readdatavalid_o <= m_avm_readdatavalid_i;
   s_avm_waitrequest_o   <= '1' when state = IDLE_ST else '0';

end architecture synthesis;
