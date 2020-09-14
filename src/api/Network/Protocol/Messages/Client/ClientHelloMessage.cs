using SupercellUilityApi.Helpers;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Network.Protocol.Messages.Client
{
    public class ClientHelloMessage : PiranhaMessage
    {
        public ClientHelloMessage(Network.Client client) : base(client)
        {
            Id = 10100;
        }

        public string Sha { get; set; }
        public GameVersion GameVersion { get; set; }

        public override void Encode()
        {
            Writer.WriteInt(GameVersion.Protocol); // Protocol
            Writer.WriteInt(GameVersion.Key); // KeyVersion
            Writer.WriteInt(GameVersion.Major); // Major
            Writer.WriteInt(GameVersion.Minor); // Minor
            Writer.WriteInt(GameVersion.Build); // Build
            Writer.WriteScString(Sha); // SHA
            Writer.WriteInt(2); // Device
            Writer.WriteInt(2); // AppStore
        }
    }
}