JVM_IMAGE_NAME="eclipse-temurin:21-jdk-alpine"

docker run --rm \
      -v .:/test_code \
      "$JVM_IMAGE_NAME" \
      sh -c "cd /test_code && javac Main.java"
