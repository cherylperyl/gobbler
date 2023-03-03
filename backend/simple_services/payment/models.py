from sqlalchemy import Column, Integer, String
# from sqlalchemy.orm import relationship
from db import Base


class User(Base):
    
    __tablename__ = "user"

    user_id = Column(Integer, primary_key=True, index=True)
    stripe_user_id = Column(String)
    subscription = Column(String)