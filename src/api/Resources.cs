using System.Threading.Tasks;
using SupercellUilityApi.Network;

namespace SupercellUilityApi
{
    public static class Resources
    {
        public static TcpClient TcpClient { get; set; }

        public static async Task Initialize()
        {
            TcpClient = new TcpClient();

            await TcpClient.ConnectAsync(Client.Game.ClashofClans);
        }
    }
}
