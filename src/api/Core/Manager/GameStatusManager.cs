using System;
using System.Collections.Generic;
using System.Timers;
using SupercellUilityApi.Database;
using SupercellUilityApi.Helpers;
using SupercellUilityApi.Models;
using SupercellUilityApi.Network;

namespace SupercellUilityApi.Core.Manager
{
    public class GameStatusManager
    {
        private readonly Timer _refreshTimer = new Timer(Constants.StatusCheckInterval * 1000);
        public Dictionary<Client.Game, GameStatus> StatusList = new Dictionary<Client.Game, GameStatus>();

        public GameStatusManager()
        {
            StatusList.Add(Client.Game.ClashRoyale, new GameStatus
            {
                GameName = "Clash Royale",
                LastUpdated = TimeUtils.CurrentUnixTimestamp,
                LatestFingerprintVersion = "3.2077.38",
                LatestFingerprintSha = "78e6afda61f125c90d7c311b9fe26f526388dd59"
            });

            StatusList.Add(Client.Game.BrawlStars, new GameStatus
            {
                GameName = "Brawl Stars",
                LastUpdated = TimeUtils.CurrentUnixTimestamp,
                LatestFingerprintVersion = "28.187.1",
                LatestFingerprintSha = "c33a3b511b50de0292708b790e3890fc657724ea"
            });

            CheckGames(null, null);

            _refreshTimer.Elapsed += CheckGames;
            _refreshTimer.Start();

            Logger.Log("GameStatusManager started.");
        }

        /// <summary>
        ///     Connect to all games in the list to check their status
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="args"></param>
        public async void CheckGames(object sender, ElapsedEventArgs args)
        {
            var games = new List<Client.Game> {Client.Game.BrawlStars, Client.Game.ClashRoyale};

            foreach (var game in games)
            {
                var tcpClient = new TcpClient();
                await tcpClient.ConnectAsync(game);
            }
        }

        /// <summary>
        ///     Updates the status of a game depending on the gameserver
        /// </summary>
        /// <param name="game"></param>
        /// <param name="statusCode"></param>
        /// <param name="fingerprint"></param>
        public async void SetStatus(Client.Game game, int statusCode, Fingerprint fingerprint = null)
        {
            // 0 = Online
            // 1 = Offline
            // 2 = Maintenance
            // 3 = Content Update

            if (!StatusList.ContainsKey(game)) return;
            var status = StatusList[game];
            var oldStatusCode = status.Status;

            if (status.Status == 3)
            {
                var current = TimeUtils.CurrentUnixTimestamp;
                var diff = Math.Abs(current - status.LastUpdated);

                if (diff < TimeSpan.FromHours(Constants.ContentUpdateTimeout).TotalMilliseconds)
                {
                    Logger.Log(
                        $"Content update is newer than {Constants.ContentUpdateTimeout} hours! Not updating status.",
                        Logger.ErrorLevel.Debug);
                    return;
                }
            }

            if (statusCode == 3)
                if (fingerprint != null)
                {
                    status.LatestFingerprintSha = fingerprint.Sha;
                    status.LatestFingerprintVersion = fingerprint.Version;

                    Logger.Log($"Fingerprint ({fingerprint.Sha}:{fingerprint.Version}) updated for {game}", Logger.ErrorLevel.Debug);
                }

            status.Status = statusCode;
            status.LastUpdated = TimeUtils.CurrentUnixTimestamp;

            if (oldStatusCode != statusCode)
            {
                await StatusDatabase.SaveGameStatus(status);
            }
        }

        /// <summary>
        ///     Returns the latest Fingerprint Hash for the game
        /// </summary>
        /// <param name="game"></param>
        /// <returns></returns>
        public string GetLatestFingerprintSha(Client.Game game)
        {
            if (!StatusList.ContainsKey(game)) return "unknown";
            return StatusList[game].LatestFingerprintSha ?? "unknown";
        }
    }
}