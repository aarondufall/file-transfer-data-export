-- ----------------------------
--  Table structure for files
-- ----------------------------
CREATE TABLE "public"."files" (
  "file_id" UUID NOT NULL,
  "name" varchar(255),
  "key" varchar(255),
  "bucket" varchar(255),
  "region" varchar(255),
  "version" int4 NOT NULL
)
WITH (OIDS=FALSE);

-- ----------------------------
--  Primary key structure for table messages
-- ----------------------------
ALTER TABLE "public"."files" ADD PRIMARY KEY ("file_id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- create table files(file_id uuid, name text, key text, bucket text, region text, version integer, primary key(file_id));                                                                 
