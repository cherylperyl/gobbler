import strawberry
from app.post_scalar import Post, PostNearby
from typing import List
from . import crud

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
    def nearby_posts(self, lat: float, long: float) -> List[PostNearby]:
        """
        Get nearby posts by lat, long
        """
        filtered_posts = crud.get_nearby_posts(lat, long)
        return filtered_posts
    
    @strawberry.field
    def posts_by_user(self, user_id: int) -> List[Post]:
        """
        get posts created by a user
        """
        filtered_posts = crud.get_posts_by_user(user_id)
        return filtered_posts
    
    @strawberry.field
    def posts_from_ids(self, post_ids: List[int]) -> List[Post]:
        """
        get a list of posts from their ids
        """
        filtered_posts = crud.get_posts_by_ids(post_ids)
        return filtered_posts
    