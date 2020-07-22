using System;
using System.Collections.Generic;
using System.Timers;
using SupercellUilityApi.Database;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Core.Cache
{
    public class FingerprintCache
    {
        private readonly string[] _games = {"Clash Royale", "Brawl Stars", "HayDay Pop"};
        private readonly object _syncObject = new object();
        private readonly Timer _updateTimer = new Timer(TimeSpan.FromSeconds(10).TotalMilliseconds);

        public Dictionary<string, IEnumerable<FingerprintLog>>
            FingerprintLogs = new Dictionary<string, IEnumerable<FingerprintLog>>();

        public FingerprintCache()
        {
            Update(null, null);

            _updateTimer.Elapsed += Update;
            _updateTimer.Start();
        }

        private async void Update(object sender, ElapsedEventArgs args)
        {
            foreach (var game in _games)
            {
                var logs = await FingerprintDatabase.GetFingerprintLogs(game);
                UpdateLogs(logs, game);
            }
        }

        public void UpdateLogs(IEnumerable<FingerprintLog> logs, string gameName)
        {
            lock (_syncObject)
            {
                if (FingerprintLogs.ContainsKey(gameName)) FingerprintLogs[gameName] = logs;
                else FingerprintLogs.Add(gameName, logs);
            }
        }

        public IEnumerable<FingerprintLog> GetCachedFingerprintLogs(string gameName)
        {
            lock (_syncObject)
            {
                return FingerprintLogs.ContainsKey(gameName) ? FingerprintLogs[gameName] : new List<FingerprintLog>();
            }
        }
    }
}