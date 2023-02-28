from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from os import environ

# SQLALCHEMY_DATABASE_URL = "sqlite:///./payment_ms.db"
SQLALCHEMY_DATABASE_URL = environ.get("dbURL")

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
