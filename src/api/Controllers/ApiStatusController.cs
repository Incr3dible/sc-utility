using System;
using Microsoft.AspNetCore.Mvc;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApiStatusController : ControllerBase
    {
        [HttpGet]
        public ApiStatus Get()
        {
            return new ApiStatus
            {
                TotalApiRequests = Resources.TotalRequests,
                UptimeSeconds = (long) DateTime.UtcNow.Subtract(Resources.StartTime).TotalSeconds,
                Maintenance = Resources.Configuration.Maintenance
            };
        }
    }
}