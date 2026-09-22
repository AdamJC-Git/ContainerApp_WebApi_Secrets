using ContainerApp_WebApi_Secrets.BusinessLogic.Settings;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
//var _configuration = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();

//builder.Services.Configure<AppSettings>(_configuration.GetSection("AppSettings"));
builder.Services.Configure<AppSettings>(builder.Configuration.GetSection("AppSettings"));

builder.Services.AddControllers();

var app = builder.Build();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
