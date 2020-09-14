using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GameStatusController : ControllerBase
    {
        [HttpGet]
        public IEnumerable<GameStatus> Get()
        {
            Resources.IncrementRequests();

            return Resources.GameStatusManager.StatusList.Values;
        }
    }
}