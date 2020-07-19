using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApiStatusController : ControllerBase
    {
        private readonly ILogger<ApiStatusController> _logger;

        public ApiStatusController(ILogger<ApiStatusController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public ApiStatus Get()
        {
            return new ApiStatus
            {
                TotalApiRequests = Resources.TotalRequests
            };
        }
    }
}