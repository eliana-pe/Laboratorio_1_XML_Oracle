-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 9.6: Verificacion final de inserciones XML
-- Objetivo: comprobar que solo se almaceno
-- el documento XML que cumple el esquema XSD

SELECT
    ID,
    XMLISVALID(
        DOCUMENTO,
        'http://unir.local/esquema_empleados.xsd',
        'ReporteEmpleados'
    ) AS CUMPLE_XSD
FROM HR_XML_VALIDACION
WHERE ID IN (1, 2)
ORDER BY ID;