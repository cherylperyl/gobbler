import strawberry
from post_scalar import Post
from typing import List
import crud

@strawberry.type
class Query:
    @strawberry.field
    def posts(self) -> List[Post]:
        """
        Get all posts
        """
        posts_data_list = crud.get_all()
        return posts_data_list
    
    @strawberry.field
    def post(self, post_id: strawberry.ID) -> Post:
        """
        Get post by id
        """
        post = crud.get_post_by_post_id(post_id)
        return post
    
    @strawberry.field
    def nearby_posts(self, lat: float, long: float) -> List[Post]:
        """
        Get nearby posts by lat, long
        """
        filtered_posts = crud.get_nearby_posts(lat, long)
        return filtered_posts