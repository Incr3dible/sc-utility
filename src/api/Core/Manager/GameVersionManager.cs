using System.Collections.Generic;
using SupercellUilityApi.Models;
using SupercellUilityApi.Network;

namespace SupercellUilityApi.Core.Manager
{
    public class GameVersionManager
    {
        public Dictionary<Enums.Game, GameVersion> VersionList = new Dictionary<Enums.Game, GameVersion>();

        public GameVersionManager()
        {
            // 3.2414.1
            VersionList.Add(Enums.Game.ClashRoyale, new GameVersion
            {
                Major = 3,
                Minor = 0,
                Build = 2414,
                Key = 29,
                Protocol = 2
            });

            // 13.369.10
            VersionList.Add(Enums.Game.ClashofClans, new GameVersion
            {
                Major = 13,
                Minor = 10,
                Build = 369,
                Key = 92,
                Protocol = 3
            });

            VersionList.Add(Enums.Game.BrawlStars, new GameVersion
            {
                Major = 29,
                Minor = 40,
                Build = 258,
                Key = 15,
                Protocol = 2
            });

            VersionList.Add(Enums.Game.HayDayPop, new GameVersion
            {
                Major = 1,
                Build = 298,
                Minor = 2,
                Key = 10,
                Protocol = 2
            });

            VersionList.Add(Enums.Game.BoomBeach, new GameVersion
            {
                Major = 43,
                Minor = 1,
                Build = 63,
                Key = 18
            });

            VersionList.Add(Enums.Game.HayDay, new GameVersion
            {
                Major = 1,
                Minor = 97,
                Build = 47,
                Key = 7
            });
        }

        private const int MinorMax = 50;
        private const int BuildMax = 3000;

        public void VersionTooLow(Enums.Game game)
        {
            if (!VersionList.ContainsKey(game)) return;
            var version = VersionList[game];

            Logger.Log($"Incorrect version! The version for {game}:{version} is too low!",
                Logger.ErrorLevel.Warning);

            if (version.Minor < MinorMax)
            {
                version.Minor++;
            }
            else if (version.Build < BuildMax)
            {
                version.Minor = 0;
                version.Build++;
            }
            else
            {
                version.Build = 0;
                version.Major++;
            }

            ReconnectForUpdate(game);
        }

        public void VersionTooHigh(Enums.Game game)
        {
            if (!VersionList.ContainsKey(game)) return;
            var version = VersionList[game];

            Logger.Log($"Incorrect version! The version for {game}:{version} is too high!",
                Logger.ErrorLevel.Warning);

            if (version.Minor > 0)
            {
                version.Minor--;
            }
            else if (version.Build > 0)
            {
                version.Minor = MinorMax;
                version.Build--;
            }
            else
            {
                version.Build = BuildMax;
                version.Major--;
            }

            ReconnectForUpdate(game);
        }

        public async void ReconnectForUpdate(Enums.Game game)
        {
            var client = Resources.GameStatusManager.GetClient(game);
            client.UpdatingVersion = true;

            await client.ConnectAsync(game);
        }

        public GameVersion GetGameVersion(Enums.Game game)
        {
            return !VersionList.ContainsKey(game) ? null : VersionList[game];
        }
    }
}