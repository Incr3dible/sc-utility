using System;
using System.Diagnostics;
using DotNetty.Buffers;
using SupercellUilityApi.Network.Protocol;
using SupercellUilityApi.Network.Protocol.Messages.Client;

namespace SupercellUilityApi.Network
{
    public class Client
    {
        public async void Login(string fingerprintSha)
        {
            var majorVersion = 0;
            var minorVersion = 0;
            var buildVersion = 0;

            switch (CurrentGame)
            {
                // 3.2077.27
                case Game.ClashRoyale:
                    majorVersion = 3;
                    buildVersion = 2077;
                    break;

                // 13.369.7
                case Game.ClashofClans:
                    majorVersion = 13;
                    minorVersion = 0;
                    buildVersion = 369;
                    break;

                // 28.189.1
                case Game.BrawlStars:
                    majorVersion = 28;
                    buildVersion = 189;
                    break;
            }

            await new ClientHelloMessage(this)
            {
                MajorVersion = majorVersion,
                MinorVersion = minorVersion,
                BuildVersion = buildVersion,
                Sha = fingerprintSha
            }.SendAsync();
        }

        /// <summary>
        ///     Process a message
        /// </summary>
        /// <param name="buffer"></param>
        /// <returns></returns>
        public void Process(IByteBuffer buffer)
        {
            var id = buffer.ReadUnsignedShort();
            var length = buffer.ReadMedium();
            var version = buffer.ReadUnsignedShort();

            if (id < 20000 || id >= 30000) return;

            if (!MessageFactory.Messages.ContainsKey(id))
            {
                Logger.Log($"Message ID: {id}, V: {version}, L: {length} is not known.",
                    Logger.ErrorLevel.Warning);
                return;
            }

            if (!(Activator.CreateInstance(MessageFactory.Messages[id], this, buffer) is PiranhaMessage
                message)) return;

            try
            {
                message.Id = id;
                message.Length = length;
                message.Version = version;

#if DEBUG
                var st = new Stopwatch();
                st.Start();
#endif

                message.Decode();
                message.Process();

#if DEBUG
                st.Stop();
                Logger.Log($"Message {id}:{length} ({message.GetType().Name}) - ({st.ElapsedMilliseconds}ms)",
                    Logger.ErrorLevel.Debug);
#endif
            }
            catch (Exception exception)
            {
                Logger.Log($"Failed to process {id}, L: {length}: " + exception, Logger.ErrorLevel.Error);
            }
        }

        #region Objects

        public Game CurrentGame { get; set; }
        public TcpClient TcpClient { get; set; }

        public enum Game
        {
            ClashRoyale,
            ClashofClans,
            BrawlStars
        }

        #endregion Objects
    }
}