# RDS Postgres Migration

## Short description

After you create an Amazon RDS DB instance, you can't modify the allocated storage size of the DB instance to decrease the total storage space it uses. To decrease the storage size of your DB instance, you must create a new DB instance that has less provisioned storage size. Then, migrate your data into the new DB instance. The recommended method is to use the database engine's native dump and restore method. 

### Resolution

This docker container peforms DB dump and restore using pg_dump and pg_restore.

## How to run?
- cp .env.dist .env
- edit .env
- docker-compose run app and follow cli instructions



