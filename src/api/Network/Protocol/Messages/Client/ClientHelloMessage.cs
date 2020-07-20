using SupercellUilityApi.Helpers;

namespace SupercellUilityApi.Network.Protocol.Messages.Client
{
    public class ClientHelloMessage : PiranhaMessage
    {
        public ClientHelloMessage(Network.Client client) : base(client)
        {
            Id = 10100;
        }

        public string Sha { get; set; }
        public int MajorVersion { get; set; }
        public int MinorVersion { get; set; }
        public int BuildVersion { get; set; }
        public int KeyVersion { get; set; }

        public override void Encode()
        {
            Writer.WriteInt(2); // Protocol
            Writer.WriteInt(KeyVersion); // KeyVersion
            Writer.WriteInt(MajorVersion); // Major
            Writer.WriteInt(MinorVersion); // Minor
            Writer.WriteInt(BuildVersion); // Build
            Writer.WriteScString(Sha); // SHA
            Writer.WriteInt(2); // Device
            Writer.WriteInt(2); // AppStore
        }
    }
}