const express = require('express');
const router = express.Router();
const action = require('../methods/actions');

// 🔹 Importar rutas de usuario (por ejemplo, registro o gestión de usuarios)
const userRoutes = require('./user.routes');
router.use('/api', userRoutes); // Rutas: /api/register, /api/login, etc.

// 🔹 Importar rutas de empleador
const empleadorRoutes = require('./empleador.routes');
router.use('/api/empleadores', empleadorRoutes); // Rutas de empleador: GET, POST, DELETE

// 🔹 Rutas de prueba
router.get('/', (req, res) => res.send('THIS IS HOME'));
router.get('/dashboard', (req, res) => res.send('THIS IS DASHBOARD'));

// ===========================================================
// 🔹 Métodos de acción para usuarios y autenticación
// ===========================================================

// Registro de usuario
router.post('/api/register', action.addNew);

// Login de usuario
router.post('/api/login', action.authenticate);

// Obtener información de usuario autenticado
router.get('/api/getinfo', action.getinfo);

// ===========================================================
// 🔹 Métodos para publicaciones (posts)
// ===========================================================

// Crear nuevo post
router.post('/api/addpost', action.addPost);

// Obtener todos los posts
router.get('/api/getallpost', action.getAllPost);

// Obtener post por ID
router.get('/api/getpostbyid/:id', action.getPostbyId);

// Obtener posts por autor
router.get('/api/getpostbyauthorid/:id', action.getPostbyAuthorId);

// Buscar posts por título
router.get('/api/searchpost/:title', action.searchPost);

// Actualizar un post
router.put('/api/updatepost/:id', action.updatePost);

// Eliminar un post
router.delete('/api/deletepost/:id', action.deletePost);

// ===========================================================
// 🔹 Exportar router
// ===========================================================
module.exports = router;
