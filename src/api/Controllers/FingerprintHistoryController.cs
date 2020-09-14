using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FingerprintHistoryController : ControllerBase
    {
        [HttpGet]
        public IEnumerable<FingerprintLog> Get(string gameName)
        {
            if (gameName == null) return null;

            Resources.IncrementRequests();

            var history = Resources.FingerprintCache.GetCachedFingerprintLogs(gameName);
            return history;
        }
    }
}