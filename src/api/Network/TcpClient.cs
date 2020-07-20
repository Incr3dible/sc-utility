using System;
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
        public TcpClient()
        {
            PacketHandler = new PacketHandler(this);
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
        }

        private MultithreadEventLoopGroup Group { get; }
        private Bootstrap Bootstrap { get; }
        private PacketHandler PacketHandler { get; }

        public IChannel ServerChannel { get; set; }
        public Client GameClient { get; set; }

        /// <summary>
        ///     Connect to a game and send ClientHello
        /// </summary>
        /// <param name="game"></param>
        /// <returns></returns>
        public async Task ConnectAsync(Enums.Game game)
        {
            GameClient = new Client {TcpClient = this};

            string host;

            switch (game)
            {
                case Enums.Game.ClashofClans:
                    GameClient.CurrentGame = game;
                    host = "gamea.clashofclans.com";
                    break;
                case Enums.Game.ClashRoyale:
                    GameClient.CurrentGame = Enums.Game.ClashRoyale;
                    host = "game.clashroyaleapp.com";
                    break;
                case Enums.Game.BrawlStars:
                    GameClient.CurrentGame = game;
                    host = "game.brawlstarsgame.com";
                    break;
                case Enums.Game.HayDayPop:
                    GameClient.CurrentGame = game;
                    host = "game.prod.haydaypop.com";
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(game), game, null);
            }

            try
            {
                ServerChannel =
                    await Bootstrap.ConnectAsync(host, 9339);
                /*var endpoint = (IPEndPoint) ServerChannel.RemoteAddress;

                Logger.Log(
                    $"Connected to {endpoint.Address.MapToIPv4()}:{endpoint.Port}.", Logger.ErrorLevel.Debug);*/

                GameClient.Login(Resources.GameStatusManager.GetLatestFingerprintSha(game));
            }
            catch (Exception exc)
            {
                Logger.Log(
                    $"Failed to connect ({game}): {exc}",
                    Logger.ErrorLevel.Warning);
            }
        }
    }
}