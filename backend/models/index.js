'use strict';

require('dotenv').config(); // 🔹 Carga variables del .env
const Sequelize = require('sequelize');

// 🔹 Configura Sequelize con variables de entorno
const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    logging: false, // desactiva logs de SQL
  }
);

// 🔹 Comprobación de conexión
sequelize.authenticate()
  .then(() => console.log('✅ Conectado a PostgreSQL correctamente'))
  .catch(err => console.error('❌ Error al conectar con PostgreSQL:', err));

// 🔹 Importar modelos explícitamente
const User = require('./user')(sequelize, Sequelize.DataTypes);
const Empleador = require('./empleador')(sequelize, Sequelize.DataTypes);

// 🔹 Registrar modelos en el objeto db
const db = {
  User,
  Empleador,
  sequelize,
  Sequelize,
};

// 🔹 Ejecutar asociaciones
Object.values(db).forEach(model => {
  if (model.associate) model.associate(db);
});

module.exports = db;
