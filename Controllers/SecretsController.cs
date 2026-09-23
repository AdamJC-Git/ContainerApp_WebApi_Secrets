using ContainerApp_WebApi_Secrets.BusinessLogic.Settings;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace ContainerApp_WebApi_Secrets.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SecretsController(IOptions<AppSettings> settings) : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            return "Test Get Succeeded 1 - v3";
        }
        [HttpGet("test")]
        public string TestGet()
        {
            return "Test Succeeded";
        }
        [HttpGet("dbconnectionstring")]
        public string GetDbConnectionString()
        {
            return settings.Value.DefaultDBConnectionString;
        }
        [HttpGet("apikey")]
        public string GetApiKey()
        {
            return settings.Value.FCApiKey;
        }
        [HttpGet("secret1")]
        public string GetSecret()
        {
            return settings.Value.Secret1;
        }
        [HttpGet("get-hotter-ftpsettings")]
        public string GetFtpSettings()
        {
            return ($"FTP Host: {settings.Value.HotterSftpHost}, {Environment.NewLine}FTP Username: {settings.Value.HotterSftpUsername}, {Environment.NewLine}FTP Password: {settings.Value.HotterSftpPassword}");
        }
        [HttpGet("create-file")]
        public IResult CreateFile()
        {
            const string mountPath = "/mnt/adam-private";
            var folder = Path.Combine(mountPath, "ftp-files");
            Directory.CreateDirectory(folder);   // no-op if it already exists

            var fileName = $"dummy-{DateTime.UtcNow:yyyyMMdd-HHmmss}.txt";
            var filePath = Path.Combine(folder, fileName);

            System.IO.File.WriteAllText(filePath,
                $"Hello from {Environment.MachineName} at {DateTime.UtcNow:O}");

            return Results.Ok(new
            {
                written = filePath,
                filesInFolder = Directory.GetFiles(folder).Select(Path.GetFileName)
            });
        }
    }
}
