rootProject.name = "monarch"

// Java services
File(rootDir, "services/java").listFiles()?.filter { it.isDirectory }?.forEach { dir ->
    include(":services:java:${dir.name}")
    project(":services:java:${dir.name}").projectDir = dir
}

// Shared Java libraries
include(":libs:common-java")
project(":libs:common-java").projectDir = file("libs/common-java")

include(":libs:db-migrations")
project(":libs:db-migrations").projectDir = file("libs/db-migrations")
