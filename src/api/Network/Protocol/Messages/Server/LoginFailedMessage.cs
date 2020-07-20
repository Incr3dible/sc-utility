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
            ErrorCode = Client.CurrentGame == Enums.Game.ClashRoyale ? Reader.ReadVInt() : Reader.ReadInt();

            if (ErrorCode == 7)
                Fingerprint = Client.CurrentGame == Enums.Game.HayDayPop
                    ? Reader.ReadCompressedString()
                    : Reader.ReadScString();
        }

        public override void Process()
        {
            switch (ErrorCode)
            {
                case 7:
                    Resources.GameStatusManager.SetStatus(Client.CurrentGame, (int) Enums.Status.Content,
                        JsonSerializer.Deserialize<Fingerprint>(Fingerprint));
                    break;
                case 8:
                    Resources.GameVersionManager.VersionTooLow(Client.CurrentGame);
                    break;
                case 9:
                    Resources.GameVersionManager.VersionTooHigh(Client.CurrentGame);
                    break;
                case 10:
                    Resources.GameStatusManager.SetStatus(Client.CurrentGame, (int) Enums.Status.Maintenance);
                    break;
                default:
                    Logger.Log($"Unknown error code from {Client.CurrentGame}: {ErrorCode}", Logger.ErrorLevel.Error);
                    Resources.GameStatusManager.SetStatus(Client.CurrentGame, (int) Enums.Status.Offline);
                    break;
            }
        }
    }
}