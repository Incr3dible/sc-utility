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
            Group = new MultithreadEventLoopGroup();
        }

        private MultithreadEventLoopGroup Group { get; }
        private Bootstrap Bootstrap { get; set; }
        private PacketHandler PacketHandler { get; set; }

        public IChannel ServerChannel { get; set; }
        public Client GameClient { get; set; }
        public bool UpdatingVersion { get; set; }

        /// <summary>
        ///     Connect to a game and send ClientHello
        /// </summary>
        /// <param name="game"></param>
        /// <returns></returns>
        public async Task ConnectAsync(Enums.Game game)
        {
            PacketHandler = new PacketHandler(this);
            GameClient = new Client {TcpClient = this};

            string host;

            switch (game)
            {
                case Enums.Game.ClashofClans:
                    host = "gamea.clashofclans.com";
                    break;
                case Enums.Game.ClashRoyale:
                    host = "game.clashroyaleapp.com";
                    break;
                case Enums.Game.BrawlStars:
                    host = "game.brawlstarsgame.com";
                    break;
                case Enums.Game.HayDayPop:
                    host = "game.prod.haydaypop.com";
                    break;
                case Enums.Game.BoomBeach:
                    host = "game.boombeachgame.com";
                    break;
                case Enums.Game.HayDay:
                    host = "game.haydaygame.com";
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(game), game, null);
            }

            GameClient.CurrentGame = game;

            try
            {
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