using Microsoft.EntityFrameworkCore;

namespace user.Data;

public class DataContext : DbContext
{
    public DataContext() { }
    public DataContext(DbContextOptions<DataContext> options) : base(options) { }
    
    // Creates database tables
    public virtual DbSet<User> Users { get; set; }
}