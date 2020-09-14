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
            var version = Resources.GameVersionManager.GetGameVersion(CurrentGame);

            await new ClientHelloMessage(this)
            {
                GameVersion = version,
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
                Logger.Log($"[S] Message ID: {id}, V: {version}, L: {length} is not known.",
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
                Logger.Log($"[S] Message {id}:{length} ({message.GetType().Name}) from {CurrentGame} - ({st.ElapsedMilliseconds}ms)",
                    Logger.ErrorLevel.Debug);
#endif
            }
            catch (Exception exception)
            {
                Logger.Log($"Failed to process {id}, L: {length}: " + exception, Logger.ErrorLevel.Error);
            }
        }

        #region Objects

        public Enums.Game CurrentGame { get; set; }
        public TcpClient TcpClient { get; set; }

        #endregion Objects
    }
}