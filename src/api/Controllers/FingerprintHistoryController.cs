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
            Resources.IncrementRequests();

            return Resources.FingerprintCache.GetCachedFingerprintLogs(gameName);
        }
    }
}