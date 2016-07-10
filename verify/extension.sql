-- Verify extension

BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'uuid-ossp';

SELECT has_function_privilege('standoffuser', 'uuid_generate_v1()', 'EXECUTE');
SELECT has_function_privilege('standoffeditor', 'uuid_generate_v1()', 'EXECUTE');
SELECT has_function_privilege('standoffadmin', 'uuid_generate_v1()', 'EXECUTE');

ROLLBACK;
