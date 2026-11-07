-- Verificar registro del esquema XSD en Oracle

SELECT
    SCHEMA_URL,
    LOCAL
FROM USER_XML_SCHEMAS
WHERE SCHEMA_URL =
    'http://unir.local/esquema_empleados.xsd';
