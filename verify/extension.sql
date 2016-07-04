-- Verify extension

BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'uuid-ossp';

SELECT has_function_privilege('arbuser', 'uuid_generate_v1()', 'EXECUTE');
SELECT has_function_privilege('arbeditor', 'uuid_generate_v1()', 'EXECUTE');
SELECT has_function_privilege('arbadmin', 'uuid_generate_v1()', 'EXECUTE');

ROLLBACK;
