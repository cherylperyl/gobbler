# Gobbler

Reducing food waste one buffet at a time

1. [API Docs](https://docs.google.com/document/d/1p9xU6xDQlhA96rWvjR7AQRDs3OLuAAEXLBefcChBxCc/edit)
2. [Project report](https://docs.google.com/document/d/1_VMYmIKxV-ouKZ3y6g-upth47BED7S6Sr370QjmmAiU/edit)
3. [Project slides](https://docs.google.com/presentation/d/1-TyOVTGNd1wzkaCL0MiyIqw7BWRxx_4Z8tZ8LAhiL3E/edit#slide=id.g1f43977f471_2_179)

# Table of Contents

1. [Project Overview](#project-overview)
2. [Technical Overview Diagram](#technical-overview-diagram)
3. [Frameworks and Databases Utilised](#frameworks-and-databases-utilised)
4. [Getting Started](#getting-started)
5. [Contributors](#contributors)

# Project Overview

<img src="readme_files\gobbler.png">
Food wastage is a severe problem in Singapore, and the amount of food waste has grown by 20% in the past 10 years. Current solutions include informal “buffet clearer” Telegram groups, which are not scalable and susceptible to spam. As such, we have created “Gobbler”, a centralized platform for users to post leftover food, and for other users to reserve a slot to take the leftover food. This will help to reduce the food wastage problem from the ground up.

# Technical Overview Diagram

<img src="readme_files\technical_overview.png">

# Frameworks and Databases Utilised

**Services and UI**

- Client (Mobile)
  - Flutter
- Server (Backend)
  - Python
    - FastAPI
    - GraphQL (strawberry)
  - Java
    - Spring Boot
  - EF Core
  - Typescript
    - Koa
  - Lua

**API Gateway**

- Kong API Gateway
  - CORS
  - Rate Limit Plugin
  - Custom Authentication Plugin

**Database**

- MySQL
- postgreSQL
- Google Cloud Storage
- Redis

**AMQP**

- RabbitMQ Messaging

**Others**

- External Services
  - Stripe Payment API
  - Firebase Cloud Messaging
- Containerization
  - Docker
  - Docker Compose
  - Kubernetes
- Google Cloud Platform
  - Google Kubernetes Engine
  - Artifact Registry

# Getting Started

### Set-up local directories

Clone this repository or download the files to a local directory.
Open a terminal session and navigate to the path of this repository/codebase.

> e.g. if working path is `/usr/lib/gobbler`

```bash
cd /usr/lib/gobbler
```

### Set-up Mobile Application

Our mobile application can be run in an emulator environment or on test phones (iOS/Android).
Refer to [mobile](mobile/README.md) for more details.

### Set-up Backend Services

Our backend services are deployed at http://gobbler.world.
Refer to [backend](backend/README.md) for more details.

# Contributors

**G3 Team 7**

<table>
    <tr>
        <td align="center"><img src="readme_files\cheryl.jpeg" width="150px"/><br /><sub><b>Cheryl Goh</b></sub></a></td>
        <td align="center"><img src="readme_files\esther.jpg" width="150px"/><br /><sub><b>Esther Lam</b></sub></a></td>
        <td align="center"><img src="readme_files\esther.jpg" width="150px"/><br /><sub><b>Ong Chuen Kai</b></sub></a></td>
        <td align="center"><img src="readme_files\jonathan.jpg" width="150px"/><br /><sub><b>Jonathan Tan</b></sub></a></td>
        <td align="center"><img src="readme_files\thaddeus.jpg" width="150px" height="200px"/><br /><sub><b>Thaddeus Lee</b></sub></a></td>
    </tr>
</table>
