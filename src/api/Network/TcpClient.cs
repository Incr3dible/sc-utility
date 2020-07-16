using System;
using System.Net;
using System.Threading.Tasks;
using DotNetty.Codecs;
using DotNetty.Transport.Bootstrapping;
using DotNetty.Transport.Channels;
using DotNetty.Transport.Channels.Sockets;
using SupercellUilityApi.Network.Handlers;

namespace SupercellUilityApi.Network
{
    public class TcpClient
    {
        private MultithreadEventLoopGroup Group { get; set; }
        private Bootstrap Bootstrap { get; set; }
        private PacketHandler PacketHandler { get; set; }

        public IChannel ServerChannel { get; set; }
        public Client GameClient { get; set; }

        /// <summary>
        ///     Connect to a game and send ClientHello
        /// </summary>
        /// <param name="game"></param>
        /// <returns></returns>
        public async Task ConnectAsync(Client.Game game)
        {
            PacketHandler = new PacketHandler(this);
            GameClient = new Client {TcpClient = this};

            string host;

            switch (game)
            {
                case Client.Game.ClashofClans:
                    GameClient.CurrentGame = game;
                    host = "gamea.clashofclans.com";
                    break;
                case Client.Game.ClashRoyale:
                    GameClient.CurrentGame = Client.Game.ClashRoyale;
                    host = "game.clashroyaleapp.com";
                    break;
                case Client.Game.BrawlStars:
                    GameClient.CurrentGame = game;
                    host = "game.brawlstarsgame.com";
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(game), game, null);
            }

            try
            {
                Group = new MultithreadEventLoopGroup();

                Bootstrap = new Bootstrap();
                Bootstrap.Group(Group);
                Bootstrap.Channel<TcpSocketChannel>();

                Bootstrap
                    .Option(ChannelOption.TcpNodelay, true)
                    .Option(ChannelOption.SoKeepalive, true)
                    .Handler(new ActionChannelInitializer<IChannel>(channel =>
                    {
                        var pipeline = channel.Pipeline;
                        pipeline.AddFirst("FrameDecoder",
                            new LengthFieldBasedFrameDecoder(int.MaxValue, 2, 3, 2, 0));
                        pipeline.AddLast("PacketHandler", PacketHandler);
                        pipeline.AddLast("PacketEncoder", new PacketEncoder());
                    }));

                ServerChannel =
                    await Bootstrap.ConnectAsync(host, 9339);
                var endpoint = (IPEndPoint) ServerChannel.RemoteAddress;

                Logger.Log(
                    $"Connected to {endpoint.Address.MapToIPv4()}:{endpoint.Port}.", Logger.ErrorLevel.Debug);

                GameClient.Login(Resources.GameStatusManager.GetLatestFingerprintSha(game));
            }
            catch (Exception)
            {
                Logger.Log(
                    "Failed to connect.",
                    Logger.ErrorLevel.Warning);
            }
        }
    }
}