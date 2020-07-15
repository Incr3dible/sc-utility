using System;
using DotNetty.Buffers;

namespace SupercellUilityApi.Network.Protocol.Messages.Server
{
    public class ServerHelloMessage : PiranhaMessage
    {
        public ServerHelloMessage(Network.Client client, IByteBuffer reader) : base(client, reader)
        {
        }

        public override void Process()
        {
            Console.WriteLine("LOGIN");
        }
    }
}