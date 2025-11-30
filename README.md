# BlogApp CRUD Rest API Express + Flutter (flutter_frontend)

RESTFUL API usando Express (Node.js) como backend y Flutter como frontend.  
Autenticación con JWT para login de usuarios.

## Funcionalidades principales

- Registro y login de usuarios.
- CRUD de posts (crear, leer, actualizar, eliminar).
- Consumo de API desde Flutter (frontend).
- Backend con Node/Express.
- Base de datos (originalmente MongoDB, ahora adaptado a otro backend en tu caso).

## Screenshots originales

- HTTP REQUEST  
  <img src="/images/http_request.JPG" width="300"> 

- Pantallas de Login / Registro  
  <p float="left">
    <img src="/images/1.png" width="300">  
    <img src="/images/2.png" width="300">
  </p>

- Pantalla Home / CRUD  
  <p float="left">
    <img src="/images/3.png" width="300">  
    <img src="/images/4.png" width="300">  
    <img src="/images/4.png" width="300">
  </p>

## flutter_frontend

Dentro de la carpeta `flutter_frontend` tienes el proyecto Flutter que estás usando como app móvil  
(roles, login, fotos, etc.).

### Cómo correr el frontend

```bash
cd flutter_frontend
flutter pub get
flutter run
