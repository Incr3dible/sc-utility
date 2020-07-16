using System;
using System.Threading.Tasks;
using DotNetty.Buffers;

namespace SupercellUilityApi.Network.Protocol
{
    public class PiranhaMessage
    {
        public PiranhaMessage(Client client)
        {
            Client = client;
            Writer = Unpooled.Buffer();
        }

        public PiranhaMessage(Client client, IByteBuffer buffer)
        {
            Client = client;
            Reader = buffer;
        }

        public IByteBuffer Writer { get; set; }
        public IByteBuffer Reader { get; set; }
        public Client Client { get; set; }
        public ushort Id { get; set; }
        public int Length { get; set; }
        public ushort Version { get; set; }

        public virtual void Decode()
        {
        }

        public virtual void Encode()
        {
        }

        public virtual void Process()
        {
        }

        /// <summary>
        ///     Writes this message to the server channel
        /// </summary>
        /// <returns></returns>
        public async Task SendAsync()
        {
            try
            {
                await Client.TcpClient.ServerChannel.WriteAndFlushAsync(this);

                Logger.Log($"[C] Message {Id} ({GetType().Name}) sent.", Logger.ErrorLevel.Debug);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                Logger.Log($"Failed to send {Id}.",Logger.ErrorLevel.Debug);
            }
        }

        public override string ToString()
        {
            Reader.SetReaderIndex(7);
            return ByteBufferUtil.HexDump(Reader.ReadBytes(Length));
        }
    }
}
