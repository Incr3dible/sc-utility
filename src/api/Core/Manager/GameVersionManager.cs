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
            VersionList.Add(Enums.Game.ClashRoyale, new GameVersion
            {
                Major = 3,
                Minor = 0,
                Build = 2077
            });

            VersionList.Add(Enums.Game.BrawlStars, new GameVersion
            {
                Major = 28,
                Minor = 0,
                Build = 189
            });

            VersionList.Add(Enums.Game.HayDayPop, new GameVersion
            {
                Major = 1,
                Build = 154
            });

            VersionList.Add(Enums.Game.ClashofClans, new GameVersion
            {
                Major = 13,
                Minor = 0,
                Build = 0
            });
        }

        public void VersionTooLow(Enums.Game game)
        {
            if (!VersionList.ContainsKey(game)) return;
            var version = VersionList[game];

            Logger.Log($"Incorrect version! The version for {game}:{version} is too low!",
                Logger.ErrorLevel.Warning);

            if (version.Build < 990)
            {
                version.Build += 10;
            }
            else
            {
                version.Build = 0;
                version.Major++;
            }
        }

        public void VersionTooHigh(Enums.Game game)
        {
            if (!VersionList.ContainsKey(game)) return;
            var version = VersionList[game];

            Logger.Log($"Incorrect version! The version for {game}:{version} is too high!",
                Logger.ErrorLevel.Warning);

            if (version.Build > 0)
            {
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