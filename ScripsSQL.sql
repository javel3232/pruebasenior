create database pruebAda;

use pruebAda;

CREATE TABLE company (
  id_company BIGINT  NOT NULL,
  codigo_company VARCHAR(50)  NOT NULL,
  name_company VARCHAR(150) NOT NULL,
  description_company VARCHAR(255),
  CONSTRAINT pk_company PRIMARY KEY (id_company),
  CONSTRAINT uk_company_code UNIQUE (codigo_company)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE application (
  app_id  BIGINT NOT NULL,
  app_code VARCHAR(50) NOT NULL,
  app_name VARCHAR(150) NOT NULL,
  app_description  VARCHAR(255),
  CONSTRAINT pk_application PRIMARY KEY (app_id),
  CONSTRAINT uk_application_code UNIQUE (app_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE version (
  version_id BIGINT NOT NULL,
  app_id BIGINT NOT NULL,
  version VARCHAR(50) NOT NULL,
  version_description VARCHAR(255),
  CONSTRAINT pk_version PRIMARY KEY (version_id),
  CONSTRAINT fk_version_app FOREIGN KEY (app_id)
      REFERENCES application(app_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uk_version_app UNIQUE (app_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE version_company (
  version_company_id   BIGINT NOT NULL,
  company_id BIGINT NOT NULL,
  version_id BIGINT NOT NULL,
  version_company_description VARCHAR(255),
  CONSTRAINT pk_version_company PRIMARY KEY (version_company_id),
  CONSTRAINT fk_vc_company  FOREIGN KEY (company_id)
      REFERENCES company(id_company)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_vc_version  FOREIGN KEY (version_id)
      REFERENCES version(version_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uk_vc_company UNIQUE (company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS TMP_LLENAR_CAMPOS (
  -- COMPANY
  id_company BIGINT,
  codigo_company VARCHAR(50),
  name_company  VARCHAR(150),
  description_company VARCHAR(255),

  -- VERSION (depende de APPLICATION)
  version_id BIGINT,
  app_id BIGINT,
  `version` VARCHAR(50),
  version_description VARCHAR(255),

  -- VERSION_COMPANY
  version_company_id BIGINT,
  company_id BIGINT,
  version_company_description VARCHAR(255),

  -- APPLICATION
  app_code VARCHAR(50),
  app_name VARCHAR(150),
  app_description VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DELIMITER $$

DROP PROCEDURE IF EXISTS sp_cargar_desde_tmp $$
CREATE PROCEDURE sp_cargar_desde_tmp()
BEGIN
   
    DECLARE v_id_company  BIGINT;
    DECLARE v_codigo_company   VARCHAR(50);
    DECLARE v_name_company  VARCHAR(150);
    DECLARE v_description_company  VARCHAR(255);

    DECLARE v_version_id  BIGINT;
    DECLARE v_app_id   BIGINT;
    DECLARE v_version  VARCHAR(50);
    DECLARE v_version_description VARCHAR(255);

    DECLARE v_version_company_id  BIGINT;
    DECLARE v_company_id_fk BIGINT;
    DECLARE v_version_company_desc VARCHAR(255);

    DECLARE v_app_code VARCHAR(50);
    DECLARE v_app_name VARCHAR(150);
    DECLARE v_app_description VARCHAR(255);

    DECLARE done INT DEFAULT 0;

    DECLARE CTemporal CURSOR FOR
        SELECT
            id_company,
            codigo_company,
            name_company,
            description_company,
            version_id,
            app_id,
            `version`,
            version_description,
            version_company_id,
            company_id,
            version_company_description,
            app_code,
            app_name,
            app_description
        FROM TMP_LLENAR_CAMPOS;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;

    OPEN CTemporal;
    read_loop: LOOP
        FETCH CTemporal INTO
            v_id_company,
            v_codigo_company,
            v_name_company,
            v_description_company,
            v_version_id,
            v_app_id,
            v_version,
            v_version_description,
            v_version_company_id,
            v_company_id_fk,
            v_version_company_desc,
            v_app_code,
            v_app_name,
            v_app_description;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO application (app_id, app_code, app_name, app_description)
        VALUES (v_app_id, v_app_code, v_app_name, v_app_description)
        ON DUPLICATE KEY UPDATE
            app_code  = VALUES(app_code),
            app_name = VALUES(app_name),
            app_description= VALUES(app_description);

        INSERT INTO `version` (version_id, app_id, `version`, version_description)
        VALUES (v_version_id, v_app_id, v_version, v_version_description)
        ON DUPLICATE KEY UPDATE
            app_id  = VALUES(app_id),
            `version`  = VALUES(`version`),
            version_description = VALUES(version_description);

        INSERT INTO company (id_company, codigo_company, name_company, description_company)
        VALUES (v_id_company, v_codigo_company, v_name_company, v_description_company)
        ON DUPLICATE KEY UPDATE
            codigo_company  = VALUES(codigo_company),
            name_company  = VALUES(name_company),
            description_company = VALUES(description_company);

        INSERT INTO version_company (version_company_id, company_id, version_id, version_company_description)
        VALUES (v_version_company_id, v_company_id_fk, v_version_id, v_version_company_desc)
        ON DUPLICATE KEY UPDATE
            version_id   = VALUES(version_id),
            version_company_description = VALUES(version_company_description);

    END LOOP;

    CLOSE CTemporal;
    COMMIT;
END $$
DELIMITER ;


INSERT INTO TMP_LLENAR_CAMPOS (
  id_company, codigo_company, name_company, description_company,
  version_id, app_id, `version`, version_description,
  version_company_id, company_id, version_company_description,
  app_code, app_name, app_description
) VALUES
(1, 'C001', 'Compañía Uno', 'Descripción de Compañía Uno',
  10, 100, '1.0.0', 'Versión inicial',
  1000, 1, 'Versión compañía inicial',
  'APP001', 'Aplicación Uno', 'Descripción de la app uno'),

(2, 'C002', 'Compañía Dos', 'Descripción de Compañía Dos',
  20, 200, '2.0.0', 'Segunda versión',
  2000, 2, 'Versión compañía dos',
  'APP002', 'Aplicación Dos', 'Descripción de la app dos');



CALL sp_cargar_desde_tmp();

