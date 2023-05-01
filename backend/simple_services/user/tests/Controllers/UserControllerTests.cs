// namespace tests.Controllers.UserControllerTests;

// using System.Collections.Generic;
// using System.Linq;
// using Moq;
// using Microsoft.VisualStudio.TestTools.UnitTesting;
// using user;
// using Microsoft.EntityFrameworkCore;
// using user.Data;
// using user.Controllers;

// [TestClass]
// public class UserControllerTests
// {
//     [TestMethod]
//     public void GetAllBlogs_orders_by_name()
//     {
//         var data = new List<User>
//         {
//             new User { UserId = 1, IsPremium = false, Username = "User1", Email = "User1@gmail.com", StripeId = "stripe", SubscriptionId = "123", FcmToken = "123" },
//             new User { UserId = 2, IsPremium = false, Username = "User2", Email = "User2@gmail.com", StripeId = "stripe2", SubscriptionId = "124", FcmToken = "124" },
//             new User { UserId = 3, IsPremium = true, Username = "User3", Email = "User3@gmail.com", StripeId = "stripe3", SubscriptionId = "125", FcmToken = "125" },
//         }.AsQueryable();

//         var mockSet = new Mock<DbSet<User>>();
//         mockSet.As<IQueryable<User>>().Setup(m => m.Provider).Returns(data.Provider);
//         mockSet.As<IQueryable<User>>().Setup(m => m.Expression).Returns(data.Expression);
//         mockSet.As<IQueryable<User>>().Setup(m => m.ElementType).Returns(data.ElementType);
//         mockSet.As<IQueryable<User>>().Setup(m => m.GetEnumerator()).Returns(() => data.GetEnumerator());

//         var mockContext = new Mock<DataContext>();
//         mockContext.Setup(c => c.Users).Returns(mockSet.Object);

//         var controller = new UserController(mockContext.Object);
//         var users = controller.Get();
//         Assert.IsInstanceOfType<List<User>>(users);

//         // Assert.AreEqual(3, users.Count);
//         // Assert.AreEqual("AAA", users[0].Name);
//         // Assert.AreEqual("BBB", users[1].Name);
//         // Assert.AreEqual("ZZZ", users[2].Name);
//     }
// }


