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
            if (Client.CurrentGame == Enums.Game.ClashRoyale)
            {
                ErrorCode = Reader.ReadVInt();

                Reader.ReadScString();
                Reader.ReadScString();
                Reader.ReadScString();
                Reader.ReadScString();

                Reader.ReadVInt();
                Reader.ReadVInt();

                Reader.ReadScString();

                Reader.ReadVInt();

                Reader.ReadScString(); // https://game-assets.clashroyaleapp.com
                Reader.ReadScString(); // https://99faf1e355c749a9a049-2a63f4436c967aa7d355061bd0d924a1.ssl.cf1.rackcdn.com
                Reader.ReadScString();

                Fingerprint = Reader.ReadCompressedString();
            }
            else
            {
                ErrorCode = Reader.ReadInt();

                if (ErrorCode == 7)
                    Fingerprint = Client.CurrentGame == Enums.Game.HayDayPop
                        ? Reader.ReadCompressedString()
                        : Reader.ReadScString();
            }
        }

        public override void Process()
        {
            Console.WriteLine(Fingerprint);

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
                    Resources.GameStatusManager.SetStatus(Client.CurrentGame, (int)Enums.Status.Maintenance);
                    break;
                case 16: // only for HayDay Pop (11.09.2020)
                    Resources.GameVersionManager.VersionTooHigh(Client.CurrentGame);
                    break;
                default:
                    Logger.Log(
                        $"Unknown error code from {Client.CurrentGame}: {ErrorCode}, Version: {Resources.GameVersionManager.GetGameVersion(Client.CurrentGame)}",
                        Logger.ErrorLevel.Error);
                    Resources.GameStatusManager.SetStatus(Client.CurrentGame, (int) Enums.Status.Offline);
                    break;
            }
        }
    }
}