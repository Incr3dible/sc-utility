using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using DotNetty.Buffers;
using DotNetty.Handlers.Timeout;
using DotNetty.Transport.Channels;

namespace SupercellUilityApi.Network.Handlers
{
    public class PacketHandler : ChannelHandlerAdapter
    {
        public PacketHandler()
        {
            Client = new Client(this);
        }

        public Client Client { get; set; }
        public IChannel Channel { get; set; }

        public override void ChannelRead(IChannelHandlerContext context, object message)
        {
            var buffer = (IByteBuffer)message;
            if (buffer == null) return;

            Client.Process(buffer);
        }

        public override void ChannelRegistered(IChannelHandlerContext context)
        {
            Channel = context.Channel;

            var remoteAddress = (IPEndPoint)Channel.RemoteAddress;

            Logger.Log($"Client {remoteAddress.Address.MapToIPv4()}:{remoteAddress.Port} connected.",
                Logger.ErrorLevel.Debug);

            base.ChannelRegistered(context);
        }

        public override void ChannelUnregistered(IChannelHandlerContext context)
        {
            var remoteAddress = (IPEndPoint)Channel.RemoteAddress;

            Logger.Log($"Client {remoteAddress.Address.MapToIPv4()}:{remoteAddress.Port} disconnected.",
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
