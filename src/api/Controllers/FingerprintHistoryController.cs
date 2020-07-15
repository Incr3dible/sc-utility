using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupercellUilityApi.Helpers;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FingerprintHistoryController : ControllerBase
    {
        private readonly ILogger<FingerprintHistoryController> _logger;

        public FingerprintHistoryController(ILogger<FingerprintHistoryController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<Fingerprint> Get(string gameName)
        {
            if (gameName == null)
            {
                return null;
            }

            var history = new List<Fingerprint>();

            history.Add(new Fingerprint
            {
                Sha = "78e6afda61f125c90d7c311b9fe26f526388dd59",
                Version = "3.2077.38",
                Timestamp = TimeUtils.CurrentUnixTimestamp
            });

            history.Add(new Fingerprint
            {
                Sha = "t876evt784ontv49ot643n9ot45679tn435o9t498",
                Version = "13.204.22",
                Timestamp = TimeUtils.CurrentUnixTimestamp
            });

            history.Add(new Fingerprint
            {
                Sha = "rurtzi34n4t90834t7j9th7n349t63149t634t984",
                Version = "10.524.10",
                Timestamp = TimeUtils.CurrentUnixTimestamp
            });

            return history;
        }
    }
}