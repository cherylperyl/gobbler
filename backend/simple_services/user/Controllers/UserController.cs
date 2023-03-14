using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Swashbuckle.AspNetCore.Annotations;
using user.Data;

namespace user.Controllers

{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {

        private readonly DataContext _context;

        // constructor
        public UserController(DataContext context)
        {
            _context = context;
        }
        
        
        [HttpGet]
        [SwaggerOperation(Summary = "Get all users")]
        public async Task<ActionResult<List<User>>> Get()
        {
            return Ok(await _context.Users.ToListAsync());
        }
        
        
        [HttpPost]
        [SwaggerOperation(Summary = "Add new user. (No need pass user_id as it is auto-incremented in DB)")]
        public async Task<ActionResult<List<User>>> AddUser(User user)
        {
            var user_db = await _context.Users
                .FirstOrDefaultAsync(u=>u.Email == user.Email);
            if (user_db == null)
            {
                await _context.Users.AddAsync(user);
                await _context.SaveChangesAsync();
                return Ok(user);
            }
                
            return BadRequest("User with email " + user.Email.ToString() + " already exists in database.");
        }
        
        
        [HttpGet("{user_id}")]
        [SwaggerOperation(Summary = "Get user by user_id")]
        public async Task<ActionResult<User>> Get(int user_id)
        {
            var user = await _context.Users.FindAsync(user_id);
            if (user == null)
                return BadRequest("User with user_id " + user_id.ToString() + " not found.");
            return Ok(user);
        }
        
        
        [HttpPut]
        [SwaggerOperation(Summary = "Update user details by user_id")]
        public async Task<ActionResult<List<User>>> UpdateUser(User request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
                return BadRequest("User with user_id " + request.UserId.ToString() + " not found.");
            
            user.IsPremium = request.IsPremium;
            user.Username = request.Username;
            user.DateCreated = request.DateCreated;
            user.LastUpdated = request.LastUpdated;
            user.Email = request.Email;
            
            await _context.SaveChangesAsync();
            
            return Ok(await _context.Users.ToListAsync());
        }
        
        
        [HttpDelete("{user_id}")]
        [SwaggerOperation(Summary = "Delete a user by user id")]
        public async Task<ActionResult<List<User>>> DeleteUser(int user_id) 
        {
            var user = await _context.Users.FindAsync(user_id);
            if (user == null)
                return BadRequest("User with user_id " + user_id.ToString() + " not found.");
            
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            
            return Ok(await _context.Users.ToListAsync());
        }
        
        
        [HttpGet("by_email/{email}")]
        [SwaggerOperation(Summary = "Get user by email")]
        public async Task<ActionResult<User>> Get(string email)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u=>u.Email == email);
            if (user == null)
                return BadRequest("User with email " + email + " not found.");
            return Ok(user);
        }
    }
}
