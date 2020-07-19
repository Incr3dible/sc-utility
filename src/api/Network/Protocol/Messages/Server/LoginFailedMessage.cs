using System;
using System.Text.Json;
using DotNetty.Buffers;
using SupercellUilityApi.Helpers;
using SupercellUilityApi.Models;

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

            if (ErrorCode == 7) Fingerprint = Client.CurrentGame == Network.Client.Game.HayDayPop ? Reader.ReadCompressedString() : Reader.ReadScString();
        }

        public override void Process()
        {
            if (ErrorCode == 7)
            {
                Resources.GameStatusManager.SetStatus(Client.CurrentGame, 3,
                    JsonSerializer.Deserialize<Fingerprint>(Fingerprint));
            }
            else if (ErrorCode == 8)
            {
                Resources.GameVersionManager.VersionTooLow(Client.CurrentGame);
            }
            else if (ErrorCode == 9)
            {
                Resources.GameVersionManager.VersionTooHigh(Client.CurrentGame);
            }
            else if (ErrorCode == 10)
            {
                Resources.GameStatusManager.SetStatus(Client.CurrentGame, 2);
            }
            else
            {
                Console.WriteLine(ErrorCode);
                Resources.GameStatusManager.SetStatus(Client.CurrentGame, 1);
            }
        }
    }
}