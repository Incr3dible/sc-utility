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
        public IEnumerable<FingerprintLog> Get(string gameName)
        {
            if (gameName == null)
            {
                return null;
            }

            Resources.IncrementRequests();

            var history = new List<FingerprintLog>();

            history.Add(new FingerprintLog
            {
                Sha = "78e6afda61f125c90d7c311b9fe26f526388dd59",
                Version = "3.2077.38",
                Timestamp = TimeUtils.CurrentUnixTimestamp
            });

            history.Add(new FingerprintLog
            {
                Sha = "t876evt784ontv49ot643n9ot45679tn435o9t498",
                Version = "13.204.22",
                Timestamp = TimeUtils.CurrentUnixTimestamp
            });

            history.Add(new FingerprintLog
            {
                Sha = "this is just a test",
                Version = "10.524.10",
                Timestamp = TimeUtils.CurrentUnixTimestamp
            });

            return history;
        }
    }
}