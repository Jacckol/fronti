const express = require('express');
const router = express.Router();
const { Empleador, User } = require('../models');
const bcrypt = require('bcrypt');

// ================================
// 🔹 LISTAR EMPLEADORES
// ================================
router.get('/', async (req, res) => {
  try {
    const empleadores = await Empleador.findAll({
      include: {
        model: User,
        attributes: ['id', 'nombre', 'email', 'rol']
      }
    });
    res.json({ message: 'Lista de empleadores obtenida', empleadores });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener empleadores' });
  }
});

// ================================
// 🔹 REGISTRAR NUEVO EMPLEADOR (User + Empleador)
// ================================
router.post('/', async (req, res) => {
  try {
    const { nombre, email, password, rol, empresa, ruc, telefono } = req.body;

    // Validaciones
    if (!nombre || !email || !password || !rol || !empresa || !ruc || !telefono) {
      return res.status(400).json({ error: 'Todos los campos son requeridos' });
    }

    // Verificar si el email ya existe
    const userExistente = await User.findOne({ where: { email } });
    if (userExistente) {
      return res.status(400).json({ error: 'El correo ya está registrado' });
    }

    // Crear usuario base
    const hashedPassword = await bcrypt.hash(password, 10);
    const nuevoUsuario = await User.create({
      nombre,
      email,
      password: hashedPassword,
      rol: rol || 'empleador'
    });

    // Crear registro de empleador asociado
    const nuevoEmpleador = await Empleador.create({
      empresa,
      ruc,
      telefono,
      userId: nuevoUsuario.id
    });

    res.status(201).json({
      message: 'Empleador registrado correctamente',
      empleador: nuevoEmpleador,
      user: nuevoUsuario
    });
  } catch (error) {
    console.error('❌ Error al registrar empleador:', error);
    res.status(500).json({ error: 'Error al registrar el empleador' });
  }
});

// ================================
// 🔹 ELIMINAR EMPLEADOR
// ================================
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const empleador = await Empleador.findByPk(id);

    if (!empleador) return res.status(404).json({ error: 'Empleador no encontrado' });

    await empleador.destroy();
    res.json({ message: 'Empleador eliminado exitosamente' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al eliminar empleador' });
  }
});

module.exports = router;
