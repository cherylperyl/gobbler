from fastapi.testclient import TestClient
from unittest.mock import patch, Mock
from .schemas import Reservation
from sqlalchemy.ext.declarative import declarative_base
import os

@patch.dict(os.environ, {"DB_SERVER": "localhost", "DB_PORT": "3306", "DB_USER": "user", "DB_PASSWORD": "password", "DATABASE": "mydatabase"})
@patch('app.models.Base')
def setup_mock_app(mock_base):
    from .main import app
    client = TestClient(app)
    return client

client = setup_mock_app()

@patch('app.crud.get_all')
def test_get_all_reservations(mock_get_all):
    mock_get_all.return_value = [
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


@patch('app.crud.get_reservation_by_reservation_id')
def test_get_reservation_by_reservation_id(mock_get_reservation_by_reservation_id):
    mock_get_reservation_by_reservation_id.return_value = {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }
    response = client.get('reservations/2')
    
    assert response.status_code == 200
    assert response.json() == {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }
    
@patch('app.crud.get_reservations_by_post_id')
def test_get_reservations_by_post_id(mock_get_reservations_by_post_id):
    mock_get_reservations_by_post_id.return_value = [{
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }]
    response = client.get('reservations/post/2')
    
    assert response.status_code == 200
    assert response.json() == [{
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }]
    
@patch('app.crud.get_reservations_by_user_id')
def test_get_reservations_by_user_id(mock_get_reservations_by_user_id):
    mock_get_reservations_by_user_id.return_value = [{
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }]
    response = client.get('reservations/user/1')
    
    assert response.status_code == 200
    assert response.json() == [{
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }]
    
@patch('app.crud.get_reservation_count_by_post_id')
def test_get_reservation_count_by_post_id(mock_get_reservation_count_by_post_id):
    mock_get_reservation_count_by_post_id.return_value = 2
    response = client.get('reservations/post/slots/1')
    
    assert response.status_code == 200
    assert response.json() == 2

@patch('app.crud.get_reservation_by_user_id_and_post_id')
def test_get_reservation_by_user_id_and_post_id(mock_get_reservation_by_user_id_and_post_id):
    mock_get_reservation_by_user_id_and_post_id.return_value = {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }

    response = client.get('/reservations/user/1/post/2')
    
    assert response.status_code == 200
    assert response.json() == {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }
    mock_get_reservation_by_user_id_and_post_id.return_value = None
    response = client.get('/reservations/user/1/post/2')
    assert response.status_code == 404
    
@patch('app.crud.create_reservation')
def test_create_reservation(mock_create_reservation):
    mock_create_reservation.return_value = {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }

    response = client.post(
        '/reservations',
        json={"user_id": 1, "post_id": 2}
    )
    
    assert response.status_code == 200
    assert response.json() == {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }
    
@patch('app.crud.get_reservation_by_reservation_id')
@patch('app.crud.update_reservation')
def test_update_reservation(mock_update_reservation, mock_get_reservation_by_reservation_id):
    mock_get_reservation_by_reservation_id.return_value = {
        "user_id":1,
        "post_id":2,
        "reservation_id":2,
    }
    mock_update_reservation.return_value = {
            "user_id":2,
            "post_id":1,
            "reservation_id":2,
        }

    response = client.put(
        '/reservations/2',
        json={"user_id": 2, "post_id": 1}
    )
    
    assert response.status_code == 200
    assert response.json() == {
            "user_id":2,
            "post_id":1,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }
    mock_get_reservation_by_reservation_id.return_value = None
    response = client.put(
        '/reservations/2',
        json={"user_id": 2, "post_id": 1}
    )
    assert response.status_code == 404
    
@patch('app.crud.get_reservation_by_reservation_id')
@patch('app.crud.delete_reservation')
def test_delete_reservation(mock_delete_reservation, mock_get_reservation_by_reservation_id):
    mock_get_reservation_by_reservation_id.return_value = {
        "user_id":1,
        "post_id":2,
        "reservation_id":2,
    }
    mock_delete_reservation.return_value = {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
        }

    response = client.delete('/reservations/2')
    
    assert response.status_code == 200
    assert response.json() == {
            "user_id":1,
            "post_id":2,
            "reservation_id":2,
            "created_at": None,
            "updated_at": None
        }
    
    mock_get_reservation_by_reservation_id.return_value = None
    response = client.delete('/reservations/2')
    assert response.status_code == 404



