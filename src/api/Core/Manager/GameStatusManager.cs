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
        private readonly Dictionary<Enums.Game, TcpClient> _clientList = new Dictionary<Enums.Game, TcpClient>();
        private readonly Timer _refreshTimer = new Timer(Constants.StatusCheckInterval * 1000);
        public Dictionary<Enums.Game, GameStatus> StatusList = new Dictionary<Enums.Game, GameStatus>();

        /// <summary>
        ///     Initialize this instance
        /// </summary>
        public async void Initialize()
        {
            StatusList.Add(Enums.Game.ClashRoyale, await CreateGameStatus("Clash Royale"));
            StatusList.Add(Enums.Game.BrawlStars, await CreateGameStatus("Brawl Stars"));
            StatusList.Add(Enums.Game.HayDayPop, await CreateGameStatus("HayDay Pop"));

            foreach (var game in StatusList.Keys) _clientList.Add(game, new TcpClient());

            CheckGames(null, null);

            _refreshTimer.Elapsed += CheckGames;
            _refreshTimer.Start();

            Logger.Log("GameStatusManager started.");
        }

        public async Task<GameStatus> CreateGameStatus(string gameName)
        {
            var status = new GameStatus
            {
                GameName = gameName,
                LastUpdated = TimeUtils.CurrentUnixTimestamp
            };

            var fingerprint = await FingerprintDatabase.GetLatestFingerprint(gameName);

            if (fingerprint == null)
            {
                status.LatestFingerprintSha = "unknown";
                status.LatestFingerprintVersion = "unknown";
            }
            else
            {
                status.LatestFingerprintVersion = fingerprint.Version;
                status.LatestFingerprintSha = fingerprint.Sha;
            }

            return status;
        }

        /// <summary>
        ///     Connect to all games in the list to check their status
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="args"></param>
        public async void CheckGames(object sender, ElapsedEventArgs args)
        {
            foreach (var (game, client) in _clientList)
                await client.ConnectAsync(game);

            //await Task.Delay(1000);
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

                await FingerprintDatabase.SaveFingerprintLog(new FingerprintLog
                {
                    Sha = fingerprint.Sha,
                    Version = fingerprint.Version,
                    Timestamp = TimeUtils.CurrentUnixTimestamp
                }, status.GameName);
            }

            status.LastUpdated = TimeUtils.CurrentUnixTimestamp;

            if (status.Status == statusCode) return;

            // Never send a online status notification when the content has been updated
            if (status.Status != (int) Enums.Status.Content && statusCode == (int) Enums.Status.Online)
                Resources.Firebase.SendNotification("Status Update", $"{status.GameName}: {(Enums.Status) statusCode}");

            status.Status = statusCode;
            await StatusDatabase.SaveGameStatus(status);
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