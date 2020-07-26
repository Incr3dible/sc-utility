using System;
using System.Linq;
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
        public IActionResult Post([FromBody] EventImageUrl value)
        {
            if (!Constants.EventGames.Contains(value.GameName))
            {
                return BadRequest();
            }

            Console.WriteLine(value.GameName);
            Console.WriteLine(value.ImageUrl);

            return Ok();
        }
    }
}