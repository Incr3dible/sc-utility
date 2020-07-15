using System;
using System.Collections.Generic;

namespace SupercellUilityApi.Network.Protocol
{
    public class MessageFactory
    {
        public static Dictionary<int, Type> Messages;

        static MessageFactory()
        {
            Messages = new Dictionary<int, Type>
            {
                //{20100, typeof(ServerHelloMessage)},
            };
        }
    }
}
