'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      // 🔹 Un usuario puede ser un empleador
      this.hasOne(models.Empleador, {
        foreignKey: 'userId',
        as: 'empleador',
        onDelete: 'CASCADE',
      });
    }
  }

  User.init(
    {
      nombre: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        validate: { isEmail: true },
      },
      password: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      rol: {
        type: DataTypes.ENUM('cliente', 'empleador'),
        allowNull: false,
      },
    },
    {
      sequelize,
      modelName: 'User',
      tableName: 'users', // 🔹 Nombre explícito para evitar pluralización rara
      timestamps: true,   // 🔹 Crea columnas createdAt / updatedAt
    }
  );

  return User;
};
