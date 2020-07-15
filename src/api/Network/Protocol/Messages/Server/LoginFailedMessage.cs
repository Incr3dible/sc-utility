using System;
using DotNetty.Buffers;
using SupercellUilityApi.Helpers;

namespace SupercellUilityApi.Network.Protocol.Messages.Server
{
    public class LoginFailedMessage : PiranhaMessage
    {
        public LoginFailedMessage(Network.Client client, IByteBuffer reader) : base(client, reader)
        {
        }

        public int ErrorCode { get; set; }
        public string Fingerprint { get; set; }

        public override void Decode()
        {
            ErrorCode = Client.CurrentGame == Network.Client.Game.ClashRoyale ? Reader.ReadVInt() : Reader.ReadInt();

            if (ErrorCode == 7)
                Fingerprint = Reader.ReadScString();
        }

        public override void Process()
        {
            Console.WriteLine(ErrorCode);
        }
    }
}