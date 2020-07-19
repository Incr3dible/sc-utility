using System.Collections.Generic;
using SupercellUilityApi.Models;
using SupercellUilityApi.Network;

namespace SupercellUilityApi.Core.Manager
{
    public class GameVersionManager
    {
        public Dictionary<Client.Game, GameVersion> VersionList = new Dictionary<Client.Game, GameVersion>();

        public GameVersionManager()
        {
            VersionList.Add(Client.Game.ClashRoyale, new GameVersion
            {
                Major = 3,
                Minor = 0,
                Build = 2077
            });

            VersionList.Add(Client.Game.BrawlStars, new GameVersion
            {
                Major = 28,
                Minor = 0,
                Build = 189
            });

            VersionList.Add(Client.Game.HayDayPop, new GameVersion
            {
                Major = 1,
                Build = 154
            });

            VersionList.Add(Client.Game.ClashofClans, new GameVersion
            {
                Major = 13,
                Minor = 0,
                Build = 0
            });
        }

        public void VersionTooLow(Client.Game game)
        {
            if (!VersionList.ContainsKey(game)) return;
            var version = VersionList[game];

            Logger.Log($"Incorrect version! The version for {game}:{version} is too low!",
                Logger.ErrorLevel.Warning);

            if (version.Build < 990)
            {
                version.Build += 10;
            }
            /*else if (version.Build > 990)
            {
                version.Build = 0;
                version.Minor++;
            }*/
            else
            {
                //version.Minor = 0;
                version.Build = 0;
                version.Major++;
            }
        }

        public void VersionTooHigh(Client.Game game)
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

        public GameVersion GetGameVersion(Client.Game game)
        {
            return !VersionList.ContainsKey(game) ? null : VersionList[game];
        }
    }
}