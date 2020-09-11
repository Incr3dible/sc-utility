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
                Key = 29
            });

            VersionList.Add(Enums.Game.BrawlStars, new GameVersion
            {
                Major = 29,
                Minor = 40,
                Build = 258,
                Key = 15
            });

            VersionList.Add(Enums.Game.HayDayPop, new GameVersion
            {
                Major = 1,
                Build = 298,
                Minor = 2,
                Key = 10
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

        public void VersionTooLow(Enums.Game game)
        {
            if (!VersionList.ContainsKey(game)) return;
            var version = VersionList[game];

            Logger.Log($"Incorrect version! The version for {game}:{version} is too low!",
                Logger.ErrorLevel.Warning);

            if (version.Minor < 50)
            {
                version.Minor++;
            }
            else if (version.Build < 999)
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

        public async void ReconnectForUpdate(Enums.Game game)
        {
            var client = Resources.GameStatusManager.GetClient(game);
            client.UpdatingVersion = true;

            await client.ConnectAsync(game);
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
            if (version.Build > 0)
            {
                version.Minor = 50;
                version.Build--;
            }
            else
            {
                version.Build = 999;
                version.Major--;
            }
        }

        public GameVersion GetGameVersion(Enums.Game game)
        {
            return !VersionList.ContainsKey(game) ? null : VersionList[game];
        }
    }
}