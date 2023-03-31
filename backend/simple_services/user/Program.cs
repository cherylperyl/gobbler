using System.Text;
using Microsoft.EntityFrameworkCore;
using user.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

var config = new StringBuilder("User Id=POSTGRES_USERNAME;Password=POSTGRES_PASSWORD;Server=DATABASE_SERVER;Port=DATABASE_PORT;Database=users;IntegratedSecurity=true;Pooling=true;");
string conn = config
    .Replace("POSTGRES_USERNAME", builder.Configuration["POSTGRES_USERNAME"])
    .Replace("POSTGRES_PASSWORD", builder.Configuration["POSTGRES_PASSWORD"])
    .Replace("DATABASE_SERVER", builder.Configuration["DATABASE_SERVER"])
    .Replace("DATABASE_PORT", builder.Configuration["DATABASE_PORT"])
    .Replace("DATABASE_NAME", builder.Configuration["DATABASE_NAME"])
    .ToString();

builder.Services.AddDbContext<DataContext>(options =>
    options.UseNpgsql(conn)
);
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(options =>
{
    options.EnableAnnotations();
});

builder.Services.AddCors(p => p.AddPolicy("corspolicy", build =>
{
    build.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
}));

var app = builder.Build();

await using var scope = app.Services.CreateAsyncScope();
await using var db = scope.ServiceProvider.GetService<DataContext>();
await db.Database.MigrateAsync();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || app.Environment.IsProduction())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();