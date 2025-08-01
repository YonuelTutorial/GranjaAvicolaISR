-- ==============================================
-- - GRANJA AVÍCOLA
-- ==============================================
CREATE DATABASE IF NOT EXISTS GranjaAvicola;
USE GranjaAvicola;

-- Tabla usuario
CREATE TABLE IF NOT EXISTS usuario (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  nombre_completo VARCHAR(100) NULL,
  email VARCHAR(150) NULL,
  activo TINYINT(1) DEFAULT 1,
  creado_fecha DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de unidades de medida
CREATE TABLE IF NOT EXISTS unidad (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  simbolo VARCHAR(10) NOT NULL UNIQUE,
  descripcion TEXT NULL
) ENGINE=InnoDB;

-- Tabla estado_notif
CREATE TABLE IF NOT EXISTS estado_notif (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE,
  descripcion TEXT NULL
) ENGINE=InnoDB;

-- Tabla tipoave
CREATE TABLE IF NOT EXISTS tipoave (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  codigo VARCHAR(10) UNIQUE,
  activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;


-- Tabla etapadesarrollo
CREATE TABLE IF NOT EXISTS etapadesarrollo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  codigo VARCHAR(10) UNIQUE,
  dia_desde INT,
  dia_hasta INT,
  activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

-- Tabla notif_tipo
CREATE TABLE IF NOT EXISTS notif_tipo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT
) ENGINE=InnoDB;


-- Tabla condicionespecial
CREATE TABLE IF NOT EXISTS condicionespecial (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  activo TINYINT(1) DEFAULT 1,
  codigo VARCHAR(10) UNIQUE
) ENGINE=InnoDB;

-- Tabla lote
CREATE TABLE IF NOT EXISTS lote (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(50) NOT NULL UNIQUE,
  tipo_ave_id INT NOT NULL,
  fecha_ingreso DATE NOT NULL,
  cantidad_inicial INT NOT NULL,
  activo TINYINT(1) DEFAULT 1,
  observaciones TEXT,
  FOREIGN KEY (tipo_ave_id) REFERENCES tipoave(id)
) ENGINE=InnoDB;



CREATE TABLE IF NOT EXISTS material (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  peso_kg INT DEFAULT 1,
  unidad_id INT NULL,
  activo TINYINT(1) DEFAULT 1,
  creado_por INT NULL,
  creado_fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  modificado_por INT NULL,
  modificado_fecha DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_material_nombre (nombre),
  FOREIGN KEY (unidad_id) REFERENCES unidad(id),
  FOREIGN KEY (creado_por) REFERENCES usuario(id),
  FOREIGN KEY (modificado_por) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- Tabla de nutrientes
CREATE TABLE IF NOT EXISTS nutriente (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  unidad_id INT NOT NULL,
  descripcion TEXT NULL,
  FOREIGN KEY (unidad_id) REFERENCES unidad(id)
) ENGINE=InnoDB;
-- Actualización de tabla material con peso


-- Asociación de nutrientes con materiales
CREATE TABLE IF NOT EXISTS material_nutriente (
  id INT AUTO_INCREMENT PRIMARY KEY,
  material_id INT NOT NULL,
  nutriente_id INT NOT NULL,
  valor INT NOT NULL,
  UNIQUE KEY uq_material_nutriente (material_id, nutriente_id),
  FOREIGN KEY (material_id) REFERENCES material(id),
  FOREIGN KEY (nutriente_id) REFERENCES nutriente(id)
) ENGINE=InnoDB;

-- Historial de nutrientes por material
CREATE TABLE IF NOT EXISTS material_nutriente_hist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  material_id INT NOT NULL,
  nutriente_id INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE DEFAULT NULL,
  valor INT NOT NULL,
  observaciones TEXT NULL,
  creado_por INT NULL,
  creado_fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_matnutri_hist (material_id, nutriente_id, fecha_inicio),
  FOREIGN KEY (material_id) REFERENCES material(id),
  FOREIGN KEY (nutriente_id) REFERENCES nutriente(id),
  FOREIGN KEY (creado_por) REFERENCES usuario(id)
) ENGINE=InnoDB;


-- Parámetros nutricionales por tipo de ave y etapa de desarrollo
CREATE TABLE IF NOT EXISTS paramnutricional_objetivo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipo_ave_id INT NOT NULL,
  etapa_id INT NOT NULL,
  nutriente_id INT NOT NULL,
  valor_min INT DEFAULT NULL,
  valor_max INT DEFAULT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE DEFAULT NULL,
  observaciones TEXT NULL,
  creado_por INT NULL,
  creado_fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  modificado_por INT NULL,
  modificado_fecha DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_param_nutriente (tipo_ave_id, etapa_id, nutriente_id, fecha_inicio),
  FOREIGN KEY (tipo_ave_id) REFERENCES tipoave(id),
  FOREIGN KEY (etapa_id) REFERENCES etapadesarrollo(id),
  FOREIGN KEY (nutriente_id) REFERENCES nutriente(id),
  FOREIGN KEY (creado_por) REFERENCES usuario(id),
  FOREIGN KEY (modificado_por) REFERENCES usuario(id)
) ENGINE=InnoDB;



