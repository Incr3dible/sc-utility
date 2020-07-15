using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupercellUilityApi.Helpers;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GameStatusController : ControllerBase
    {
        private readonly ILogger<GameStatusController> _logger;

        public GameStatusController(ILogger<GameStatusController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<GameStatus> Get()
        {
            var games = new List<GameStatus>();

            games.Add(new GameStatus
            {
                GameName = "Clash Royale",
                Status = 0,
                LatestFingerprintSha = "78e6afda61f125c90d7c311b9fe26f526388dd59",
                LatestFingerprintVersion = "3.2077.38",
                LastUpdated = TimeUtils.CurrentUnixTimestamp
            });

            games.Add(new GameStatus
            {
                GameName = "Clash of Clans",
                Status = 1,
                LatestFingerprintSha = "t876evt784ontv49ot643n9ot45679tn435o9t498",
                LatestFingerprintVersion = "13.204.22",
                LastUpdated = TimeUtils.CurrentUnixTimestamp
            });

            games.Add(new GameStatus
            {
                GameName = "Brawl Stars",
                Status = 2,
                LatestFingerprintSha = "rurtzi34n4t90834t7j9th7n349t63149t634t984",
                LatestFingerprintVersion = "10.524.10",
                LastUpdated = TimeUtils.CurrentUnixTimestamp
            });

            return games;
        }
    }
}