using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
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

        [HttpGet("{gameName}")]
        public IEnumerable<FingerprintLog> Get(string gameName)
        {
            if (gameName == null) return null;

            Resources.IncrementRequests();

            var history = Resources.FingerprintCache.GetCachedFingerprintLogs(gameName);
            return history;
        }
    }
}