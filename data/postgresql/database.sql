/*
 Navicat PostgreSQL Data Transfer

 Source Server         : t-gw-motma-awe.intra.realstuff.ch
 Source Server Version : 90109
 Source Host           : localhost
 Source Database       : helpdesk
 Source Schema         : public

 Target Server Version : 90109
 File Encoding         : utf-8

 Date: 05/24/2016 12:49:44 PM
*/


-- ----------------------------
--  Drop Tables to have clean database
-- ----------------------------
DROP TABLE IF EXISTS "public"."events";
DROP TABLE IF EXISTS "public"."tickets";

-- ----------------------------
--  Table structure for tickets
-- ----------------------------
CREATE TABLE "public"."tickets" (
	"idtickets" bigserial PRIMARY KEY,
	"ticketnumber" text COLLATE "default",
	"ticketstatus" text COLLATE "default",
	"created" timestamp(6) NOT NULL,
	"modified" timestamp(6) NULL
);
ALTER TABLE "public"."tickets" OWNER TO "helpdesk";

-- ----------------------------
--  Table structure for events
-- ----------------------------
CREATE TABLE "public"."events" (
	"idevents" bigserial PRIMARY KEY,
	"host" text NOT NULL COLLATE "default",
	"service" text COLLATE "default",
	"category" text COLLATE "default",
	"parameters" text COLLATE "default",
	"priority" text COLLATE "default",
	"message" text NOT NULL COLLATE "default",
	"monitoringstatus" text NOT NULL COLLATE "default",
	"created" timestamp(6) NOT NULL,
	"fk_idtickets" int8
);
ALTER TABLE "public"."events" OWNER TO "helpdesk";

-- ----------------------------
--  Indexes structure for table tickets
-- ----------------------------
CREATE UNIQUE INDEX  "tickets_idtickets_key" ON "public"."tickets" USING btree(idtickets "pg_catalog"."int8_ops" ASC NULLS LAST);
CREATE UNIQUE INDEX  "events_idevents_key" ON "public"."events" USING btree(idevents "pg_catalog"."int8_ops" ASC NULLS LAST);
CREATE INDEX  "events_fk_idtickets_key" ON "public"."events" USING btree(fk_idtickets "pg_catalog"."int8_ops" ASC NULLS LAST);

-- ----------------------------
--  Foreign keys structure for table events
-- ----------------------------
ALTER TABLE "public"."events" ADD CONSTRAINT "fk_idtickets" FOREIGN KEY ("fk_idtickets") 
	REFERENCES "public"."tickets" ("idtickets") ON UPDATE NO ACTION ON DELETE NO ACTION NOT DEFERRABLE INITIALLY IMMEDIATE;

