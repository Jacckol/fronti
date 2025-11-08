const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const passport = require('passport');
const routes = require('./routes/index');
const { sequelize } = require('./models'); // Sequelize

require('dotenv').config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(morgan('dev'));

// Passport JWT
app.use(passport.initialize());
require('./config/passport')(passport);

// Rutas
app.use(routes);

// Sincronizar modelos con la DB
sequelize.sync({ alter: true })
  .then(() => console.log('✅ Tablas sincronizadas'))
  .catch(err => console.error('❌ Error sincronizando tablas:', err));

// Conectar PostgreSQL
sequelize.authenticate()
  .then(() => console.log('✅ Conectado correctamente a PostgreSQL'))
  .catch(err => console.error('❌ Error al conectar a PostgreSQL:', err));

// Puerto
const PORT = process.env.PORT || 57100;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
});
