namespace user;

public class User
{
    
    // public User() { }

    // public User(string username, string email)
    // {
    //     Username = username;
    //     Email = email;
    // }

    public int UserId { get; set; }
    
    public bool? IsPremium { get; set; }
    
    public string? Username { get; set; }
    
    public DateTime? DateCreated { get; set; }
    
    public DateTime? LastUpdated { get; set; }

    public string? Email { get; set; }
    
    public string? StripeId { get; set; }
    
    public string? SubscriptionId { get; set; }
    
    public string? FcmToken { get; set; }
    
}