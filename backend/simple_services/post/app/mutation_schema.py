import strawberry
from post_scalar import PostInput, Post, PostUpdate
import crud

@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_post(self, post: PostInput) -> Post:
        db_post = crud.create_post(post)
        return db_post
    
    @strawberry.mutation
    def update_post(self, post_id: int, post: PostUpdate) -> Post:
        db_post = crud.get_post_by_post_id(post_id)
        if db_post is None:
            raise Exception("Post not found")
        return crud.update_post(db_post, post)