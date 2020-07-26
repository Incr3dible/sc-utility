using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupercellUilityApi.Core;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class EventController : ControllerBase
    {
        private readonly ILogger<EventController> _logger;

        public EventController(ILogger<EventController> logger)
        {
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] EventImageUrl value)
        {
            if (!Constants.EventGames.Contains(value.GameName)) return BadRequest();

            var exists = await value.EventExists();

            if (exists)
            {
                // TODO: SAVE TO DB
                return Ok();
            }

            return NotFound();
        }
    }
}