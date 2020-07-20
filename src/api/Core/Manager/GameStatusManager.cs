using System;
using System.Collections.Generic;
using System.Threading.Tasks;
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
        public Dictionary<Enums.Game, GameStatus> StatusList = new Dictionary<Enums.Game, GameStatus>();
        private Dictionary<Enums.Game, TcpClient> ClientList = new Dictionary<Enums.Game, TcpClient>();

        public GameStatusManager()
        {
            StatusList.Add(Enums.Game.ClashRoyale, new GameStatus
            {
                GameName = "Clash Royale",
                LastUpdated = TimeUtils.CurrentUnixTimestamp,
                LatestFingerprintVersion = "3.2077.38",
                LatestFingerprintSha = "78e6afda61f125c90d7c311b9fe26f526388dd59"
            });

            StatusList.Add(Enums.Game.BrawlStars, new GameStatus
            {
                GameName = "Brawl Stars",
                LastUpdated = TimeUtils.CurrentUnixTimestamp,
                LatestFingerprintVersion = "28.187.1",
                LatestFingerprintSha = "c33a3b511b50de0292708b790e3890fc657724ea"
            });

            StatusList.Add(Enums.Game.HayDayPop, new GameStatus
            {
                GameName = "HayDay Pop",
                LastUpdated = TimeUtils.CurrentUnixTimestamp,
                LatestFingerprintVersion = "1.154.4",
                LatestFingerprintSha = "6a621ca47c6fd1ef30fba8a0d6cbcf5732e34e5d"
            });

            foreach (var game in StatusList.Keys)
            {
                ClientList.Add(game, new TcpClient());
            }

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
            foreach (var (game, client) in ClientList)
            {
                await client.ConnectAsync(game);

                //await Task.Delay(1000);
            }
        }

        /// <summary>
        ///     Updates the status of a game depending on the gameserver
        /// </summary>
        /// <param name="game"></param>
        /// <param name="statusCode"></param>
        /// <param name="fingerprint"></param>
        public async void SetStatus(Enums.Game game, int statusCode, Fingerprint fingerprint = null)
        {
            if (!StatusList.ContainsKey(game)) return;
            var status = StatusList[game];

            // Content update was the last status, before we set a new status we keep this for a given time
            if (status.Status == (int) Enums.Status.Content)
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

            // Content Update is new and fingerprint is given
            if (statusCode == (int) Enums.Status.Content && fingerprint != null)
            {
                if (status.LatestFingerprintSha == fingerprint.Sha)
                {
                    Logger.Log($"The new Fingerprint of {game} has the same sha!", Logger.ErrorLevel.Error);
                    return;
                }

                status.LatestFingerprintSha = fingerprint.Sha;
                status.LatestFingerprintVersion = fingerprint.Version;

                Logger.Log($"Fingerprint ({fingerprint.Sha}:{fingerprint.Version}) updated for {game}");
            }

            status.LastUpdated = TimeUtils.CurrentUnixTimestamp;

            if (status.Status == statusCode) return;

            status.Status = statusCode;
            await StatusDatabase.SaveGameStatus(status);

            Resources.Firebase.SendNotification("Status Update", $"{status.GameName}: {(Enums.Status) statusCode}");
        }

        /// <summary>
        ///     Returns the latest Fingerprint Hash for the game
        /// </summary>
        /// <param name="game"></param>
        /// <returns></returns>
        public string GetLatestFingerprintSha(Enums.Game game)
        {
            if (!StatusList.ContainsKey(game)) return "unknown";
            return StatusList[game].LatestFingerprintSha ?? "unknown";
        }
    }
}