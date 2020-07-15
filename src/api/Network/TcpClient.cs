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
        public MultithreadEventLoopGroup Group { get; set; }
        public Bootstrap Bootstrap { get; set; }

        public async Task ConnectAsync(string host)
        {
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
                        pipeline.AddFirst("FrameDecoder", new LengthFieldBasedFrameDecoder(ushort.MaxValue, 2, 3, 2, 0));
                        pipeline.AddLast("PacketHandler", new PacketHandler());
                        pipeline.AddLast("PacketEncoder", new PacketEncoder());
                    }));

                var connectedChannel =
                    await Bootstrap.ConnectAsync(host, 9339);
                var endpoint = (IPEndPoint)connectedChannel.RemoteAddress;

                Logger.Log(
                    $"Connected to {endpoint.Address.MapToIPv4()}:{endpoint.Port}.");
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
