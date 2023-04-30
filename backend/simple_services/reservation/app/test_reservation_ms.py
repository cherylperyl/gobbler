from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from .main import app
from . import crud
from .schemas import Reservation

client = TestClient(app)

@patch('app.crud.get_all')
def test_user(mocked_func1):
    mocked_func1.return_value = [
        {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }
    ]
    response = client.get('reservations/all')
    assert response.status_code == 200
    assert response.json() == [
        {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }
    ]