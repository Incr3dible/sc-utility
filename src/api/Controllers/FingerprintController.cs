using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SupercellUilityApi.Database;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FingerprintController : ControllerBase
    {
        [HttpGet]
        public async Task<Fingerprint> Get(string gameName, string sha)
        {
            Resources.IncrementRequests();

            return await FingerprintDatabase.GetFingerprintBySha(gameName, sha);
        }
    }
}