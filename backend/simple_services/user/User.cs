namespace user;

public class User
{
    public int UserId { get; set; }
    
    public bool IsPremium { get; set; }
    
    public string Username { get; set; }
    
    public DateTime DateCreated { get; set; }
    
    public DateTime LastUpdated { get; set; }

    public string Email { get; set; }
    
}