# Gobbler

Reducing food waste one buffet at a time

1. [API Docs](https://docs.google.com/document/d/1p9xU6xDQlhA96rWvjR7AQRDs3OLuAAEXLBefcChBxCc/edit#)
2. [Project report](https://docs.google.com/document/d/1_VMYmIKxV-ouKZ3y6g-upth47BED7S6Sr370QjmmAiU/edit#)
3. [Project slides](https://docs.google.com/presentation/d/1PHVv5L6tf0aZxGBe03qdmbyn4Hcb2RM2lkL6T6ADREI/edit#slide=id.g228ed7c04e1_0_135)

# Table of Contents

1. [Project Overview](#project-overview)
2. [Technical Overview Diagram](#technical-overview-diagram)
3. [Frameworks and Databases Utilised](#frameworks-and-databases-utilised)
4. [Getting Started](#getting-started)
5. [Contributors](#contributors)

# Project Overview

<p align="center">
  <img src="readme_files\gobbler.png" width=200px>
</p>
Food wastage is a severe problem in Singapore, and the amount of food waste has grown by 20% in the past 10 years. Current solutions include informal “buffet clearer” Telegram groups, which are not scalable and susceptible to spam. As such, we have created “Gobbler”, a centralized platform for users to post leftover food, and for other users to reserve a slot to take the leftover food. This will help to reduce the food wastage problem from the ground up.

# Technical Overview Diagram

<html>
<p align="center">
<img src="readme_files\technical_overview.png" style="border-radius:10px">
</p>
</html>

# Frameworks and Databases Utilised
<p align="center"><strong>Services and UI</strong></p>
<p align="center">
<a href="https://fastapi.tiangolo.com/"><img src="https://fastapi.tiangolo.com/img/logo-margin/logo-teal.png" alt="FastAPI" width="88"/></a>&nbsp;&nbsp;<a href="https://graphql.org/"><img src="https://graphql.org/img/brand/logos/logo-wordmark.svg" alt="GraphQL Logo" width="88"></a>&nbsp;&nbsp;<a href="https://flutter.dev/"><img src="https://storage.googleapis.com/cms-storage-bucket/6a07d8a62f4308d2b854.svg" alt="Flutter" width="88"/></a>&nbsp;&nbsp;<a href="https://learn.microsoft.com/en-us/dotnet/core/introduction"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/.NET_Core_Logo.svg/2048px-.NET_Core_Logo.svg.png" alt=".Net Core" height="40"/></a>&nbsp;&nbsp;<a href="https://spring.io/"><img src="https://4.bp.blogspot.com/-ou-a_Aa1t7A/W6IhNc3Q0gI/AAAAAAAAD6Y/pwh44arKiuM_NBqB1H7Pz4-7QhUxAgZkACLcBGAs/s1600/spring-boot-logo.png" alt="SpringBoot" height="40"/></a>&nbsp;&nbsp;<a href="https://strawberry.rocks/"><img src="https://warehouse-camo.ingress.cmh1.psfhosted.org/ef5bddae9a8a975d7be7a05765bc6f2665ac7a1a/68747470733a2f2f6769746875622e636f6d2f737472617762657272792d6772617068716c2f737472617762657272792f7261772f6d61696e2f2e6769746875622f6c6f676f2e706e67" alt="Strawberry" height="40"/></a>&nbsp;&nbsp;<a href="https://www.typescriptlang.org/"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Typescript_logo_2020.svg/1200px-Typescript_logo_2020.svg.png" alt="Typescript" height="40"/></a>&nbsp;&nbsp;<a href="https://koajs.com/"><img src="https://embed-ssl.wistia.com/deliveries/3d6bf592e5cff413c9d60258434142ad.jpg" alt="Koa" height="40"/></a>&nbsp;&nbsp;
</p>
<br>
<p align="center"><strong>API Gateway</strong></p>
<p align="center">
<a href="https://konghq.com/"><img src="https://konghq.com/wp-content/uploads/2018/08/thumbnail-logo-color-full.svg" alt="Kong API Gateway" width="88"/></a>
<br>
<i>CORS · Rate Limit Plugin · Custom Authentication Plugin</i>
</p>
<br>

<p align="center"><strong>Databases</strong></p>
<p align="center">
<a href="https://www.mysql.com/"><img src="https://d1.awsstatic.com/asset-repository/products/amazon-rds/1024px-MySQL.ff87215b43fd7292af172e2a5d9b844217262571.png" alt="MySQL" height="40"/></a>&nbsp;&nbsp;<a href="https://firebase.google.com/"><img src="https://www.gstatic.com/devrel-devsite/prod/vc7c98be6f4d139e237c3cdaad6a00bb295b070a83e505cb2fa4435daae3d0901/firebase/images/lockup.svg" alt="Firebase" width="88"/></a>&nbsp;&nbsp;<a href="https://www.postgresql.org/" ><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Postgresql_elephant.svg/1200px-Postgresql_elephant.svg.png" alt="PostgreSQL" height="40"/>&nbsp;PostgreSQL</a>&nbsp;&nbsp;<a href="https://cloud.google.com/"><img src="https://www.gstatic.com/devrel-devsite/prod/vc7c98be6f4d139e237c3cdaad6a00bb295b070a83e505cb2fa4435daae3d0901/cloud/images/cloud-logo.svg" alt="PostgreSQL" width="88"/></a>&nbsp;&nbsp;<a href="https://redis.com/"><img src="https://redis.com/wp-content/themes/wpx/assets/images/logo-redis.svg?auto=webp&quality=85,75&width=120" alt="Redis" width="88"/></a> 
</p>
<br>

<p align="center"><strong>AMQP</strong></p>
<p align="center">
<a href="https://www.rabbitmq.com/"><img src="https://logo-download.com/wp-content/data/images/png/RabbitMQ-logo.png" alt="RabbitMQ" width="88"/></a>
</p>
<br>

<p align="center"><strong>Others</strong></p>
<p align="center">
<a href="https://stripe.com/en-gb-sg"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Stripe_Logo%2C_revised_2016.svg/1280px-Stripe_Logo%2C_revised_2016.svg.png" alt="Stripe Payment API" width="88"/></a>&nbsp;&nbsp;<a href="https://kubernetes.io/"><img src="https://gcloud.devoteam.com/wp-content/uploads/sites/32/2021/10/kubernetes-logo-1-1.svg" alt="Kubernetes" height="44"/></a>&nbsp;&nbsp;<a href="https://www.docker.com/"><img src="https://www.docker.com/wp-content/uploads/2022/03/horizontal-logo-monochromatic-white.png" alt="Docker" width="88"/></a>
<br>
<i>Firebase Cloud Messaging · Docker Compose · GCP Google Kubernetes Engine · GCP Artifact Registry</i>
</p>
<br>

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
        <td align="center"><img src="readme_files\chuenkai.jpg" width="150px"/><br /><sub><b>Ong Chuen Kai</b></sub></a></td>
        <td align="center"><img src="readme_files\jonathan.jpg" width="150px"/><br /><sub><b>Jonathan Tan</b></sub></a></td>
        <td align="center"><img src="readme_files\thaddeus.jpg" width="150px"/><br /><sub><b>Thaddeus Lee</b></sub></a></td>
    </tr>
</table>
