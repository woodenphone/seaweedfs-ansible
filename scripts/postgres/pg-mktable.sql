/* pg-mktable.sql
 * Create table for postgres filer
 */

/* Remove whatever was in the way */
DROP TABLE "filemeta";

/* Create a fresh table */
CREATE TABLE IF NOT EXISTS "filemeta" (
  dirhash   BIGINT,
  name      VARCHAR(65535),
  directory VARCHAR(65535),
  meta      bytea,
  PRIMARY KEY (dirhash, name)
);

/* Add a note about what the table is */
COMMENT ON TABLE "filemeta" IS 'Seaweedfs filer metadata store';

/* Let account seaweedfs do whatever on filemeta: */
GRANT ALL ON "filemeta" TO "seaweedfs";