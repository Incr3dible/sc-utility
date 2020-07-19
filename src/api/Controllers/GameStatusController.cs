using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
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
            Resources.IncrementRequests();

            return Resources.GameStatusManager.StatusList.Values;
        }
    }
}