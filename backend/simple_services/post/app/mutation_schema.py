import strawberry
from app.post_scalar import PostInput, Post, PostUpdate
from app.gcloud_bucket import upload_to_posts_bucket
import app.crud as crud
import json

@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_post(self, post: PostInput) -> Post:
        image_url = upload_to_posts_bucket(post.file_name, post.image_file.file)
        post.image_url = image_url
        del post.image_file
        del post.file_name

        db_post = crud.create_post(post)
        return db_post

    @strawberry.mutation
    def update_post(self, post_id: int, post: PostUpdate) -> Post:
        db_post = crud.get_post_by_post_id(post_id)
        if db_post is None:
            raise Exception("Post not found")
        if post.image_file is not None:
            image_url = upload_to_posts_bucket(post.file_name, post.image_file.file)
            post.image_url = image_url
            del post.image_file
            del post.file_name
        return crud.update_post(db_post, post)

    @strawberry.mutation
    def delete_post(self, post_id: int) -> Post:
        db_post = crud.get_post_by_post_id(post_id)
        if db_post is None:
            raise Exception("Post not found")
        return crud.delete_post(db_post)
