using System;
using System.Collections.Generic;
using SupercellUilityApi.Network.Protocol.Messages.Server;

namespace SupercellUilityApi.Network.Protocol
{
    public class MessageFactory
    {
        public static Dictionary<int, Type> Messages;

        static MessageFactory()
        {
            Messages = new Dictionary<int, Type>
            {
                {20100, typeof(ServerHelloMessage)},
                {20103, typeof(LoginFailedMessage)}
            };
        }
    }
}
