using System;
using System.Net;
using DotNetty.Buffers;
using DotNetty.Handlers.Timeout;
using DotNetty.Transport.Channels;

namespace SupercellUilityApi.Network.Handlers
{
    public class PacketHandler : ChannelHandlerAdapter
    {
        public PacketHandler(TcpClient tcpClient)
        {
            TcpClient = tcpClient;
        }

        public TcpClient TcpClient { get; set; }
        public IChannel Channel { get; set; }

        public override void ChannelRead(IChannelHandlerContext context, object message)
        {
            var buffer = (IByteBuffer)message;
            if (buffer == null) return;

            TcpClient.GameClient.Process(buffer);
        }

        public override void ChannelRegistered(IChannelHandlerContext context)
        {
            Channel = context.Channel;
            TcpClient.GameClient.Handler = this;
        }

        public override void ChannelUnregistered(IChannelHandlerContext context)
        {
            var remoteAddress = (IPEndPoint)Channel.RemoteAddress;

            Logger.Log($"Disconnected from {remoteAddress.Address.MapToIPv4()}:{remoteAddress.Port}",
                Logger.ErrorLevel.Debug);

            base.ChannelUnregistered(context);
        }

        public override void ExceptionCaught(IChannelHandlerContext context, Exception exception)
        {
            if (exception.GetType() != typeof(ReadTimeoutException) &&
                exception.GetType() != typeof(WriteTimeoutException))
                Logger.Log(exception, Logger.ErrorLevel.Error);

            context.CloseAsync();
        }
    }
}