-- Tabla formulaalimento
CREATE TABLE IF NOT EXISTS formulaalimento (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipo_ave_id INT NOT NULL,
  etapa_id INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  observaciones TEXT,
  FOREIGN KEY (tipo_ave_id) REFERENCES tipoave(id),
  FOREIGN KEY (etapa_id) REFERENCES etapadesarrollo(id)
) ENGINE=InnoDB;

-- Tabla detalleformula
CREATE TABLE IF NOT EXISTS detalleformula (
  id INT AUTO_INCREMENT PRIMARY KEY,
  formula_id INT NOT NULL,
  material_id INT NOT NULL,
  porcentaje INT NOT NULL,
  UNIQUE KEY uq_detalle_formula (formula_id, material_id),
  FOREIGN KEY (formula_id) REFERENCES formulaalimento(id) ON DELETE CASCADE,
  FOREIGN KEY (material_id) REFERENCES material(id)
) ENGINE=InnoDB;

-- Tabla formulacondicion
CREATE TABLE IF NOT EXISTS formulacondicion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  formula_base_id INT NOT NULL,
  condicion_id INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  observaciones TEXT,
  FOREIGN KEY (formula_base_id) REFERENCES formulaalimento(id),
  FOREIGN KEY (condicion_id) REFERENCES condicionespecial(id)
) ENGINE=InnoDB;

-- Tabla detalleformulacondicion
CREATE TABLE IF NOT EXISTS detalleformulacondicion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  formula_cond_id INT NOT NULL,
  material_id INT NOT NULL,
  porcentaje DECIMAL(5,2) NOT NULL,
  UNIQUE KEY uq_detalle_formulacond (formula_cond_id, material_id),
  FOREIGN KEY (formula_cond_id) REFERENCES formulacondicion(id) ON DELETE CASCADE,
  FOREIGN KEY (material_id) REFERENCES material(id)
) ENGINE=InnoDB;

-- Tabla lote_formula
CREATE TABLE IF NOT EXISTS lote_formula (
  id INT AUTO_INCREMENT PRIMARY KEY,
  lote_id INT NOT NULL,
  formulaalimento_id INT,
  formulacondicion_id INT,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  observaciones TEXT,
  UNIQUE KEY uq_lote_formula_inicio (lote_id, fecha_inicio),
  FOREIGN KEY (lote_id) REFERENCES lote(id),
  FOREIGN KEY (formulaalimento_id) REFERENCES formulaalimento(id),
  FOREIGN KEY (formulacondicion_id) REFERENCES formulacondicion(id)
) ENGINE=InnoDB;


-- Tabla notif_suscripcion
CREATE TABLE IF NOT EXISTS notif_suscripcion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  notif_tipo_id INT NOT NULL,
  canal VARCHAR(10) NOT NULL,
  activo TINYINT(1) DEFAULT 1,
  UNIQUE KEY uq_notif_sub (usuario_id, notif_tipo_id, canal),
  FOREIGN KEY (usuario_id) REFERENCES usuario(id),
  FOREIGN KEY (notif_tipo_id) REFERENCES notif_tipo(id)
) ENGINE=InnoDB;

-- Tabla notif_queue actualizada con estado normalizado
CREATE TABLE IF NOT EXISTS notif_queue (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  notif_tipo_id INT NOT NULL,
  ref_tabla VARCHAR(50),
  ref_id INT,
  mensaje TEXT NOT NULL,
  fecha_generada DATETIME DEFAULT CURRENT_TIMESTAMP,
  fecha_enviada DATETIME DEFAULT NULL,
  estado_id INT NOT NULL,
  FOREIGN KEY (notif_tipo_id) REFERENCES notif_tipo(id),
  FOREIGN KEY (estado_id) REFERENCES estado_notif(id)
) ENGINE=InnoDB;

-- Tabla audit_log
CREATE TABLE IF NOT EXISTS audit_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tabla VARCHAR(64) NOT NULL,
  pk_valor VARCHAR(64) NOT NULL,
  accion VARCHAR(10) NOT NULL,
  usuario_id INT,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  detalle JSON,
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- Tabla riesgo
CREATE TABLE IF NOT EXISTS riesgo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  categoria VARCHAR(30) NOT NULL,
  descripcion TEXT NOT NULL,
  severidad VARCHAR(10) NOT NULL,
  probabilidad VARCHAR(10) NOT NULL,
  impacto_estimado DECIMAL(12,2),
  ref_tabla VARCHAR(50),
  ref_id INT,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  creado_por INT,
  FOREIGN KEY (creado_por) REFERENCES usuario(id)
) ENGINE=InnoDB;
